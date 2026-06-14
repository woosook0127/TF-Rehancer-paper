# Chapter 3 Draft v8 Paper-Ready Review

대상:

- `/home/wooseok/project/TF_Renhancer/project_analysis/paper/ch3_draftv8.md`

판정:

- 기술 정합성: 대체로 통과
- 논문 본문 완성도: 아직 부족
- 핵심 문제: method narrative가 구현 설명에 끌려가고, contribution이 `observed high-band query`와 `HBR adapter` 쪽으로 흩어진다

## 1. 가장 큰 문제

현재 Chapter 3는 "논문 method section"보다 "architecture implementation note"에 가깝다.

문제는 수식이 많아서가 아니다. 문제는 수식과 shape 설명이 논리 전개를 밀어내고 있다는 점이다.

현재 독자가 읽는 흐름:

```text
STFT tensor shape
compressed input
stem shape
low/high slicing shape
encoder shape
decoder shape
query shape
MHCA projection shape
upsample shape
filter head shape
loss details
```

논문에서 보여야 하는 흐름:

```text
Full-band SE is expensive if all full-band tokens are encoded.
TF-Rehancer encodes stable low-band structure with the heavy encoder.
Observed high-band evidence is kept in the decoder path.
The low-band encoder output guides full-band decoder refinement.
The final spectrum is estimated by complex TF filtering over the original noisy STFT.
```

이 흐름이 지금은 보이지만, 너무 늦게 보이고 너무 많이 반복된다.

## 2. Section 구조 수정

현재 구조:

```text
3.1 Problem Formulation
3.2 TF-Rehancer Architecture
3.3 Low-to-High Embedded Query Refinement
3.4 Full-Resolution Complex TF Filtering
3.5 Training Objective
```

수정 권장:

```text
3.1 Problem Formulation
3.2 Overview of TF-Rehancer
3.3 Low-Band-Guided Full-Band Decoding
3.4 Full-Resolution Complex TF Filtering
3.5 Training Objective
```

핵심: `Low-to-High Embedded Query Refinement`라는 제목을 버려라.

이 제목은 논문 기여를 high-band query/HBR 쪽으로 몰아간다. 네가 말한 contribution은 HBR이 아니라 "encoder output으로 full-band decoder representation을 refine하는 것"이다.

더 나은 제목:

- `Low-Band-Guided Full-Band Decoding`
- `Low-Band-Guided Decoder Refinement`
- `Full-Band Decoder Refinement from Low-Band Encoding`

가장 추천:

```text
3.3 Low-Band-Guided Full-Band Decoding
```

## 3. 3.1 Problem Formulation 수정

### 문제

3.1에 batched real-imaginary tensor shape가 너무 빨리 나온다.

현재 line 17-23:

```text
In implementation, we use a batched real-imaginary tensor representation...
```

이건 problem formulation이 아니라 implementation detail이다. 초반에 독자의 집중을 끊는다.

### 수정

3.1에서는 complex STFT와 filtering formulation만 남겨라.

삭제 또는 3.2로 이동:

```text
In implementation, we use a batched real-imaginary tensor representation...
Unless a batched tensor shape is explicitly required...
```

권장 3.1 흐름:

```text
Let y and x be noisy and clean waveforms. Their STFTs are Y and X.
The model estimates X_hat by predicting a local complex filter W and applying it to Y.
This separates neural estimation from signal reconstruction: the network predicts a filter, not a clean spectrum directly.
```

### 5 kHz 설명 위치

line 34의 low/high split 설명은 3.1보다 3.2 overview가 맞다.

3.1은 problem formulation이다. architecture design motivation까지 넣으면 section이 흐려진다.

수정:

- 3.1에서는 `W = G(Phi(Y))`, `X_hat = W otimes Y`까지만.
- low/high split은 3.2 첫 부분으로 이동.

## 4. 3.2 Overview 수정

### 문제

3.2는 architecture overview인데 shape가 너무 많고 반복된다.

특히 다음은 본문에서 과하다.

- line 60-64: input tensor shape 재등장
- line 94-96: H shape
- line 100-106: slicing index detail
- line 112-115: Z shape
- line 120-122: D0 shape
- line 126-128: D_emb shape
- line 134-135: D_full shape

모든 shape가 틀린 것은 아니다. 하지만 전부 본문에 있으면 method가 코드 설명처럼 읽힌다.

### 수정 원칙

본문에는 중요한 세 shape만 남겨라.

1. input feature `Phi(Y)`
2. low/high split concept
3. final full-resolution decoder feature before filter

나머지 detailed tensor shape는 appendix 또는 architecture note로 넘겨라.

### flow diagram

line 40-58의 arrow diagram은 나쁘지 않다. 하지만 `Z, Q_h -> D_emb`가 너무 압축되어 cross-attention의 의미가 안 보인다.

권장:

```text
Phi(Y) -> shared frequency stem -> low/high embedded tokens.
Low-band tokens are encoded by the TF encoder.
High-band tokens remain in the decoder path as observed upper-band evidence.
The decoder refines the full embedded sequence using the low-band encoder output and then predicts a full-resolution complex TF filter.
```

수식 flow는 유지해도 되지만, prose가 먼저 와야 한다.

## 5. 3.3 제목과 본문 대수정

### 문제 1: 제목이 contribution을 흐린다

`Low-to-High Embedded Query Refinement`는 어색하고 좁다.

이 제목은 "고주파 query를 refine하는 module"처럼 보인다. 하지만 논문 contribution은 더 넓다.

수정:

```text
## 3.3 Low-Band-Guided Full-Band Decoding
```

### 문제 2: HBR adapter 설명이 너무 강조된다

line 144-150은 HBR 설명이 길다.

현재 문장:

```text
This residual design is important because the query is neither an empty learned token nor a generated high-band placeholder.
```

문제:

- 방어적이다.
- related work와 싸우는 문장처럼 보인다.
- 논문 method 본문에서 부자연스럽다.
- HBR을 필요 이상으로 중요한 module처럼 보이게 한다.

권장 수정:

```text
The high-band decoder tokens are initialized from the observed high-band embedding. A lightweight residual adapter is applied only to provide local conditioning before decoding:
Q_h = H_high + Adapter_h(H_high).
Because Q_h is computed from the noisy observation, the decoder preserves upper-band evidence instead of relying on learned placeholder tokens.
```

더 짧게:

```text
The high-band decoder tokens are initialized from the observed high-band embedding and lightly adapted with a residual local convolution. This keeps upper-band evidence in the decoder path before low-band-guided refinement.
```

### 문제 3: cross-attention 설명이 너무 projection 중심

line 164-184는 projection detail이 길다.

논문 독자는 `Pi_q`, `Pi_k`, `Pi_v`보다 "무엇이 무엇을 refine하는가"가 중요하다.

권장:

```text
Only the high-band part of the decoder sequence attends to the low-band encoder output in this stage:

D_high' = D_high + MHCA(D_high, Z, Z).

The low-band decoder tokens are then concatenated back with the updated high-band tokens, and the following decoder self-attention operates over the full embedded frequency sequence.
```

projection matrices 설명은 삭제해도 된다. 필요하면 한 문장:

```text
The query, key, and value projections are learned inside MHCA.
```

### 문제 4: "only high-band updated"와 main contribution 충돌

현재 line 158:

```text
only the high-band decoder tokens are updated using the low-band encoder representation
```

이건 구현상 맞아도, 너무 앞에 놓으면 "전체 대역 refinement" 기여를 약화한다.

수정 방향:

```text
The decoder first injects low-band encoder information into the observed high-band tokens through cross-attention. The following full-sequence decoder block then refines the complete embedded frequency representation.
```

이렇게 써야 "high-band만 조금 만지는 구조"가 아니라 "full-band decoder refinement"로 읽힌다.

## 6. 3.4 Filtering section

3.4는 가장 좋다. 살려도 된다.

다만 activation detail이 조금 구현 설명처럼 보인다.

현재:

```text
The output is interpreted as one positive scale component and two bounded real-imaginary components...
```

괜찮다. 이건 filter parameterization이라 method 본문에 남길 수 있다.

수정 권장:

- `Boundary bins are handled by padding...`는 짧게 유지하거나 appendix로 보냄.
- `This encourages the network...` 문장은 좋지만 "encourages"가 약간 추상적이다.

권장:

```text
This formulation makes the enhanced spectrum an explicit local transformation of the observed noisy spectrum, rather than an unconstrained direct prediction from decoder features.
```

이 문장이 더 논문스럽다.

## 7. 3.5 Training Objective

### 문제 1: loss weight는 Method보다 Experiments에 가까움

loss form은 Method에 필요하다. 하지만 exact weight는 training setup에 더 가깝다.

둘 중 하나 선택:

1. Method에 그대로 둔다면 짧게 유지
2. weight는 Chapter 4 setup으로 이동

논문 method가 길면 weight는 Chapter 4로 보내는 게 낫다.

### 문제 2: implementation 표현 제거

line 265:

```text
used in implementation and omitted from the notation
```

수정:

```text
We use an epsilon-stabilized magnitude in all compressed-spectrum terms.
```

line 307:

```text
All squared spectral losses are implemented as mean-squared errors...
```

수정:

```text
We average the squared spectral losses over all time-frequency bins and channels.
```

line 331:

```text
to match the PESQ loss implementation
```

수정:

```text
The PESQ auxiliary term is evaluated on 16 kHz resampled waveforms and is used only as a weak auxiliary signal.
```

### 문제 3: "For configurations using PESQ"가 내부 실험 냄새

현재:

```text
For configurations using the PESQ auxiliary term...
```

논문 본문에서는 final method를 말해야 한다.

수정:

```text
We include a small PESQ auxiliary term,
...
```

만약 실험마다 PESQ 사용 여부가 다르면 Chapter 4 ablation에서 말해라. Method 본문에서는 final training recipe만 서술하는 게 낫다.

## 8. 삭제해야 할 표현 목록

다음 표현은 paper 본문에서 줄이거나 삭제해라.

### implementation 냄새

- `In implementation`
- `Unless a batched tensor shape is explicitly required`
- `used in implementation and omitted from the notation`
- `loss implementation`
- `implemented as`

### 방어적 표현

- `neither an empty learned token nor a generated high-band placeholder`
- `rather than high-band generation from an empty query`

이 표현들은 related work/rebuttal 느낌이다. Method 본문에서는 더 자연스럽게 쓰면 된다.

### 반복되는 contribution 표현

현재 너무 많이 나온다.

- filtering-based refinement
- observed high-band query
- decoder-side observed query representation
- low-to-high refinement
- directed low-to-high refinement

핵심 용어를 하나로 통일해라.

추천 용어:

```text
low-band-guided full-band decoder refinement
```

이 용어를 main phrase로 쓰고, `observed high-band tokens`는 보조 설명으로만 써라.

## 9. 가장 중요한 rewrite 방향

Chapter 3 첫머리에서 독자가 잡아야 할 한 문장:

```text
TF-Rehancer reduces full-band modeling cost by encoding only low-band speech structure with the heavy encoder, preserving observed upper-band evidence in the decoder path, and refining the full-band representation before applying a full-resolution complex TF filter.
```

이 문장을 3.2 초반에 넣어라.

지금 원고는 이 메시지가 여러 곳에 흩어져 있다.

## 10. Suggested Compact 3.2 Opening

현재 3.2 초반을 아래 흐름으로 바꾸는 것을 권장한다.

```text
TF-Rehancer is designed to avoid applying the full encoder stack to all full-band frequency tokens. The model first builds a shared embedded representation from a power-law compressed complex STFT. It then splits the embedded frequency axis into low-band and high-band tokens. Low-band tokens are processed by the TF encoder, while high-band tokens remain in the decoder path as observed upper-band evidence. The decoder uses the low-band encoder output to refine the full embedded sequence and predicts a full-resolution complex TF filter that is applied to the original noisy STFT.
```

이 문단이 있어야 독자가 method를 바로 이해한다.

## 11. Suggested 3.3 Rewrite Skeleton

```text
## 3.3 Low-Band-Guided Full-Band Decoding

After the shared frequency stem, TF-Rehancer assigns the embedded tokens below the cutoff to the encoder and keeps the remaining observed high-band tokens in the decoder path. The high-band tokens are initialized from the noisy observation and passed through a lightweight residual local adapter:

Q_h = H_high + Adapter_h(H_high).

The initial decoder sequence is formed by concatenating the encoded low-band representation and the adapted high-band tokens:

D_0 = Proj([Z; Q_h]_F).

The decoder first injects low-band encoder information into the high-band portion through cross-attention:

D_high' = D_high + MHCA(D_high, Z, Z).

The updated high-band tokens are concatenated back with the low-band decoder tokens, and subsequent self-attention and temporal modeling operate over the full embedded frequency sequence. Thus, the model does not generate the high band from scratch; it refines a full-band decoder representation that retains observed upper-band evidence while being guided by the low-band encoder output.
```

이 정도면 충분하다. projection detail, repeated shape, defensive wording은 필요 없다.

## 12. Final Reviewer Verdict

현재 Ch3는 기술 설명 문서로는 좋다. 논문 본문으로는 아직 길고 구현 냄새가 난다.

필수 수정:

1. `Low-to-High Embedded Query Refinement` 제목 교체
2. 3.1에서 tensor implementation detail 제거
3. 3.2에서 shape 반복 줄이기
4. HBR/local adapter 설명 축소
5. cross-attention projection detail 축소
6. main phrase를 `low-band-guided full-band decoder refinement`로 통일
7. implementation/rebuttal 냄새나는 표현 삭제
8. loss section에서 implementation wording 제거

이 수정 후에야 Chapter 3가 paper-ready에 가까워진다.

