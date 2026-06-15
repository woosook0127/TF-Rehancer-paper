# Paper Team Revision Plan — User-Confirmed Direction

Target manuscript: `thesis.pdf` first complete draft  
Purpose: revise the paper according to the confirmed author choices and the prior deep-review recommendations.  
Status: use this document as the authoritative handoff for the next revision pass.

---

## 0. Global Positioning

### 0.1 Keep the current title

Do **not** rename the thesis title. Keep:

```text
Full-Band Speech Enhancement via Low-Band-Conditioned Refinement
```

Previous title suggestions are rejected for now. Do not change the cover/title pages.

### 0.2 Core contribution wording

The contribution should be framed as:

```text
low-band encoder-guided full-band decoder refinement
```

Do not reduce the contribution to HBR or to a high-band query trick. The key idea is that the decoder-side full-band representation is refined using low-band encoder context.

Use this wording family:

- `low-band encoder-guided full-band decoder refinement`
- `low-band-conditioned refinement of decoder-side full-band representations`
- `observed high-band evidence in the decoder path`
- `complex TF filtering over the original noisy STFT`

Avoid:

- `HBR is the main contribution`
- `high band is generated from low band`
- `observed high-band query is proven necessary`
- `48 kHz full-band SOTA`
- `external full-band system ranking`

### 0.3 Attention-based defense logic

Use the following defense logic when revising Introduction, Figure captions, and Method.

From the attention viewpoint:

```text
Q = decoder-side full-band / full-resolution input representation
K, V = low-band encoded representation
Output = full-band decoder representation refined under low-band context
```

The low-band encoder output serves as **conditioning context**. It conditions the update direction of the full-band query representation. This avoids the mistaken interpretation that the model simply generates high-band speech from low-band input.

Recommended wording:

```text
The decoder-side full-band representation is used as the query, while the low-band encoder output provides the key and value context. Cross-attention therefore conditions the update of the full-band decoder representation using low-band speech-structure evidence.
```

More compact version:

```text
The low-band encoder output acts as the key-value context that conditions the refinement of the decoder-side full-band query representation.
```

Use this argument to defend against reviewer questions such as:

- “Is the high band generated from low-band speech?”
- “Is this just bandwidth extension?”
- “What exactly does the low-band representation do in attention?”

Answer:

```text
No. The high-band/full-band representation is already present in the decoder-side query path. Low-band encoder features are used as conditioning context for refinement, not as the sole source for high-band generation.
```

---

## 1. Abstract Revision

### 1.1 Use Option A for FastEnhancer-M comparison

Use the current PDF approach: FastEnhancer-M is a **paper-reported reference**.

Keep the comparison, but make the caveat explicit.

Recommended sentence:

```text
Against the paper-reported FastEnhancer-M reference, the low-computation TF-Rehancer configuration reports higher PESQ-WB, SI-SDR, and DNSMOS P.835 values with fewer model-side MACs, while FastEnhancer-M remains slightly stronger in SCOREQ and ESTOI.
```

Add caveat if space allows:

```text
This comparison is interpreted as benchmark context rather than a same-evaluator ranking.
```

### 1.2 Use “low-computation TF-Rehancer configuration”

Replace:

```text
online-friendly TF-Rehancer configuration
```

with:

```text
low-computation TF-Rehancer configuration
```

Rationale: strict streaming/RTF evidence is not included. `low-computation` matches the current evidence better than `online-friendly`.

### 1.3 Keep 48 kHz claim limited

The Abstract must state that the 48 kHz results are **controlled ablations**, not external full-band ranking.

Safe sentence:

```text
The 48 kHz experiments are used as controlled full-band ablations rather than external system rankings.
```

Do not write:

```text
TF-Rehancer achieves state-of-the-art 48 kHz full-band speech enhancement.
```

---

## 2. Introduction Revision

### 2.1 Keep the current high-level narrative

The Introduction should continue to emphasize:

1. 16 kHz wideband SE does not directly model the full 48 kHz spectrum.
2. BWE/Speech-SR reconstruct missing high-frequency content, while full-band SE enhances noisy observed upper-band components.
3. Practical full-band models such as PercepNet and DeepFilterNet2 are important but use perceptual/ERB-band compression for efficiency.
4. TF-Rehancer proposes low-band encoder-guided decoder refinement and complex TF filtering.
5. The evaluation contains a 16 kHz quality-efficiency comparison and controlled 48 kHz ablations, not external full-band ranking.

### 2.2 Contribution wording

Revise contribution bullets to match the chosen framing.

Recommended contribution wording:

```text
1. We frame direct 48 kHz full-band SE as observation-preserving enhancement, where upper-band components are treated as noisy spectral evidence rather than missing content to be generated after wideband processing.

2. We propose TF-Rehancer, a TF-domain architecture for low-band encoder-guided full-band decoder refinement. The decoder-side full-band representation is refined using low-band encoder context, and the enhanced spectrum is estimated through complex filtering over the noisy STFT.

3. We provide a 16 kHz quality-efficiency comparison and controlled 48 kHz ablations that analyze complex TF filtering, decoder cross-attention, and low-band cutoff sensitivity without treating them as external full-band system rankings.
```

### 2.3 Figure 1.1 caption

The current caption focuses too much on “observed high-band query.” Revise toward the chosen contribution.

Recommended caption:

```text
Figure 1.1: Conceptual overview of TF-Rehancer. The model encodes low-band speech evidence, keeps observed high-band information in the decoder path, refines the decoder-side full-band representation using low-band context, and estimates the enhanced spectrum through local complex filtering.
```

If the figure shows Q/K/V explicitly, use this caption:

```text
Figure 1.1: Conceptual overview of TF-Rehancer. The decoder-side full-band representation serves as the query, while the low-band encoder output provides the key-value context for cross-band refinement. The refined representation is then used to estimate local complex filters over the original noisy STFT.
```

### 2.4 Attention defense paragraph

Add a short paragraph either in Introduction or in the Method transition.

Recommended paragraph:

```text
From the attention perspective, the decoder-side full-band representation serves as the query, and the low-band encoder output serves as the key-value context. Thus, cross-attention does not generate high-band speech from low-band information alone; rather, it conditions the update of the observed full-band decoder representation using low-band speech-structure evidence.
```

This paragraph is especially useful for reviewer defense.

---

## 3. Related Work Revision

### 3.1 Rename Related Work sections

Use the author-confirmed section titles:

```text
2.1 Wideband SE and the Observed Gap
2.2 Full-Band Speech Enhancement
2.3 Query-Based Modeling Method
```

Minor grammar note: `Query-Based Modeling Method` is acceptable if the author wants this title, but `Query-Based Modeling Methods` is more natural. Use the author’s title unless the thesis style team strongly prefers plural.

### 3.2 2.1 Wideband SE and the Observed Gap

Purpose:

- Briefly summarize wideband SE progress.
- Explain why 16 kHz SE leaves an observed-band gap for 48 kHz full-band signals.
- Distinguish full-band SE from BWE/Speech-SR.

Keep:

```text
Neural SE has evolved from TF mask estimation to phase-aware, complex-domain, time-domain, and modern TF-domain modeling.
```

Keep the BWE/full-band distinction.

Recommended closing sentence:

```text
This information-condition difference motivates direct full-band enhancement, where upper-band components are treated as noisy observed evidence rather than missing content.
```

### 3.3 2.2 Full-Band Speech Enhancement

Purpose:

- Discuss PercepNet and DeepFilterNet2 as practical full-band references.
- Discuss frequency-structured modeling such as BSRNN, BS-RoFormer, TF-Locoformer, GTCRN, LiSenNet, FastEnhancer if needed.
- Avoid overclaiming that ERB/perceptual-band methods are weak.

Replace overly strong wording such as:

```text
preserve explicit frequency-bin evidence
```

with safer wording:

```text
Such perceptual or ERB-band representations trade bin-level spectral resolution for efficiency, motivating complementary TF-domain designs based on learned frequency representations and observation-preserving filtering.
```

This avoids a reviewer attack that TF-Rehancer also uses frequency-strided compression.

### 3.4 2.3 Query-Based Modeling Method — keep or remove?

Decision: **keep 2.3, but make it shorter and safer.**

Reason:

- It explains the lineage from TF-Restormer without weakening the novelty.
- It helps defend why query-based modeling is relevant.
- It allows the paper to distinguish missing-band query restoration from observed full/high-band refinement.

Risk:

- If written too strongly, it can make TF-Rehancer look like a direct adaptation of TF-Restormer rather than a new SE architecture.

Therefore, 2.3 should be compact and limited to the role change:

```text
TF-Restormer uses decoder-side queries for target frequency regions in restoration with decoupled input-output rates. In bandwidth restoration, such queries can represent missing frequency regions. In direct full-band SE, however, the high-frequency region is already observed in the noisy input. TF-Rehancer therefore uses decoder-side observed full/high-band representations and refines them using low-band encoder context.
```

Do **not** write:

```text
TF-Rehancer is based on TF-Restormer.
```

Do **not** imply:

```text
TF-Restormer already solved the same observed high-band refinement problem.
```

### 3.5 SFI-STFT in Related Work

SFI-STFT is not the main related work contribution. Reduce or remove the detailed SFI-STFT explanation from Related Work.

Recommended:

- Keep detailed SFI-STFT explanation in Method 3.2.1.
- In Related Work 2.3, mention it at most in one short sentence if needed.

Short sentence if retained:

```text
TF-Restormer also uses a duration-fixed STFT frontend, which is useful for comparing TF-domain representations across sampling rates.
```

If space is tight, remove SFI-STFT from Related Work entirely.

---

## 4. Proposed Method Revision

### 4.1 Keep current structure

Current Method structure is acceptable:

```text
3.1 Problem Definition / Problem Formulation
3.2 TF-Rehancer Architecture
3.2.1 SFI-STFT Conditioning
3.2.2 Observed High-Band Query
3.2.3 Cross-Band Refinement
3.2.4 Complex TF Filtering
3.3 Training Objective
```

Optional title polish:

```text
3.1 Problem Formulation
3.2.1 SFI-STFT Conditioning and Shared Embedding
3.2.3 Cross-Band Decoder Refinement
```

### 4.2 Add attention defense in 3.2.3

The current Method already explains cross-band refinement, but add the attention-context defense explicitly.

Recommended text after Eq. (3.5):

```text
In this attention view, the decoder-side full-band representation provides the query, while the low-band encoder output provides the key and value context. The low-band representation therefore conditions the update direction of the decoder-side full-band representation. This differs from generating high-band content from low-band features alone, because the high-band evidence is already present in the decoder-side representation.
```

If the implementation updates only high-band tokens, use this more precise version:

```text
In this attention view, the decoder-side representation, including the observed high-band query, provides the query, while the low-band encoder output provides the key and value context. The low-band representation therefore conditions the update of the observed high-band/full-band decoder representation.
```

### 4.3 Add MHCA projection sentence

Add after the MHCA equation:

```text
The query, key, and value tensors are linearly projected inside the MHCA module, so the low-band encoder width and decoder width need not be identical.
```

### 4.4 F-stride vs ERB compression defense

Add one sentence in Method or at the end of Related Work 2.2.

Recommended:

```text
TF-Rehancer does not avoid frequency compression; instead, it uses learned frequency-strided embedding for compact modeling while keeping the final enhancement tied to the original noisy STFT through full-resolution complex filtering.
```

This prevents reviewer criticism that the paper attacks ERB compression while using F-stride itself.

### 4.5 Replace “matched-rate” terminology

If the manuscript still contains `matched-rate`, replace it.

Use:

```text
16 kHz and 48 kHz speech enhancement, where input and target share the same sampling rate
```

or simply:

```text
same-sampling-rate speech enhancement
```

---

## 5. Chapter 4 Experiments Revision

### 5.1 Use Option A: keep current PDF-style 16 kHz comparison

The author chooses Option A:

- Keep the current PDF-style 16 kHz table using the paper-reported FastEnhancer-M row.
- Ensure citation is clear.
- Do not overclaim same-evaluator ranking.

Recommended wording:

```text
The FastEnhancer-M row is paper-reported and is used as benchmark context rather than as a same-evaluator comparison.
```

Keep `TF-Rehancer (on)` / `TF-Rehancer (off)` terminology if desired, but caption must define it.

Recommended caption addition:

```text
(on) denotes the FastGRU-based low-computation configuration, and (off) denotes the non-streaming TimeMHSA-EFN diagnostic configuration. No runtime or streaming claim is made.
```

### 5.2 Metric naming

The author chooses to keep current metric naming.

Therefore:

- Keep current `DNSMOS(P.835) SIG / BAK / OVL` style if already used.
- Do not force `OVRL` unless the paper team decides to align all source names later.
- Keep current `P.808`/`P808` style if already consistent within each table, but avoid mixing inside the same table.

### 5.3 Keep online-friendly/offline terminology with caption caveat

Maintain current on/off row labels if desired.

Allowed labels:

```text
TF-Rehancer (on)
TF-Rehancer (off)
```

Mandatory caption/caveat:

```text
TF-Rehancer (on) denotes the FastGRU-based low-computation configuration, while TF-Rehancer (off) denotes the TimeMHSA-EFN offline diagnostic configuration. The table does not claim measured real-time or streaming performance.
```

### 5.4 Keep current section order

The author chooses not to reorder low-band cutoff and architecture ablation.

Keep:

```text
4.2.1 Wideband Results
4.2.2 Low-Band Cutoff
4.2.3 Architecture Ablations
```

Do not move architecture ablation before cutoff unless later explicitly requested.

### 5.5 Remove LSD-H if not used

The author chooses to omit LSD-H because LSD-H and LSD are nearly identical in the current result.

Therefore:

- Do not force LSD-H@8k into Chapter 4.
- Use LSD and MCD as spectral metrics.
- Remove or simplify any metric definition for LSD-H if the final tables do not include it.

### 5.6 Architecture Ablation flow

Adopt the recommended table-first flow.

Use:

```text
4.2.3 Architecture Ablations
[Table]
Interpretation paragraph
```

Do not put the interpretation paragraph before the table.

Recommended interpretation:

```text
The direct mapping head is weaker than complex TF filtering across the reported metric families. This suggests that filtering-based output estimation is more reliable than direct spectrum mapping in the 48 kHz ablation setting. The w/o decoder MHCA variant shows a mixed trend. It improves STOI, ESTOI, CSIG, COVL, and DNSMOS SIG, but degrades SI-SDR, LSD, MCD, and DNSMOS BAK, while DNSMOS OVL remains tied after rounding. Thus, decoder MHCA should be interpreted as changing the trade-off between perceptual scores and spectral fidelity, rather than as a uniformly beneficial module.
```

### 5.7 48 kHz external comparison absence

Adopt the recommended caveat sentence.

Place near the start of Chapter 4 or before the 48 kHz ablation discussion:

```text
Because a protocol-aligned 48 kHz comparison against external full-band systems is not available in this study, the 48 kHz experiments are designed as controlled component analyses rather than external system comparisons.
```

This is required to defend the absence of external 48 kHz baseline comparison.

### 5.8 Table 4.1 source policy

Since Option A is selected, ensure the text says:

```text
Relative to the paper-reported FastEnhancer-M reference, ...
```

Do not write:

```text
Compared with the locally evaluated FastEnhancer-M checkpoint, ...
```

because the selected table uses paper-reported FE-M.

---

## 6. Chapter 5 Conclusion and Limitations

### 6.1 Adopt the revised 5.2 Limitations and Future Work

Change section title:

```text
5.2 Limitations
```

into:

```text
5.2 Limitations and Future Work
```

### 6.2 Keep the core limitation

Retain this limitation idea:

```text
The 48 kHz experiments are designed for controlled component analysis, not for ranking against external full-band speech enhancement systems.
```

### 6.3 Use the safe future-work direction

Do not propose learned/zero/generated high-band query alternatives in a way that weakens the observed high-band path.

Use:

```text
Further isolating the lightweight high-band adaptation from the subsequent decoder refinement would clarify this component, for example by removing or replacing the local high-band adapter while preserving the observed high-band embedding.
```

### 6.4 Add protocol-aligned 48 kHz future work

Use:

```text
A protocol-aligned 48 kHz comparison with strong full-band baselines remains necessary to assess how far the controlled findings generalize beyond the ablation setting.
```

### 6.5 Optional final sentence

If desired, end with:

```text
These extensions would further clarify the role of low-band-guided refinement in practical full-band speech enhancement.
```

---

## 7. Additional Review Decisions Adopted by Default

For all items not explicitly overridden by the author, adopt the previous deep-review recommendations.

That means:

- Keep claims below full-band SOTA/external ranking level.
- Keep DeepFilterNet2 and PercepNet descriptions respectful and non-adversarial.
- Avoid saying TF-Rehancer avoids compression; it uses learned compact embedding and filtering-based output estimation.
- Use `controlled 48 kHz ablation` wording for 48 kHz experiments.
- Avoid raw internal-document language such as `pending`, `current evidence set`, `TBD`, `active`, `metric wrapper`, `paperwork`, or local artifact paths in the main body.
- Make every table caption clarify whether a row is paper-reported, local evaluation, diagnostic, or ablation.
- Do not claim runtime/streaming performance unless RTF/latency is measured.

---

## 8. Final Checklist for Paper Team

### Title

- [ ] Keep current title.

### Abstract

- [ ] Use `low-computation TF-Rehancer configuration`.
- [ ] Keep FastEnhancer-M as paper-reported reference.
- [ ] Add benchmark-context caveat.
- [ ] Keep 48 kHz results as controlled ablations.

### Introduction

- [ ] Add attention defense logic.
- [ ] Revise Figure 1.1 caption toward full-band decoder refinement.
- [ ] Revise contribution bullets to emphasize low-band encoder-guided full-band decoder refinement.

### Related Work

- [ ] Rename sections to user-confirmed titles.
- [ ] Keep 2.3 but shorten and make it safer.
- [ ] Remove or greatly reduce SFI-STFT explanation in Related Work.
- [ ] Add F-stride vs ERB compression defense.

### Method

- [ ] Add attention Q/K/V explanation.
- [ ] Add MHCA projection sentence.
- [ ] Remove `matched-rate` wording.
- [ ] Ensure high-band query is described as embedded observed high-band evidence, not raw STFT or learned placeholder.

### Experiments

- [ ] Keep current table source policy Option A.
- [ ] Keep current metric naming style.
- [ ] Keep on/off labels with caption caveat.
- [ ] Keep current order: Wideband Results → Low-Band Cutoff → Architecture Ablations.
- [ ] Do not force LSD-H if final tables omit it.
- [ ] Make architecture ablation table-first.
- [ ] Add 48 kHz external-comparison absence caveat.

### Conclusion

- [ ] Rename 5.2 to `Limitations and Future Work`.
- [ ] Keep controlled-component-analysis limitation.
- [ ] Use safe high-band adapter future work.
- [ ] Avoid full-band external superiority claims.

---

## 9. One-Sentence Final Positioning

Use this as the paper’s internal north star:

```text
This thesis proposes TF-Rehancer as a low-band encoder-guided full-band decoder refinement architecture for speech enhancement, validated through 16 kHz quality-efficiency comparison and controlled 48 kHz component ablations rather than external full-band system ranking.
```
