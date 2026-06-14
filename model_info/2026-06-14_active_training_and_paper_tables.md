# 2026-06-14 Active Training and Paper Table Handoff

작성 시각: 2026-06-14 KST  
최신 점검: 2026-06-14 19:53 KST  
대상: Paperwork team  
목적: 현재 서버별 학습 상태와, 각 학습이 논문 Chapter 4의 어떤 table을 채우는지 정리한다. 현재 수치는 최종이 아니므로 본문은 protocol/method 중심으로 먼저 작성하고, table 값은 최종 평가 후 교체한다.

## 0. 2026-06-14 자정 전 사용 가능성

결론:

- `100ep` final DNS4 48 kHz 결과는 오늘 24:00 KST까지 불가능하다.
- `V5 48 kHz online main`은 현재 속도 기준 epoch 20 부근까지는 오늘 밤 도달 가능하다. 따라서 `epoch20 전후 best-valid checkpoint`를 별도 평가하면 paper draft용 near-final/interim 48 kHz row는 만들 수 있다.
- `V5-T1 TimeMHSA-EFN 48 kHz diagnostic`은 오늘 24:00 KST까지 epoch 39-40 수준 예상이다. Final row는 불가능하고, diagnostic 중간 checkpoint 평가만 가능하다.
- `V5 NoHBR internal ablation`은 오늘 21:00-22:00 KST 사이 학습+평가 완료 가능성이 높다.
- 기존 watcher는 `V5 48 kHz online main`과 `V5-T1 48 kHz diagnostic`을 `epoch100` 완료 후 평가하도록 걸려 있다. 오늘 자정 전 수치가 필요하면 `epoch20` 또는 current-best 별도 eval trigger가 필요하다.

| run | 현재 상태 | 속도 추정 | 오늘 24:00 전 사용 가능성 | 사용처 |
|---|---|---|---|---|
| V5 48 kHz online main, DNS4, `enc6/dec3 C48/C24` | Attention GPU1, latest `epoch.0012` at 16:26 KST | 약 42-44 min/epoch | `epoch20` 전후 중간평가는 가능. `epoch100` final은 불가 | 48 kHz final table의 placeholder/near-final row |
| V5-T1 TimeMHSA-EFN 48 kHz diagnostic | Zeroshot GPU0, latest `epoch.0028` at 16:59 KST | 약 36-38 min/epoch | epoch 39-40 중간평가 가능. `epoch100` final은 불가 | offline upper-bound diagnostic |
| V5 NoHBR internal ablation | Echo GPU1, latest `epoch.0004` at 17:02 KST | 약 13 min/epoch | 가능. `epoch20` + VBD48 eval 예상 21:00-22:00 KST | HBR removal ablation |
| V5-T1 TimeMHSA-EFN 16 kHz diagnostic | Echo GPU0, latest `epoch.0086` at 16:58 KST | 약 5.8 min/epoch | `epoch200` final은 익일 새벽. current-best eval은 이미 있음 | 16 kHz offline diagnostic |

## 1. 현재 진행 중인 학습/평가

### 1.1 Attention 서버

| GPU | 상태 | 모델/실험 | config | dataset | epoch 상태 | 생성될 table |
|---:|---|---|---|---|---|---|
| 0 | 학습 중 | V5 main 16 kHz long run | `v5_baseline_efn_adaptiveavgpool_lnrestore_fecompressed_conscompressed_tmax500_nohighpe_stft640_hop320_inputmag_tf3_bs16_vbd16_500ep.yaml` | VBD16 train/valid | latest `epoch.0325` at 17:00 KST | Final / near-final 16 kHz table |
| 1 | 학습 중 | V5 48 kHz final candidate, `enc6/dec3`, `C48/C24` | `v5_enc6dec3_c48c24_dns4eng48_sfi40_fepesq001_bs4_200ep.yaml` | DNS4 English clean + DNS fullband noise, 48 kHz | latest `epoch.0012` at 16:26 KST, `epoch20` ETA around 22:05-22:30 KST | Final 48 kHz table, high-band metric table |
| 2 | 완료 | V5 16 kHz long run, best snapshot eval | `v5_baseline...500ep.yaml`, current-best `epoch296` row | VBD16 official test N=824 | eval 완료, `failures={}` | Final / near-final 16 kHz table |
| 2 | 완료 | Filter vs Mapping internal ablation | `v5_mappinghead_vctk_dns48_sfi40_20ep.yaml` | VCTK clean + DNS fullband noise, 48 kHz | best checkpoint eval 완료 | Filter-vs-Mapping ablation table |
| 3 | 완료 | Cross-attention removal internal ablation | `v5_nomhca_efndecoder_vctk_dns48_sfi40_20ep.yaml` | VCTK clean + DNS fullband noise, 48 kHz | best checkpoint eval 완료 | Cross-attention removal ablation table |

Evidence:

- `project_analysis/run_logs/v5_20260613/v5_conscompressed_train_gpu0.log`
- `project_analysis/run_logs/v5_20260613/eval/v5_base_long_ep296_currentbest_table2_gpu3.log`
- `project_analysis/run_logs/v5_final_48k_dns4_20260614/v5_enc6dec3_c48c24_dns4eng48_sfi40_fepesq001_bs4_100ep_gpu1.log`
- `project_analysis/run_logs/v5_filter_vs_mapping_20260614/train_gpu2_20ep.log`
- `project_analysis/run_logs/v5_cross_attention_removal_20260614/train_gpu3_20ep.log`

### 1.2 Zeroshot 서버

| GPU | 상태 | 모델/실험 | config | dataset | epoch 상태 | 생성될 table |
|---:|---|---|---|---|---|---|
| 0 | 학습 중 | V5-T1 TimeMHSA-EFN 48 kHz diagnostic | `v5_t1_timemhsa_efn_dns4eng48_sfi40_fepesq001_bs4_100ep.yaml` | DNS4 English clean + DNS fullband noise, 48 kHz | latest `epoch.0028` at 16:59 KST, 24:00 ETA `epoch39-40` | Time module diagnostic row in 48 kHz analysis |
| 1 | idle | 없음 | - | - | - | - |

Purpose:

- V5 main은 causal FastGRU temporal model이다.
- V5-T1은 Time module을 offline MHSA-style로 바꾼 diagnostic이다.
- 논문 main claim row로 쓰기보다는, “temporal modeling choice / offline upper-bound” 성격으로만 사용한다.

Evidence:

- `project_analysis/run_logs/v5_t1_timemhsa_dns4_48k_zeroshot_20260613/train.log`
- log root: `TF_Restormer-7B28/models/TF_Rehancer_v5_TimeMHSA_EFN/log/log_pretrain_to48k_v5_t1_timemhsa_efn_dns4eng48_sfi40_fepesq001_bs4_100ep.yaml/`

### 1.3 YOLO 서버

| GPU | 상태 | 모델/실험 | config | dataset | epoch 상태 | 생성될 table |
|---:|---|---|---|---|---|---|
| 0 | 학습 중 | V5-T1 TimeMHSA-EFN VCTK+DNS4 noise 48 kHz preliminary diagnostic, `enc6/dec3`, `C48/C24` | `v5_t1_enc6dec3_c48c24_timemhsa_efn_vctk_dns4noise48_sfi40_bs4_20ep.yaml` | VCTK clean + DNS4 fullband noise synthesis, 48 kHz | started 2026-06-14 17:44 KST, train loop 진입 확인, GPU0 약 15.3 GB 사용 | VCTK+DNS4-noise preliminary TF-Locoformer/TF-Rehancer comparison table |
| 0 | 완료 | V5 cutoff 4 kHz | `v5_cutoff4k_enc4dec2_c48c24_vctk_dns48_sfi40_bs4_20ep.yaml` | VCTK clean + DNS fullband noise, 48 kHz | best epoch 18, VBD48 eval 완료 | cutoff ablation table |
| 1 | 완료 | V5 cutoff 3 kHz | `v5_cutoff3k_enc4dec2_c48c24_vctk_dns48_sfi40_bs4_20ep.yaml` | VCTK clean + DNS fullband noise, 48 kHz | best epoch 17, VBD48 eval 완료 | cutoff ablation table |

Evidence:

- `project_analysis/run_logs/vctk_dns4noise48_prelim_20260614/v5_t1_timemhsa_yolo_gpu0_train.log`
- `project_analysis/run_logs/v5_cutoff_sweep_vctk_dns48_20260614/v5_cut4k_yolo_gpu0.log`
- `project_analysis/run_logs/v5_cutoff_sweep_vctk_dns48_20260614/v5_cut3k_yolo_gpu1.log`

Results:

- `project_analysis/analyze_results/v5_auto_eval_20260614/v5_cutoff4k_yolo_best_full/full_se_metrics_n824.csv`
- `project_analysis/analyze_results/v5_auto_eval_20260614/v5_cutoff3k_yolo_best_full/full_se_metrics_n824.csv`

### 1.4 Warmup 서버

| GPU | 상태 | 모델/실험 | config | dataset | epoch 상태 | 생성될 table |
|---:|---|---|---|---|---|---|
| 1 | 완료 | V5 cutoff 8 kHz | `v5_cutoff8k_enc4dec2_c48c24_vctk_dns48_sfi40_bs4_20ep.yaml` | VCTK clean + DNS fullband noise, 48 kHz | best epoch 19, NAS manifest rerun eval 완료 | cutoff ablation table |
| 2 | 완료 | V5 cutoff 7 kHz | `v5_cutoff7k_enc4dec2_c48c24_vctk_dns48_sfi40_bs4_20ep.yaml` | VCTK clean + DNS fullband noise, 48 kHz | best epoch 19, NAS manifest rerun eval 완료 | cutoff ablation table |
| 3 | 완료 | V5 cutoff 6 kHz | `v5_cutoff6k_enc4dec2_c48c24_vctk_dns48_sfi40_bs4_20ep.yaml` | VCTK clean + DNS fullband noise, 48 kHz | best epoch 20, VBD48 eval 완료 | cutoff ablation table |
| 4 | 완료 | V5 cutoff 5 kHz | `v5_cutoff5k_enc4dec2_c48c24_vctk_dns48_sfi40_bs4_20ep.yaml` | VCTK clean + DNS fullband noise, 48 kHz | best epoch 17, VBD48 eval 완료 | cutoff ablation table |

Evidence:

- `project_analysis/run_logs/v5_cutoff_sweep_vctk_dns48_20260614/`

Results:

- `project_analysis/analyze_results/v5_auto_eval_20260614/v5_cutoff6k_warmup_best_full/full_se_metrics_n824.csv`
- `project_analysis/analyze_results/v5_auto_eval_20260614/v5_cutoff5k_warmup_best_full/full_se_metrics_n824.csv`
- `project_analysis/analyze_results/v5_auto_eval_20260614/v5_cutoff7k_warmup_best_full/full_se_metrics_n824.csv`
- `project_analysis/analyze_results/v5_auto_eval_20260614/v5_cutoff8k_warmup_best_full/full_se_metrics_n824.csv`

### 1.5 Echo 서버

| GPU | 상태 | 모델/실험 | config | dataset | epoch 상태 | 생성될 table |
|---:|---|---|---|---|---|---|
| 0 | 학습 중 | V5-T1 TimeMHSA-EFN 16 kHz offline diagnostic | `v5_t1_timemhsa_efn_fecompressed_conscompressed_tmax500_nohighpe_stft640_hop320_inputmag_tf3_bs16_vbd16_200ep_echo_gpu0.yaml` | VBD16 official paired train/valid via Echo NAS manifest | latest `epoch.0086` at 2026-06-14 16:58 KST, ETA final epoch 200 around 2026-06-15 early morning | 16 kHz FE-M comparison diagnostic row |
| 1 | 완료 | V5 internal anchor, MHCA + Filtering | `v5_anchor_filtering_vctk_dns48_sfi40_20ep_echo_nas.yaml` | VCTK clean + DNS fullband noise synthesis via Echo NAS scp | best epoch 20, watcher eval 완료 | Cross-attention removal / Filter-vs-Mapping ablation anchor |
| 1 | 학습 중 | V5 No HBR internal ablation | `v5_nohbr_vctk_dns48_sfi40_20ep_echo_nas.yaml` | VCTK clean + DNS fullband noise synthesis via Echo NAS scp | latest `epoch.0004` at 17:02 KST, `epoch20` ETA around 20:30 KST, watcher armed | HBR removal ablation table |

Echo data rule:

- VBD and VCTK are different assets. Do not mix them.
- VBD16 paired train/valid uses:
  `project_analysis/dataset_manifests/vbd16_official_20260601_echo_nas`
  with source wavs under `/home/nas/DB/Voicebank+Demand/VD_all/train/{clean,noisy}`.
- VBD48 test uses:
  `project_analysis/test_manifests/voicebank_demand_test_20260528_echo_nas.csv`
  with source wavs under `/home/nas/DB/Voicebank+Demand/{clean_testset_wav,noisy_testset_wav}`.
- VCTK+DNS synthesis uses:
  `TF_Restormer-7B28/data/scp/scp_VCTK_EchoNAS`
  with VCTK under `/home/nas/DB/VCTK/...` and DNS noise under `/home/nas3/DB/DNS_challenge/...`.

Evidence:

- `project_analysis/run_logs/v5_echo_new_runs_20260614/v5_t1_vbd16_gpu0_train.log`
- `project_analysis/run_logs/v5_echo_new_runs_20260614/v5_anchor_vctkdns48_gpu1_train.log`
- `project_analysis/run_logs/v5_nohbr_ablation_echo_20260614/train_gpu1.log`
- `project_analysis/run_logs/v5_train_eval_watch_20260614/watch_v5_t1_vbd16_echo_gpu0.log`
- `project_analysis/run_logs/v5_train_eval_watch_20260614/watch_v5_anchor_vctkdns48_echo_gpu1.log`
- `project_analysis/run_logs/v5_train_eval_watch_20260614/watch_v5_nohbr_vctkdns48_echo_gpu1.log`

Results:

- `project_analysis/analyze_results/v5_auto_eval_20260614/v5_anchor_filtering_vctkdns48_echo_best_full/full_se_metrics_n824.csv`
- `project_analysis/analyze_results/v5_auto_eval_20260614/v5_t1_timemhsa_vbd16_echo_currentbest_table2/full_se_metrics_n824.csv`
- pending: `project_analysis/analyze_results/v5_auto_eval_20260614/v5_nohbr_ablation_vctkdns48_echo_best_full/full_se_metrics_n824.csv`
- `project_analysis/analyze_results/v5_auto_eval_20260614/cutoff_3_6_anchor_summary_20260614/v5_cutoff_3_6_anchor_summary.md`

Specs:

- `project_analysis/experiment_design/todo_specs_20260614/v5_t1_timemhsa_efn_vbd16_spec.md`
- `project_analysis/experiment_design/todo_specs_20260614/v5_anchor_filtering_vctkdns48_spec.md`
- `project_analysis/experiment_design/todo_specs_20260614/v5_no_hbr_ablation_vctkdns48_echo_spec.md`

## 2. 논문 table 별 작성 지침

### 2.1 Table: 16 kHz Speech Enhancement and Efficiency

목적:

- V5가 16 kHz setting에서도 FastEnhancer 계열과 비교 가능한 quality/efficiency를 갖는지 보여준다.
- 최종 claim은 “48 kHz full-band SE model의 utility check” 성격이다. 16 kHz 자체가 main contribution은 아니다.

Rows:

| row | source | status |
|---|---|---|
| BSRNN | FastEnhancer Table 2 paper-reported number | reference |
| FastEnhancer-M | FastEnhancer Table 2 paper-reported number | reference |
| TF-Rehancer V5 16 kHz main | Attention GPU0 long run + GPU2 eval, current-best around ep295/296 | 진행 중 |
| Optional V5 wider/deeper variant | 이미 완료된 V5 enc6/dec3 16 kHz 결과 또는 추후 rerun | 선택 |

Metrics:

- Params
- MACs
- DNSMOS P.808
- DNSMOS P.835 SIG / BAK / OVL
- SCOREQ
- SI-SDR
- PESQ
- STOI
- ESTOI

Paperwork wording:

- “We evaluate the 16 kHz configuration on the VoiceBank+DEMAND test set to compare the quality-efficiency trade-off against lightweight 16 kHz speech enhancement baselines.”
- 숫자 전까지 superiority 표현 금지.
- BSRNN/FastEnhancer-M은 FastEnhancer paper Table 2의 paper-reported number로 표기한다.
- FE official checkpoint local eval과 paper-reported number가 다르면 source를 분리해서 표기한다.

Replacement target:

- 최종 CSV/MD는 `project_analysis/analyze_results/v5_baseline_20260614/` 아래 생성될 가능성이 높다.

### 2.2 Table: 48 kHz Full-Band Speech Enhancement

목적:

- 논문 main table.
- V5가 48 kHz full-band SE에서 DeepFilterNet2-style comparison protocol에 들어갈 수 있는지 보여준다.

Rows:

| row | source | status |
|---|---|---|
| DeepFilterNet2 + postfilter | paper-reported number 우선 | reference |
| TF-Locoformer | local train/eval result 있으면 사용 | baseline |
| MP-SENet | YOLO 학습 중단 여부에 따라 사용 가능성 낮음 | optional / pending |
| TF-Rehancer V5 online main | Attention GPU1 DNS4 48 kHz run | 진행 중 |
| TF-Rehancer V5 TimeMHSA | Zeroshot DNS4 48 kHz run | diagnostic |

Metrics for VBD48:

- Params
- MACs
- PESQ
- CSIG
- CBAK
- COVL
- STOI
- SI-SDR

Metrics for DNS blind:

- DNSMOS P.835 SIG / BAK / OVL
- DNSMOS P.808 if supported

Paperwork wording:

- “For 48 kHz full-band evaluation, the primary comparison follows the DNS4-trained setting where possible.”
- DFN2 number를 paper에서 가져오면 “paper-reported”로 명시한다.
- Same-evaluator 직접 비교가 아니면 “direct same-evaluator superiority” 표현 금지.

Replacement target:

- Attention run log: `project_analysis/run_logs/v5_final_48k_dns4_20260614/`
- expected result root should be created after eval, e.g. `project_analysis/analyze_results/v5_final_48k_dns4_20260614/`

### 2.3 Table: 48 kHz High-Band Analysis

목적:

- full-band SE를 주장할 때, high-band fidelity를 따로 보여준다.
- 48 kHz를 쓰는 이유가 “wide spectrum preservation”이므로 LSD/MCD/high-band LSD가 필요하다.

Rows:

- noisy
- DeepFilterNet2 if local output exists; 없으면 제외하거나 paper-reported metric만 분리
- TF-Locoformer if local output exists
- TF-Rehancer V5 online main
- Optional V5 TimeMHSA diagnostic

Metrics:

- LSD
- LSD-H@5k
- LSD-H@8k
- MCD
- optional: SI-SDR

Paperwork wording:

- “We additionally report high-band spectral metrics to avoid relying only on narrow-band intelligibility or perceptual proxies.”
- high-band metric이 낮으면, fullband claim을 과장하지 말고 “trade-off”로 적는다.

### 2.4 Table: Cross-Attention Removal Ablation

목적:

- Decoder MHCA가 필요한지 검증.
- V5에서는 encoder output `Z`가 이미 frequency concat으로 decoder input에 들어가므로, MHCA K/V route가 redundancy인지 확인한다.

Rows:

| row | protocol | status |
|---|---|---|
| V5 internal anchor, 5 kHz cutoff | VCTK+DNS 48 kHz, 20ep, VBD48 test | 완료: Echo best epoch 20 |
| V5 NoMHCA EFN Decoder | VCTK+DNS 48 kHz, 20ep, VBD48 test | 완료: Attention best checkpoint eval |

Metrics:

- Params
- MACs
- PESQ, CSIG, CBAK, COVL
- STOI, SI-SDR
- LSD, LSD-H@8k, MCD

Paperwork wording:

- “This internal ablation is not used as final model comparison because it uses a fast VCTK+DNS 20-epoch protocol.”
- 좋은 결과가 나와도 final model row로 쓰지 않는다. Architecture evidence로만 사용한다.
- Result readout: NoMHCA improves PESQ/STOI/CSIG/COVL/DNSMOS-SIG slightly, but anchor keeps better SI-SDR/LSD/LSD-H/MCD/DNSMOS-BAK/OVL/P808/UTMOS. Do not claim MHCA is unnecessary. Safer wording: “MHCA is not uniformly beneficial under the fast internal protocol and shows a perceptual-fidelity trade-off.”

Spec:

- `project_analysis/experiment_design/todo_specs_20260614/v5_cross_attention_removal_efn_decoder_spec.md`
- Result summary: `project_analysis/analyze_results/v5_auto_eval_20260614/v5_internal_ablation_mapping_nomhca_summary.md`

### 2.5 Table: Filter vs Mapping Ablation

목적:

- Complex TF filtering head가 direct mapping보다 나은 inductive bias인지 검증.

Rows:

| row | protocol | status |
|---|---|---|
| V5 filtering head anchor | VCTK+DNS 48 kHz, 20ep, VBD48 test | 완료: Echo best epoch 20 |
| V5 direct MappingHead | VCTK+DNS 48 kHz, 20ep, VBD48 test | 완료: Attention best checkpoint eval |

Metrics:

- Params
- MACs
- PESQ, CSIG, CBAK, COVL
- STOI, SI-SDR
- LSD, LSD-H@8k, MCD

Expected interpretation:

- MappingHead loses broadly: PESQ/STOI/CSIG/CBAK/COVL/SI-SDR/LSD/LSD-H/MCD/DNSMOS/UTMOS all worse than filtering anchor or NoMHCA filtering.
- This supports complex TF filtering as the safer output inductive bias under the internal ablation protocol.
- Do not overclaim final superiority until final protocol-aligned model tables are complete.

Spec:

- `project_analysis/experiment_design/todo_specs_20260614/v5_filter_vs_mapping_ablation_spec.md`
- Result summary: `project_analysis/analyze_results/v5_auto_eval_20260614/v5_internal_ablation_mapping_nomhca_summary.md`

### 2.6 Table: Low-Band Cutoff Ablation

목적:

- Low-band analysis / high-band refinement design에서 cutoff 선택의 민감도를 보여준다.
- Decoder high-band query와 encoder low-band analysis의 balance를 설명하는 핵심 ablation.

Rows:

| cutoff | server | status |
|---:|---|---|
| 8 kHz | Warmup GPU1 | 완료: best epoch 19, VBD48 eval 완료 |
| 7 kHz | Warmup GPU2 | 완료: best epoch 19, VBD48 eval 완료 |
| 6 kHz | Warmup GPU3 | 완료: best epoch 20, VBD48 eval 완료 |
| 5 kHz | Echo Anchor | 대표값: Echo best epoch 20 사용. Warmup GPU4 duplicate run은 audit-only |
| 4 kHz | YOLO GPU0 | 완료: best epoch 18, VBD48 eval 완료 |
| 3 kHz | YOLO GPU1 | 완료: best epoch 17, VBD48 eval 완료 |

Protocol:

- V5 `enc4/dec2`, `C48/C24`
- VCTK clean + DNS fullband noise synthesis
- 48 kHz
- SFI-STFT 1920/960
- 20ep
- VBD48 official test N=824

Metrics:

- Params
- MACs
- PESQ, CSIG, CBAK, COVL
- STOI, SI-SDR
- LSD, LSD-H@8k, MCD

Paperwork wording:

- “The cutoff ablation examines how much low-band context is required for full-band enhancement when the high band is provided as an observed query.”
- Warmup 5 kHz row is duplicate of the Echo anchor model/config and should not be used as the paper-facing 5 kHz result. Use Echo Anchor as the representative 5 kHz row.
- Best cutoff가 5 kHz가 아니면, method section의 default cutoff 설명을 결과에 맞게 수정한다.

Spec:

- `project_analysis/experiment_design/todo_specs_20260614/v5_cutoff_7_6_5_4_3_ablation_spec.md`

## 3. Chapter 4에 먼저 쓸 수 있는 내용

### 3.1 Dataset paragraph

먼저 작성 가능:

- 16 kHz comparison uses VoiceBank+DEMAND train/test protocol for FastEnhancer comparison.
- 48 kHz final comparison uses DNS4 English clean speech with DNS fullband noise for training where possible.
- Internal ablations use VCTK clean + DNS fullband noise synthesis for fast architecture ranking, then VBD48 official test for evaluation.

주의:

- Internal ablation protocol과 final DNS4 protocol을 같은 final comparison table에 섞지 않는다.
- VCTK+DNS 20ep result는 architecture decision evidence다.

### 3.2 Model configuration paragraph

먼저 작성 가능:

- Main V5 uses SFI-STFT 40/20 ms.
- Input feature: real/imag plus PLC magnitude channel.
- Low-band encoder receives bins below cutoff after shared F-axis stem.
- High-band query is processed by high-band refinement block and concatenated with encoder output along frequency axis.
- Decoder generates complex TF filter; enhanced output is obtained by filtering normalized linear noisy STFT.
- Temporal module in online main uses FastGRU-style causal temporal modeling.

주의:

- TimeMHSA row는 offline diagnostic이다. Online main으로 쓰지 않는다.

### 3.3 Evaluation paragraph

먼저 작성 가능:

- 16 kHz table: FE Table-2 style metrics.
- 48 kHz table: VBD48 full metrics plus high-band metrics.
- DNSMOS P.835는 SIG/BAK/OVL separate columns로 표기한다.
- Source column must distinguish:
  - `local same-protocol run`
  - `official checkpoint local eval`
  - `paper-reported number`

## 4. Paper table skeletons

### 4.1 16 kHz Speech Enhancement Table

| Model | Source | Params ↓ | MACs ↓ | DNSMOS P.808 ↑ | P.835 SIG ↑ | P.835 BAK ↑ | P.835 OVL ↑ | SCOREQ ↓ | SI-SDR ↑ | PESQ ↑ | STOI ↑ | ESTOI ↑ |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| BSRNN | FastEnhancer Table 2, paper-reported | **0.334M** | **0.245G** | 3.44 | 3.36 | 4.00 | 3.07 | 0.303 | 18.9 | 3.06 | 0.942 | 0.855 |
| FastEnhancer-M | FastEnhancer Table 2, paper-reported | 0.492M | 2.90G | <u>3.48</u> | 3.39 | 4.02 | <u>3.11</u> | **0.243** | <u>19.4</u> | 3.24 | <u>0.950</u> | <u>0.873</u> |
| TF-Rehancer V5 16 kHz anchor, current-best ep295/296 | local same-protocol run | <u>0.470M</u> | <u>1.90G</u> | **3.49** | **3.41** | <u>4.04</u> | **3.13** | <u>0.244</u> | <u>19.4</u> | <u>3.33</u> | <u>0.950</u> | 0.872 |
| TF-Rehancer V5-T1 TimeMHSA-EFN, current-best ep77 | local same-protocol run, offline diagnostic | 0.615M | 2.00G | <u>3.48</u> | <u>3.40</u> | **4.05** | **3.13** | 0.247 | **19.6** | **3.39** | **0.952** | **0.874** |

Note:

- BSRNN/FastEnhancer-M values come from FastEnhancer Table 2 on VoiceBank+DEMAND.
- TF-Rehancer value uses `project_analysis/analyze_results/v5_baseline_20260614/conscompressed_tmax500_currentbest_ep296_table2/full_se_metrics_n824.csv`. The watcher log saw latest `epoch.0295.pth`; the eval artifact records `epoch=296`, so this row is labeled `ep295/296` to avoid source ambiguity.
- Display precision follows the FastEnhancer Table 2 style: DNSMOS/PESQ two decimals, SCOREQ/STOI/ESTOI three decimals, and SI-SDR one decimal.
- Local TF-Rehancer Params/MACs use the maximum value among `ptflops`, `THOP`, and `torchinfo`. Paper-reported reference rows keep paper Table 2 values.
- Bold marks best value by column direction. Underline marks second-best value. Ties after display rounding share the same marking.

### 4.2 48 kHz Full-Band Table

| Model | Source | Params ↓ | MACs ↓ | PESQ ↑ | CSIG ↑ | CBAK ↑ | COVL ↑ | STOI ↑ | SI-SDR ↑ | DNSMOS SIG ↑ | DNSMOS BAK ↑ | DNSMOS OVL ↑ |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| DeepFilterNet2 + PostFilter | paper-reported | 2.31M | **0.36G** | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| TF-Locoformer Stack B16/R1 | local complexity reference | 7.424M | 474.90G | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| TF-Rehancer V5 online, enc6/dec3 C48/C24 | local same-protocol run | **0.689M** | <u>4.14G</u> | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| TF-Rehancer V5 TimeMHSA, enc6/dec3 C48/C24 | diagnostic, local run | <u>0.906M</u> | 4.31G | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

Near-term note:

- Local TF-Rehancer Params/MACs in this table use the maximum value among `ptflops`, `THOP`, and `torchinfo`, 1 s input, model-only profile. No `effective MACs` value is shown.
- Current V5 online DNS4 48 kHz run will not reach `epoch100` today.
- If a draft row is needed by 2026-06-14 24:00 KST, evaluate `weights_best/best.pth` after `epoch20` appears. Label row as `near-final epoch20 DNS4 run`, not final.
- V5-T1 TimeMHSA 48 kHz diagnostic is shown with the same `enc6/dec3 C48/C24` scale as the V5 online 48 kHz row. Use only as `intermediate offline diagnostic` if evaluated before completion.

### 4.3 48 kHz High-Band Table

| Model | Source | LSD ↓ | LSD-H@5k ↓ | LSD-H@8k ↓ | MCD ↓ | SI-SDR ↑ |
|---|---|---:|---:|---:|---:|---:|
| Noisy | local eval | TBD | TBD | TBD | TBD | TBD |
| TF-Locoformer | local run if available | TBD | TBD | TBD | TBD | TBD |
| TF-Rehancer V5 online | local same-protocol run | TBD | TBD | TBD | TBD | TBD |
| TF-Rehancer V5 TimeMHSA | diagnostic, local run | TBD | TBD | TBD | TBD | TBD |

### 4.4 Internal Architecture Ablation Table

| Model | Changed component | Protocol | Params ↓ | MACs ↓ | PESQ ↑ | COVL ↑ | STOI ↑ | SI-SDR ↑ | LSD ↓ | LSD-H@8k ↓ | MCD ↓ |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| V5 internal anchor | none | VCTK+DNS 48k 20ep | <u>0.470</u> | <u>3.04</u> | <u>3.285</u> | <u>3.878</u> | <u>0.947</u> | **16.835** | **0.719** | **0.709** | **2.265** |
| V5 NoMHCA EFN decoder | remove decoder MHCA | VCTK+DNS 48k 20ep | 0.477 | 3.14 | **3.294** | **3.899** | **0.948** | <u>16.379</u> | <u>0.737</u> | <u>0.735</u> | <u>2.283</u> |
| V5 MappingHead | filter head -> direct mapping | VCTK+DNS 48k 20ep | **0.464** | **2.79** | 3.054 | 3.658 | 0.940 | 14.896 | 0.776 | 0.775 | 2.524 |

### 4.5 Cutoff Ablation Table

| Cutoff | Protocol | Params ↓ | MACs ↓ | PESQ ↑ | COVL ↑ | STOI ↑ | SI-SDR ↑ | LSD ↓ | LSD-H@8k ↓ | MCD ↓ |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 8 kHz | VCTK+DNS 48k 20ep | 0.470 | 3.83 | **3.305** | **3.896** | <u>0.946</u> | 16.503 | 0.752 | 0.748 | 2.382 |
| 7 kHz | VCTK+DNS 48k 20ep | 0.470 | 3.57 | <u>3.294</u> | 3.878 | **0.947** | 16.111 | 0.753 | 0.752 | 2.347 |
| 6 kHz | VCTK+DNS 48k 20ep | 0.470 | 3.30 | 3.293 | <u>3.888</u> | **0.947** | <u>16.747</u> | <u>0.721</u> | **0.708** | **2.257** |
| 5 kHz | VCTK+DNS 48k 20ep, Echo anchor representative | 0.470 | 3.04 | 3.285 | 3.878 | **0.947** | **16.835** | **0.719** | <u>0.709</u> | <u>2.265</u> |
| 4 kHz | VCTK+DNS 48k 20ep | 0.470 | <u>2.78</u> | 3.271 | 3.869 | **0.947** | 16.286 | 0.733 | 0.725 | 2.312 |
| 3 kHz | VCTK+DNS 48k 20ep | 0.470 | **2.51** | 3.226 | 3.841 | <u>0.946</u> | 15.406 | 0.781 | 0.787 | 2.378 |

Note:

- Cutoff variants have the same parameter count after display rounding, so Params rank marking is omitted in this table.
- MACs use the maximum value among `ptflops`, `THOP`, and `torchinfo`.

## 5. Claim safety rules for Paperwork

1. Final contribution wording should wait for:
   - V5 48 kHz DNS4 result
   - V5 16 kHz result
   - Cross-attention / mapping / cutoff ablations
2. 지금 작성 가능한 claim:
   - “We propose a low-band analysis and high-band refinement framework.”
   - “The model avoids ERB compression or narrow band-split embeddings in the observed high-band path.”
   - “We evaluate both protocol-aligned final models and fast internal ablations.”
3. 아직 쓰면 안 되는 claim:
   - “outperforms DeepFilterNet2”
   - “outperforms FastEnhancer-M”
   - “cross-attention is unnecessary”
   - “filtering is superior to mapping”
   - “5 kHz cutoff is optimal”
4. Table source labels mandatory:
   - `local same-protocol run`
   - `official checkpoint local eval`
   - `paper-reported`
   - `internal ablation`

## 6. Pending after training completes

1. Evaluate all active runs with best-valid checkpoint, not final epoch.
2. Produce CSV/MD result folders for each table.
3. Replace `TBD` in this handoff skeleton.
4. Bold best value and underline second-best value by metric direction.
5. Keep internal ablation tables separate from final comparison tables.
