# TF-Rehancer V5 Architecture Detail Note

Date: 2026-06-13 KST  
Purpose: thesis/paper method writing support  
Base compact note: `project_analysis/implementation_notes/2026-06-13_tf_rehancer_v5_architecture_tensor_flow.md`

## 1. Scope

이 문서는 `TF-Rehancer V5 baseline`의 실제 code path를 기준으로 architecture를 detail하게 정리한다.

대상 config:

```text
TF_Restormer-7B28/models/TF_Rehancer_v5/configs/
  v5_baseline_efn_adaptiveavgpool_lnrestore_fecompressed_conscompressed_tmax500_nohighpe_stft640_hop320_inputmag_tf3_bs16_vbd16_500ep.yaml
```

V5의 architecture는 `V4 EFN AdaptiveAvgPool LNRestore`와 동일하다. V5의 본질적 변경은 loss:

```text
V4: FE spectral terms 일부가 linear STFT scale로 들어간 bug 존재
V5: FastEnhancer-style gamma-compressed mag/complex/consistency loss로 수정
```

따라서 논문 architecture 설명은 `V5` 기준으로 쓰되, topology 자체는 V4 best structure에서 온 것으로 보면 된다.

## 2. Notation

| Symbol | Meaning |
|---|---|
| `B` | batch size |
| `F` | full STFT frequency bins |
| `T` | STFT frame count |
| `C_e` | encoder/shared channel, V5에서는 `48` |
| `C_d` | decoder channel, V5에서는 `24` |
| `F_low` | embedded low-band token count, V5 16 kHz에서는 `101` |
| `F_high` | embedded high-band token count, V5 16 kHz에서는 `60` |
| `F_emb` | embedded full-band token count after F-stride stem, `F_low + F_high = 161` |
| `Z` | low-band encoder representation |
| `Q_h` | high-band observed query |
| `W` | complex TF filter |

16 kHz V5 active setting:

```text
STFT: 640 / 320 samples = 40 ms / 20 ms
Full F: 321
Low cutoff bin before stem: 201
F-stride: 2
Embedded F: 161
Embedded low cutoff: 101
Embedded high tokens: 60
```

48 kHz로 같은 SFI-STFT 40/20 ms를 쓰면:

```text
STFT: 1920 / 960 samples
Full F: 961
5 kHz cutoff bin: 201
Embedded low cutoff: 101
Embedded high tokens: 380
```

즉 16 kHz와 48 kHz 모두 low-band encoder token 수는 5 kHz 기준으로 같고, 48 kHz에서는 high-band decoder query token만 크게 늘어난다. 이것이 TF-Rehancer의 compute scaling 논리에서 중요하다.

## 3. Full Forward Flow

High-level flow:

```text
noisy waveform
-> STFT
-> complex STFT real/imag
-> input normalization
-> power-law compressed condition
-> [compressed real, compressed imag, compressed magnitude]
-> shared F-stride pre-conv
-> embedded low/high split
-> low-band encoder
-> high-band refinement adapter
-> concat encoder Z + high query
-> decoder query projection
-> decoder F-MHCA/F-MHSA + Time FastGRU2
-> frequency upsample
-> complex TF filter estimation
-> complex TF filtering on linear noisy STFT
-> inverse normalization
-> iSTFT
-> corrected FastEnhancer composite loss
```

Important: model predicts a complex filter, not direct clean spectrogram mapping.

```text
Condition feature uses PLC.
Final filtering target is linear noisy STFT.
No inverse PLC exists in model output path.
```

## 4. Input Processing

### 4.1 STFT Input

Engine converts waveform to complex STFT and model receives:

```text
x: [B, F, T, 2]
```

The last dimension is:

```text
x[..., 0] = real
x[..., 1] = imag
```

V5 model first normalizes the complex STFT:

```text
x_norm, x_scale = norm(x)
x_linear_norm = x_norm
```

`x_linear_norm` is preserved as final filtering reference.

### 4.2 Power-Law Compression Condition

V5 uses power-law compressed complex STFT only as conditioning feature:

$$
X_\text{plc} = |X|^{\gamma - 1} X,\quad \gamma = 0.3
$$

In real/imag tensor form:

```text
x_condition = power_law_ri(x_linear_norm, gamma=0.3)
```

This keeps phase direction and compresses magnitude dynamic range.

### 4.3 Input Feature Channel

V5 uses `real_imag_mag`:

```text
x_feature = [Re(X_plc), Im(X_plc), |X_plc|]
shape: [B, F, T, 3]
```

Design intent:

- real/imag keeps complex phase-aware observation
- compressed magnitude gives direct speech/noise energy cue
- PLC reduces extreme scale before neural filter estimation
- linear reference still preserved for output filtering

## 5. Shared F-Stride Pre-Conv

V5 uses one shared pre-conv before low/high split:

```text
FastPreConvInputEmbedding
Conv2d(3 -> 48, kernel=(4,1), stride=(2,1), padding=(2,0))
-> BatchNorm2d
-> SiLU
```

Tensor:

```text
[B, F=321, T, 3]
-> permute to [B, 3, F, T]
-> Conv2d / BN / SiLU
-> [B, 48, F_emb=161, T]
-> permute back
-> [B, 161, T, 48]
```

Why shared pre-conv:

- old low/high separate embedding duplicated early convolution
- shared stem reduces redundant compute
- F-stride halves frequency tokens before expensive TF blocks
- stem still sees fullband input before split, so high-band local pattern is not discarded before first projection

Why `kernel=(4,1), stride=(2,1)`:

- compression only along frequency axis
- time resolution untouched
- each embedded frequency token can observe small local F context
- no temporal lookahead from pre-conv because time kernel is `1`

Current caveat:

- F-stride is information-compressing.
- V5 later restores full F by transposed convolution before filter estimation.
- Filter quality depends on whether compressed embedded tokens retain enough F-local information.

## 6. Low/High Split

After shared stem:

```text
x_shared: [B, 161, T, 48]
```

Split:

```text
x_low_shared  = x_shared[:, :101]     # [B, 101, T, 48]
x_high_shared = x_shared[:, 101:]     # [B, 60, T, 48]
```

Interpretation:

- `x_low_shared` goes into heavy low-band encoder.
- `x_high_shared` bypasses encoder and becomes observed high-band query after local refinement.

This is the core TF-Rehancer asymmetry:

```text
low band: analyzed by encoder
high band: preserved as observed query and refined by decoder
```

## 7. Low-Band Encoder

### 7.1 Encoder Input / Output

Input:

```text
x_enc_in = x_low_shared
shape: [B, 101, T, 48]
```

Output:

```text
Z = Encoder(x_enc_in)
shape: [B, 101, T, 48]
```

V5 does not add pre-encoder sinusoidal frequency PE:

```text
pre_encoder_freq_pe: false
```

Reason:

- F-axis RoPE is already applied inside frequency attention modules.
- Avoid duplicating positional encoding.

### 7.2 Encoder Stack

Encoder has `4` stacked blocks:

```text
for block in encoder_blocks[1..4]:
  x = FreqModule(x)
  x = TimeModule(x)
final LayerNorm(48)
```

This is stack, not weight repeat. Each block has its own parameters.

## 8. Encoder Freq Module

The encoder Freq module operates across frequency tokens at each time frame.

Input:

```text
x: [B, F_low, T, C_e]
```

Reshape:

```text
x -> [B*T, F_low, C_e]
```

Block:

```text
EFN
-> F-MHSA with RoPE
-> EFN
```

Output reshape:

```text
[B*T, F_low, C_e] -> [B, F_low, T, C_e]
```

### 8.1 No F-Proj

V5 sets:

```text
Ekv_encoder = None
```

Therefore F-MHSA does not use Linformer frequency projection. Attention sees all low-band embedded frequency tokens.

Design implication:

- avoids frequency information bottleneck from F-Proj
- matches SE task where frequency bins have fixed physical meaning
- cost remains controlled because encoder only sees low-band tokens (`101`), not full 48 kHz F tokens

### 8.2 Freq RoPE

V5 uses RoPE in encoder F-MHSA:

```text
freq_rope_encoder: true
```

RoPE is applied to Q/K before scaled dot-product attention. In F-axis attention, this gives relative position sensitivity over frequency-token order without introducing a learned high-band PE.

## 9. Encoder Time Module: FastGRU2

The encoder Time module operates along time frames independently for each frequency token.

Input:

```text
x: [B, F_low, T, C_e]
```

Reshape:

```text
x -> [B*F_low, T, C_e]
```

V5 Time module:

```text
FastGRUResidualBlock x2
```

One `FastGRUResidualBlock`:

```text
residual = x
y = LayerNorm(x)
y, h = unidirectional GRU(y)
y = transpose to [B*F, C, T]
y = Conv1d(C -> C, kernel=1, bias=False)
y = BatchNorm1d(C)
y = transpose back to [B*F, T, C]
out = residual + y
```

Full FastGRU2:

```text
x1 = FastGRUResidualBlock_1(x)
x2 = FastGRUResidualBlock_2(x1)
```

Design intent:

- replace temporal self-attention with recurrent temporal modeling
- keep temporal causality at block level because GRU is unidirectional
- preserve residual stream scale through post-BN correction branch
- reduce temporal attention quadratic cost

Important current status:

```text
model.online=false in active V5 config
```

So training/eval currently calls normal full-sequence `forward`. The code has `forward_stream` for FastGRU2 state passing, but online path must be explicitly configured/tested when making online inference claims.

## 10. High-Band Query Processing

High-band embedded observation:

```text
x_high_shared: [B, 60, T, 48]
```

V5 applies a local high-band adapter:

```text
Conv2d(48 -> 48, kernel=3x3, padding=1)
-> SiLU
-> LayerNorm(48)
-> residual add
```

Tensor path:

```text
h = Conv2d(x_high_shared)
h = SiLU(h)
h = LayerNorm(h)
Q_h = x_high_shared + h
```

V5 config:

```text
high_adapter:
  mode: conv2d_ln_silu
  kernel_size: [3, 3]
  residual: true
high_freq_pe: false
```

Meaning:

- high-band tokens are not encoded by heavy encoder
- high-band query is still locally processed before decoder
- residual preserves observed noisy high-band cue
- no learned high-frequency PE is added

This is where the "observed high-band refinement" idea enters most directly.

## 11. Decoder Query Construction

Decoder input is formed by frequency-axis concatenation:

```text
concat_input = concat(Z, Q_h, dim=F)
shape: [B, 101 + 60, T, 48] = [B, 161, T, 48]
```

Then channel projection:

```text
Linear(48 -> 24)
-> LayerNorm(24)
```

Output:

```text
X_dec_in: [B, 161, T, 24]
```

Why projection:

- encoder operates at wider channel `48`
- decoder operates at lighter channel `24`
- after concatenation, low-band encoder representation and high-band query must share one decoder channel space

## 12. Decoder Stack

Decoder has `2` stacked blocks:

```text
for block in decoder_blocks[1..2]:
  x = FreqModule(x, kv=Z)
  x = TimeModule(x)
final LayerNorm(24)
```

Input/output:

```text
[B, 161, T, 24] -> [B, 161, T, 24]
```

Decoder keeps all embedded low+high frequency tokens. The encoder output `Z` is separately supplied as `K/V` for cross-attention.

## 13. Decoder Freq Module

Decoder Freq module:

```text
MHCA
-> F-MHSA
-> EFN
```

Input reshape:

```text
x:  [B, F_dec=161, T, C_d=24]
kv: [B, F_low=101, T, C_e=48]

x  -> [B*T, 161, 24]
kv -> [B*T, 101, 48]
```

### 13.1 Cross Attention: Low Encoder Conditions High Query

Decoder cross-attention is implemented by `LinMHCA`.

Important code behavior:

```text
len_seq = kv.shape[1] = 101
orig = x[:, :101]
pad  = x[:, 101:]

only pad/high tokens are updated by MHCA
low tokens are passed through unchanged
```

Form:

```text
Q = LN(high decoder tokens)
K,V = encoder Z
high_updated = high + Attention(Q_high, K_low, V_low)
decoder_tokens = concat(low_orig, high_updated)
```

Why this matters:

- low-band decoder tokens already correspond to encoder output region
- high-band observed query asks low-band encoder representation for speech-structure guidance
- this realizes low-to-high conditioning without encoding full high-band by heavy encoder

RoPE offset:

```text
q_offset = len_seq
k_offset = 0
```

Reason:

- query high tokens occupy absolute frequency positions after low-band region
- key/value low tokens start at low-band offset 0
- offset preserves relative/absolute frequency ordering in RoPE cross-attention

### 13.2 Decoder F-MHSA

After MHCA, decoder applies F-axis self-attention over all embedded frequency tokens:

```text
F-MHSA over 161 tokens
```

This lets low/high decoder tokens interact after high-band cross conditioning.

V5 uses:

```text
freq_rope_decoder_self: true
Ekv_fmhsa = None
```

So there is no F-Proj in decoder self-attention.

### 13.3 Decoder EFN

After F-MHSA, decoder uses one EFN:

```text
EFN over F-axis sequence
```

This provides local-convolutional gated mixing after attention.

## 14. Efficient Conv FFN

V5 uses `EfficientConvFFN` in frequency modules.

Input:

```text
x: [N, L, C]
```

where `L` is frequency sequence length:

- encoder F module: `L=101`
- decoder F module: `L=161`

Operation:

```text
residual = x
y = LayerNorm(x)
y = permute to [N, C, L]
y = adaptive_avg_pool1d(y, output_size=ceil(L/2))
y_value = grouped Conv1d(C -> H, kernel=3, groups=2)
y_gate  = grouped Conv1d(C -> H, kernel=3, groups=2)
y = SiLU(y_value) * y_gate
y = Conv1d(H -> C, kernel=1, groups=1)
y = nearest interpolate to original L
y = permute back to [N, L, C]
out = residual + 0.5 * y
```

Config:

```text
encoder EFN: C=48, H=144, groups=2, output groups=1
decoder EFN: C=24, H=72, groups=2, output groups=1
sequence_downsample=2
downsample_mode=adaptive_avgpool
upsample_mode=nearest
```

Why EFN exists:

- original ConvFFN over all frequency tokens was costly
- EFN computes gated conv branch on downsampled sequence
- output is upsampled and added back to full-resolution residual stream
- residual path keeps token-level representation alive
- `out_groups=1` restores cross-group channel mixing at output projection

Relation to SepReFormer / TF-CorrNet:

- inspired by sequence down/up processing around bottleneck sequence
- V5 uses downsampled correction branch, not full replacement
- this keeps a full-resolution residual path through every EFN

## 15. Frequency Upsample Before Filter Head

Decoder output still has embedded frequency length:

```text
X_dec_out: [B, 161, T, 24]
```

Filter must be estimated at full STFT resolution:

```text
F=321
```

V5 uses `FastFilterUpsample`:

```text
1x1 Conv2d(24 -> 24)
-> norm none
-> activation none
-> ConvTranspose2d(24 -> 24, kernel=(4,1), stride=(2,1), padding=(2,0), output_padding=(1,0))
-> crop/pad to target F
```

Tensor:

```text
[B, 161, T, 24]
-> [B, 24, 161, T]
-> 1x1 Conv2d
-> ConvTranspose2d along F
-> [B, 24, 321, T]
-> [B, 321, T, 24]
```

Design intent:

- decoder can run at compressed F tokens
- filter estimation still returns full-resolution TF filter
- no low-resolution filter is directly applied to full-resolution STFT

## 16. Complex TF Filter Head

### 16.1 Raw Filter Estimation

V5 filter head:

```text
filter_head: pconv
filter_axis: time_freq
taps_frame: [1, 1]
taps_freq: [1, 1]
mag_activation: softplus
complex_activation: tanh
```

The name `pconv` here means local `Conv2d` head over decoder features:

```text
Conv2d(24 -> 27, kernel=3x3, padding=1)
```

Channel count:

```text
27 = 3 * 9
9 = (1 left F + center F + 1 right F)
  * (1 left T + center T + 1 right T)
```

Raw filter tensor:

```text
raw: [B, 9, 3, F, T]
raw[:, :, 0]   = magnitude logit
raw[:, :, 1:3] = real/imag logits
```

### 16.2 Filter Activation

Magnitude:

```text
M = softplus(raw_mag)
```

Complex direction:

```text
R,I = tanh(raw_ri)
```

Final complex filter:

$$
W_{l,t,f} = M_{l,t,f} \left(R_{l,t,f} + j I_{l,t,f}\right)
$$

Implementation tensor:

```text
W: [B, 9, F, T, 2]
```

### 16.3 TF3 Filtering

Because `taps_frame=[1,1]` and `taps_freq=[1,1]`, each output bin uses 3x3 TF neighborhood:

```text
frequency offsets: -1, 0, +1
time offsets:      -1, 0, +1
num taps: 9
```

For each target bin:

$$
\hat{X}_{t,f} = \sum_{\Delta f=-1}^{1} \sum_{\Delta t=-1}^{1}
W_{\Delta f,\Delta t,t,f} \cdot X^\text{noisy}_{t+\Delta t,f+\Delta f}
$$

Boundary handling:

```text
x_ref complex STFT is padded in F/T before neighbor collection
```

Output:

```text
y: [B, F, T, 2]
```

### 16.4 Difference From SR-CorrNet Filter Head

V5 current head:

```text
one Conv2d produces [mag, real, imag] jointly
```

SR-CorrNet paper diagram describes separate branches:

```text
D -> conv -> tanh -> real
D -> conv -> tanh -> imag
D -> conv -> softplus -> magnitude
W = magnitude * (real + j imag)
```

Therefore V5 uses same high-level `M * (a + jb)` formulation, but not necessarily the same branch factorization as SR-CorrNet. This distinction matters when writing method/ablation.

## 17. Output Path

Filter is applied to:

```text
x_ref = x_linear_norm
```

not:

```text
x_condition = PLC(x_linear_norm)
```

After filtering:

```text
y_norm = ComplexFilterHead(h_dec, x_ref)
y = inverse_norm(y_norm, x_scale)
```

Engine then converts complex STFT to waveform by iSTFT.

## 18. Loss Path

V5 active loss:

```text
FastEnhancerCompositeLoss
```

Weights:

| Term | Weight |
|---|---:|
| `mag_mse` | `0.3` |
| `complex_mse` | `0.2` |
| `consistency` | `0.3` |
| `wav_l1` | `0.2` |
| `pesq` | `0.001` |

Compressed complex STFT:

$$
X_c = |X|^{0.3} \exp(j \angle X)
$$

Loss terms:

- `mag_mse`: MSE between `abs(enhanced_spec_compressed)` and `abs(clean_spec_compressed)`
- `complex_mse`: MSE between real/imag of compressed enhanced and clean complex STFT
- `consistency`: iSTFT output waveform is recomputed into STFT, then compressed complex MSE to clean
- `wav_l1`: waveform L1
- `pesq`: `torch_pesq` loss, evaluated at 16 kHz

V5 correction:

```text
mag_mse / complex_mse / consistency all use gamma-compressed complex STFT.
```

This is the main difference from V4 loss behavior.

## 19. Paper-Writing Interpretation

### 19.1 Core Claim-Friendly Description

TF-Rehancer V5 can be described as:

```text
frequency-decoupled fullband SE model
that encodes low-band speech structure
and refines observed high-band noisy spectra
through cross-band decoder attention and complex TF filtering.
```

Do not describe it as:

```text
high-band generation from empty query
```

Reason:

```text
high-band query is directly derived from noisy high-band observation.
```

### 19.2 Why Low-Band Encoder

Low-band contains most speech formant, harmonic, and intelligibility structure. V5 spends heavy encoder capacity only on embedded low-band tokens. This avoids applying full encoder stack to all fullband frequency bins.

### 19.3 Why Observed High Query

High band still contains fricatives, transients, breath/noise cues, and perceptually relevant fine detail. V5 does not discard high band by ERB compression or generate it from a learned extension query. It keeps high-band observation as query and lets decoder refine it using low-band representation.

### 19.4 Why Complex TF Filter

Mapping head directly predicts clean STFT. Filter head instead predicts local complex operator applied to noisy STFT. This biases model toward enhancement/refinement rather than unconstrained generation.

### 19.5 Why F-Stride + Upsample

F-stride reduces token count before expensive TF blocks. Post-decoder upsample restores full STFT frequency resolution before filter estimation. Thus full-resolution output is maintained while internal token sequence is compressed.

## 20. Important Caveats For Paper

### 20.1 Online Status

Current config:

```text
model.online=false
```

Architecture has streaming components:

- `FastGRU2` is unidirectional
- `forward_stream` exists for stem, high adapter, encoder, decoder, upsample, filter head

But active training/evaluation uses full-sequence `forward`. If paper claims online/streaming, include separate verification of `forward_stream` path and define allowed right-context from convolution/filter head.

### 20.2 STFT / MACs

V5 compute depends strongly on STFT setting and high-band token count.

16 kHz active:

```text
F=321, F_emb=161, high tokens=60
```

48 kHz SFI 40/20 ms:

```text
F=961, F_emb=481, high tokens=380
```

Encoder low tokens remain around `101` when cutoff fixed at 5 kHz. Decoder/high path scales with fullband range.

### 20.3 `pconv` Naming

In V5 config, `filter_head: pconv` means local `Conv2d` coefficient head. It is not necessarily identical to SR-CorrNet's paper-level `PConv2D` branch design.

### 20.4 V5 vs V4

V5 architecture same as V4 selected architecture. V5 result should be treated as corrected-loss result, not a new topology ablation.

## 21. Code Evidence Map

| Component | File |
|---|---|
| Main model forward / split / concat / upsample | `TF_Restormer-7B28/models/TF_Rehancer_v5/model.py` |
| `TF_stage`, stem, HBR, upsample classes | `TF_Restormer-7B28/models/TF_Rehancer_v5/model.py` |
| Encoder / Decoder wrapper | `TF_Restormer-7B28/models/TF_Rehancer_v5/modules/module.py` |
| `ComplexFilterHead` | `TF_Restormer-7B28/models/TF_Rehancer_v5/modules/module.py` |
| `LinformerAttention`, `LinMHSA`, `LinMHCA` | `TF_Restormer-7B28/models/TF_Rehancer_v5/modules/network.py` |
| `EfficientConvFFN` | `TF_Restormer-7B28/models/TF_Rehancer_v5/modules/network.py` |
| `FastGRU2TemporalEncoder` | `TF_Restormer-7B28/models/TF_Rehancer_v5/modules/network.py` |
| `FastEnhancerCompositeLoss` | `TF_Restormer-7B28/models/TF_Rehancer_v5/loss.py` |
| Engine loss dispatch / STFT-iSTFT path | `TF_Restormer-7B28/models/TF_Rehancer_v5/engine.py` |

## 22. Figure Draft Suggestion

논문 figure는 아래 4개 block으로 나누면 좋다.

```text
             noisy waveform
                   |
                  STFT
                   |
       +-----------+-----------+
       |                       |
 linear STFT ref        PLC feature [Re,Im,Mag]
       |                       |
       |              shared F-stride stem
       |                       |
       |              low/high embedded split
       |                 |            |
       |             low encoder   high adapter
       |                 |            |
       |                 Z        observed high query
       |                 +-----+------+
       |                       |
       |              decoder projection
       |                       |
       |        decoder: MHCA + F-MHSA + EFN + FastGRU2
       |                       |
       |              F-resolution upsample
       |                       |
       |             complex TF filter head
       |                       |
       +-----------> complex TF filtering
                               |
                              iSTFT
                               |
                         enhanced waveform
```

Recommended labels:

- Low-band analysis encoder
- Observed high-band query
- Cross-band decoder refinement
- Full-resolution complex TF filtering

