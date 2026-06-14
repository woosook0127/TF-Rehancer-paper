# ch4_draftv13 최종 리뷰

대상: `/home/wooseok/project/TF_Renhancer/project_analysis/paper/ch4_draftv13.md`  
판정: **FINAL_PASS**

v13은 Chapter 4 final draft로 넘겨도 된다. v12에서 남았던 polish 항목이 모두 적절히 반영됐다. 현재 기준에서 과학적 blocker, claim blocker, 용어 blocker는 없다.

## 1. 반영 확인

### 1.1 `LSD-H@8k` 표기

통과.

- line 27: `LSD-H@8k` 정의가 정확함.
- lines 50, 56, 62: table header와 해석 문장도 `LSD-H@8k`로 통일됨.
- `above approximately 8 kHz` 표현은 evaluator의 `cutoff_bin=321`과 충돌하지 않음.

### 1.2 `DNSMOS P.808` / `DNSMOS OVRL` 표기

통과.

- table header와 본문에서 `DNSMOS P.808`, `DNSMOS OVRL`로 통일됨.
- CSV source의 `DNSMOS_OVRL`와도 맞음.

### 1.3 16 kHz comparison 해석

통과.

- FastEnhancer-M 대비 이기는 metric과 지는 metric을 모두 명시함.
- FastEnhancer-S의 강점도 언급함.
- BSRNN은 paper-reported reference라고 분리함.
- `uniform dominance`를 부정해서 claim이 안전함.

현재 line 42-44 흐름은 최종본으로 충분히 자연스럽다.

### 1.4 48 kHz ablation scope

통과.

- line 11, line 48에서 external system ranking이 아니라고 명시함.
- 이 문장이 있으므로 48 kHz external baseline 부재에 대한 방어가 가능하다.
- Chapter 4는 “controlled full-band ablation”으로 읽힌다.

### 1.5 MappingHead / MHCA 해석

통과.

- Direct mapping head는 complex TF filtering보다 전반적으로 나쁘다는 claim이 수치와 맞음.
- w/o decoder MHCA는 mixed trend로 해석함.
- MHCA가 necessary/unnecessary라고 단정하지 않음.

### 1.6 Cutoff 해석

통과.

- 8 kHz가 일부 perceptual score에서 강하다는 사실과 충돌하지 않음.
- 5 kHz를 `balanced operating point`로 설명함.
- `optimal` claim이 없음.

## 2. 남은 선택적 polish

필수 아님. 지금 상태로도 충분히 제출 가능하다.

### 2.1 line 7 반복

현재:

> The 48 kHz setting uses ... in the 48 kHz full-band setting.

`48 kHz setting`이 한 문장 안에서 반복된다. 거슬리면 아래처럼 줄일 수 있다.

> The 48 kHz setting uses VCTK clean speech mixed with DNS full-band noise to analyze the architectural components of TF-Rehancer under full-band processing.

단, 지금 문장도 문제는 아니다.

### 2.2 line 48 caption 길이

caption이 길지만, 필요한 caveat가 들어 있어 유지해도 된다. LaTeX table caption에서 너무 길면 두 문장으로 나누면 된다.

## 3. Claim Safety

v13이 방어할 수 있는 claim:

- TF-Rehancer provides competitive 16 kHz quality-efficiency trade-off.
- TF-Rehancer improves PESQ-WB and DNSMOS SIG/BAK/OVRL over locally evaluated FastEnhancer-M, while FastEnhancer-M remains stronger in DNSMOS P.808, SCOREQ, SI-SDR, STOI, and ESTOI.
- Complex TF filtering is more reliable than direct spectrum mapping in the 48 kHz controlled ablation.
- Decoder MHCA changes the trade-off between perceptual scores and spectral fidelity.
- The 5 kHz cutoff provides a balanced operating point under the 48 kHz ablation setting.

v13이 주장하면 안 되는 것:

- 48 kHz full-band SOTA.
- External full-band system superiority.
- MHCA is necessary.
- 5 kHz is optimal.
- TF-Rehancer dominates FastEnhancer-M.

현재 원고는 금지 claim을 하지 않는다.

## 4. 최종 결론

Chapter 4는 완성본으로 봐도 된다. 더 고칠수록 과수정 위험이 크다.

다음 단계는 Chapter 4 내부 수정이 아니라, Abstract / Introduction / Conclusion의 claim 강도를 이 Chapter 4 증거 수준에 맞추는 것이다. 특히 48 kHz 결과는 external ranking이 아니라 controlled ablation이라는 점이 논문 전체에서 일관되어야 한다.
