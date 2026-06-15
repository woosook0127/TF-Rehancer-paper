# 현재 논문 챕터별 한글 번역본

- 기준: 현재 LaTeX source (`thesis.tex`, `covers/abstract.tex`, `text/chapter1.tex`--`text/conclusion.tex`, `tables/*.tex`)
- 목적: 최종 제출 전 한글로 빠르게 읽고 이상한 논리/표현을 피드백하기 위한 번역본
- 원칙: 수식, metric, dataset, model name, module name은 원문 표기를 최대한 유지했다.

## 제목

**Full-Band Speech Enhancement via Low-Band-Conditioned Refinement**

**저대역 유도 정제를 통한 Full-Band 음성 향상**

## Abstract

본 논문은 direct full-band processing을 위한 time-frequency speech enhancement architecture인 TF-Rehancer를 제안한다. 이 모델은 48 kHz speech의 high-frequency components를 band-limited input에서 생성해야 하는 missing information으로 보지 않고, noisy spectral evidence로 이미 관측되어 있으나 noise에 의해 훼손된 정보로 다룬다. TF-Rehancer는 low-band-guided full-band refinement를 수행한다. 즉, low-band speech structure를 encoding하고, observed upper-band evidence를 decoder path에 보존하며, original noisy STFT에 대한 local complex time-frequency filtering을 통해 enhanced spectrum을 추정한다.

TF-Rehancer는 세 가지 관점에서 평가한다. 첫째, 16 kHz VoiceBank+DEMAND benchmark에서 compact FastGRU-based TF-Rehancer configuration은 0.47M parameters와 1.89G model-side MACs로 PESQ 3.33, DNSMOS SIG 3.41, DNSMOS BAK 4.04, DNSMOS OVL 3.13을 달성한다. Paper-reported FastEnhancer-M reference와 비교했을 때, 이 configuration은 더 낮은 model-side MACs로 PESQ, SI-SDR, DNSMOS P.835에서 더 높은 값을 보고하며, FastEnhancer-M은 SCOREQ와 ESTOI에서 약간 더 강하다.

둘째, VoiceBank+DEMAND 48 kHz test set에서 DNS4-trained online TF-Rehancer configuration은 published PercepNet 및 DeepFilterNet2 references와 비교해 competitive full-reference scores를 얻는다. 셋째, controlled 48 kHz ablations는 complex TF filtering을 direct spectrum mapping으로 대체하면 full-reference, spectral, non-intrusive metrics가 저하됨을 보인다. 또한 decoder cross-attention을 사용하는 것이 제거하는 것보다 대부분의 reported full-reference 및 spectral metrics에서 더 효과적이며, 5 kHz low-band cutoff가 controlled ablation setting에서 balanced operating point를 제공함을 보인다.

## Chapter 1. Introduction

많은 기존 speech enhancement benchmarks와 baselines는 conventional 16 kHz wideband settings를 중심으로 구성되어 있다. 이 setting에서는 48 kHz full-band speech에 포함된 upper-band spectral components가 model input 밖에 있다. 따라서 direct 48 kHz full-band speech enhancement는 다른 operating condition을 가진다. 모델은 noisy full-band signal을 입력으로 받으며, upper-band spectrum은 enhance해야 할 noisy evidence로 제공된다. Full-band enhancement는 prior work에서 탐구되었지만, direct 48 kHz full-band SE에 대한 same-protocol references는 conventional wideband evaluation보다 아직 덜 확립되어 있다.

Speech bandwidth extension과 speech super-resolution은 다른 information condition을 대상으로 한다. 이 task들은 band-limited inputs에서 missing 또는 degraded high-frequency content를 복원하는 것을 목표로 한다. 반면 48 kHz full-band SE는 noisy full-band observation에서 시작한다. 따라서 핵심 문제는 wideband enhancement 이후 upper band를 합성하는 것이 아니라, useful spectral evidence를 보존하면서 full observed spectrum 전체에서 noise를 억제하는 것이다. 이러한 차이는 high-frequency region을 나중에 생성해야 하는 missing component가 아니라 noisy observation의 일부로 다루는 direct full-band enhancement approach를 동기화한다.

PercepNet 및 DeepFilterNet2와 같은 practical full-band systems는 strict computational constraints 아래에서도 full-band enhancement가 가능함을 보였다. PercepNet은 perceptually motivated critical-band features와 comb filtering을 사용하고, DeepFilterNet2는 ERB-domain enhancement와 deep filtering을 결합한다. 이러한 perceptual-band front ends는 efficiency를 위해 bin-level spectral resolution을 희생한다. 이는 learned frequency representation을 사용하면서도 original noisy STFT에 대한 complex filtering을 통해 enhanced spectrum을 추정하는 complementary TF-domain design을 동기화한다.

Full-band frequency tokens 전체에 heavy TF modeling을 직접 적용하는 것은 computationally costly할 수 있다. 특히 sampling rate가 증가하면서 STFT bins 수가 늘어날 때 그렇다. Harmonic 및 formant-related speech-structure evidence는 주로 lower frequencies에 집중되어 있고, upper-frequency bins는 noisy input에서 이미 관측되어 있다. 따라서 natural design은 heavier encoding을 low-band structure에 집중하고, high band를 decoder-side observed-query evidence로 전달하는 것이다.

본 논문에서는 direct full-band speech enhancement를 위한 refinement-oriented time-frequency architecture인 TF-Rehancer를 제안한다. 핵심 아이디어는 low-band-guided full-band refinement이다. TF-Rehancer는 low-band speech structure에 heavier encoding을 집중하고, observed upper-band evidence를 decoder path에 보존하며, original noisy STFT에 대한 complex filtering으로 enhanced spectrum을 추정한다. 이 설계는 model이 cross-band speech structure를 활용하면서도 final estimation을 observed noisy signal에 묶어 둔다.

Attention 관점에서 low-band encoder output은 decoder representation의 high-band portion에 대한 key/value context를 제공한다. Cross-attention은 observed high-band decoder tokens를 update하고, 이후 full-sequence decoder modules가 joint low- and high-band representation을 model한다. 따라서 TF-Rehancer는 low-band information만으로 high-band speech를 생성하지 않는다. Low-band context를 사용해 observed high-band features의 update를 condition한다.

**Figure 1.1. TF-Rehancer conceptual overview.** Low-band encoder output은 observed high-band decoder tokens를 update하기 위한 key/value context를 제공한다. Updated representation은 full-sequence decoder modules에 의해 처리되고, original noisy STFT에 대한 local complex filters를 추정하는 데 사용된다.

TF-Rehancer는 세 가지 setting에서 평가한다. 첫째, VoiceBank+DEMAND 48 kHz test set에서 published full-band references와 비교하는 48 kHz full-band results이다. 둘째, 16 kHz VoiceBank+DEMAND quality-efficiency comparison이다. 셋째, proposed architecture에 대한 controlled 48 kHz ablation analysis이다.

본 논문의 contributions는 다음과 같다.

1. 48 kHz full-band SE를 observation-preserving refinement로 formulate한다. 여기서 upper-band components는 wideband processing 이후 생성해야 하는 missing content가 아니라 noisy spectral evidence로 다루어진다.
2. Low-band-guided full-band refinement를 위한 TF-domain architecture인 TF-Rehancer를 제안한다. 이 구조는 low-band encoder context를 사용해 observed high-band decoder tokens를 update하고, resulting full embedded sequence를 model하며, noisy STFT에 대한 complex filtering으로 enhanced spectrum을 추정한다.
3. TF-Rehancer를 48 kHz full-band results against published full-band references, 16 kHz quality-efficiency comparison, controlled 48 kHz ablations of complex filtering, decoder cross-attention, low-band cutoff를 통해 평가한다.

이 thesis의 나머지 구성은 다음과 같다. Chapter 2는 wideband enhancement, bandwidth extension, practical full-band enhancement 관련 연구를 검토한다. Chapter 3은 TF-Rehancer architecture와 training objective를 설명한다. Chapter 4는 experimental setup, benchmark results, ablation analysis를 제시한다. Chapter 5는 thesis를 요약하고 limitations와 future work를 논의한다.

## Chapter 2. Related Work

### 2.1 Full-Band Speech Enhancement

Neural speech enhancement (SE)는 time-frequency mask estimation에서 phase-aware, complex-domain, time-domain, modern TF-domain modeling으로 발전해 왔다. 초기 system은 보통 STFT domain에서 real-valued masks를 추정했고, 이후 methods는 phase-related distortion을 더 잘 다루기 위해 phase-sensitive masks, complex ratio masks, complex-valued networks를 도입했다. Time-domain systems는 fixed STFT representation을 learned analysis and synthesis bases로 대체했고, 최근 TF-domain models는 temporal and spectral dependencies를 명시적으로 modeling하여 enhancement quality를 더욱 개선했다. 그러나 많은 reported comparisons는 여전히 16 kHz 또는 protocol-specific settings에 묶여 있으며, 이 경우 48 kHz speech에 존재하는 upper-band components는 input representation 밖에 있다.

Full-band SE의 동기는 high-frequency speech information에 대한 perceptual studies에서도 뒷받침된다. Conventional wideband range 위의 extended high-frequency cues는 noise 속 speech perception과 fricative-related cues perception에 기여하는 것으로 나타났다. 이러한 발견은 full-band spectrum이 input에 이미 존재할 때 upper-band observations를 유지하고 refine해야 할 필요성을 동기화한다.

Speech bandwidth extension과 speech super-resolution은 direct full-band SE와 다른 information condition을 다룬다. 이 task들은 band-limited inputs에서 missing high-frequency content를 reconstruct 또는 supplement하는 것을 목표로 하며, 종종 더 높은 output sampling rate 또는 더 넓은 output bandwidth를 target한다. 반면 48 kHz full-band SE는 noisy full-band observation에서 시작하며, upper-band spectrum은 이미 존재하지만 noise에 의해 훼손되어 있다. 따라서 full-band SE는 band-limited input으로부터 high-band만 reconstruction하는 것이 아니라, observed full-band signal 전체에서 noise suppression과 spectral refinement를 수행해야 한다. 이러한 observed-band condition은 reliable low-band speech structure를 refinement context로 사용하면서 noisy full-band evidence를 유지하는 architectures를 동기화한다.

### 2.2 Efficient Full-Band Modeling

Practical full-band SE는 주로 real-time 및 low-complexity constraints 아래에서 연구되어 왔다. PercepNet은 perceptually motivated critical-band features와 comb filtering을 사용해 48 kHz speech를 enhance하고, DeepFilterNet2는 low-complexity full-band enhancement를 위해 ERB-domain enhancement와 deep filtering을 결합한다. 이러한 perceptual 또는 ERB-band representations는 frequency resolution을 efficiency와 trade-off한다. 이는 observed STFT와의 연결을 더 가깝게 유지하면서도 computational cost를 제어하는 complementary TF-domain designs를 동기화한다.

Frequency-structured modeling 역시 modern SE 및 source separation의 주요 design axis가 되었다. Subband 및 band-split models는 spectra를 grouped frequency regions로 처리하고, TF-domain dual-path models는 efficiency와 representation power를 개선하기 위해 temporal 및 spectral modeling을 분리한다. BSRNN과 BS-RoFormer는 band-wise modeling이 high-resolution audio modeling에 효과적임을 보였고, TF-Locoformer는 convolution을 통한 local modeling을 갖춘 RNN-free TF-domain dual-path architecture를 개발했다. GTCRN, LiSenNet, FastEnhancer와 같은 lightweight systems도 compact recurrent, subband, frequency-time modeling이 real-time SE에서 performance-efficiency trade-off를 개선할 수 있음을 보였다.

많은 band-split 및 lightweight models는 compact subband grouping 또는 efficient within-band/global sequence modeling을 강조한다. TF-Rehancer 역시 frequency compression을 사용한다. Input stem은 learned frequency-strided embedding을 적용해 token count를 줄인다. 차이는 final enhancement가 full-resolution complex filtering을 통해 original noisy STFT에 묶인다는 점이다. 이 design은 high-frequency region이 missing된 것이 아니라 decoder path에서 noisy spectral evidence로 이용 가능한 direct 48 kHz full-band SE를 target한다.

### 2.3 Query Refinement and TF Filtering

Query-based restoration은 또 다른 관련 방향이다. TF-Restormer는 decoupled input and output sampling rates를 갖는 speech restoration을 위해 asymmetric encoder-decoder architecture를 도입한다. Encoder는 observed input bandwidth에 집중하고, decoder는 frequency extension queries를 통해 target frequency regions를 restore한다. 이 mechanism은 decoder-side queries가 input에 없는 frequency regions를 위한 slots로 기능할 수 있는 bandwidth restoration에 잘 맞는다.

Direct 48 kHz full-band SE는 다른 information condition을 가진다. TF-Restormer는 restoration에서 missing 또는 target frequency regions를 위한 decoder-side queries를 사용하지만, TF-Rehancer는 high-band region이 observed and noisy인 direct full-band SE에서 query modeling을 사용한다. 따라서 query는 missing-band placeholder가 아니다. Query는 observed high-band evidence에서 도출되며 low-band context를 사용해 update된다.

Filtering-based enhancement는 이러한 observation-preserving view와 밀접하게 관련된다. Latent representation을 clean spectrum으로 직접 mapping하는 대신, deep filtering은 complex local filters를 추정하고 noisy STFT에 적용한다. SR-CorrNet과 같은 최근 correlation-to-filter approaches는 correlation-derived 또는 structure-conditioned filters가 direct spectral mapping에 대한 효과적인 alternative가 될 수 있음을 보여주는 관련 evidence를 제공한다. TF-Rehancer는 original noisy STFT에 대한 complex filtering을 통해 enhanced spectrum을 추정함으로써 이 filtering-based principle을 따른다.

Prior work는 이 문제의 complementary parts를 다룬다. Practical full-band systems는 perceptual-band efficiency를 강조하고, frequency-structured models는 주로 efficient within-band 또는 band-split modeling을 다루며, query-based restoration methods는 주로 missing-band reconstruction을 target한다. 반면 TF-Rehancer는 low-band-guided full-band refinement와 noisy STFT에 대한 complex filtering을 통해 direct full-band SE를 target한다.

## Chapter 3. Proposed Method

### 3.1 Problem Formulation

Noisy speech waveform과 clean speech waveform을 각각 $y \in \mathbb{R}^{L}$, $x \in \mathbb{R}^{L}$라고 하자. Single-channel speech enhancement에서 noisy signal은 다음과 같이 model된다.

$$
y = x + n,
$$

여기서 $n$은 additive noise를 나타낸다. Short-time Fourier transform (STFT)을 적용하면 noisy 및 clean complex spectra $Y,X\in\mathbb{C}^{F\times T}$를 얻는다. 여기서 $F$와 $T$는 frequency bins와 time frames를 나타낸다. Full-band speech enhancement의 목표는 noisy full-band observation $Y$에서 clean full-band spectrum $\hat{X}$를 추정하고, inverse STFT reconstruction을 통해 enhanced waveform $\hat{x}$를 얻는 것이다.

TF-Rehancer는 observation-preserving filtering formulation을 따른다. Neural network는 complex local time-frequency filter $W$를 예측하고, final spectrum은 이 filter를 linear noisy STFT reference $Y^{\mathrm{ref}}$에 적용하여 얻는다.

$$
W = \mathcal{G}_{\theta}(\Phi(Y)), \qquad
\hat{X} = W \otimes Y^{\mathrm{ref}}.
$$

여기서 $\mathcal{G}_{\theta}$는 TF-Rehancer, $\Phi(Y)$는 neural conditioning feature, $\otimes$는 time-frequency neighborhood에 대한 local complex filtering을 의미한다. Compressed feature $\Phi(Y)$는 conditioning에 사용되고, output operator는 original linear noisy spectrum에 적용된다. 따라서 모델은 $\hat{X}$의 unconstrained direct generator로 학습되지 않는다. 모델은 observed noisy spectrum을 변환하기 위해 사용되는 filter coefficients를 추정한다.

48 kHz full-band input에서 upper band는 noise에 의해 훼손되어 있지만 $Y$ 안에 이미 존재한다. TF-Rehancer는 이 region을 observed noisy evidence로 다루고, 여기서 decoder-side high-band query features를 도출한 뒤 complex filtering 이전에 decoder representation을 refine한다.

### 3.2 TF-Rehancer Architecture

이 section은 TF-Rehancer를 low-band-guided full-band refinement pipeline으로 설명한다. Pipeline은 shared TF embedding, observed high-band query construction, cross-band decoder refinement, full-resolution complex TF filtering으로 구성된다.

**Figure 3.1. Overall TF-Rehancer architecture.** Shared input layer는 full-band STFT를 embedding한다. Low-band region은 TF encoder에 의해 encoded되고, observed high-band region은 decoder-side query evidence로 전달된다. Decoder cross-attention은 low-band encoder context를 사용해 high-band tokens를 update하고, subsequent full-sequence decoder modeling은 complex TF filter estimation을 위한 features를 생성한다.

### 3.2.1 SFI-STFT Conditioning and Shared Embedding

TF-Rehancer는 TF-Restormer에서 사용된 sampling-frequency-independent STFT (SFI-STFT) principle을 채택한다. Analysis window와 hop은 fixed sample count가 아니라 physical duration인 40 ms와 20 ms로 고정된다. 따라서 16 kHz configuration은 $N=640$, $H=320$, $F=321$을 사용하고, 48 kHz configuration은 $N=1920$, $H=960$, $F=961$을 사용한다. 이는 sampling rates 간 temporal frame geometry를 고정하고, frequency-bin count가 bandwidth에 따라 scale되도록 한다. TF-Restormer가 restoration 및 super-resolution을 위해 decoupled input-output rates를 사용하는 것과 달리, TF-Rehancer는 same-sampling-rate 16 kHz 및 48 kHz speech enhancement settings에서 noisy input, clean target, inverse-STFT reconstruction에 동일한 SFI-STFT parameterization을 사용한다.

Figure 3.1은 이 thesis에서 사용한 TF-Rehancer architecture를 요약한다. Frontend는 final filtering step을 위한 linear noisy STFT reference를 보존하면서 power-law compressed conditioning feature를 구성한다. Shared input layer는 full-band STFT를 embedding하고 frequency resolution만 줄인다. Fixed 5 kHz split은 low-band tokens를 TF encoder로, observed high-band tokens를 decoder-side query path로 보낸다. Encoder는 low-band time-frequency blocks 4개를 사용해 speech-structure evidence를 model한다. Decoder는 cross-band time-frequency blocks 2개를 사용한다. 이 block들은 먼저 low-band key/value context를 사용해 high-band decoder tokens만 update하고, 이후 full embedded sequence를 model한다. 마지막으로 FastFilterUpsample은 original STFT frequency resolution을 복원하고, output layer는 $Y^{\mathrm{ref}}$에 적용되는 local $3\times3$ complex filter를 추정한다.

Neural conditioning feature는 power-law compressed complex STFT에서 구성된다. $\gamma=0.3$이 주어질 때 compressed spectrum과 input feature는 다음과 같다.

$$
C_{\gamma}(Y) =
Y\left(|Y|^2+\epsilon\right)^{(\gamma-1)/2},
\qquad
\Phi(Y)=
\left[
\operatorname{Re}(C_{\gamma}(Y)),
\operatorname{Im}(C_{\gamma}(Y)),
|C_{\gamma}(Y)|
\right].
$$

Power-law compression은 neural processing을 위해 spectral amplitudes의 dynamic range를 안정화한다. Uncompressed noisy STFT reference $Y^{\mathrm{ref}}$는 final filtering operation을 위해 별도로 유지된다.

Feature $\Phi(Y)$는 shared frequency-strided input stem을 통과하며, 이를 $H=\operatorname{Stem}(\Phi(Y))$로 나타낸다. Stem은 $\operatorname{Conv2D}(3 \rightarrow 48)$, batch normalization, SiLU activation으로 구성된다. Convolution은 kernel size $(4,1)$, stride $(2,1)$, padding $(2,0)$을 사용하므로 frequency resolution만 줄이고 frame rate는 보존한다. 이 shared stem은 16 kHz 및 48 kHz configurations 모두에 사용된다. Stem 이후 embedded frequency resolution은 16 kHz에서 $F_{\mathrm{emb}}=161$, 48 kHz에서 $F_{\mathrm{emb}}=481$이다. Shared stem은 efficient modeling을 위해 frequency axis를 compress하면서, input representation의 observed high-band portion에서 high-band decoder tokens를 도출한다.

Output side에서는 local complex filter coefficients를 추정하기 전에 decoder representation을 original STFT frequency resolution으로 복원한다. 따라서 input-side embedding과 output-side filtering은 unconstrained waveform generation이 아니라 explicit STFT reference 주변의 local convolutional transformations로 설명된다.

### 3.2.2 Observed High-Band Query Construction

**Figure 3.2. Local convolutional layer notation.** Input stem, high-band adapter, output-side upsampling/filtering layers에서 사용되는 local convolutional layer notation을 보여준다. Channel width, stride, normalization은 module마다 다르며 본문에서 설명한다.

Shared stem 이후 TF-Rehancer는 5 kHz cutoff를 사용해 embedded frequency axis를 $H_{\mathrm{low}}$와 $H_{\mathrm{high}}$로 나눈다. 16 kHz에서는 $F_{\mathrm{low}}=101$, $F_{\mathrm{high}}=60$이고, 48 kHz에서는 $F_{\mathrm{low}}=101$, $F_{\mathrm{high}}=380$이다. 따라서 동일한 low-band speech-structure region이 두 sampling rates에서 encoded되고, 48 kHz model은 decoder path에 훨씬 큰 observed high-band region을 유지한다.

High-band branch는 observed high-band stem feature에서 도출된다.

$$
Q_h = H_{\mathrm{high}} + \operatorname{Adapter}_{h}(H_{\mathrm{high}}).
$$

Adapter는 SiLU activation과 layer normalization을 갖는 residual local convolutional block이며, Figure 3.2에 요약된 local convolutional layer notation을 사용한다. 이 block은 cross-band refinement 이전에 observed high-band representation을 decoder query space에 align한다. Adapter는 decoder refinement를 자체적으로 수행하지 않는다. High-band tokens를 decoder에 준비시키는 역할을 한다. Query source는 observed high-band embedding으로 유지되며, adapter는 cross-band refinement 이전의 lightweight local transformation만 제공한다.

다음으로 decoder cross-attention에서 사용되는 context representation을 생성하는 low-band encoder를 설명한다. Low-band encoder는 stacked blocks 4개를 사용해 $H_{\mathrm{low}}$를 encoded representation $Z$로 mapping한다. 각 block은 frequency feed-forward layers, frequency-axis self-attention with RoPE, FastGRU2 temporal modeling을 결합한다. Encoder는 frequency projection layer나 pre-encoder sinusoidal positional encoding을 사용하지 않는다. Encoder의 역할은 harmonic 및 formant-related evidence가 상대적으로 dense한 low-band region에서 speech structure를 modeling하는 것이다.

Encoder frequency module은 Macaron-style structure를 따른다. Convolutional feed-forward layer가 frequency-axis self-attention의 앞과 뒤에 배치된다. 이 F-ConvFFN--F-MHSA--F-ConvFFN ordering은 local convolutional mixing과 global frequency attention이 서로 보완되도록 한다. Decoder frequency module은 full-sequence self-attention 이전에 cross-attention을 삽입하여 이 pattern을 확장한다. 즉, F-MHCA--F-MHSA--F-ConvFFN 구조를 사용한다.

RoPE는 learned absolute positional table에 의존하지 않고 frequency tokens의 relative order를 encode하기 위해 frequency-axis attention에 적용된다. 이는 frequency axis가 fixed physical ordering을 갖는 반면 token 수는 16 kHz와 48 kHz settings에서 달라지기 때문에 유용하다. Decoder cross-attention에서 high-band query와 low-band key/value tokens는 서로 다른 frequency regions를 차지하므로, RoPE offsets는 cross-band attention 동안 relative frequency positions를 보존한다.

Frequency feed-forward layers의 cost를 줄이기 위해 TF-Rehancer는 efficient convolutional FFN을 사용한다. 이 module은 full frequency sequence에 large convolutional FFN을 적용하는 대신, 먼저 adaptive average pooling으로 frequency-axis sequence를 downsample한다. 그런 다음 shortened sequence에서 separate value/gate branches와 SiLU gating을 사용하는 grouped gated 1-D convolutions를 적용한다. Computation을 줄이기 위해 group convolution with two groups를 사용한다. Output은 다시 projected, upsampled되어 original frequency length로 돌아간 뒤 scaled residual correction으로 더해진다. 이 design은 full-length residual path를 유지하면서 expensive gated convolutional correction을 짧은 sequence에서 수행한다.

### 3.2.3 Cross-Band Decoder Refinement

**Figure 3.3. TF-Rehancer encoder and decoder core blocks.** Encoder frequency module은 RoPE를 사용한 Macaron-style F-ConvFFN--F-MHSA--F-ConvFFN 구조를 사용한다. Decoder frequency module은 먼저 F-MHCA를 적용해 low-band encoder context로 high-band tokens를 update하고, 이후 full-sequence F-MHSA와 F-ConvFFN을 적용한다.

Decoder는 먼저 low-band encoder output $Z$와 adapted high-band query $Q_h$를 frequency axis 방향으로 concatenate하여 full embedded sequence를 만든다. Linear projection with layer normalization은 concatenated 48-channel representation을 24-channel decoder width로 mapping한다. 이 projection은 encoder/query interface와 decoder blocks 사이의 separate alignment stage이다.

Projected decoder input을 $D=[D_{\mathrm{low}};D_{\mathrm{high}}]$로 split한다고 하자. 여기서 $D_{\mathrm{high}}$는 observed high-band portion에 해당한다. TF-Rehancer는 decoder blocks 2개를 사용한다. 각 block에서 $D_{\mathrm{low}}$는 MHCA에 의해 update되지 않고 cross-attention stage를 통과한다. 반면 $D_{\mathrm{high}}$는 query로 사용된다. Key와 value는 low-band encoder output $Z$에서 얻는다.

$$
Q = \Pi_q(D_{\mathrm{high}}), \qquad
K = \Pi_k(Z), \qquad
V = \Pi_v(Z).
$$

High-band update는 다음과 같이 계산된다.

$$
\tilde{D}_{\mathrm{high}}
=
D_{\mathrm{high}}
+
\operatorname{MHCA}(Q,K,V),
$$

Decoder sequence는 다음과 같이 재구성된다.

$$
\tilde{D}=[D_{\mathrm{low}};\tilde{D}_{\mathrm{high}}].
$$

Projection operators $\Pi_q$, $\Pi_k$, $\Pi_v$는 MHCA module 내부에 구현되어 있으므로 decoder-side query와 low-band context의 input widths가 같을 필요는 없다. 따라서 cross-attention은 observed high-band decoder tokens만 update함으로써 directed low-to-high conditioning을 수행한다. 이어지는 frequency self-attention, frequency feed-forward processing, FastGRU2 temporal modeling은 $\tilde{D}$ 전체에 적용되므로, directed update 이후 low- and high-band tokens는 full embedded sequence 위에서 상호작용한다.

이 design은 세 역할을 분리한다. High-band adapter는 $H_{\mathrm{high}}$에서 observed high-band query evidence를 준비한다. Concat-projection layer는 low-band encoder output과 high-band query를 decoder width에 align한다. Decoder blocks는 cross-attention-based high-band token update를 수행한 뒤 full-sequence time-frequency modeling을 수행한다.

### 3.2.4 Complex TF Filtering

**Figure 3.4. Complex TF filtering module.** TF-Rehancer는 complex filter coefficients를 예측하고, noisy STFT reference의 local time-frequency neighborhood에 적용한다.

Decoder output은 아직 embedded frequency resolution에 있다. Filter estimation 전에 TF-Rehancer는 FastFilterUpsample을 사용해 이를 original STFT frequency resolution으로 복원한다. 이 module은 pointwise convolution 다음에 frequency axis 방향 transposed convolution을 사용한다. 복원된 full-resolution feature는 partial-convolution filter head와 local $3 \times 3$ time-frequency convolution으로 전달된다. Output-side convolutional operations는 Figure 3.2의 compact local-layer notation을 따르며, explicit filtering operation은 아래와 같이 설명된다.

각 time-frequency bin에 대해 head는 local offsets $\Delta f,\Delta t\in\{-1,0,1\}$에 대한 nine complex taps를 예측한다. Raw head output은 27 channels를 가진다. 각 tap마다 one magnitude scale, one real component, one imaginary component를 포함한다. Softplus activation은 magnitude scale을 positive하게 constrain하고, tanh activations는 complex coefficients $W_{\Delta f,\Delta t,f,t}$를 만들기 전에 real 및 imaginary components를 bound한다.

Enhanced spectrum은 다음과 같이 계산된다.

$$
\hat{X}_{f,t}
=
\sum_{\Delta f=-1}^{1}
\sum_{\Delta t=-1}^{1}
W_{\Delta f,\Delta t,f,t}
Y^{\mathrm{ref}}_{f+\Delta f,t+\Delta t}.
$$

Boundary positions는 local neighborhoods를 gather하기 전에 padding된다. 이 operation은 correlation estimate가 아니라 complex filtering operation이다. Coefficients $W$는 $\hat{X}$를 구성하는 데 사용되는 predicted filter weights이다. 이들은 decoder feature에 의해 conditioned되고, observed noisy STFT reference에 적용된다.

따라서 filtering head는 proposed refinement architecture의 output estimator이다. Main representation-level contribution은 low-band-guided full-band refinement에 있다.

### 3.3 Training Objective

TF-Rehancer는 input feature와 동일한 $\gamma=0.3$ power-law compression을 사용하고, $\epsilon$-stabilized magnitude를 갖는 composite enhancement loss로 학습된다. $\hat{X}$와 $X$를 estimated 및 clean complex STFTs라 하고, $\hat{x}=\operatorname{iSTFT}(\hat{X})$, $x=\operatorname{iSTFT}(X)$를 corresponding waveforms라고 하자. Total enhancement loss는 다음과 같다.

$$
\mathcal{L}
=
\lambda_{\mathrm{mag}}\mathcal{L}_{\mathrm{mag}}
+
\lambda_{\mathrm{cplx}}\mathcal{L}_{\mathrm{cplx}}
+
\lambda_{\mathrm{cons}}\mathcal{L}_{\mathrm{cons}}
+
\lambda_{\mathrm{wav}}\mathcal{L}_{\mathrm{wav}}
+
\lambda_{\mathrm{pesq}}\mathcal{L}_{\mathrm{pesq}}.
$$

$C_\gamma(\cdot)$를 compressed complex spectrum, $\operatorname{RI}(\cdot)$를 real-imaginary channel stacking이라고 할 때 spectral terms는 다음과 같다.

$$
\mathcal{L}_{\mathrm{mag}}
=
\operatorname{MSE}
\left(
|C_\gamma(\hat{X})|,
|C_\gamma(X)|
\right),
$$

$$
\mathcal{L}_{\mathrm{cplx}}
=
\operatorname{MSE}
\left(
\operatorname{RI}(C_\gamma(\hat{X})),
\operatorname{RI}(C_\gamma(X))
\right).
$$

$\mathcal{L}_{\mathrm{mag}}$는 compressed magnitude envelope를 match하여 upper band를 포함한 frequency bands 전반의 energy consistency를 유도한다. 이는 phase를 직접 supervise하지 않는다. $\mathcal{L}_{\mathrm{cplx}}$는 compressed real 및 imaginary components를 비교하므로 complex filter output에 phase-sensitive supervision을 제공한다.

Consistency term은 waveform reconstruction 이후 계산된다.

$$
\tilde{X}
=
\operatorname{STFT}
\left(
\operatorname{iSTFT}(\hat{X})
\right),
\qquad
\mathcal{L}_{\mathrm{cons}}
=
\operatorname{MSE}
\left(
\operatorname{RI}(C_\gamma(\tilde{X})),
\operatorname{RI}(C_\gamma(X))
\right).
$$

따라서 $\mathcal{L}_{\mathrm{cons}}$는 단순히 pre-reconstruction STFT tensors 두 개를 비교하는 것이 아니다. 이 term은 inverse STFT 전에는 plausible해 보이지만 waveform reconstruction과 STFT 재변환 이후 inconsistent해지는 spectra를 penalize한다.

Waveform 및 perceptual auxiliary terms는 다음과 같다.

$$
\mathcal{L}_{\mathrm{wav}}
=
\|\hat{x}-x\|_{1},
\qquad
\mathcal{L}_{\mathrm{pesq}}
=
\operatorname{PesqLoss}
\left(
\mathcal{R}_{16}(\hat{x}),
\mathcal{R}_{16}(x)
\right).
$$

여기서 $\mathcal{R}_{16}$은 training waveform이 48 kHz일 때 16 kHz로 resampling하는 operation이고, 16 kHz training에서는 identity operation이다. $\mathcal{L}_{\mathrm{wav}}$는 spectral losses만으로 충분히 포착되지 않을 수 있는 sample-level reconstruction error와 time-domain artifacts를 줄인다. $\mathcal{L}_{\mathrm{pesq}}$는 differentiable PESQ-like training loss이며, reported evaluation PESQ score가 아니다. 이는 weak perceptual regularizer로만 사용된다.

$\mathcal{L}_{\mathrm{mag}}$, $\mathcal{L}_{\mathrm{cplx}}$, $\mathcal{L}_{\mathrm{cons}}$, $\mathcal{L}_{\mathrm{wav}}$, $\mathcal{L}_{\mathrm{pesq}}$의 weights는 각각 0.3, 0.2, 0.3, 0.2, 0.001이다. 따라서 optimization은 주로 compressed spectral reconstruction, reconstruction consistency, waveform-domain supervision에 의해 driven되며, PESQ term은 lightly weighted된다.

## Chapter 4. Experiments

### 4.1 Experimental Setup

TF-Rehancer는 48 kHz full-band results, 16 kHz wideband benchmark, 48 kHz controlled ablation setting을 사용해 평가된다. 48 kHz results는 VBD 48 kHz test set을 사용하여 TF-Rehancer를 published full-band references와 비교하고, full-band processing에서 architectural components를 분석한다. 16 kHz setting은 official VoiceBank+DEMAND (VBD) corpus를 사용하여 proposed model을 lightweight speech enhancement baselines와 비교한다.

16 kHz comparison에는 official VBD paired speech enhancement corpus를 사용한다. Official training partition은 28 speakers를 포함하며, fixed random seed를 사용해 10,413 training utterances와 1,159 validation utterances로 split된다. Evaluation은 unseen speakers를 포함하는 official 824-utterance test set에서 수행된다.

Controlled 48 kHz ablation experiments에서는 VCTK clean speech와 DNS full-band noise를 사용해 noisy mixtures를 합성한다. Evaluation은 VBD 48 kHz test set에서 수행된다. VBD 48 kHz test set은 paired clean and noisy files를 갖도록 48 kHz로 준비된 official 824-utterance VoiceBank+DEMAND test split이며, DNS-remixed test set이 아니다. Ablation experiments는 controlled component analysis를 목적으로 한다.

이 chapter는 Chapter 3에서 설명한 final TF-Rehancer architecture를 평가한다. Main design principle은 low-band-guided full-band refinement이다. Model은 low-band representation에 heavy encoding을 집중하고, observed high-band evidence를 decoder path에 유지하며, low-band encoder output을 key/value context로 사용해 high-band decoder tokens를 update하고, original noisy STFT에 대한 complex TF filtering으로 enhanced spectrum을 추정한다.

별도로 명시하지 않는 한, TF-Rehancer는 low-band-guided full-band refinement와 complex TF filtering을 수행하는 architecture를 의미한다. 16 kHz comparison에서는 compact FastGRU-based configuration과 non-streaming TimeMHSA-EFN configuration을 보고한다. 두 variants는 동일한 high-band update 및 filtering pipeline을 공유한다. 이 labels는 model configurations를 설명하며 measured real-time 또는 streaming claims로 사용되지 않는다.

모든 TF-Rehancer experiments는 40 ms analysis window와 20 ms frame shift를 사용한다. 이 setting에서 16 kHz 및 48 kHz configurations 모두 frequency spacing은 25 Hz이다. Default low-band cutoff는 5 kHz이며, 이는 201 full-resolution frequency bins와 frequency-strided stem 이후 101 embedded low-band tokens에 해당한다. 따라서 low-band encoder length는 16 kHz와 48 kHz configurations에서 거의 고정되고, observed high-band decoder tokens의 수는 48 kHz setting에서 증가한다.

Model complexity는 parameters 수와 model-side multiply-accumulate operations (MACs)로 보고한다. 별도로 명시하지 않는 한, MACs는 STFT와 inverse STFT operations를 제외한다.

Locally trained TF-Rehancer runs의 경우, evaluation은 lowest validation loss checkpoint를 사용한다. Default VoiceBank+DEMAND evaluation set은 824 utterances를 포함한다.

Full-reference metrics와 non-intrusive metrics를 모두 사용한다. DNSMOS P.808 및 DNSMOS P.835 SIG/BAK/OVL은 waveform을 16 kHz로 resampling한 뒤 계산한다. SCOREQ는 16 kHz resampling 이후 full-reference natural-speech mode로 계산한다. PESQ, STOI, ESTOI도 16 kHz resampling 이후 계산한다. 별도로 명시하지 않는 한, SI-SDR은 task sampling rate에서 계산된다.

48 kHz analysis에서는 많은 standard speech enhancement metrics가 16 kHz resampling 이후 계산되어 upper-frequency region을 직접 평가하지 않으므로 full-band spectral metrics를 추가로 보고한다. 48 kHz outputs에 대해 full-band LSD, MCD, SI-SDR을 보고한다. DNSMOS SIG/BAK/OVL은 DNSMOS P.835를 의미하고, CSIG/CBAK/COVL은 composite full-reference metrics를 의미한다.

### 4.2 Experimental Results

#### 4.2.1 48 kHz Full-Band Results

Table 4.1은 VBD 48 kHz test set에서의 48 kHz full-band results를 PercepNet 및 DeepFilterNet2 references와 함께 보고한다. TF-Rehancer (on) row는 VBD 48 kHz test set에서 평가된 DNS4-trained online configuration이다.

**Table 4.1. 48 kHz full-band results on VoiceBank+DEMAND 48 kHz**

| Method | Params | MACs | PESQ | STOI | CSIG | CBAK | COVL | SI-SDR |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| PercepNet | 8.00M | 0.80G | 2.73 | - | - | - | - | - |
| DFN2 + Simplified DNN | 2.31M | 0.36G | 3.08 | 0.943 | 4.30 | 3.40 | 3.70 | 15.709 |
| DFN2 + Post-Filter | 2.31M | 0.36G | 3.03 | 0.941 | 3.72 | 3.37 | 3.63 | 15.769 |
| TF-Rehancer (on) | 0.615M | 3.15G | 3.233 | 0.951 | 4.286 | 3.567 | 3.771 | 17.789 |

PercepNet과 DeepFilterNet2 rows는 published-reference context를 제공한다. DeepFilterNet2 SI-SDR values는 official-checkpoint evaluation summary에서 가져왔고, TF-Rehancer (on)은 locally evaluated이다. MACs는 model-side estimates이며 STFT/iSTFT를 제외한다.

Table 4.1은 TF-Rehancer (on)이 published full-band references와 비교해 VBD 48 kHz test set에서 competitive full-reference scores를 얻는다는 것을 보여준다. TF-Rehancer (on)의 PESQ, STOI, CBAK, COVL, SI-SDR values는 listed PercepNet 및 DeepFilterNet2 references보다 높다. 반면 simplified DeepFilterNet2 reference는 CSIG에서 약간 높고, DeepFilterNet2 rows는 더 낮은 MACs를 보고한다. Available DeepFilterNet2 SI-SDR values는 official-checkpoint evaluation context로 포함된다. 대부분의 reference-row values는 locally re-evaluated된 것이 아니라 prior papers에서 가져온 것이므로, 이 table은 strict direct re-evaluation이 아니라 published-reference comparison으로 읽어야 한다.

#### 4.2.2 Wideband Results

다음으로 16 kHz configuration을 standard wideband benchmark에서 평가하여 enhancement quality와 computational cost를 비교한다.

Table 4.2는 16 kHz VoiceBank+DEMAND results를 보고한다. FastEnhancer-M row는 paper-reported reference이다. TF-Rehancer (on)은 compact FastGRU-based configuration을 의미하고, TF-Rehancer (off)는 non-streaming TimeMHSA-EFN configuration을 의미한다. On/off labels는 model configurations를 구분하며 measured real-time 또는 streaming performance를 나타내지 않는다.

**Table 4.2. VoiceBank+DEMAND 16 kHz test results**

| Method | Params | MACs | P808 | SIG | BAK | OVL | SCOREQ | SI-SDR | PESQ | STOI | ESTOI |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| FastEnhancer-M | 0.49M | 2.90G | 3.48 | 3.39 | 4.02 | 3.11 | 0.243 | 19.40 | 3.24 | 0.950 | 0.873 |
| TF-Rehancer (on) | 0.47M | 1.89G | 3.49 | 3.41 | 4.04 | 3.13 | 0.244 | 19.44 | 3.33 | 0.950 | 0.872 |
| TF-Rehancer (off) | 0.62M | 2.00G | 3.49 | 3.41 | 4.06 | 3.14 | 0.242 | 19.72 | 3.40 | 0.953 | 0.876 |

FastEnhancer-M은 paper-reported values를 사용하며, TF-Rehancer rows는 824-utterance VBD test set에서 locally evaluated되었다. MACs는 model-side estimates이며 STFT/iSTFT를 제외한다.

Paper-reported FastEnhancer-M reference와 비교할 때, TF-Rehancer (on)은 similar parameter scale에서 fewer model-side MACs를 사용한다. 또한 PESQ, SI-SDR, DNSMOS SIG, BAK, OVL values가 더 높다. FastEnhancer-M은 SCOREQ와 ESTOI에서 약간 더 좋다. TF-Rehancer (off)는 TF-Rehancer (on)보다 더 높은 parameter count와 MACs를 사용하며, SCOREQ는 더 낮고 PESQ, SI-SDR, STOI, ESTOI, DNSMOS BAK, DNSMOS OVL values는 더 높다. 따라서 16 kHz result는 intended interpretation과 일치한다. Proposed design은 compact configuration에서 competitive values를 보고하고, non-streaming TimeMHSA-EFN configuration에서 더 높은 quality metrics를 보고한다.

#### 4.2.3 Low-Band Cutoff

다음으로 48 kHz ablation setting에서 low-band cutoff를 3 kHz부터 8 kHz까지 변화시킨다. 모든 cutoff variants는 동일한 model size를 사용하고 VBD 48 kHz test set에서 평가된다.

**Table 4.3. Low-band cutoff ablation**

| Cutoff | MACs | P808 | SIG | BAK | OVL | SI-SDR | PESQ | STOI | ESTOI | CSIG | CBAK | COVL | LSD | MCD |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 8 kHz | 3.81G | 3.46 | 3.39 | 3.98 | 3.08 | 16.50 | 3.31 | 0.946 | 0.866 | 4.42 | 3.60 | 3.90 | 0.75 | 2.38 |
| 7 kHz | 3.54G | 3.45 | 3.39 | 3.96 | 3.07 | 16.11 | 3.29 | 0.947 | 0.867 | 4.40 | 3.57 | 3.88 | 0.75 | 2.35 |
| 6 kHz | 3.28G | 3.46 | 3.39 | 3.97 | 3.07 | 16.75 | 3.29 | 0.947 | 0.868 | 4.42 | 3.60 | 3.89 | 0.72 | 2.26 |
| 5 kHz | 3.02G | 3.46 | 3.38 | 3.98 | 3.07 | 16.83 | 3.29 | 0.947 | 0.868 | 4.40 | 3.60 | 3.88 | 0.72 | 2.27 |
| 4 kHz | 2.76G | 3.45 | 3.38 | 3.97 | 3.07 | 16.29 | 3.27 | 0.947 | 0.867 | 4.41 | 3.56 | 3.87 | 0.73 | 2.31 |
| 3 kHz | 2.50G | 3.45 | 3.40 | 3.92 | 3.06 | 15.41 | 3.23 | 0.946 | 0.867 | 4.40 | 3.51 | 3.84 | 0.78 | 2.38 |

Cutoff sweep는 computation, perceptual quality, spectral fidelity 사이의 trade-off를 보여준다. Larger cutoffs는 computation을 증가시키고 일부 perceptual scores를 개선한다. 반면 smaller cutoffs는 MACs를 줄이지만 LSD와 MCD로 측정되는 full-band spectral fidelity를 저하시킬 수 있다. Controlled 48 kHz ablation setting에서 5 kHz는 computational cost, SI-SDR, full-band spectral metrics 사이의 balanced operating point를 제공하기 때문에 default cutoff로 사용된다.

#### 4.2.4 Architecture Ablations

Table 4.4는 default TF-Rehancer architecture를 두 variants와 비교한다. 하나는 decoder MHCA가 없는 variant이고, 다른 하나는 complex TF filtering을 direct spectrum mapping으로 대체한 variant이다. 이 ablation은 decoder cross-attention과 filtering-based output estimation의 효과를 조사하기 위한 것이다.

**Table 4.4. 48 kHz architecture ablation**

| Method | P808 | SIG | BAK | OVL | SI-SDR | PESQ | STOI | ESTOI | CSIG | CBAK | COVL | LSD | MCD |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| TF-Rehancer | 3.45 | 3.38 | 3.98 | 3.07 | 16.70 | 3.29 | 0.948 | 0.868 | 4.40 | 3.59 | 3.88 | 0.73 | 2.28 |
| w/o Decoder MHCA | 3.45 | 3.39 | 3.96 | 3.05 | 16.27 | 3.14 | 0.944 | 0.858 | 4.35 | 3.52 | 3.77 | 0.77 | 2.50 |
| w/ Direct Mapping | 3.44 | 3.35 | 3.96 | 3.03 | 14.90 | 3.05 | 0.940 | 0.853 | 4.24 | 3.40 | 3.66 | 0.78 | 2.52 |

Direct mapping head는 reported metric families 전반에서 complex TF filtering보다 약하다. 이는 48 kHz ablation setting에서 filtering-based output estimation이 direct spectrum mapping보다 더 reliable함을 시사한다. W/o decoder MHCA variant는 direct mapping보다 강하지만, 대부분의 full-reference 및 spectral metrics에서 TF-Rehancer보다 낮다. DNSMOS P.808은 rounding 이후 tie이고, DNSMOS SIG는 w/o decoder MHCA row가 약간 더 높다. 따라서 controlled ablation은 decoder cross-attention이 main full-reference 및 spectral trends에서 제거하는 것보다 더 효과적임을 보여준다. 동시에 broader low-band-guided refinement path는 indirect하게 평가된 상태로 남아 있다.

## Chapter 5. Conclusion

### 5.1 Summary

본 thesis는 computationally controlled full-band processing을 위한 time-frequency-domain speech enhancement architecture인 TF-Rehancer를 제시했다. 핵심 아이디어는 low-band-guided full-band refinement이다. TF-Rehancer는 low-band speech structure에 heavier modeling을 집중하고, observed upper-band evidence를 decoder path에 유지하며, low-band encoder context를 사용해 high-band decoder tokens를 update하고, original noisy STFT에 대한 complex time-frequency filtering을 통해 enhanced spectrum을 추정한다.

48 kHz VoiceBank+DEMAND results는 DNS4-trained online TF-Rehancer configuration이 published PercepNet 및 DeepFilterNet2 references와 비교해 competitive full-reference scores를 얻음을 보여준다. 16 kHz VoiceBank+DEMAND benchmark는 competitive quality-efficiency trade-off를 보여준다. Compact FastGRU-based setting은 similar parameter scale에서 paper-reported FastEnhancer-M reference보다 fewer model-side MACs를 사용한다. 또한 PESQ, SI-SDR, DNSMOS P.835 values를 더 높게 보고하며, FastEnhancer-M은 SCOREQ와 ESTOI에서 약간 더 강하다. Controlled 48 kHz ablation setting에서 direct spectrum mapping은 complex TF filtering보다 full-reference, spectral, non-intrusive metrics를 저하시킨다. 이는 filtering-based output estimation이 proposed architecture에 더 reliable하다는 것을 시사한다. Decoder MHCA ablation은 decoder cross-attention이 main full-reference 및 spectral trends에서 이를 제거하는 것보다 더 효과적임을 보인다. Low-band cutoff analysis는 5 kHz가 computational cost, waveform fidelity, full-band spectral fidelity 사이의 balanced operating point를 제공함을 보인다.

종합하면, 이러한 결과는 low-band-guided full-band refinement가 full-band speech enhancement를 위한 computationally controlled design direction임을 지지한다. 이 architecture는 observed upper-band information을 보존하고, heavy full-band encoding을 피하며, full-resolution complex TF filtering을 사용해 enhanced spectrum을 생성한다.

### 5.2 Limitations and Future Work

48 kHz comparison에는 paper-reported full-band references가 포함된다. TF-Rehancer는 locally evaluated된다. 더 강한 external full-band claims를 위해서는 locally re-evaluated baselines를 포함한 fully aligned protocol이 필요하다. 이 work의 48 kHz ablation experiments는 controlled component analysis를 위해 설계되었다. 따라서 future work는 TF-Rehancer와 competing full-band systems를 shared training and evaluation protocol 아래에서 평가해야 하며, aligned metric computation과 runtime measurement를 포함해야 한다.

몇 가지 architectural questions도 남아 있다. 현재 ablation은 output estimator로서 complex TF filtering을 지지하고 decoder MHCA의 효과를 characterize한다. Lightweight high-band adaptation을 subsequent decoder refinement와 더 분리해서 조사하면 이 component가 더 명확해질 것이다. 예를 들어 observed high-band embedding은 유지하면서 local high-band adapter를 제거하거나 대체하는 실험이 필요하다. 또한 low-band cutoff는 48 kHz ablation setting에서 balanced operating point로 선택되었다. 더 넓은 datasets, noise conditions, sampling rates에서는 adaptive 또는 data-dependent cutoff strategies가 필요할 수 있다.

마지막으로 practical deployment는 model-side MACs를 넘어서는 추가 validation을 요구한다. Future work는 real-time runtime profiling, latency analysis, device-oriented scenarios에서의 evaluation을 포함해야 한다. Multi-channel 또는 reverberant conditions로의 확장도 가능한 방향이다.

이러한 확장 연구는 practical speech enhancement에서 low-band-guided full-band refinement의 역할을 더 명확히 할 것이다.

