# Paper-Team Revision Plan: Precision Pass for TF-Rehancer Draft

## 0. Scope and decision lock

This memo reflects the user's confirmed choices and the current thesis draft. Do **not** change the title. The title, **Full-Band Speech Enhancement via Low-Band-Conditioned Refinement**, should remain as is.

The main remaining issue is not the global structure. The major issue is **mechanistic precision**: some parts of the draft can still be read as if the low-band encoder output directly refines the entire full-band representation. That is not the intended claim. The architecture first performs **low-band-conditioned high-band refinement**, and only afterward performs **full-band decoder modeling**.

Use the following mechanism as the source of truth:

1. The shared F-stride stem produces embedded low/high tokens.
2. Low-band tokens go through the encoder and produce the low-band representation \(Z\).
3. High-band tokens form the observed high-band query \(Q_h\) through a lightweight local adapter.
4. \(Z\) and \(Q_h\) are concatenated along the frequency axis and projected to decoder width.
5. In decoder cross-attention, **only the high-band decoder tokens** are updated.
6. The encoded low-band representation \(Z\) provides **key/value context**.
7. After high-band update, the updated high-band tokens are concatenated back with low-band decoder tokens.
8. The following frequency-axis self-attention and temporal modules operate on the **full embedded sequence**.

This is already described in the current method text: the decoder concatenates \(Z\) and \(Q_h\), projects them, updates only high-band tokens through MHCA using \(Z\) as key/value, then applies full-sequence modules to the complete embedded sequence. This should remain the governing interpretation. The detailed implementation notes also confirm that high-band tokens bypass the encoder and become observed high-band queries, while cross-attention uses high decoder tokens as queries and low encoder output as key/value context. fileciteturn75file1 fileciteturn76file0 fileciteturn76file6

---

## 1. Main terminology correction: do not say low-band evidence directly refines full-band

### Problem

Some current wording can be interpreted as:

> low-band evidence refines the full-band representation.

This is too coarse. It obscures the actual mechanism and gives reviewers an opening to ask whether the model really performs low-to-high refinement.

### Required phrasing

Use this as the canonical wording:

> TF-Rehancer uses the low-band encoder output as key/value context to refine the observed high-band decoder tokens through cross-attention. The updated high-band tokens are then combined with the low-band decoder tokens, and subsequent self-attention and temporal modeling refine the full-band decoder representation.

### Avoid

- `low-band evidence refines the full-band representation` without qualification.
- `low-band context refines the full-band query` unless immediately followed by the high-token-only cross-attention detail.
- `high band is generated from low band`.
- `HBR is the main refinement module`.

### Preferred short phrase

When space is limited, use:

> low-band-conditioned high-band refinement followed by full-band decoder modeling

or:

> low-band encoder-guided refinement of observed high-band decoder tokens

---

## 2. Abstract revision instruction

### Current issue

The abstract should not drift toward either of these extremes:

- Too broad: `low-band encoder-guided full-band decoder refinement` without explaining high-band update.
- Too narrow: `observed high-band query refinement` as if the method is only a query trick.

### Replace the architecture sentence with

```text
TF-Rehancer uses sampling-frequency-independent STFT analysis, power-law compressed complex spectral conditioning, low-band-conditioned refinement of observed high-band decoder tokens, subsequent full-band decoder modeling, and local complex time-frequency filtering over the original noisy STFT.
```

### If the abstract needs to be shorter

```text
TF-Rehancer refines observed high-band decoder tokens using low-band encoder context, then performs full-band decoder modeling and local complex TF filtering over the original noisy STFT.
```

### Keep the evidence boundary

The abstract should continue to say that the 48 kHz experiments are **controlled ablations**, not external full-band rankings. The current draft already keeps this boundary, and that should be preserved. The current thesis also uses this safe evidence framing in Chapter 4 and Conclusion. fileciteturn75file15

---

## 3. Introduction and Figure 1.1 caption revision

### 3.1 Main introduction paragraph

The current introduction contains the attention-perspective defense, which is good. However, it should be made more implementation-faithful by explicitly separating the high-band cross-attention stage from the later full-band self-attention stage.

### Recommended replacement paragraph

```text
From the attention perspective, the decoder representation is first formed by concatenating the low-band encoder output and the observed high-band query, followed by projection to the decoder width. In the cross-attention stage, only the high-band decoder tokens act as queries, while the low-band encoder output provides the key-value context. The updated high-band tokens are then combined with the low-band decoder tokens, and the following frequency self-attention and temporal modules refine the full embedded sequence. Thus, TF-Rehancer does not generate high-band speech from low-band information alone; it uses low-band context to condition the update of observed high-band features.
```

### 3.2 Figure 1.1 caption

Current conceptual caption is close, but it can still sound like generic full-band refinement. Use the precise high-band-first wording.

#### Recommended caption

```text
Figure 1.1: Conceptual overview of TF-Rehancer. The low-band encoder output provides key-value context, while the observed high-band decoder tokens serve as the cross-attention queries. Cross-attention refines the high-band tokens, and subsequent full-sequence decoder modeling refines the joint full-band representation before local complex filtering is applied to the original noisy STFT.
```

### 3.3 Contribution bullet 2

Revise to:

```text
We propose TF-Rehancer, a TF-domain architecture that refines observed high-band decoder tokens using low-band encoder context, then models the resulting full-band decoder representation and estimates the enhanced spectrum through complex filtering over the noisy STFT.
```

This avoids the misleading impression that the low-band encoder directly updates every full-band token in the cross-attention stage.

---

## 4. Related Work: keep 2.3, but shrink and remove SFI-STFT from Related Work

### 4.1 Section title policy

Use the user-confirmed structure:

```text
2.1 Wideband SE and the Observed Gap
2.2 Full-Band Speech Enhancement
2.3 Query-Based Modeling Method
```

This structure is acceptable. It keeps the 48 kHz problem motivation in 2.1, practical full-band systems in 2.2, and query/filtering context in 2.3.

### 4.2 Does 2.3 weaken the contribution?

Keep 2.3, but make it **compact**. It is useful because TF-Rehancer borrows the idea that decoder-side query information can guide frequency-region modeling. However, 2.3 must not sound like TF-Restormer already did your contribution.

The key contrast must be:

- TF-Restormer: query slots for target/missing frequency regions in restoration or bandwidth expansion.
- TF-Rehancer: observed high-band features are already present; the query is derived from the noisy high-band observation and updated by low-band encoder context.

### 4.3 Remove or drastically reduce SFI-STFT in Related Work

SFI-STFT is not a related-work research direction in this thesis. It is a frontend parameterization used in the method. The current method section already explains SFI-STFT in detail. The SFI-STFT paragraph in Related Work should be removed or reduced to one sentence.

#### Delete this type of paragraph from Related Work

```text
TF-Restormer also uses a sampling-frequency-independent STFT formulation ...
```

#### If a minimal mention is needed

```text
TF-Restormer also motivates the use of sampling-frequency-independent STFT parameterization, which we describe as part of the proposed method in Section 3.
```

Then stop. Do not spend a full Related Work paragraph on SFI-STFT.

### 4.4 Recommended 2.3 structure

```text
Query-based restoration provides a related but different mechanism. TF-Restormer uses decoder-side queries to restore target frequency regions in a restoration setting where input and output bandwidths may differ. This is appropriate when the target frequency region is missing or under-observed.

TF-Rehancer uses query modeling under a different information condition. In direct full-band SE, high-band components are already observed with noise. Therefore, the decoder-side high-band query is derived from the observed high-band representation, and cross-attention uses the low-band encoder output as key-value context to update that high-band query.

Filtering-based enhancement is also relevant. Instead of mapping a latent representation directly to a clean spectrum, deep filtering estimates local complex filters over the noisy STFT. TF-Rehancer combines this filtering view with low-band-conditioned high-band refinement.
```

Do not make 2.3 longer than this unless necessary.

---

## 5. Chapter 3: required precision additions

### 5.1 Current strengths

The current method already contains the most important cross-attention detail: after concatenation and projection, decoder MHCA updates only the high-band tokens using the encoded low-band representation as key/value. This is exactly the defense logic needed for reviewer questions. fileciteturn76file4

### 5.2 Still missing: explicit Macaron-style frequency module explanation

The current text and Figure 3.3 mention F-ConvFFN, F-MHSA with RoPE, and F-MHCA, but the body text does not sufficiently explain the design. Add a short paragraph around Section 3.2.2 or 3.2.3.

#### Insert after the low-band encoder paragraph in 3.2.2

```text
The frequency module follows a Macaron-style structure: a convolutional feed-forward layer is placed before and after frequency-axis self-attention. This ConvFFN -> MHSA -> ConvFFN ordering lets local convolutional mixing and global frequency attention complement each other. The decoder frequency module extends this pattern by inserting cross-attention before full-sequence self-attention, i.e., MHCA -> MHSA -> ConvFFN.
```

If the paper wants to avoid the term `Macaron-style`, use:

```text
The frequency module uses a sandwich structure in which frequency-axis attention is surrounded by convolutional feed-forward processing.
```

### 5.3 Missing: RoPE rationale

The current text says RoPE is used, but it does not explain why. Add a concise rationale.

#### Insert near the frequency attention description

```text
RoPE is applied to frequency-axis attention to encode the relative order of frequency tokens without relying on a learned absolute positional table. This is useful because the frequency axis has a fixed physical ordering, while the number of tokens differs between 16 kHz and 48 kHz settings. In decoder cross-attention, the high-band query and low-band key/value tokens occupy different frequency regions, so the RoPE offsets preserve their relative frequency positions during cross-band attention.
```

This is consistent with the implementation notes: the model disables pre-encoder absolute positional encoding, uses RoPE in frequency attention, and applies different offsets for high-query and low-key/value regions in cross-attention. fileciteturn76file12 fileciteturn76file6

### 5.4 Missing: Efficient ConvFFN detail

The current paper does not sufficiently explain F-ConvFFN. Add the following paragraph.

#### Insert after Macaron-style module paragraph

```text
To reduce the cost of the frequency feed-forward layers, we use an efficient convolutional FFN. Instead of applying a large convolutional FFN over the full frequency sequence, the module first downsamples the frequency-axis sequence by adaptive average pooling. It then applies grouped gated 1-D convolutions on the shortened sequence, using separate value and gate branches followed by SiLU gating. We use group convolution with two groups to reduce computation. The output is projected back, upsampled to the original frequency length, and added to the residual stream. This design keeps a full-length residual path while applying the expensive gated convolutional correction on a shorter sequence.
```

Implementation details support this exactly: EfficientConvFFN uses LayerNorm, adaptive average pooling to roughly half the sequence length, grouped value/gate Conv1D with groups=2, SiLU(value) * gate, a full output projection, nearest upsampling, and residual addition. fileciteturn76file5 fileciteturn76file1

### 5.5 Cross-band decoder refinement: add exact Q/K/V formulation

The current method should keep the exact high-token-only formulation. Strengthen it with this precise wording.

#### Replacement / addition for 3.2.3

```text
Let the projected decoder input be split as \(D=[D_{\mathrm{low}};D_{\mathrm{high}}]\). In the cross-attention stage, \(D_{\mathrm{low}}\) is passed through this stage without being updated by MHCA, while \(D_{\mathrm{high}}\) is used as the query. The key and value are obtained from the low-band encoder output \(Z\):

\[
Q = \Pi_q(D_{\mathrm{high}}), \quad K = \Pi_k(Z), \quad V = \Pi_v(Z).
\]

The high-band update is then computed as

\[
\tilde{D}_{\mathrm{high}} = D_{\mathrm{high}} + \mathrm{MHCA}(Q,K,V),
\]

and the decoder sequence is reconstructed as

\[
\tilde{D}=[D_{\mathrm{low}};\tilde{D}_{\mathrm{high}}].
\]

Thus, cross-attention conditions the update of the observed high-band decoder tokens using low-band encoded context. The following frequency self-attention operates on \(\tilde{D}\), so low- and high-band tokens interact over the full embedded sequence after the directed low-to-high update.
```

This is the most important defense against reviewer confusion. The implementation notes explicitly state that low tokens pass through unchanged, high tokens are updated by MHCA, and decoder self-attention then operates over all embedded tokens. fileciteturn76file6

### 5.6 Figure 3.3 caption update

Current Fig. 3.3 caption is close but should include the two-stage interpretation.

#### Recommended caption

```text
Figure 3.3: TF-Rehancer encoder and decoder core blocks. The encoder frequency module uses a Macaron-style F-ConvFFN -> F-MHSA -> F-ConvFFN structure with RoPE. The decoder first applies F-MHCA, where only high-band decoder tokens are updated using the low-band encoder output as key/value context, and then applies full-sequence F-MHSA and F-ConvFFN to refine the joint embedded representation. The temporal module uses residual PConv1D-GRU stages.
```

### 5.7 Figure 3.1 caption update

The current Figure 3.1 caption says the decoder refines the full-band representation. That is mostly fine, but it should make the high-band-first path explicit.

#### Recommended caption

```text
Figure 3.1: Overall TF-Rehancer architecture. The shared input layer produces embedded low- and high-band representations. The low-band representation is encoded by the TF encoder, while the observed high-band representation is carried to the decoder as query evidence. The decoder first refines the high-band tokens using the low-band encoder output as key/value context, then performs full-sequence TF modeling before estimating local complex TF filters over the original noisy STFT.
```

---

## 6. Chapter 4: keep current evidence framing, but avoid terminology drift

The current Chapter 4 is acceptable for the present evidence level. It uses 16 kHz comparison plus controlled 48 kHz ablations, and it does not claim full-band external ranking. This evidence boundary should remain. The prior reviews also emphasized that 48 kHz results are controlled component evidence, not external full-band system ranking. fileciteturn75file5 fileciteturn75file12

### Required consistency checks

1. Use `low-computation` rather than `online` if the paper is not providing measured streaming/RTF evidence. If `online-friendly` remains, keep a caption/footnote that it indicates temporal-module design, not measured streaming performance.
2. Keep `DNS full-band noise` or `DNS4 full-band noise` consistent throughout. Do not mix both.
3. Use `LSD-H@8k` if the evaluation uses the cutoff corresponding to approximately 8 kHz.
4. Do not write that 48 kHz ablations validate superiority over external full-band systems.
5. If Table 4.1 uses paper-reported FastEnhancer-M, keep the `benchmark context` caveat.

---

## 7. High-risk phrases to eliminate or rewrite

| Risky phrase | Why risky | Replace with |
|---|---|---|
| `low-band evidence refines full-band representation` | makes MHCA sound like full-band update | `low-band encoder context updates observed high-band decoder tokens; subsequent self-attention refines the full sequence` |
| `high-band query refinement` alone | too narrow; may sound like HBR/query trick | `low-band-conditioned high-band refinement followed by full-band decoder modeling` |
| `full-band query is refined by low-band context` | can be imprecise unless conceptual figure only | `the high-band slice of the decoder representation queries the low-band encoded context` |
| `HBR is the main contribution` | false; adapter is not main | `HBR prepares observed high-band query evidence; decoder refinement is the main mechanism` |
| `SFI-STFT in Related Work` long paragraph | SFI-STFT is method detail, not a related-work line | Move to 3.2.1 and cite TF-Restormer briefly |
| `online model` | no strict streaming evidence | `low-computation configuration` or `online-friendly temporal configuration` with caveat |
| `proves` / `verifies` for ablation | too strong for controlled ablation | `suggests`, `supports`, `indicates` |

---

## 8. Reviewer-question defense checklist

The revised manuscript should be able to answer these questions without relying on oral explanation.

### Q1. Is the high band generated or observed?

Answer should be in Introduction, Related Work 2.3, and Method 3.2.2:

> The high-band representation is derived from the observed noisy high-band stem feature, not from a learned missing-band placeholder.

### Q2. What exactly is Q, K, and V in cross-attention?

Answer should be in Method 3.2.3:

> \(Q\) is the high-band portion of the projected decoder representation; \(K,V\) are linear projections of the low-band encoder output \(Z\).

### Q3. Are low-band tokens also updated by cross-attention?

Answer should be explicit:

> No. Low-band decoder tokens pass through the cross-attention stage; only high-band tokens are updated. Full-sequence interaction happens afterward through frequency self-attention and temporal modeling.

### Q4. Why RoPE?

Answer should be explicit:

> RoPE gives frequency-order sensitivity without a learned absolute frequency table, and offsets preserve the relative frequency positions between low-band keys/values and high-band queries.

### Q5. Why ConvFFN / EFN?

Answer should be explicit:

> EFN reduces the cost of frequency feed-forward processing by applying grouped gated convolution on a downsampled frequency sequence and restoring the result through a residual correction branch.

### Q6. Does F-stride destroy the high-band observation?

Answer:

> F-stride compresses the latent representation, but the shared stem observes the full-band input before the split, high-band embedded tokens remain in the decoder path, and final filtering is applied to the original noisy STFT.

### Q7. What does Chapter 4 actually prove?

Answer:

> It supports competitive 16 kHz quality-efficiency behavior and controlled 48 kHz component evidence. It does not prove external full-band SOTA or strict superiority over full-band baselines.

---

## 9. Action list for the paper-writing team

### Must fix

1. Correct every place where the paper says or implies that low-band evidence directly refines the entire full-band representation through cross-attention.
2. Add explicit Q/K/V formulation and high-token-only update in 3.2.3.
3. Add Macaron-style F-ConvFFN -> F-MHSA -> F-ConvFFN explanation.
4. Add EFN detail: adaptive average pooling over frequency, grouped gated Conv1D with groups=2, upsample, residual correction.
5. Add RoPE rationale and cross-attention offset rationale.
6. Remove or reduce SFI-STFT paragraph from Related Work; keep SFI-STFT detail in Method 3.2.1.
7. Update Figure 1.1, Figure 3.1, and Figure 3.3 captions to reflect high-band-first refinement followed by full-band modeling.

### Should fix

1. Replace broad `full-band decoder refinement` phrases with precise `low-band-conditioned high-band refinement followed by full-band decoder modeling` where context requires implementation detail.
2. Keep `low-band encoder-guided full-band decoder refinement` as a high-level thesis phrase only when accompanied by the precise high-token update explanation elsewhere.
3. Use `low-computation configuration` in Abstract unless `online-friendly` is explicitly defined as a configuration label, not streaming evidence.
4. Keep Chapter 4 claims aligned with controlled ablation evidence.

### Do not change

1. Thesis title.
2. Overall chapter structure.
3. 16 kHz / 48 kHz evidence boundary.
4. Conclusion claim strength, unless Chapter 4 changes substantially.

---

## 10. Suggested final wording bundle

If the team wants a compact replacement set, use these exact sentences.

### Abstract method sentence

```text
TF-Rehancer refines observed high-band decoder tokens using low-band encoder context, then performs full-band decoder modeling and local complex TF filtering over the original noisy STFT.
```

### Introduction defense sentence

```text
In decoder cross-attention, the high-band slice of the decoder representation acts as the query, while the low-band encoder output provides key-value context. The low-band context therefore conditions the update of observed high-band tokens; full-band interaction is performed afterward by self-attention and temporal modeling over the complete decoder sequence.
```

### Method transition sentence

```text
This separates local high-band query construction from decoder refinement: the adapter prepares observed high-band evidence, the MHCA stage performs low-band-conditioned high-band update, and the following full-sequence modules refine the joint full-band representation.
```

### EFN sentence

```text
The Efficient ConvFFN reduces feed-forward cost by applying grouped gated convolution on a downsampled frequency sequence and adding the upsampled correction back to the full-length residual stream.
```

### RoPE sentence

```text
RoPE is used in frequency attention to encode relative frequency order without a learned absolute frequency table, and cross-attention offsets preserve the positions of low-band keys/values and high-band queries.
```
