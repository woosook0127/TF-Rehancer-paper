# Writing Team Revision Plan — Final Pass with 48 kHz Reference Table

## Scope

이 문서는 최신 `thesis(4).pdf`를 기준으로, 48 kHz 결과 table을 추가하면서도 논문의 claim boundary가 무너지지 않도록 최종 수정 방향을 정리한다. 핵심 목표는 다음 세 가지다.

1. **48 kHz 결과 table을 추가해 full-band claim을 보강한다.**
2. **Abstract와 Chapter 4의 claim을 table의 실제 성격에 맞게 조정한다.**
3. **page budget을 맞추기 위해 Chapter 2에서 정확히 한 문장을 줄인다.**

논문 제목은 유지한다.

---

## 1. 48 kHz 결과 table 추가 지침

### 1.1 Table을 넣는 위치

현재 Chapter 4는 다음 구조다.

```text
4.2.1 Wideband Results
4.2.2 Low-Band Cutoff
4.2.3 Architecture Ablations
```

48 kHz reference table을 추가하면 아래처럼 바꾼다.

```text
4.2.1 Wideband Results
4.2.2 48 kHz Reference Positioning
4.2.3 Low-Band Cutoff
4.2.4 Architecture Ablations
```

Section title은 반드시 **Reference Positioning** 계열로 둔다. 다음 표현은 피한다.

```text
48 kHz Full-Band Benchmark
48 kHz SOTA Comparison
Protocol-Aligned DNS4 Full-Band Evaluation
```

이유: DeepFilterNet2 rows는 paper-reported reference이고, TF-Rehancer rows는 local evaluation이다. Strict same-evaluator ranking이 아니다.

---

### 1.2 추가할 main table

아래 table을 `4.2.2 48 kHz Reference Positioning`에 넣는다. Table caption과 본문 caveat를 반드시 함께 넣어야 한다.

```markdown
**Table 4.X: 48 kHz reference positioning on the VoiceBank+DEMAND 48 kHz test set.** DeepFilterNet2 rows are paper-reported references, while TF-Rehancer rows are locally evaluated. Therefore, this table is used for reference positioning rather than strict same-evaluator ranking. MACs are model-side estimates.

| Model | Source | Train data | Params ↓ | MACs ↓ | PESQ ↑ | STOI ↑ | CSIG ↑ | CBAK ↑ | COVL ↑ | SI-SDR ↑ | LSD ↓ |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| DFN2 + Simplified DNN | paper-reported | mixed / paper protocol | 2.31M | **0.36G** | 3.08 | 0.943 | 4.30 | 3.40 | 3.70 | -- | -- |
| DFN2 + Post-Filter | paper-reported | DNS4 full-band | 2.31M | **0.36G** | 3.03 | 0.941 | 3.72 | 3.37 | 3.63 | -- | -- |
| TF-Rehancer (on) | local eval | VCTK + DNS noise 48 kHz | **0.470M** | 3.04G | **3.287** | 0.948 | **4.400** | **3.594** | **3.877** | 16.702 | **0.725** |
| TF-Rehancer (off) | local eval | DNS4 48 kHz | 0.615M | 3.15G | 3.233 | **0.951** | 4.286 | 3.567 | 3.771 | **17.789** | 0.730 |
```

`TF-Rehancer (off)`는 TimeMHSA diagnostic configuration이다. Caption 또는 직후 문장에 반드시 diagnostic row임을 명시한다.

---

### 1.3 48 kHz table 해석 문단

Table 뒤에는 아래 문단을 넣는다.

```text
Table 4.X provides 48 kHz reference positioning rather than a strict same-evaluator comparison. On the VBD48 test set, TF-Rehancer (on) obtains the highest PESQ, CSIG, CBAK, and COVL among the listed rows, while TF-Rehancer (off) gives the highest STOI and SI-SDR among the TF-Rehancer variants. Since the DeepFilterNet2 rows are paper-reported references and are not re-evaluated with the local pipeline, these results should not be interpreted as direct superiority over DeepFilterNet2. Instead, they indicate that TF-Rehancer reaches competitive full-reference scores on a 48 kHz evaluation surface while using substantially fewer parameters than the published DeepFilterNet2 reference.
```

### 금지 표현

아래 표현은 쓰지 않는다.

```text
TF-Rehancer outperforms DeepFilterNet2.
TF-Rehancer establishes a new 48 kHz full-band benchmark.
TF-Rehancer is the state-of-the-art full-band SE model.
```

### 허용 표현

아래 정도는 가능하다.

```text
TF-Rehancer obtains competitive 48 kHz full-reference scores against published DeepFilterNet2 references.
The 48 kHz table is used for reference positioning rather than strict same-evaluator ranking.
The offline diagnostic row suggests the quality potential of non-streaming temporal modeling.
```

---

### 1.4 DNS4 blind table 사용 여부

`v5_dfn2_comparison_tables.md`에는 DNS4 official blind DNSMOS table도 있다. 하지만 page budget을 고려하면 **main text에는 VBD48 reference positioning table 하나만 넣는 것을 우선**한다.

DNS4 blind table은 다음 조건에서만 넣는다.

- page budget이 충분한 경우
- 또는 Appendix / supplementary table로 뺄 수 있는 경우

넣는다면 caption은 아래처럼 방어적으로 쓴다.

```text
Table 4.Y: DNS4 blind-set no-reference DNSMOS comparison. DeepFilterNet2 rows are taken from the published table, while TF-Rehancer rows are evaluated locally using legacy split DNSMOS P.835 models for scale compatibility. The TF-Rehancer (off) row is an offline diagnostic configuration and is not used as the main low-computation claim.
```

권장 해석은 다음 수준으로 제한한다.

```text
The DNS4-trained offline diagnostic configuration reaches the DeepFilterNet2 range on SIG and approaches it on OVR, while remaining below DeepFilterNet2 + Post-Filter on BAK and OVR. This result is diagnostic evidence and does not replace a same-evaluator full-band benchmark.
```

---

## 2. Abstract 검토 및 수정 지침

### 2.1 현재 Abstract 평가

현재 Abstract는 읽히는 흐름 자체는 좋다. Method 요약도 안전하다. 다만 48 kHz reference table을 추가하면 현재 문장인 `The evaluation is organized around two roles`는 좁게 보인다. 16 kHz + 48 kHz ablation만 있는 구조에서 작성된 문장이기 때문이다.

48 kHz reference positioning table을 넣으면 Abstract는 아래 세 축으로 정리해야 한다.

1. 16 kHz quality-efficiency comparison
2. 48 kHz reference positioning against paper-reported DeepFilterNet2 references
3. 48 kHz controlled ablations

### 2.2 Abstract 수정안

아래 문단 구조로 바꾸는 것을 권장한다. 너무 길어지면 숫자 일부를 줄여도 된다.

```text
This thesis presents TF-Rehancer, a time-frequency speech enhancement architecture for direct full-band processing. The model treats high-frequency components in 48 kHz speech as observed but noisy spectral evidence rather than as missing information to be generated from a band-limited input. TF-Rehancer uses sampling-frequency-independent STFT analysis, power-law compressed complex spectral conditioning, low-band encoder-guided high-band token update followed by full-band decoder modeling, and local complex time-frequency filtering over the original noisy STFT.

We evaluate TF-Rehancer from three perspectives. First, on the 16 kHz VoiceBank+DEMAND benchmark, the low-computation TF-Rehancer configuration achieves PESQ 3.33, DNSMOS SIG 3.41, DNSMOS BAK 4.04, and DNSMOS OVL 3.13 with 0.47M parameters and 1.89G model-side MACs. Against the paper-reported FastEnhancer-M reference, it reports higher PESQ, SI-SDR, and DNSMOS P.835 values with fewer model-side MACs, while FastEnhancer-M remains slightly stronger in SCOREQ and ESTOI. This comparison is interpreted as benchmark context rather than a same-evaluator ranking.

Second, a 48 kHz reference positioning table compares TF-Rehancer with published DeepFilterNet2 references on the VoiceBank+DEMAND 48 kHz test set. TF-Rehancer obtains competitive full-reference scores, while the DeepFilterNet2 rows remain paper-reported references rather than locally re-evaluated baselines. Third, controlled 48 kHz ablations show that replacing complex TF filtering with direct spectrum mapping degrades full-reference, spectral, and non-intrusive metrics. They also show that decoder cross-attention changes the trade-off between perceptual scores and spectral fidelity, and that a 5 kHz low-band cutoff provides a balanced operating point under the controlled ablation setting.
```

### 2.3 Abstract에서 피해야 할 표현

```text
outperforms DeepFilterNet2
state-of-the-art full-band speech enhancement
strong full-band benchmark model
strict full-band ranking
```

---

## 3. Chapter 2에서 한 문장 줄이기

Page를 맞추기 위해 Chapter 2에서 아래 한 문장을 삭제한다.

삭제 대상: Section 2.2 `Full-Band Speech Enhancement`의 PercepNet/DeepFilterNet2 문단.

```text
These systems are important references because they show that 48 kHz full-band enhancement can be made practical under strict computational constraints.
```

삭제 이유:

- 앞 문장에서 이미 PercepNet/DeepFilterNet2가 practical full-band SE system이라는 점이 전달된다.
- 뒤 문장도 perceptual/ERB-band representation의 efficiency trade-off로 이어진다.
- 이 문장을 삭제해도 논리 손실이 거의 없고, 정확히 한 줄 수준의 공간을 줄일 수 있다.

삭제 후 문단 흐름:

```text
Practical full-band SE has been studied mainly under real-time and low-complexity constraints. PercepNet enhances 48 kHz speech using perceptually motivated critical-band features and comb filtering, while DeepFilterNet2 combines ERB-domain enhancement with deep filtering for low-complexity full-band enhancement [3, 4]. Such perceptual or ERB-band representations trade frequency resolution for efficiency, motivating complementary TF-domain designs that retain a closer connection to the observed STFT while still controlling computational cost.
```

---

## 4. Training Objective 검토

### 4.1 전체 판단

Training objective 부분은 전반적으로 자연스럽다. 각 loss가 어떤 역할을 하는지 설명이 들어가면서, 이전보다 훨씬 방어 가능해졌다. 특히 다음 내용은 유지한다.

- `Lmag`: compressed magnitude envelope matching
- `Lcplx`: compressed real/imaginary component matching, phase-sensitive supervision
- `Lcons`: iSTFT 이후 다시 STFT를 취해 reconstruction consistency를 확인
- `Lwav`: waveform-domain sample-level reconstruction term
- `Lpesq`: differentiable PESQ-like auxiliary term, reported PESQ score가 아님
- 48 kHz training에서 PESQ auxiliary는 16 kHz resampling 후 계산

### 4.2 약간 다듬을 수 있는 부분

현재 문장 중 아래 표현은 조금 강하게 읽힐 수 있다.

```text
Lmag matches the compressed magnitude envelope and stabilizes the energy of speech components, including high-band energy.
```

`stabilizes`는 너무 보장하는 느낌이 있으므로 아래처럼 바꾸면 더 안전하다.

```text
Lmag matches the compressed magnitude envelope and encourages energy consistency across frequency bands, including the upper band.
```

`Lcplx` 설명은 유지 가능하다.

```text
Lcplx compares the compressed real and imaginary components, so it gives phase-sensitive supervision for the complex filter output.
```

`Lcons` 설명도 좋다. 다만 page 압축이 필요하면 아래처럼 줄일 수 있다.

현재 의미:

```text
It penalizes spectra that appear plausible before inverse STFT but become inconsistent after waveform reconstruction and re-analysis.
```

간결 버전:

```text
It penalizes spectra that become inconsistent after waveform reconstruction and STFT re-analysis.
```

### 4.3 결론

Training objective는 크게 수정하지 않아도 된다. 위의 `Lmag` 표현만 약하게 바꾸는 것을 권장한다.

---

## 5. Caption 정리 지침

Caption은 짧게 유지하고, training epoch/checkpoint 같은 내부 정보는 본문 또는 appendix로 보낸다.

### 5.1 Figure captions

Figure 1.1 caption은 현재 좋다. 유지 가능하다.

Figure 3.1 caption은 조금 길어질 수 있으나, architecture overview로는 허용 가능하다. 단, caption에서 너무 많은 operation을 설명하지 말고 본문에 맡긴다.

권장:

```text
Figure 3.1: Overall TF-Rehancer architecture. The low-band region is encoded by the TF encoder, while the observed high-band region is carried as decoder-side query evidence. The decoder performs cross-band refinement followed by full-sequence modeling and complex TF filter estimation.
```

Figure 3.3 caption은 현재 수준이면 유지 가능하다. `Macaron-style`, `F-MHCA`, `RoPE` 등 핵심 정보가 있어야 한다.

Figure 3.4 caption은 현재 좋다.

---

### 5.2 Table captions

#### Table 4.1

현재 caption이 길다면 아래처럼 줄인다.

```text
Table 4.1: VoiceBank+DEMAND 16 kHz test results. FastEnhancer-M uses paper-reported values [20], while TF-Rehancer rows are locally evaluated on the 824-utterance VBD test set. MACs are model-side estimates and exclude STFT/iSTFT.
```

`on/off` label 설명은 caption이 아니라 Table 앞 문단에 둔다.

#### New 48 kHz reference table

```text
Table 4.X: 48 kHz reference positioning on the VoiceBank+DEMAND 48 kHz test set. DeepFilterNet2 rows are paper-reported references, while TF-Rehancer rows are locally evaluated. This table is not a strict same-evaluator ranking.
```

#### Table 4.2 cutoff

현재 caption은 괜찮다. 너무 길어지면 다음 정도로 줄인다.

```text
Table 4.X: Low-band cutoff ablation. All rows use the 48 kHz VCTK-DNS setting. Parameter counts are identical and omitted; MACs are model-side estimates.
```

#### Table 4.3 architecture ablation

현재 caption에서 epoch/checkpoint 설명은 제거한다. 권장 caption:

```text
Table 4.X: 48 kHz architecture ablation on the VoiceBank+DEMAND 48 kHz test set. All models are trained using VCTK clean speech and DNS full-band noise and evaluated on the VBD 48 kHz test set. These results are intended for controlled component analysis, not external full-band system ranking.
```

삭제할 정보:

```text
40-epoch warmup retest checkpoint
12 epoch checkpoint
best epXX
```

이 정보는 manuscript 본문/caption에 넣지 않는다.

---

## 6. Chapter 4 구조 수정안

48 kHz table 추가 후 Chapter 4는 아래 순서로 정리한다.

```text
4.2 Experimental Results
  4.2.1 Wideband Results
  4.2.2 48 kHz Reference Positioning
  4.2.3 Low-Band Cutoff
  4.2.4 Architecture Ablations
```

List of Tables도 자동 업데이트되어야 한다.

```text
4.1 VoiceBank+DEMAND 16 kHz test results
4.2 48 kHz reference positioning on VoiceBank+DEMAND 48 kHz
4.3 Low-band cutoff ablation
4.4 48 kHz architecture ablation
```

---

## 7. Conclusion / Limitations 수정 지침

48 kHz reference positioning table이 들어가면 Conclusion summary에 한 문장 정도 추가할 수 있다.

추가 가능 문장:

```text
The 48 kHz reference positioning table further shows that TF-Rehancer obtains competitive full-reference scores against published DeepFilterNet2 references on the VBD48 test set, although the comparison is not a strict same-evaluator ranking.
```

Limitations에서는 아래 문장을 유지하거나 약간 수정한다.

```text
The 48 kHz reference comparison relies partly on paper-reported DeepFilterNet2 values, and a protocol-aligned same-evaluator comparison with strong full-band baselines remains necessary for broader performance claims.
```

---

## 8. Final claim boundary

### 허용 claim

```text
TF-Rehancer obtains competitive 48 kHz full-reference scores against published DeepFilterNet2 references.
The 48 kHz table provides reference positioning, not strict same-evaluator ranking.
The offline diagnostic row suggests the quality potential of non-streaming temporal modeling.
Complex TF filtering is more reliable than direct spectrum mapping in the controlled 48 kHz ablation.
```

### 금지 claim

```text
TF-Rehancer outperforms DeepFilterNet2.
TF-Rehancer establishes a new 48 kHz benchmark.
TF-Rehancer is state-of-the-art full-band SE.
The 48 kHz results prove external full-band superiority.
```

---

## 9. Writing team checklist

1. Add `4.2.2 48 kHz Reference Positioning` after `4.2.1 Wideband Results`.
2. Insert the VBD48 reference table from Section 1.2 of this document.
3. Shift current `Low-Band Cutoff` and `Architecture Ablations` section numbers.
4. Update List of Tables automatically.
5. Update Abstract from two-role framing to include 48 kHz reference positioning.
6. Delete exactly one sentence in Chapter 2: `These systems are important references...`.
7. Keep Training Objective mostly unchanged; optionally soften the `Lmag` sentence.
8. Remove epoch/checkpoint details from table captions.
9. Keep all 48 kHz comparison language as `reference positioning`, not `external ranking`.
10. Do not change the thesis title.
