# Final Caption and Manuscript Polish Plan

Target file: `thesis(2).pdf`  
Goal: produce a near-final thesis/paper draft by fixing caption length, moving implementation details from captions into body text, and tightening the remaining claim boundaries.

## 0. Overall Verdict

The manuscript is close to final. The main logic is now coherent:

- The title can remain unchanged.
- The central contribution is consistently framed as **low-band encoder-guided high-band token update followed by full-band decoder modeling**.
- The Introduction now properly explains that the high band is observed noisy evidence, not missing content.
- Chapter 3 now gives enough detail on the attention path, Macaron-style frequency modules, RoPE, efficient ConvFFN, and complex TF filtering.
- Chapter 4 is appropriately conservative: 16 kHz is a quality-efficiency comparison, and 48 kHz results are controlled ablations rather than external full-band system rankings.
- Chapter 5 is aligned with the evidence level.

The remaining issues are not scientific blockers. They are **caption style, table-caption overload, and a few prose placement issues**. The most important final edit is to ensure that captions do not carry information that belongs in the body.

## 1. Global Caption Rule

Use this rule throughout the final manuscript:

> Captions should state what the figure or table shows and define any non-obvious abbreviations. Training details, checkpoint details, epoch numbers, asymmetric comparison caveats, and interpretation should be moved to the surrounding body text.

In particular, captions should not include:

- exact training epoch details such as `epoch-12`, `40-epoch warmup retest`, or `selected by validation loss`;
- long caveats about ranking and evidence scope;
- excessive mechanism explanation already described in the body;
- implementation/debug wording such as `retest checkpoint`, `warmup`, `metric wrapper`, or `script`.

## 2. Figure Caption Review and Replacements

### 2.1 Figure 1.1

Current caption is scientifically correct but slightly long. It is acceptable, but can be shortened.

Recommended caption:

```latex
Figure 1.1: Conceptual overview of TF-Rehancer. The low-band encoder output provides key-value context for updating the observed high-band decoder tokens. The resulting full embedded sequence is then modeled and used to estimate local complex filters over the original noisy STFT.
```

Reason:

- Keeps the key attention logic.
- Avoids the ambiguous statement that low-band context refines the whole full-band representation directly.
- Makes clear that cross-attention updates **high-band decoder tokens**, followed by full-sequence modeling.

### 2.2 Figure 3.1

Current caption is mostly good. It already says that decoder cross-attention updates high-band tokens using the low-band encoder output. Keep that logic, but shorten slightly.

Recommended caption:

```latex
Figure 3.1: Overall TF-Rehancer architecture. The shared input layer produces an embedded full-band representation. The low-band region is encoded by the TF encoder, while the observed high-band region is carried as decoder-side query evidence. Decoder cross-attention updates the high-band tokens using the low-band encoder output, and the following full-sequence decoder modeling produces features for complex TF filter estimation.
```

Do not use:

```text
The low-band evidence refines the full-band representation.
```

This is too broad. The correct statement is:

```text
The low-band encoder output conditions the high-band token update, followed by full-sequence decoder modeling.
```

### 2.3 Figure 3.2

Current caption is fine but can be shortened.

Recommended caption:

```latex
Figure 3.2: Local convolutional layer notation used for the input stem, high-band adapter, and output-side upsampling/filtering layers. The channel width, stride, and normalization differ by module and are specified in the text.
```

Reason:

- The figure is notation support, not a main contribution figure.
- Avoid over-explaining in the caption.

### 2.4 Figure 3.3

Current caption is accurate but a bit dense. Since the body already explains Macaron-style modules, RoPE, and decoder cross-attention, the caption can be shorter.

Recommended caption:

```latex
Figure 3.3: Encoder and decoder core blocks of TF-Rehancer. The encoder uses Macaron-style F-ConvFFN--F-MHSA--F-ConvFFN blocks with RoPE and residual temporal GRU modules. The decoder inserts F-MHCA before full-sequence F-MHSA, where only high-band decoder tokens are updated using the low-band encoder output as key-value context.
```

Reason:

- Keeps the core module logic.
- Makes the high-token-only update explicit.
- Avoids overloading the caption with every layer detail.

### 2.5 Figure 3.4

Current caption is already good. Keep it or make a minor polish.

Recommended caption:

```latex
Figure 3.4: Local 3 x 3 complex TF filtering. For each output bin, TF-Rehancer predicts complex coefficients over a local time-frequency neighborhood and applies them to the corresponding noisy STFT samples.
```

No major change needed.

## 3. Table Caption Review and Replacements

### 3.1 Table 4.1 - Wideband Results

Current issue:

- The caption is too long.
- It explains model configuration, checkpoint selection, on/off meaning, and MAC policy all in one caption.
- This should be split: put model-definition details in the paragraph before the table, and keep the caption compact.

Recommended body text before Table 4.1:

```latex
Table 4.1 reports the 16 kHz VoiceBank+DEMAND results. The FastEnhancer-M row is the paper-reported reference. TF-Rehancer (on) denotes the low-computation FastGRU-based configuration, and TF-Rehancer (off) denotes the non-streaming TimeMHSA-EFN diagnostic configuration. The on/off labels distinguish model configurations and do not indicate measured real-time or streaming performance.
```

Recommended caption:

```latex
Table 4.1: VoiceBank+DEMAND 16 kHz test results. The FastEnhancer-M row is paper-reported, while TF-Rehancer rows are evaluated locally on the 824-utterance VBD test set. MACs are model-side estimates and exclude STFT/iSTFT.
```

Reason:

- Caption now states table scope and source policy.
- Configuration explanation moves to the body.
- Avoids caption overload.

### 3.2 Table 4.2 - Low-Band Cutoff

Current issue:

- The caption is acceptable but still includes training protocol detail.
- Training epochs do not need to be in the caption.

Recommended body text before Table 4.2:

```latex
We next vary the low-band cutoff from 3 kHz to 8 kHz under the 48 kHz ablation setting. All cutoff variants use the same model size and are evaluated on the VBD 48 kHz test set.
```

Recommended caption:

```latex
Table 4.2: Low-band cutoff ablation. Parameter counts are identical across cutoff settings and are omitted. MACs are model-side estimates.
```

Reason:

- Caption becomes clean.
- Training protocol stays in Section 4.1 or the preceding paragraph.

### 3.3 Table 4.3 - Architecture Ablations

Current issue:

- This is the most important caption to fix.
- Current caption contains checkpoint/epoch information such as `40-epoch warmup retest` and `epoch-12 checkpoint`.
- These are internal experimental details and should not be in the main paper caption.
- If checkpoint provenance is needed, put it in an appendix/source map, not in the main caption.

Recommended body text before Table 4.3:

```latex
Table 4.3 compares the default TF-Rehancer architecture with two variants: one without decoder MHCA and one that replaces complex TF filtering with direct spectrum mapping. This ablation is intended to examine the effects of decoder cross-attention and filtering-based output estimation.
```

Recommended caption:

```latex
Table 4.3: 48 kHz architecture ablation on the VoiceBank+DEMAND 48 kHz test set. All models are trained using VCTK clean speech and DNS full-band noise and evaluated on the VBD 48 kHz test set. The table is used for controlled component analysis rather than external full-band system ranking.
```

Optional even shorter caption:

```latex
Table 4.3: 48 kHz architecture ablation on the VoiceBank+DEMAND 48 kHz test set. The table compares decoder MHCA and output-head variants under the same ablation setting.
```

Use the longer one if the thesis needs self-contained captions. Use the shorter one if table layout is tight.

## 4. Critical Body-Text Placement Fixes

### 4.1 Move result interpretation after Table 4.3

Current problem:

In Section 4.2.3, the sentence beginning with:

```text
The direct mapping head is weaker than complex TF filtering...
```

appears before the table. This violates the style used elsewhere and makes the section feel like the result is being interpreted before the reader sees the table.

Recommended structure:

```latex
4.2.3 Architecture Ablations

Table 4.3 compares the default TF-Rehancer architecture with two variants: one without decoder MHCA and one that replaces complex TF filtering with direct spectrum mapping.

[Table 4.3]

The direct mapping head is weaker than complex TF filtering across the reported metric families. ...
```

This matches the paper style: table first, interpretation second.

### 4.2 Remove checkpoint/epoch details from main captions

Remove from Table 4.3 caption:

```text
The TF-Rehancer row uses the 40-epoch warmup retest checkpoint selected by validation loss, and the w/o Decoder MHCA row uses the epoch-12 checkpoint.
```

If needed, use an appendix note:

```latex
Checkpoint details for local ablation rows are provided in the experiment source map.
```

But do not put this in the main result caption.

### 4.3 Avoid “low-band refines full-band directly” phrasing

Use this canonical description throughout:

```text
Decoder cross-attention updates the observed high-band decoder tokens using the low-band encoder output as key-value context. The updated high-band tokens are then combined with low-band tokens and processed by full-sequence decoder modeling.
```

Avoid:

```text
Low-band evidence refines the full band.
Low-band context refines the whole full-band representation.
Low-band features enhance the entire band.
```

Those are imprecise and can mislead reviewers.

## 5. Chapter 2 Review

### 5.1 48 kHz SE motivation

The Related Work section now supports the 48 kHz motivation reasonably well:

- Section 2.1 explains that standard SE comparisons are mostly 16 kHz or protocol-specific.
- It distinguishes full-band SE from BWE/SR by the observed-band condition.
- It cites perceptual studies on high-frequency information.
- Section 2.2 positions PercepNet and DeepFilterNet2 as practical full-band references without attacking them.

This is adequate.

### 5.2 Section 2.3 necessity

Keep Section 2.3. It no longer weakens the contribution as long as the final paragraph keeps the distinction clear:

```text
TF-Restormer uses queries for missing-band restoration, whereas TF-Rehancer uses observed high-band evidence and low-band encoder context for direct full-band SE.
```

Do not expand Section 2.3 further. It should remain compact.

### 5.3 SFI-STFT in Related Work

The current version does not overuse SFI-STFT in Related Work. That is good. SFI-STFT is a method/detail inheritance point and belongs mainly in Chapter 3.

## 6. Chapter 3 Review

### 6.1 Current strength

Chapter 3 is now much stronger than earlier drafts. It includes:

- SFI-STFT conditioning and shared embedding;
- observed high-band query construction;
- clear separation between high-band adapter, projection, and decoder refinement;
- Macaron-style frequency module explanation;
- RoPE motivation;
- efficient ConvFFN with frequency downsampling and grouped gated convolution;
- high-token-only MHCA update;
- full-sequence decoder modeling after cross-attention;
- complex TF filtering applied to the original noisy STFT.

Do not remove these details. They are important for defending the model against reviewer questions.

### 6.2 One structural issue

Section 3.2.2 is titled `Observed High-Band Query Construction`, but it also explains the low-band encoder, Macaron-style module, RoPE, and efficient ConvFFN. This is not fatal, but it is slightly mismatched.

Recommended fix if time allows:

Rename Section 3.2.2 to:

```text
3.2.2 Observed High-Band Query and Low-Band Encoder Context
```

or move the low-band encoder/Macaron/RoPE/ConvFFN paragraphs to Section 3.2.3 before the cross-attention equations.

Fastest safe option:

Keep the current structure, but add a transition before the encoder paragraphs:

```latex
We next describe the low-band encoder that produces the context representation used by the decoder cross-attention.
```

### 6.3 RoPE explanation

The RoPE explanation is now present and should be preserved. It gives a defensible reason:

- frequency axis has fixed physical order;
- token count differs between 16 kHz and 48 kHz;
- RoPE avoids a learned absolute positional table;
- RoPE helps preserve relative frequency positions in cross-band attention.

This answers a likely reviewer question.

### 6.4 Efficient ConvFFN explanation

The efficient ConvFFN explanation is now present and should be preserved. It correctly explains:

- frequency-axis sequence is first downsampled;
- grouped gated 1-D convolution is applied on the shortened sequence;
- group convolution with two groups reduces computation;
- output is upsampled back to the original frequency length;
- the full-length residual path is retained.

This is valuable and should not be shortened too aggressively.

## 7. Chapter 4 Review

### 7.1 Wideband Results

Table 4.1 is acceptable. It now uses paper-reported FastEnhancer-M as benchmark context, matching the user’s selected Option A.

The interpretation is safe because it says:

- FastEnhancer-M row is paper-reported;
- the comparison is benchmark context, not same-protocol comparison;
- TF-Rehancer (on) is low-computation;
- TF-Rehancer (off) is non-streaming diagnostic.

Potential final polish:

Use `low-computation configuration` instead of `online-friendly configuration` if avoiding streaming implications is more important. If `online-friendly` is kept, the caption already states that it does not indicate measured real-time or streaming performance.

### 7.2 Low-Band Cutoff

The cutoff table and interpretation are safe.

The caption should be shortened as suggested in Section 3.2 of this review.

The interpretation is good:

- no “optimal” claim;
- 5 kHz is a balanced operating point;
- trade-off among computation, perceptual quality, and spectral fidelity.

### 7.3 Architecture Ablations

Scientific interpretation is good, but presentation needs final polish.

Required edits:

1. Move result interpretation after the table.
2. Remove checkpoint/epoch details from the caption.
3. Keep the explanation that ablations are controlled component evidence, not external ranking.
4. If row values change, update the text about which metrics are improved/degraded.

Recommended interpretation style after table:

```latex
The direct mapping head performs worse than complex TF filtering across the reported metric families, suggesting that filtering-based output estimation is more reliable than direct spectrum mapping in this 48 kHz ablation setting. The w/o decoder MHCA variant shows a mixed trend: it improves several perceptual and composite metrics, but degrades SI-SDR and spectral distortion metrics. Thus, decoder MHCA should be interpreted as changing the trade-off between perceptual scores and spectral fidelity, rather than as a uniformly beneficial module.
```

This is safer than saying MHCA is simply helpful.

## 8. Conclusion Review

Conclusion is mostly consistent with the current evidence level.

Minor adjustment:

If Chapter 4 states that MHCA is mixed, the conclusion should not say “mostly favorable to TF-Rehancer” too strongly. Use:

```text
The decoder MHCA ablation shows that cross-attention changes the trade-off between perceptual scores and spectral fidelity.
```

This matches the safest interpretation.

Also, if Chapter 4 removes checkpoint details, the conclusion does not need any change.

## 9. Final Caption Replacement List

Use this list as a direct editing checklist.

### Figure 1.1

```latex
Figure 1.1: Conceptual overview of TF-Rehancer. The low-band encoder output provides key-value context for updating the observed high-band decoder tokens. The resulting full embedded sequence is then modeled and used to estimate local complex filters over the original noisy STFT.
```

### Figure 3.1

```latex
Figure 3.1: Overall TF-Rehancer architecture. The shared input layer produces an embedded full-band representation. The low-band region is encoded by the TF encoder, while the observed high-band region is carried as decoder-side query evidence. Decoder cross-attention updates the high-band tokens using the low-band encoder output, and the following full-sequence decoder modeling produces features for complex TF filter estimation.
```

### Figure 3.2

```latex
Figure 3.2: Local convolutional layer notation used for the input stem, high-band adapter, and output-side upsampling/filtering layers. The channel width, stride, and normalization differ by module and are specified in the text.
```

### Figure 3.3

```latex
Figure 3.3: Encoder and decoder core blocks of TF-Rehancer. The encoder uses Macaron-style F-ConvFFN--F-MHSA--F-ConvFFN blocks with RoPE and residual temporal GRU modules. The decoder inserts F-MHCA before full-sequence F-MHSA, where only high-band decoder tokens are updated using the low-band encoder output as key-value context.
```

### Figure 3.4

```latex
Figure 3.4: Local 3 x 3 complex TF filtering. For each output bin, TF-Rehancer predicts complex coefficients over a local time-frequency neighborhood and applies them to the corresponding noisy STFT samples.
```

### Table 4.1

```latex
Table 4.1: VoiceBank+DEMAND 16 kHz test results. The FastEnhancer-M row is paper-reported, while TF-Rehancer rows are evaluated locally on the 824-utterance VBD test set. MACs are model-side estimates and exclude STFT/iSTFT.
```

### Table 4.2

```latex
Table 4.2: Low-band cutoff ablation. Parameter counts are identical across cutoff settings and are omitted. MACs are model-side estimates.
```

### Table 4.3

```latex
Table 4.3: 48 kHz architecture ablation on the VoiceBank+DEMAND 48 kHz test set. All models are trained using VCTK clean speech and DNS full-band noise and evaluated on the VBD 48 kHz test set. The table is used for controlled component analysis rather than external full-band system ranking.
```

## 10. Final High-Priority Editing Checklist

Apply these edits before final PDF generation:

1. Shorten all figure/table captions using the replacement list above.
2. Move checkpoint/epoch details out of captions, especially Table 4.3.
3. Move result interpretation in Section 4.2.3 to after Table 4.3.
4. Ensure every cross-attention description says **high-band tokens are updated using low-band K/V context**, followed by full-sequence modeling.
5. Avoid the phrase “low-band evidence refines the full band” unless immediately qualified by the high-token update mechanism.
6. Keep the RoPE and efficient ConvFFN details in Chapter 3.
7. Keep Section 2.3 compact; do not expand it further.
8. Keep Chapter 4 claim boundary: 48 kHz results are controlled ablations, not external full-band ranking.
9. If final rows or checkpoints change, update the text that lists which metrics improve/degrade.
10. Ensure Conclusion mirrors the safest Chapter 4 interpretation.

## 11. Final Readiness Assessment

After the caption shortening and Section 4.2.3 ordering fix, the manuscript can be considered final-draft ready.

Remaining scientific limitations are already acknowledged:

- no protocol-aligned 48 kHz external ranking;
- no direct observed-query-source ablation;
- no runtime/latency measurement beyond model-side MACs.

These are not manuscript blockers because the current thesis frames 48 kHz experiments as controlled component analysis and keeps claims appropriately conservative.
