# 현재 논문 챕터별 한글 정리

- 기준 source: `thesis.tex`, `covers/abstract.tex`, `text/chapter1.tex`--`text/conclusion.tex`, `tables/*.tex`
- 목적: 최종 제출 전 빠른 한글 검토용
- 주의: 아래는 직역이 아니라 논문 흐름과 claim을 빠르게 읽기 위한 요약 번역이다.

## 제목 및 초록

### 제목

영문 제목은 현재 다음과 같다.

> Full-Band Speech Enhancement via Low-Band-Conditioned Refinement

국문 제목은 현재 다음과 같다.

> 저대역 유도 정제를 통한 Full-Band 음성 향상

### 영문 초록 내용

본 논문은 direct full-band speech enhancement를 위한 time-frequency 영역 모델인 TF-Rehancer를 제안한다. 48 kHz 음성의 고주파 성분을 wideband 입력에서 새로 생성해야 하는 missing information으로 보지 않고, noisy input 안에 이미 존재하지만 noise에 의해 훼손된 observed spectral evidence로 본다.

TF-Rehancer는 low-band speech structure를 encoding하고, observed upper-band evidence를 decoder path에 보존하며, 원 noisy STFT에 local complex time-frequency filtering을 적용해 enhanced spectrum을 추정한다.

평가는 세 관점으로 구성된다.

1. 16 kHz VoiceBank+DEMAND benchmark에서 compact FastGRU-based TF-Rehancer는 0.47M parameters, 1.89G model-side MACs로 PESQ 3.33, DNSMOS SIG 3.41, BAK 4.04, OVL 3.13을 달성한다. FastEnhancer-M paper-reported reference와 비교해 더 낮은 MACs로 PESQ, SI-SDR, DNSMOS P.835는 더 높고, FastEnhancer-M은 SCOREQ와 ESTOI에서 약간 더 좋다.
2. VoiceBank+DEMAND 48 kHz test set에서 DNS4-trained online TF-Rehancer configuration은 published PercepNet 및 DeepFilterNet2 reference와 비교해 competitive full-reference scores를 달성한다.
3. Controlled 48 kHz ablation에서 complex TF filtering을 direct spectrum mapping으로 바꾸면 full-reference, spectral, non-intrusive metrics가 나빠진다. Decoder cross-attention을 쓰는 것이 제거하는 것보다 대부분의 full-reference 및 spectral metrics에서 효과적이며, 5 kHz cutoff가 balanced operating point를 제공한다.

## Chapter 1. Introduction

### 문제 설정

기존 speech enhancement benchmark와 baseline은 대부분 16 kHz wideband setting 중심이다. 이 경우 48 kHz full-band speech에 포함된 upper-band spectral components는 model input 밖에 있다.

하지만 direct 48 kHz full-band speech enhancement는 조건이 다르다. 모델은 noisy full-band signal을 입력으로 받으며, upper-band spectrum은 이미 입력 안에 noisy evidence로 존재한다. 따라서 고주파를 나중에 생성하는 문제가 아니라, observed full-band spectrum 전체에서 noise를 줄이고 useful spectral evidence를 보존하는 문제다.

### BWE/SR과의 차이

Speech bandwidth extension과 speech super-resolution은 band-limited input에서 missing or degraded high-frequency content를 복원하는 문제다. 반면 48 kHz full-band SE는 noisy full-band observation에서 시작한다. 따라서 high-band를 wideband enhancement 이후 새로 합성하는 것이 아니라, 입력에 이미 있는 high-frequency region을 noisy observation의 일부로 다루어야 한다.

### 기존 full-band system과 TF-domain 동기

PercepNet과 DeepFilterNet2는 full-band enhancement를 strict computational constraints 아래 실현할 수 있음을 보였다. PercepNet은 critical-band features와 comb filtering을 쓰고, DeepFilterNet2는 ERB-domain enhancement와 deep filtering을 결합한다. 이런 perceptual-band front end는 효율성은 좋지만 bin-level spectral resolution을 희생한다.

따라서 본 논문은 complementary한 TF-domain design을 제안한다. Learned frequency representation을 사용하되, 최종 enhancement는 original noisy STFT에 complex filtering을 적용하는 방식으로 유지한다.

### 핵심 아이디어

Full-band frequency tokens 전체에 heavy TF modeling을 직접 적용하면 sampling rate가 커질수록 STFT bin 수가 늘어 computational cost가 커진다. Speech structure evidence, 즉 harmonic/formant 관련 정보는 주로 low band에 집중되어 있고, high-frequency bins는 noisy input 안에 이미 observed evidence로 존재한다.

따라서 TF-Rehancer는 heavy encoding을 low-band speech structure에 집중하고, high band는 decoder-side observed-query evidence로 운반한다. Low-band encoder output은 high-band decoder token을 update하기 위한 key/value context로 쓰인다. Cross-attention 이후 full-sequence decoder modules가 low/high band representation을 함께 model한다.

중요한 방어선은 다음이다. TF-Rehancer는 high-band speech를 low-band information만으로 생성하지 않는다. Observed high-band feature를 low-band context로 condition/update하는 구조다.

### Contribution

1. 48 kHz full-band SE를 observation-preserving refinement 문제로 정식화한다. Upper-band components를 missing content가 아니라 noisy spectral evidence로 다룬다.
2. Low-band context로 observed high-band decoder tokens를 update하고, noisy STFT에 complex filtering을 적용하는 TF-Rehancer architecture를 제안한다.
3. 48 kHz full-band published-reference comparison, 16 kHz quality-efficiency comparison, 48 kHz controlled ablation을 통해 평가한다.

## Chapter 2. Related Work

### 2.1 Full-Band Speech Enhancement

Speech enhancement는 STFT mask estimation에서 phase-aware mask, complex ratio mask, complex-valued network, time-domain network, modern TF-domain modeling으로 발전했다. 하지만 많은 비교는 여전히 16 kHz 또는 protocol-specific setting에 묶여 있다. 48 kHz full-band speech에 있는 upper-band component는 이 평가에서는 input representation 밖에 있다.

고주파 speech information에 대한 perceptual studies도 full-band SE 동기를 뒷받침한다. Conventional wideband range 위쪽의 extended high-frequency cues는 noisy condition에서 speech perception과 fricative cue perception에 기여할 수 있다. 따라서 full-band spectrum이 입력에 이미 존재한다면 upper-band observation을 유지하고 refine하는 것이 타당하다.

BWE와 SR은 missing high-frequency content를 복원하는 문제이고, direct full-band SE는 noisy full-band observation을 denoise/refine하는 문제다. 이 차이가 noisy full-band evidence를 유지하면서 reliable low-band speech structure를 refinement context로 쓰는 architecture를 motivate한다.

### 2.2 Efficient Full-Band Modeling

Practical full-band SE는 real-time/low-complexity constraint 중심으로 연구되어 왔다. PercepNet은 48 kHz speech를 critical-band feature와 comb filtering으로 처리하고, DeepFilterNet2는 ERB-domain enhancement와 deep filtering을 결합한다. 이들은 efficiency를 위해 perceptual/ERB band representation을 사용한다.

Frequency-structured modeling도 중요한 축이다. BSRNN, BS-RoFormer는 band-wise modeling이 high-resolution audio에 효과적임을 보였고, TF-Locoformer는 local convolution 기반 RNN-free TF-domain dual-path architecture를 제안했다. GTCRN, LiSenNet, FastEnhancer는 compact recurrent/subband/frequency-time modeling이 real-time SE에서 performance-efficiency trade-off를 개선함을 보였다.

TF-Rehancer도 frequency compression을 사용한다. Input stem이 learned frequency-strided embedding으로 token count를 줄인다. 차이는 final enhancement가 full-resolution complex filtering을 통해 original noisy STFT에 묶여 있다는 점이다.

### 2.3 Query Refinement and TF Filtering

TF-Restormer는 decoupled input/output sampling rate를 사용하는 speech restoration architecture이며, encoder는 observed input bandwidth에 집중하고 decoder는 frequency extension queries로 target frequency regions를 복원한다. 이는 missing-band restoration에 적합하다.

TF-Rehancer는 direct 48 kHz full-band SE를 다룬다. 여기서 high-band는 missing slot이 아니라 observed noisy evidence다. 따라서 decoder query는 missing-band placeholder가 아니라 observed high-band evidence에서 유도되고, low-band context로 update된다.

Filtering-based enhancement는 observation-preserving view와 잘 맞는다. Latent representation에서 clean spectrum을 직접 생성하는 대신, complex local filters를 추정하고 noisy STFT에 적용한다. TF-Rehancer는 이 원칙을 따라 original noisy STFT에 complex filtering을 적용한다.

Related Work의 결론은 다음이다. Practical full-band systems는 perceptual-band efficiency에 강점이 있고, frequency-structured models는 efficient within-band/band-split modeling에 강점이 있으며, query-based restoration은 missing-band reconstruction에 초점이 있다. TF-Rehancer는 direct full-band SE를 low-band context와 complex filtering으로 해결하려는 위치에 있다.

## Chapter 3. Proposed Method

### 3.1 Problem Formulation

Noisy waveform $y$와 clean waveform $x$는 additive noise $n$을 통해 $y=x+n$으로 표현된다. STFT를 적용하면 noisy/clean complex spectra $Y, X$를 얻는다. Full-band SE의 목표는 noisy full-band observation $Y$로부터 clean full-band spectrum $\hat{X}$를 추정하고 iSTFT로 enhanced waveform $\hat{x}$를 복원하는 것이다.

TF-Rehancer는 observation-preserving filtering formulation을 따른다. Network는 complex local TF filter $W$를 예측하고, 이 filter를 linear noisy STFT reference $Y^{ref}$에 적용해 $\hat{X}$를 얻는다. 즉, 모델은 clean spectrum을 자유롭게 생성하는 direct generator가 아니라, observed noisy spectrum을 변환하는 filter coefficient estimator다.

48 kHz input에서 upper band는 이미 $Y$ 안에 존재하므로, TF-Rehancer는 이 영역을 observed noisy evidence로 다룬다. High-band query feature를 여기서 만들고 decoder에서 refine한 뒤 complex filtering을 수행한다.

### 3.2 TF-Rehancer Architecture

논문은 TF-Rehancer를 네 단계 pipeline으로 설명한다.

1. SFI-STFT conditioning and shared embedding
2. Observed high-band query construction
3. Cross-band decoder refinement
4. Full-resolution complex TF filtering

#### 3.2.1 SFI-STFT Conditioning and Shared Embedding

TF-Rehancer는 TF-Restormer의 sampling-frequency-independent STFT 원칙을 따른다. Window/hop을 sample count가 아니라 physical duration으로 고정한다. 16 kHz에서는 window 640, hop 320, frequency bins 321이고, 48 kHz에서는 window 1920, hop 960, frequency bins 961이다. 이렇게 하면 temporal frame geometry는 sampling rate와 무관하게 유지되고, frequency-bin count만 bandwidth에 따라 증가한다.

Input feature는 power-law compressed complex STFT로 만든다. $\gamma=0.3$을 사용하고, real, imaginary, magnitude channel을 쌓아 $\Phi(Y)$를 만든다. Power-law compression은 spectral amplitude dynamic range를 안정화한다. 다만 final filtering에는 compressed spectrum이 아니라 uncompressed noisy STFT reference $Y^{ref}$를 따로 보존해 사용한다.

Shared stem은 Conv2D, batch normalization, SiLU로 구성되며 frequency axis만 stride 2로 줄인다. Frame rate는 유지한다. 16 kHz에서는 embedded frequency resolution이 161, 48 kHz에서는 481이 된다.

#### 3.2.2 Observed High-Band Query Construction

Shared stem 이후 embedded frequency axis를 5 kHz cutoff로 low band와 high band로 나눈다. 16 kHz에서는 low 101 tokens, high 60 tokens이고, 48 kHz에서는 low 101 tokens, high 380 tokens이다. 즉, low-band encoder length는 sampling rate가 달라도 거의 고정되고, 48 kHz에서는 observed high-band decoder tokens만 크게 늘어난다.

High-band branch는 observed high-band stem feature에서 직접 나온다. High-band adapter는 residual local convolutional block으로, high-band tokens를 decoder query space에 맞추는 lightweight local transformation이다. Adapter 자체가 decoder refinement를 하는 것이 아니라, cross-band refinement 전에 observed high-band query를 준비한다.

Low-band encoder는 $H_{low}$를 $Z$로 mapping한다. 4개의 stacked block을 사용하며, frequency feed-forward layer, frequency-axis self-attention with RoPE, FastGRU2 temporal modeling을 결합한다. Encoder의 역할은 harmonic/formant evidence가 밀집한 low-band speech structure를 modeling하는 것이다.

Encoder frequency module은 F-ConvFFN, F-MHSA, F-ConvFFN 순서의 Macaron-style 구조다. Decoder frequency module은 여기에 cross-attention을 먼저 삽입하여 F-MHCA, F-MHSA, F-ConvFFN 구조를 사용한다.

RoPE는 frequency-axis attention에서 frequency token의 relative order를 encoding한다. 16 kHz와 48 kHz는 token 수가 달라지지만 frequency axis의 물리적 순서는 유지되므로 RoPE가 유용하다. Decoder cross-attention에서는 high-band query와 low-band key/value의 서로 다른 frequency 위치 관계를 보존하는 데 쓰인다.

Efficient convolutional FFN은 frequency sequence를 adaptive average pooling으로 줄인 뒤 grouped gated 1-D convolution을 적용하고 다시 upsample한다. Full-length residual path는 유지하면서 비싼 convolutional correction만 짧은 sequence에서 수행해 cost를 줄인다.

#### 3.2.3 Cross-Band Decoder Refinement

Decoder는 low-band encoder output $Z$와 adapted high-band query $Q_h$를 frequency axis로 concatenate한다. 이후 linear projection과 layer normalization으로 48-channel representation을 24-channel decoder width에 맞춘다.

Decoder input을 low/high로 다시 나누면, MHCA 단계에서는 high-band 부분만 query로 사용하고, key/value는 low-band encoder output $Z$에서 얻는다. Low-band token은 MHCA에서 직접 update되지 않고, high-band token만 low-band context를 받아 update된다.

이후 decoder sequence는 updated high-band와 low-band를 다시 합친 full embedded sequence가 되고, frequency self-attention, frequency feed-forward, FastGRU2 temporal modeling이 전체 sequence에 적용된다. 즉, 먼저 directed low-to-high conditioning을 하고, 그 다음 full-sequence modeling을 수행한다.

역할 분리는 다음과 같다.

- High-band adapter: observed high-band query evidence 준비
- Concat-projection layer: low-band encoder output과 high-band query를 decoder width로 정렬
- Decoder blocks: cross-attention 기반 high-band token update와 full-sequence TF modeling 수행

#### 3.2.4 Complex TF Filtering

Decoder output은 embedded frequency resolution에 있으므로, filter estimation 전에 FastFilterUpsample로 original STFT frequency resolution으로 되돌린다. 이후 partial-convolution filter head와 local $3 \times 3$ TF convolution을 사용해 complex filter coefficients를 예측한다.

각 time-frequency bin마다 local offsets $\Delta f,\Delta t \in \{-1,0,1\}$에 대한 9개 complex taps를 예측한다. Head output은 각 tap의 magnitude scale, real component, imaginary component를 포함한다. Magnitude는 softplus로 positive하게 만들고, real/imaginary는 tanh로 bound한다.

Enhanced spectrum은 예측된 local complex filter $W$를 noisy STFT reference $Y^{ref}$의 local neighborhood에 적용해 계산한다. Boundary는 padding한다.

중요한 해석은 다음이다. 이 operation은 correlation estimate가 아니라 complex filtering이다. Filtering head는 output estimator이고, representation-level contribution은 low-band 기반 full-band refinement이다.

### 3.3 Training Objective

Training loss는 composite enhancement loss다. Input feature와 동일하게 $\gamma=0.3$ power-law compression을 사용한다.

전체 loss는 magnitude MSE, complex MSE, consistency loss, waveform L1 loss, PESQ-like loss의 weighted sum이다.

- $\mathcal{L}_{mag}$: compressed magnitude envelope를 맞춘다. Energy consistency를 돕지만 phase를 직접 supervise하지 않는다.
- $\mathcal{L}_{cplx}$: compressed real/imaginary component를 비교한다. Complex filter output에 phase-sensitive supervision을 제공한다.
- $\mathcal{L}_{cons}$: $\hat{X}$를 iSTFT로 waveform으로 복원한 뒤 다시 STFT를 적용해 clean compressed spectrum과 비교한다. iSTFT 이후에도 spectrum이 일관되도록 penalize한다.
- $\mathcal{L}_{wav}$: waveform L1 loss로 sample-level reconstruction error와 time-domain artifact를 줄인다.
- $\mathcal{L}_{pesq}$: 16 kHz로 resampling한 waveform에 대한 differentiable PESQ-like training loss다. Evaluation PESQ와 동일한 metric이 아니며 weak perceptual regularizer로 사용된다.

Loss weights는 magnitude 0.3, complex 0.2, consistency 0.3, waveform 0.2, PESQ 0.001이다. 따라서 optimization은 spectral reconstruction, reconstruction consistency, waveform supervision이 주도하고 PESQ term은 약하게 작동한다.

## Chapter 4. Experiments

### 4.1 Experimental Setup

평가는 세 축으로 구성된다.

1. 48 kHz full-band results: VBD 48 kHz test set에서 TF-Rehancer와 published full-band references 비교
2. 16 kHz wideband benchmark: official VBD corpus에서 lightweight SE baseline과 비교
3. 48 kHz controlled ablation: full-band processing에서 architecture components 분석

16 kHz comparison은 official VoiceBank+DEMAND paired corpus를 사용한다. Training partition은 28 speakers, 10,413 training utterances와 1,159 validation utterances로 split된다. Evaluation은 unseen speakers가 포함된 official 824 utterance test set에서 수행된다.

Controlled 48 kHz ablation은 VCTK clean speech와 DNS full-band noise를 섞어 noisy mixtures를 만들고, evaluation은 VBD 48 kHz test set에서 수행한다. VBD 48 kHz test set은 official 824-utterance VoiceBank+DEMAND test split을 48 kHz paired clean/noisy files로 준비한 것이며, DNS-remixed test set이 아니다.

기본 model configuration은 40 ms analysis window, 20 ms frame shift를 사용한다. 5 kHz cutoff는 201 full-resolution frequency bins, frequency-strided stem 이후 101 embedded low-band tokens에 해당한다.

Metrics는 full-reference와 non-intrusive를 함께 사용한다. DNSMOS P.808, DNSMOS P.835, SCOREQ, PESQ, STOI, ESTOI는 16 kHz resampling 후 계산한다. SI-SDR은 task sampling rate에서 계산한다. 48 kHz analysis에서는 full-band LSD, MCD, SI-SDR도 보고한다고 설명되어 있으며, 실제 cutoff/architecture ablation tables에는 LSD/MCD가 포함되어 있다.

### 4.2.1 48 kHz Full-Band Results

Table 4.1은 VBD 48 kHz test set에서 PercepNet, DeepFilterNet2, TF-Rehancer (on)를 비교한다. TF-Rehancer (on)는 DNS4-trained online configuration이다.

표의 핵심 수치는 다음이다.

- PercepNet: 8.00M params, 0.80G MACs, PESQ 2.73
- DFN2 + Simplified DNN: 2.31M params, 0.36G MACs, PESQ 3.08, STOI 0.943, CSIG 4.30, CBAK 3.40, COVL 3.70, SI-SDR 15.709
- DFN2 + Post-Filter: 2.31M params, 0.36G MACs, PESQ 3.03, STOI 0.941, CSIG 3.72, CBAK 3.37, COVL 3.63, SI-SDR 15.769
- TF-Rehancer (on): 0.615M params, 3.15G MACs, PESQ 3.233, STOI 0.951, CSIG 4.286, CBAK 3.567, COVL 3.771, SI-SDR 17.789

본문 해석은 다음이다. TF-Rehancer (on)는 listed references보다 PESQ, STOI, CBAK, COVL, SI-SDR이 높다. Simplified DFN2는 CSIG가 약간 더 높고, DFN2 rows는 MACs가 낮다. 단, PercepNet/DFN2 reference values는 대부분 prior papers에서 가져온 것이고 TF-Rehancer는 locally evaluated이므로 strict direct re-evaluation이 아니라 published-reference comparison으로 읽어야 한다.

### 4.2.2 16 kHz Wideband Results

Table 4.2는 16 kHz VoiceBank+DEMAND 결과다. FastEnhancer-M은 paper-reported reference이고, TF-Rehancer rows는 local evaluation이다.

핵심 수치는 다음이다.

- FastEnhancer-M: 0.49M params, 2.90G MACs, P808 3.48, SIG 3.39, BAK 4.02, OVL 3.11, SCOREQ 0.243, SI-SDR 19.40, PESQ 3.24, STOI 0.950, ESTOI 0.873
- TF-Rehancer (on): 0.47M params, 1.89G MACs, P808 3.49, SIG 3.41, BAK 4.04, OVL 3.13, SCOREQ 0.244, SI-SDR 19.44, PESQ 3.33, STOI 0.950, ESTOI 0.872
- TF-Rehancer (off): 0.62M params, 2.00G MACs, P808 3.49, SIG 3.41, BAK 4.06, OVL 3.14, SCOREQ 0.242, SI-SDR 19.72, PESQ 3.40, STOI 0.953, ESTOI 0.876

해석은 다음이다. TF-Rehancer (on)는 FastEnhancer-M보다 similar parameter scale에서 fewer model-side MACs를 사용하고 PESQ, SI-SDR, DNSMOS SIG/BAK/OVL이 높다. FastEnhancer-M은 SCOREQ와 ESTOI에서 약간 더 좋다. TF-Rehancer (off)는 더 큰 parameter/MACs를 쓰며 SCOREQ, PESQ, SI-SDR, STOI, ESTOI, DNSMOS BAK/OVL이 더 좋다.

결론은 uniform dominance가 아니라, compact configuration에서 competitive values를 보이고 non-streaming configuration에서 더 높은 quality metrics를 보인다는 것이다.

### 4.2.3 Low-Band Cutoff

3 kHz부터 8 kHz까지 low-band cutoff를 바꾸어 평가한다. 모든 variant는 같은 model size를 쓰며 VBD 48 kHz test set에서 평가한다.

핵심 해석은 다음이다. Cutoff가 커지면 computation이 증가하고 일부 perceptual score가 좋아질 수 있다. Cutoff가 작아지면 MACs는 줄지만 full-band spectral fidelity, 특히 LSD/MCD가 나빠질 수 있다. 5 kHz는 cost, SI-SDR, full-band spectral metrics 사이에서 balanced operating point로 선택된다.

표에서 5 kHz row는 3.02G MACs, SI-SDR 16.83, PESQ 3.29, STOI 0.947, ESTOI 0.868, LSD 0.72, MCD 2.27이다.

### 4.2.4 Architecture Ablations

Table 4.4는 기본 TF-Rehancer, w/o Decoder MHCA, w/ Direct Mapping을 비교한다.

핵심 수치는 다음이다.

- TF-Rehancer: P808 3.45, SIG 3.38, BAK 3.98, OVL 3.07, SI-SDR 16.70, PESQ 3.29, STOI 0.948, ESTOI 0.868, CSIG 4.40, CBAK 3.59, COVL 3.88, LSD 0.73, MCD 2.28
- w/o Decoder MHCA: P808 3.45, SIG 3.39, BAK 3.96, OVL 3.05, SI-SDR 16.27, PESQ 3.14, STOI 0.944, ESTOI 0.858, CSIG 4.35, CBAK 3.52, COVL 3.77, LSD 0.77, MCD 2.50
- w/ Direct Mapping: P808 3.44, SIG 3.35, BAK 3.96, OVL 3.03, SI-SDR 14.90, PESQ 3.05, STOI 0.940, ESTOI 0.853, CSIG 4.24, CBAK 3.40, COVL 3.66, LSD 0.78, MCD 2.52

해석은 다음이다. Direct mapping head는 complex TF filtering보다 전반적으로 약하다. 따라서 filtering-based output estimation이 proposed architecture에 더 reliable하다. w/o Decoder MHCA는 direct mapping보다 강하지만, 대부분의 full-reference/spectral metrics에서 TF-Rehancer보다 낮다. P808은 rounding 후 tie이고, DNSMOS SIG는 w/o Decoder MHCA가 약간 높다. 따라서 decoder cross-attention은 main full-reference/spectral trend에서 제거하는 것보다 효과적이라고 해석한다.

## Chapter 5. Conclusion

### Summary

본 논문은 computationally controlled full-band processing을 위한 TF-domain speech enhancement architecture인 TF-Rehancer를 제안했다. 핵심은 low-band refinement이다. Low-band speech structure에 heavier modeling을 집중하고, observed upper-band evidence를 decoder path에 유지하며, high-band decoder tokens를 low-band encoder context로 update하고, original noisy STFT에 complex TF filtering을 적용해 enhanced spectrum을 추정한다.

결과 요약은 다음이다.

1. 48 kHz VoiceBank+DEMAND 결과에서 DNS4-trained online TF-Rehancer configuration은 published PercepNet/DeepFilterNet2 references와 비교해 competitive full-reference scores를 보였다.
2. 16 kHz VoiceBank+DEMAND benchmark에서 compact FastGRU-based setting은 paper-reported FastEnhancer-M reference보다 similar parameter scale에서 fewer model-side MACs를 사용하고 PESQ, SI-SDR, DNSMOS P.835 values가 더 높다. FastEnhancer-M은 SCOREQ와 ESTOI에서 약간 더 좋다.
3. Controlled 48 kHz ablation에서 direct spectrum mapping은 complex TF filtering보다 나빴다. 이는 filtering-based output estimation이 proposed architecture에 더 reliable하다는 근거다.
4. Decoder MHCA ablation은 decoder cross-attention이 제거한 것보다 main full-reference/spectral trends에서 더 효과적임을 보인다.
5. Low-band cutoff analysis는 5 kHz가 computational cost, waveform fidelity, full-band spectral fidelity 사이의 balanced operating point임을 보인다.

전체적으로 결과는 low-band 기반 full-band refinement가 full-band speech enhancement에서 computationally controlled design direction이 될 수 있음을 지지한다.

### Limitations and Future Work

48 kHz comparison에는 paper-reported full-band references가 포함되어 있고, TF-Rehancer는 locally evaluated이다. 따라서 더 강한 external full-band claim을 위해서는 locally re-evaluated baselines와 fully aligned protocol이 필요하다.

48 kHz ablation은 controlled component analysis를 위한 것이며, external system ranking 목적이 아니다. 향후에는 TF-Rehancer와 competing full-band systems를 shared training/evaluation protocol, aligned metric computation, runtime measurement 아래 비교해야 한다.

Architecture 측면에서도 남은 문제가 있다. 현재 ablation은 complex TF filtering과 decoder MHCA의 효과는 보여주지만, lightweight high-band adaptation과 subsequent decoder refinement의 기여를 완전히 분리하지는 않는다. High-band adapter를 제거하거나 대체하면서 observed high-band embedding은 유지하는 focused ablation이 필요하다.

또한 5 kHz cutoff는 현재 48 kHz ablation setting에서 balanced point로 선택된 것이다. 더 넓은 datasets, noise conditions, sampling rates에서는 adaptive 또는 data-dependent cutoff strategy가 필요할 수 있다.

마지막으로 practical deployment를 위해 model-side MACs를 넘는 validation이 필요하다. Real-time runtime profiling, latency analysis, device-oriented scenarios 평가가 필요하고, multi-channel 또는 reverberant conditions로 확장할 수 있다.

## 빠른 피드백 체크 포인트

1. **Title/body 용어 불일치**
   - 영문 제목은 `Low-Band-Conditioned Refinement`.
   - 국문 제목은 아직 `저대역 유도 정제`.
   - Abstract, Chapter 1--5 본문 핵심 표현은 아직 `low-band-guided full-band refinement`가 많이 남아 있다.
   - 최종 방향이 `conditioned`라면 제목, abstract, 본문 핵심 phrase를 `low-band-conditioned`로 통일하는 것이 맞다.

2. **48 kHz Table 4.1과 spectral metric 설명**
   - Table 4.1에서는 LSD/MCD를 최종 제거했다.
   - Chapter 4 metric section은 48 kHz analysis에서 LSD/MCD를 report한다고 말한다. 이는 cutoff/architecture ablation tables에는 맞지만 Table 4.1에는 해당하지 않는다.
   - 이상하게 읽히면 “For controlled 48 kHz ablations, we additionally report...”처럼 범위를 좁히는 것이 더 깔끔하다.

3. **Table 4.1 comparison 성격**
   - 본문은 published-reference comparison이라고 caveat를 둔다.
   - 이 방어선은 안전하다. Strict same-protocol ranking처럼 읽히지 않는다.

4. **Decoder MHCA claim**
   - 현재 표현은 “main full-reference/spectral trends에서 제거하는 것보다 효과적”이다.
   - P808 tie, SIG slight advantage for no-MHCA를 같이 언급하므로 과한 claim은 아니다.

5. **Low-band adapter/query contribution**
   - Conclusion limitation에서 high-band adapter contribution을 별도 isolate하지 못했다고 인정한다.
   - 이 부분은 논리적으로 안전하지만, main novelty가 high-band query 쪽이라면 reviewer가 evidence gap으로 볼 수 있다.
