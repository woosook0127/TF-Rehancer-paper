# Final Refine Instructions for Writing Team

**Scope:** Apply these edits to the latest thesis draft. This is the final refinement pass before paper-team handoff.

The most important update is that the **VBD48 table should be used as a main 48 kHz full-band result**, not as a weakly titled “reference positioning” subsection. However, the interpretation must remain conservative because the PercepNet/DeepFilterNet2 rows are paper-reported references, while the TF-Rehancer row is locally evaluated.

---

## 0. Global decisions

### 0.1 Title

Adopt the reviewer’s suggested title:

```text
Full-Band Speech Enhancement via Low-Band-Guided Refinement
```

Reason:
- The current title uses **Low-Band-Conditioned**, but the body consistently uses **guided / encoder-guided / refinement**.
- “Low-Band-Guided Refinement” is shorter, clearer, and better aligned with the final contribution statement.
- Update the cover page, approval page title, running title if any, and metadata.

### 0.2 Global core phrase

Use the following **high-level phrase** consistently:

```text
low-band-guided full-band refinement
```

Use the following **technical clarification** only where detail is needed:

```text
The low-band encoder output provides key/value context for updating the observed high-band decoder tokens. The updated high-band tokens are then modeled together with the low-band tokens by full-sequence decoder modules.
```

Avoid repeatedly writing the long phrase:

```text
low-band encoder-guided high-band token update followed by full-band decoder modeling
```

That phrase is accurate, but too long for repeated abstract/introduction/conclusion usage.

### 0.3 Keep the attention mechanism precise

Do **not** write that “low-band evidence refines the full-band representation” without clarification. The exact mechanism is:

1. Shared input stem produces embedded low/high-band features.
2. Low-band features are encoded into \(Z\).
3. High-band features form \(Q_h\) through the high-band adapter.
4. Decoder input is formed by concatenating \(Z\) and \(Q_h\), followed by projection.
5. In MHCA, **only the high-band decoder tokens are updated**:
   \[
   Q = D_{\mathrm{high}}, \quad K,V = Z
   \]
6. The updated high-band tokens are concatenated back with low-band decoder tokens.
7. The following full-sequence F-MHSA / FFN / temporal modules model the entire embedded sequence.

Safe wording:

```text
Cross-attention updates the high-band portion of the decoder representation using low-band encoder context; subsequent decoder modules model the full embedded sequence.
```

Unsafe wording:

```text
Low-band evidence refines the full-band representation.
```

This is too broad and hides the high-band-only MHCA update.

---

## 1. Abstract revision

The Abstract should not over-promote the 48 kHz DFN2 comparison, but now that the VBD48 table is main, it should mention it once.

### 1.1 Replace the first paragraph core method sentence

Current style is too long.

Use:

```text
TF-Rehancer performs low-band-guided full-band refinement: it encodes low-band speech structure, preserves observed upper-band evidence in the decoder path, and estimates the enhanced spectrum through local complex time-frequency filtering over the original noisy STFT.
```

If space is tight:

```text
TF-Rehancer combines low-band-guided full-band refinement with local complex time-frequency filtering over the original noisy STFT.
```

### 1.2 Add 48 kHz result without making it the abstract headline

Do **not** use “reference positioning” in the Abstract.

Use:

```text
On the VoiceBank+DEMAND 48 kHz test set, TF-Rehancer reports competitive full-reference scores compared with published PercepNet and DeepFilterNet2 references, while the published rows are not locally re-evaluated baselines.
```

This is enough. Do not add more caveat sentences in the Abstract.

### 1.3 Replace “low-computation configuration”

Avoid:

```text
low-computation TF-Rehancer configuration
```

Prefer:

```text
compact FastGRU-based TF-Rehancer configuration
```

or simply:

```text
TF-Rehancer (on)
```

Use `on/off` only if already defined in the table caption. In prose, prefer:

```text
FastGRU-based configuration
TimeMHSA-EFN configuration
```

Avoid excessive “diagnostic configuration” language in the Abstract.

---

## 2. Introduction revision

### 2.1 Top-level contribution statement

Use this high-level version:

```text
In this work, we propose TF-Rehancer, a refinement-oriented time-frequency architecture for direct full-band speech enhancement. The core idea is low-band-guided full-band refinement. TF-Rehancer concentrates heavier encoding on low-band speech structure, preserves observed upper-band evidence in the decoder path, and estimates the enhanced spectrum through complex filtering over the original noisy STFT.
```

Then, if attention detail is needed, add one compact paragraph:

```text
From the attention perspective, the low-band encoder output provides key/value context for the high-band portion of the decoder representation. Cross-attention updates the observed high-band decoder tokens, after which full-sequence decoder modules model the joint low- and high-band representation.
```

Avoid repeating both versions many times.

### 2.2 Figure 1.1 caption

Current caption should be made precise and not too long.

Use:

```text
Figure 1.1: Conceptual overview of TF-Rehancer. The low-band encoder output provides key/value context for updating the observed high-band decoder tokens. The updated representation is then processed by full-sequence decoder modules and used to estimate local complex filters over the original noisy STFT.
```

This is better than saying the “full-band representation serves as the query,” because MHCA updates only the high-band portion.

### 2.3 Contribution list

Revise the second contribution to:

```text
We propose TF-Rehancer, a TF-domain architecture for low-band-guided full-band refinement. It updates observed high-band decoder tokens using low-band encoder context, models the resulting full embedded sequence, and estimates the enhanced spectrum through complex filtering over the noisy STFT.
```

Revise the third contribution to include the VBD48 main result:

```text
We evaluate TF-Rehancer through a 16 kHz quality-efficiency comparison, 48 kHz full-band results against published full-band references, and controlled 48 kHz ablations of complex filtering, decoder cross-attention, and low-band cutoff.
```

Do not say “external full-band ranking.”

---

## 3. Related Work

### 3.1 Section headings

Use the current improved heading style, or adopt the following final headings:

```text
2.1 Full-Band Speech Enhancement
2.2 Efficient Full-Band Modeling
2.3 Query Refinement and TF Filtering
```

This is better than:

```text
Wideband SE and the Observed Gap
Query-Based Modeling Method
```

because those headings sound less final-paper ready.

### 3.2 SFI-STFT

Do not over-explain SFI-STFT in Related Work. It is not the related-work contribution of this paper.

If SFI-STFT is still described in Chapter 2, keep it to one short sentence, or move detail to Method:

```text
TF-Rehancer adopts SFI-STFT only as a consistent TF parameterization across sampling rates; the main contribution is the low-band-guided refinement architecture.
```

### 3.3 Query section caution

Keep the query section, but make it short and defensive of the novelty.

Do not make TF-Restormer sound like it already solved your problem. The contrast must be explicit:

```text
TF-Restormer uses decoder-side queries for missing or target frequency regions in restoration. TF-Rehancer instead uses query modeling in direct full-band SE, where the high-band region is observed and noisy. The query is therefore not a missing-band placeholder; it is derived from observed high-band evidence and updated using low-band context.
```

---

## 4. Method section

### 4.1 Problem Definition

Current content is mostly correct. Ensure the last paragraph does not overgeneralize.

Safe wording:

```text
For a 48 kHz full-band input, the upper band is already present in \(Y\), although it is corrupted by noise. TF-Rehancer treats this region as observed noisy evidence, derives decoder-side high-band query features from it, and refines the decoder representation before complex filtering.
```

### 4.2 Architecture overview

Use the concise global phrase, then detail the mechanism.

Safe overview:

```text
This section describes TF-Rehancer as a low-band-guided full-band refinement pipeline: shared TF embedding, observed high-band query construction, cross-band decoder refinement, and full-resolution complex TF filtering.
```

### 4.3 Cross-Band Refinement subsection

This section must remain precise. Keep or restore the explicit high-band-only update:

```text
In each decoder block, MHCA updates only the high-band decoder tokens. The high-band tokens are used as queries, while the low-band encoder output provides the key and value context.
```

Equation should preserve this meaning:

\[
\tilde{D}_{\mathrm{high}} =
D_{\mathrm{high}} + \mathrm{MHCA}(D_{\mathrm{high}}, Z, Z)
\]

Then:

```text
The updated high-band tokens are concatenated back with the low-band decoder tokens, and the subsequent frequency self-attention, feed-forward processing, and temporal module operate on the full embedded sequence.
```

### 4.4 Figure 3.1 caption

Use a medium-length caption:

```text
Figure 3.1: Overall TF-Rehancer architecture. The shared input layer embeds the full-band STFT. The low-band region is encoded by the TF encoder, while the observed high-band region is carried as decoder-side query evidence. Decoder cross-attention updates the high-band tokens using low-band encoder context, and subsequent full-sequence decoder modeling produces features for complex TF filter estimation.
```

### 4.5 Figure 3.3 caption

Use:

```text
Figure 3.3: TF-Rehancer encoder and decoder core blocks. The encoder frequency module uses a Macaron-style F-ConvFFN–F-MHSA–F-ConvFFN structure with RoPE. The decoder frequency module first applies F-MHCA to update high-band tokens using low-band encoder context, then applies full-sequence F-MHSA and F-ConvFFN.
```

### 4.6 Training Objective

Current compressed version is acceptable.

Optional minor polish:

- If the paper has space, keep the one-sentence descriptions of \(L_{\mathrm{mag}}\), \(L_{\mathrm{cplx}}\), \(L_{\mathrm{cons}}\), \(L_{\mathrm{wav}}\), and \(L_{\mathrm{pesq}}\).
- Avoid saying \(L_{\mathrm{mag}}\) “stabilizes high-band energy” too strongly. Use “encourages magnitude consistency” instead.

Recommended replacement:

```text
Here, \(L_{\mathrm{mag}}\) and \(L_{\mathrm{cplx}}\) compare compressed magnitude and compressed complex spectra, \(L_{\mathrm{cons}}\) enforces STFT consistency after waveform reconstruction, \(L_{\mathrm{wav}}\) is an \(\ell_1\) waveform-domain term, and \(L_{\mathrm{pesq}}\) is a weak PESQ auxiliary term.
```

---

## 5. Chapter 4: include VBD48 table as a main result

### 5.1 Section order

Change the result order to put 48 kHz first:

```text
4.2 Experimental Results
  4.2.1 48 kHz Full-Band Results
  4.2.2 Wideband Results
  4.2.3 Low-Band Cutoff
  4.2.4 Architecture Ablations
```

Reason:
- The paper is a full-band SE thesis.
- 48 kHz result should be the main result, not after the wideband result.
- The previous “Reference Positioning” title is too weak and internal.

Update Contents and List of Tables accordingly.

### 5.2 Rename Table 4.2

Do not use:

```text
48 kHz Reference Positioning
```

Use:

```text
48 kHz full-band results on VoiceBank+DEMAND 48 kHz
```

or:

```text
48 kHz full-band comparison on VoiceBank+DEMAND 48 kHz
```

### 5.3 Caption for VBD48 table

Use a short caption with one caveat:

```text
Table 4.X: 48 kHz full-band results on the VoiceBank+DEMAND 48 kHz test set. PercepNet and DeepFilterNet2 rows are paper-reported references, while TF-Rehancer is locally evaluated. MACs are model-side estimates and exclude STFT/iSTFT.
```

Do **not** write a long defensive caption. Do not use “reference positioning.”

### 5.4 VBD48 table content

Use the current table values. Do not change the numbers.

```markdown
| Method | Params↓ | MACs | PESQ↑ | STOI↑ | CSIG↑ | CBAK↑ | COVL↑ | SI-SDR↑ | LSD↓ |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| PercepNet [3,4] | 8.00M | 0.80G | 2.73 | -- | -- | -- | -- | -- | -- |
| DFN2 + Simplified DNN [4] | 2.31M | 0.36G | 3.08 | 0.943 | 4.30 | 3.40 | 3.70 | -- | -- |
| DFN2 + Post-Filter [4] | 2.31M | 0.36G | 3.03 | 0.941 | 3.72 | 3.37 | 3.63 | -- | -- |
| TF-Rehancer | 0.615M | 3.15G | 3.233 | 0.951 | 4.286 | 3.567 | 3.771 | 17.789 | 0.730 |
```

If the team prefers to include the FastGRU anchor row as an additional row, that is optional, but the current one-row TF-Rehancer table is acceptable and cleaner.

### 5.5 Interpretation paragraph for VBD48 table

Do not write:

```text
TF-Rehancer obtains the highest PESQ/STOI/CBAK/COVL among listed rows.
```

This reads like a strict ranking.

Use:

```text
Table 4.X shows that TF-Rehancer obtains competitive full-reference scores on the VBD 48 kHz test set relative to published full-band references. Its PESQ, STOI, CBAK, and COVL values are above the listed PercepNet and DeepFilterNet2 references, while the simplified DeepFilterNet2 reference remains slightly higher in CSIG and the DeepFilterNet2 rows report lower MACs. Because the reference rows are taken from prior papers rather than locally re-evaluated, the table should be read as a published-reference comparison rather than a strict direct re-evaluation.
```

This is main-table language but still defensible.

### 5.6 Abstract update for VBD48 table

Add only one compact sentence. Do not over-promote it.

Use:

```text
On the VoiceBank+DEMAND 48 kHz test set, TF-Rehancer obtains competitive full-reference scores relative to published PercepNet and DeepFilterNet2 references.
```

Then immediately continue to ablation result.

Avoid:

```text
reference positioning table
strict same-evaluator ranking
external system ranking
```

Too much caveat in the Abstract weakens the paper.

---

## 6. Chapter 4 caveat cleanup

### 6.1 Avoid repeated caveats

The caveat that PercepNet/DFN2 rows are paper-reported should appear in:
1. Table 4.X caption.
2. One interpretation sentence.

Do not repeat it in:
- Abstract,
- Chapter 4 setup paragraph,
- Conclusion multiple times.

### 6.2 Replace defensive/internal phrases

| Avoid | Use |
|---|---|
| reference positioning | 48 kHz full-band results / published-reference comparison |
| same-evaluator ranking | direct re-evaluation / strict direct comparison |
| diagnostic configuration | TimeMHSA-EFN configuration / offline configuration |
| low-computation configuration | FastGRU-based configuration / compact configuration |
| cross-system ranking | external system comparison, if needed |

---

## 7. Chapter 5 update

### 7.1 Summary should include VBD48 table

Add one sentence:

```text
The 48 kHz VoiceBank+DEMAND results further show competitive full-reference scores relative to published PercepNet and DeepFilterNet2 references.
```

### 7.2 Limitation wording

Update limitations:

```text
The 48 kHz comparison includes paper-reported full-band references, while TF-Rehancer is locally evaluated. A fully aligned protocol with locally re-evaluated baselines remains necessary for stronger external full-band claims.
```

Do not over-repeat the caveat.

---

## 8. Final reviewer comments: accepted or rejected

### Accepted

- **Core phrase too long:** accepted. Use `low-band-guided full-band refinement`.
- **Title mismatch:** accepted. Change to `Full-Band Speech Enhancement via Low-Band-Guided Refinement`.
- **Abstract overstates 48 kHz reference positioning:** accepted. Mention 48 kHz result in one compact sentence only.
- **Awkward headings:** mostly accepted. Use `Full-Band Speech Enhancement`, `Efficient Full-Band Modeling`, `Query Refinement and TF Filtering`, `Problem Definition`.
- **Internal/defensive wording:** accepted. Remove or reduce `reference positioning`, `same-evaluator ranking`, `diagnostic configuration`, `low-computation`.
- **Caveat repetition:** accepted. Caveat appears only in caption + one interpretation sentence.
- **Table 4.2 ranking-like wording:** accepted. Use “competitive full-reference scores” and list metric tendencies without “highest among listed rows.”

### Not fully accepted

- Do **not** remove the DFN2/PercepNet caveat entirely. It is still necessary because the references are paper-reported and not locally re-evaluated.
- Do **not** claim SOTA or strict superiority over DeepFilterNet2.

---

## 9. Final checklist

Before producing the final PDF:

- [ ] Change title to `Full-Band Speech Enhancement via Low-Band-Guided Refinement`.
- [ ] Replace repeated long core phrase with `low-band-guided full-band refinement`.
- [ ] Keep detailed Q/K/V mechanics only in Method and figure captions.
- [ ] Add VBD48 table as `4.2.1 48 kHz Full-Band Results`.
- [ ] Rename `48 kHz Reference Positioning` to `48 kHz Full-Band Results`.
- [ ] Move Wideband Results to `4.2.2`.
- [ ] Update List of Tables.
- [ ] Add one compact Abstract sentence about VBD48 competitive scores.
- [ ] Remove “reference positioning” from final section titles.
- [ ] Remove “highest among listed rows” interpretation.
- [ ] Keep DFN2/PercepNet caveat only in caption and one interpretation sentence.
- [ ] Update Chapter 5 summary and limitations.
- [ ] Check page count after inserting the VBD48 table.
