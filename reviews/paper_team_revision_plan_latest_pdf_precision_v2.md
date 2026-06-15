# Latest Thesis Draft Revision Plan — High-Band Refinement Precision Pass

작성 목적: 최신 업로드 PDF 기준으로 writer에게 전달할 **정밀 수정 지침**이다.  
핵심은 TF-Rehancer의 refinement mechanism을 더 이상 “low-band evidence가 full-band를 막연히 refine한다”로 쓰지 않게 고정하는 것이다. 정확한 구조는 다음과 같다.

```text
1. Shared stem produces embedded full-band representation.
2. Low-band tokens go through the encoder and produce Z.
3. High-band tokens are converted into observed high-band query Q_h through a lightweight local adapter.
4. Decoder input is formed by concatenating Z and Q_h along frequency and projecting to decoder width.
5. In the cross-attention sublayer, only the high-band decoder tokens are updated.
   Q = projected high-band decoder tokens
   K,V = projected low-band encoder output Z
6. The updated high-band tokens are concatenated back with the low-band decoder tokens.
7. Frequency-axis self-attention and following modules then operate on the full embedded sequence.
8. The final full-resolution complex filter is estimated and applied to the original noisy STFT.
```

따라서 정확한 논문 framing은:

> low-band encoder-guided **high-band token update**, followed by **full-band decoder modeling** and complex TF filtering.

아래 표현은 피해야 한다.

```text
low-band evidence refines the full band
low-band reconstructs high band
high-band is generated from low-band
query is empty / learned missing-band token
HBR is the main contribution
```

---

## 1. Global Terminology and Claim Boundary

### 1.1 제목 유지

현재 제목은 유지한다.

```text
Full-Band Speech Enhancement via Low-Band-Conditioned Refinement
```

단, 본문에서 “Low-Band-Conditioned Refinement”의 의미를 정확히 풀어야 한다.  
그 의미는 **low-band encoder output이 high-band decoder token update를 condition하고, 이후 full-band decoder sequence를 self-attention으로 modeling한다**는 뜻이다.

### 1.2 “full-band refinement” 표현 사용 조건

`full-band decoder refinement`는 사용할 수 있다. 다만 그것만 쓰면 writer가 low-band가 full-band 전체를 직접 refine한다고 오해할 수 있다.

권장 표현:

```text
low-band encoder-guided high-band token update followed by full-band decoder modeling
```

또는 더 compact하게:

```text
low-band-conditioned high-band refinement and subsequent full-band decoder modeling
```

### 1.3 “matched-rate” 표현 제거

최신 PDF Method에 `matched-rate 16 kHz and 48 kHz speech enhancement` 같은 표현이 보인다. 이 표현은 이전에 폐기한 `matched 48 kHz SE`와 같은 계열로 읽힐 수 있다.

수정:

```text
same-input-output sampling-rate 16 kHz and 48 kHz speech enhancement
```

또는 더 자연스럽게:

```text
16 kHz and 48 kHz speech enhancement settings where input and target share the same sampling rate
```

더 간단히는 그냥:

```text
16 kHz and 48 kHz speech enhancement settings
```

---

## 2. Abstract Revision

### 2.1 `online-friendly` 대신 `low-computation` 사용

사용자 선택에 따라 Abstract에서는 `online-friendly`보다 `low-computation TF-Rehancer configuration`을 사용한다.

현재 최신 PDF Abstract에 남아 있는 표현:

```text
online-friendly TF-Rehancer configuration
```

수정:

```text
low-computation TF-Rehancer configuration
```

`online-friendly/offline` terminology는 Chapter 4 caption에서는 유지 가능하지만, Abstract에서는 결과 claim이 과하게 보일 수 있으므로 `low-computation`이 더 안전하다.

### 2.2 Abstract의 method summary를 더 정확히 수정

현재 Abstract의 핵심 문장:

```text
low-band encoder-guided refinement of observed high-band query features
```

이 표현은 high-band query만으로 좁아질 수 있다. 아래로 바꾼다.

권장:

```text
low-band encoder-guided high-band token update followed by full-band decoder modeling
```

Abstract method sentence 추천안:

```text
TF-Rehancer uses sampling-frequency-independent STFT analysis, power-law compressed complex spectral conditioning, low-band encoder-guided high-band token update followed by full-band decoder modeling, and local complex time-frequency filtering over the original noisy STFT.
```

### 2.3 FastEnhancer-M 비교는 Option A 유지

사용자 선택에 따라 Abstract에서는 paper-reported FastEnhancer-M reference를 유지한다. 다만 same-evaluator ranking이 아님을 분명히 한다.

권장 문장:

```text
Against the paper-reported FastEnhancer-M reference, the low-computation TF-Rehancer configuration reports higher PESQ, SI-SDR, and DNSMOS P.835 values with fewer model-side MACs, while this comparison is interpreted as benchmark context rather than a same-evaluator ranking.
```

---

## 3. Introduction Revision

### 3.1 Attention viewpoint must be precise

현재 Introduction에 attention 관점 설명이 들어간 것은 좋다. 그러나 “decoder-side full-band representation serves as the query”라고만 쓰면 실제 구현의 high-token-only cross-attention과 약간 충돌할 수 있다.

정확한 문장:

```text
From the attention perspective, the decoder first forms a full embedded sequence by concatenating the low-band encoder output and the observed high-band query feature. In the cross-attention sublayer, only the high-band segment of this decoder sequence is used as the query, while the low-band encoder output provides the key-value context. The updated high-band tokens are then concatenated back with the low-band decoder tokens, and the following self-attention module models the full embedded sequence.
```

이 문장을 Introduction에 너무 길게 넣기 부담스러우면, Introduction에는 짧게 두고 Method 3.2.3에 완전한 버전을 넣는다.

Introduction용 compact version:

```text
In the decoder, the observed high-band tokens are updated by cross-attending to the low-band encoder output, which serves as the key-value context. The updated high-band tokens are then modeled together with the low-band tokens by full-sequence self-attention.
```

### 3.2 Contribution 문장 수정

현재 contribution이 “observed high-band decoder queries” 중심으로 읽히는 경우 아래처럼 고친다.

추천:

```text
We propose TF-Rehancer, a TF-domain architecture that updates observed high-band decoder tokens using low-band encoder context, models the resulting full embedded sequence, and estimates the enhanced spectrum through complex filtering over the noisy STFT.
```

### 3.3 Figure 1.1 caption 교체

현재 caption은 “refines an observed high-band query”로 너무 압축되어 있다. 아래처럼 고친다.

권장 caption:

```text
Figure 1.1: Conceptual overview of TF-Rehancer. The low-band encoder produces key-value context, while the observed high-band representation forms decoder-side query tokens. Cross-attention updates only the high-band tokens, after which full-sequence decoder modeling and local complex filtering estimate the enhanced spectrum from the original noisy STFT.
```

이 caption은 reviewer가 질문할 수 있는 “Q/K/V가 정확히 무엇인가?”를 바로 막아준다.

---

## 4. Related Work Revision

### 4.1 목차는 사용자 지정안으로 맞춘다

최신 PDF의 Related Work 목차가 다음처럼 되어 있다.

```text
2.1 Full-Band Speech Enhancement
2.2 Efficient Full-Band Modeling
2.3 Query Refinement and TF Filtering
```

사용자 선택을 반영하면 아래가 더 적절하다.

```text
2.1 Wideband SE and the Observed Gap
2.2 Full-Band Speech Enhancement
2.3 Query-Based Modeling Method
```

다만 2.3 제목은 조금 더 자연스럽게는 아래도 가능하다.

```text
2.3 Query-Based Modeling and TF Filtering
```

`Query-Based Modeling Method`는 다소 직역 느낌이 있으므로, paper style에서는 `Query-Based Modeling and TF Filtering`을 추천한다.

### 4.2 2.3은 유지하되 contribution을 약화시키지 않게 축소

2.3을 완전히 제거하면 TF-Restormer에서 착안한 query mechanism과 filtering-based output에 대한 연결이 약해진다.  
하지만 너무 길면 “이미 query refinement 선행연구가 내 contribution을 거의 했다”처럼 읽힐 수 있다.

따라서 2.3은 유지하되, 다음 역할만 수행하게 한다.

1. TF-Restormer는 missing-band restoration에서 query를 사용했다.
2. TF-Rehancer는 missing-band query가 아니라 observed high-band decoder token update로 재해석한다.
3. Deep filtering 계열은 direct mapping이 아니라 noisy STFT에 filter를 적용하는 output formulation을 제공한다.
4. TF-Rehancer는 이 둘을 direct full-band SE 정보 조건에 맞게 결합한다.

### 4.3 SFI-STFT는 Related Work에서 줄인다

최신 PDF 2.3에 SFI-STFT 설명이 들어가 있다. SFI-STFT는 TF-Restormer에서 온 frontend principle이지만, 이 논문의 related-work 핵심은 아니다. Related Work에서 길게 설명하면 논점이 흐려진다.

수정 방향:

- Related Work 2.3의 SFI-STFT paragraph는 삭제하거나 한 문장으로 줄인다.
- 자세한 설명은 Method 3.2.1에 둔다.

Related Work용 한 문장:

```text
TF-Restormer also motivates the use of sampling-frequency-independent STFT parameterization, which we adopt as a frontend design and describe in Section 3.2.1.
```

Method에는 현재처럼 40 ms / 20 ms와 16 kHz/48 kHz bin 수를 설명하면 된다.

---

## 5. Method Section: Critical Fixes

## 5.1 3.2.1 SFI-STFT Conditioning

### 5.1.1 `matched-rate` 제거

현재 문장:

```text
matched-rate 16 kHz and 48 kHz speech enhancement
```

수정:

```text
16 kHz and 48 kHz speech enhancement settings where the input and target share the same sampling rate
```

또는:

```text
same-sampling-rate 16 kHz and 48 kHz speech enhancement settings
```

### 5.1.2 shared stem 설명은 충분하지만 “local information retained” claim은 조심

현재 shared stem은 F-stride compression을 수행한다. 그러므로 “high-band bin-level observation is preserved”처럼 쓰면 안 된다.

안전 표현:

```text
The shared stem compresses the frequency axis for efficient modeling while deriving high-band decoder tokens from the observed high-band portion of the input representation.
```

---

## 5.2 3.2.2 Observed High-Band Query

현재 설명은 대체로 좋다. 다만 아래 문장을 유지해야 한다.

```text
The adapter does not perform decoder refinement by itself; it prepares the high-band tokens for the decoder.
```

이 문장은 HBR이 main contribution으로 오해되는 것을 막는다.

추가하면 좋은 문장:

```text
The query source remains the observed high-band embedding; the adapter only provides a lightweight local transformation before cross-band refinement.
```

---

## 5.3 3.2.3 Cross-Band Refinement: 반드시 더 정확히 써야 함

최신 PDF의 3.2.3은 좋아졌지만, writer가 여전히 헷갈릴 수 있다. 아래 replacement block을 거의 그대로 넣는 것을 추천한다.

### Recommended replacement paragraph

```text
The decoder first forms a full embedded sequence by concatenating the low-band encoder output Z and the adapted high-band query Q_h along the frequency axis. A projection layer maps the concatenated representation to the decoder width. Let the projected decoder sequence be D = [D_low; D_high], where D_high corresponds to the observed high-band portion. In the cross-attention sublayer, only D_high is updated. The high-band tokens provide the query, while the low-band encoder output Z provides the key and value context:
```

수식:

```text
Q = Π_q(D_high),   K = Π_k(Z),   V = Π_v(Z),
D_high' = D_high + MHCA(Q,K,V).
```

이어지는 문장:

```text
The updated high-band tokens D_high' are concatenated back with D_low. The subsequent frequency-axis self-attention and convolutional feed-forward modules are then applied to the full embedded sequence. Thus, cross-attention performs directed low-to-high conditioning, whereas the following self-attention stage performs full-band decoder modeling.
```

이 표현이 가장 중요하다.

### 금지 표현

```text
low-band evidence refines the full band
low-band reconstructs high-band speech
full-band query is directly refined by low-band context
```

정확한 표현:

```text
low-band context updates the high-band segment of the decoder sequence; the resulting full sequence is then modeled by self-attention.
```

---

## 5.4 Macaron-style frequency module 설명 추가

현재 Figure 3.3 caption에는 `F-ConvFFN`, `F-MHSA`, `F-MHCA`가 보이지만, 본문 설명은 부족하다.  
Macaron-style block의 의도를 설명해야 한다.

추가 위치: 3.2.2 low-band encoder 설명 직후 또는 3.2.3 decoder 설명 직후.

추천 문장:

```text
Both encoder and decoder frequency modules follow a macaron-style structure, where a convolutional feed-forward layer is placed before and after the attention module. In the encoder, the frequency module uses F-ConvFFN -> F-MHSA -> F-ConvFFN. In the decoder, the frequency module adds cross-attention before full-sequence self-attention. This design lets local spectral transformations and global frequency-token interaction complement each other within each block.
```

Decoder용 조금 더 정확한 문장:

```text
In the decoder, F-MHCA first injects low-band context into the high-band tokens, and the following F-MHSA operates on the full embedded sequence. The surrounding ConvFFN layers provide local nonlinear spectral transformation before and after attention-based mixing.
```

---

## 5.5 RoPE 설명 추가

현재 RoPE가 Figure 3.3과 문장에만 나오고, 왜 쓰는지 설명이 부족하다. RoPE는 짧게라도 설명해야 한다.

추가 위치: 3.2.2 encoder block 설명 또는 3.2.3 decoder block 설명.

추천 문장:

```text
RoPE is used in frequency-axis attention to provide relative frequency-position information without introducing a learned absolute positional table. This is useful for the SFI-STFT setting because the number of frequency tokens changes with sampling rate, while the frequency order remains physically meaningful.
```

더 보수적으로:

```text
RoPE gives the attention module an ordered frequency-axis bias while avoiding a fixed learned positional embedding tied to a specific number of frequency bins.
```

이 설명은 reviewer가 “왜 RoPE?”라고 물었을 때 최소 답이 된다.

---

## 5.6 Efficient ConvFFN 설명 추가

현재 ConvFFN 설명이 충분하지 않다. Figure 3.3 확대도에는 grouped convolution이 보이지만 본문이 따라오지 않는다.  
사용자가 설계한 경량 FFN 의도를 분명히 써야 한다.

추가 위치: 3.2.2 또는 3.2.3의 block 설명 후.

추천 paragraph:

```text
The F-ConvFFN is designed as a lightweight alternative to applying a large convolutional FFN at the original frequency-token length. It first reduces the frequency-axis sequence length, applies grouped gated convolution at the reduced length, and then restores the original frequency length. The gated convolution uses grouped convolution with g=2 to reduce computation while retaining local spectral nonlinearity. This structure lowers the cost of the FFN part of the frequency module, which is important because the decoder operates on the full embedded frequency sequence in the 48 kHz setting.
```

더 간결한 paper style:

```text
To reduce the cost of frequency-axis feed-forward processing, F-ConvFFN first downsamples the frequency-token sequence, applies a grouped gated convolution at the reduced length, and then upsamples it back to the original length. The grouped convolution with g=2 reduces computation while preserving local spectral transformation capability.
```

이 내용은 Method detail로 꼭 들어가야 한다. 현재 원고만 보면 `F-ConvFFN`이 무엇인지 reviewer가 충분히 이해하기 어렵다.

---

## 5.7 Figure 3.3 caption 보완

현재 caption은 좋지만, module detail을 더 정확히 드러내려면 아래처럼 수정한다.

추천 caption:

```text
Figure 3.3: TF-Rehancer encoder and decoder core blocks. The frequency module follows a macaron-style ConvFFN-attention-ConvFFN design. The encoder uses F-MHSA with RoPE, while the decoder first applies F-MHCA to update high-band tokens using low-band encoder context and then applies F-MHSA over the full embedded sequence. The F-ConvFFN uses lightweight grouped gated convolution at reduced frequency length.
```

caption이 너무 길면 마지막 문장은 본문으로 옮겨도 된다.

---

## 5.8 Complex TF Filtering section

현재 3.2.4는 대체로 좋다. 다만 마지막 문장:

```text
the main representation-level contribution lies in low-band-guided decoder refinement of observed high-band evidence
```

이것은 약간 좁다. high-band evidence만이 아니라 high-band update 후 full-sequence modeling까지 포함해야 한다.

수정:

```text
the main representation-level contribution lies in low-band encoder-guided high-band token update followed by full-band decoder modeling.
```

또는:

```text
the main representation-level contribution lies in low-band-conditioned high-band refinement and subsequent full-band decoder modeling.
```

---

## 6. Figure and Caption Corrections

### 6.1 Figure 1.1

현재 caption:

```text
The model analyzes low-band speech evidence and refines an observed high-band query before local complex filtering and waveform reconstruction.
```

문제: 너무 단순하다. high-band query update 이후 full-band decoder modeling이 빠져 있다.

교체:

```text
Figure 1.1: Conceptual overview of TF-Rehancer. The low-band encoder provides key-value context, and the observed high-band representation forms decoder-side query tokens. Cross-attention updates the high-band tokens, after which the full embedded sequence is modeled and used to estimate local complex filters over the original noisy STFT.
```

### 6.2 Figure 3.1

현재 caption은 대체로 괜찮다. 다만 “the decoder refines the full-band representation”만 쓰면 low-band가 full-band를 바로 refine하는 것처럼 보일 수 있다.

수정:

```text
Figure 3.1: Overall TF-Rehancer architecture. The shared input layer produces an embedded full-band representation. The low-band region is encoded by the TF encoder, and the observed high-band region is carried as decoder-side query evidence. Decoder cross-attention updates the high-band tokens using the low-band encoder output, and subsequent full-sequence decoder modeling produces features for complex TF filter estimation.
```

### 6.3 Figure 3.4

현재 caption은 충분히 명확하다. 유지 가능.

---

## 7. Chapter 4 Notes

현재 Chapter 4는 claim을 낮춰 잘 작성되어 있다. 다만 Abstract/Conclusion과 용어를 맞춘다.

### 7.1 on/off terminology

Chapter 4의 `(on)` / `(off)` labels는 유지 가능하다. 하지만 caption의 caveat는 유지한다.

권장 caption fragment:

```text
The on/off labels distinguish model configurations and do not indicate measured real-time or streaming performance.
```

### 7.2 48 kHz ablation limitation 유지

Chapter 4의 다음 제한은 반드시 유지한다.

```text
These experiments are intended for controlled component analysis, not for ranking against external full-band systems.
```

### 7.3 cutoff order 유지

현재 order와 table 구성 유지.

### 7.4 LSD-H 제외 유지

사용자 선택에 따라 LSD-H와 LSD가 너무 비슷하면 제외 가능. 단, table에서 LSD-H를 제거했다면 metric section과 conclusion에서도 언급하지 않아야 한다.

---

## 8. Chapter 5 Alignment

Chapter 5는 현재 대체로 안전하다. 다만 Method 표현 수정에 맞춰 아래 표현으로 통일한다.

현재 혹은 유사 표현:

```text
low-band encoder-guided full-band decoder refinement
```

유지 가능하지만, 필요 시 더 정확히:

```text
low-band encoder-guided high-band token update followed by full-band decoder modeling
```

Limitations에서 direct query-source ablation은 아래처럼 유지한다.

```text
Further isolating the lightweight high-band adaptation from the subsequent decoder refinement would clarify this component, for example by removing or replacing the local high-band adapter while preserving the observed high-band embedding.
```

이 표현은 observed high-band path 자체를 흔들지 않기 때문에 안전하다.

---

## 9. Writer Checklist

### 반드시 고칠 것

- [ ] Abstract의 `online-friendly`를 `low-computation`으로 수정.
- [ ] Introduction과 contribution에서 “low evidence refines full band” 식 표현 제거.
- [ ] Cross-attention mechanism을 `D_high query`, `Z key/value`, `high-token-only update`, `then full-sequence MHSA`로 명확히 설명.
- [ ] Figure 1.1 caption 수정.
- [ ] Figure 3.1 caption 수정.
- [ ] 3.2.3에 Q/K/V projection and high-token-only update 수식 추가.
- [ ] Macaron-style `ConvFFN -> MHSA -> ConvFFN` 설명 추가.
- [ ] RoPE를 왜 쓰는지 설명 추가.
- [ ] Efficient ConvFFN의 frequency downsampling, grouped gated convolution, upsampling 구조 설명 추가.
- [ ] `matched-rate` 표현 제거.
- [ ] SFI-STFT 설명은 Related Work에서 줄이고 Method에 집중.
- [ ] 3.2.4 마지막 contribution sentence를 high-band update + full-band decoder modeling으로 수정.

### 유지할 것

- [ ] 제목 유지.
- [ ] 16 kHz comparison은 benchmark context로 유지.
- [ ] 48 kHz experiments는 controlled component analysis로 유지.
- [ ] Complex filtering이 direct mapping보다 안정적이라는 ablation 해석 유지.
- [ ] MHCA는 uniformly beneficial이 아니라 trade-off를 바꾼다는 해석 유지.
- [ ] 5 kHz cutoff는 optimal이 아니라 balanced operating point로 유지.
