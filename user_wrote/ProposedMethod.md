# 3 Proposed Method

## 3.1 Problem Formulation

Let \(y \in \mathbb{R}^{L}\) and \(x \in \mathbb{R}^{L}\) denote the noisy and clean speech waveforms, respectively. In single-channel speech enhancement, the noisy signal is modeled as

\[
y = x + n,
\]

where \(n\) denotes additive noise. Applying the short-time Fourier transform (STFT) to \(y\) and \(x\) gives the noisy and clean complex spectra

\[
Y, X \in \mathbb{C}^{F \times T},
\]

where \(F\) and \(T\) denote the number of frequency bins and time frames. The coefficients \(Y_{f,t}\) and \(X_{f,t}\) correspond to frequency bin \(f\) and time frame \(t\). In implementation, we use a batched real-imaginary tensor representation,

\[
\mathbf{Y}_{\mathrm{ri}} \in \mathbb{R}^{B \times F \times T \times 2},
\]

where the last dimension contains the real and imaginary components. In this paper, \(Y\) denotes the complex spectrum, while \(\mathbf{Y}_{\mathrm{ri}}\) denotes its corresponding real-imaginary tensor representation. Unless a batched tensor shape is explicitly required, the batch dimension is omitted for notation simplicity.

The goal of full-band speech enhancement is to estimate the clean full-band spectrum \(\hat{X}\) from the noisy full-band observation \(Y\), and then reconstruct the enhanced waveform \(\hat{x}\) by inverse STFT. TF-Rehancer does not directly generate the enhanced spectrum from a latent representation. Instead, it follows a filtering-based refinement formulation: the network predicts a complex time-frequency filter \(W\), which is then applied to the noisy STFT:

\[
W = \mathcal{G}_{\theta}(\Phi(Y)), \qquad
\hat{X} = W \otimes Y,
\]

where \(\mathcal{G}_{\theta}\) denotes TF-Rehancer, \(\Phi(Y)\) is the neural conditioning feature defined in Section 3.2, and \(\otimes\) denotes local complex filtering over the noisy STFT. This formulation clarifies the role of the network: TF-Rehancer predicts the filter, while the output spectrum is obtained by filtering the observed noisy spectrum. The detailed filtering operation is described in Section 3.4.

For full-band modeling, TF-Rehancer divides the embedded frequency axis into low-band and high-band tokens after an initial shared frequency embedding. The low-band cutoff is set to \(f_c = 5\) kHz. In practice, the closest STFT bin corresponding to \(f_c\) is selected, and frequency bins up to \(f_c\) are assigned to the low-band region. This region contains much of the harmonic, formant, and intelligibility-related structure, and is therefore used as the main source for the low-band representation. The high-band tokens are derived from the observed upper-frequency region and are used as decoder-side query features. This design avoids applying the full encoder stack to all full-band tokens, while allowing the low-band representation to refine the observed high-band information.

## 3.2 TF-Rehancer Architecture

TF-Rehancer is a time-frequency-domain architecture for full-band speech enhancement. Its overall processing flow is summarized as

\[
Y
\rightarrow
\Phi(Y)
\rightarrow
H
\rightarrow
(H_{\mathrm{low}}, H_{\mathrm{high}})
\rightarrow
Z, Q_h
\rightarrow
D_{\mathrm{emb}}
\rightarrow
D_{\mathrm{full}}
\rightarrow
W
\rightarrow
\hat{X}.
\]

The model receives the noisy complex STFT in real-imaginary tensor form:

\[
\mathbf{Y}_{\mathrm{ri}} \in \mathbb{R}^{B \times F \times T \times 2}.
\]

The original linear noisy STFT \(Y\) is preserved as the reference spectrum for final complex filtering. The neural conditioning feature is constructed from a power-law compressed complex STFT. Given a compression factor \(\gamma=0.3\), the compressed spectrum is

\[
Y_{\mathrm{plc}} = |Y|^{\gamma-1}Y.
\]

For numerical stability, a small \(\epsilon\)-stabilized magnitude is used in implementation and omitted from the notation. The input feature is formed by concatenating the compressed real part, compressed imaginary part, and compressed magnitude:

\[
\Phi(Y)=
[
\operatorname{Re}(Y_{\mathrm{plc}}),
\operatorname{Im}(Y_{\mathrm{plc}}),
|Y_{\mathrm{plc}}|
]
\in \mathbb{R}^{B \times F \times T \times 3}.
\]

The power-law compressed feature is used only as the network input. The final output is obtained by applying the predicted filter to the original linear noisy STFT, not to the compressed STFT.

The conditioning feature is first passed through a shared frequency-strided convolutional stem:

\[
H = \operatorname{Stem}(\Phi(Y)).
\]

The stem consists of a 2-D convolution, batch normalization, and SiLU activation. The convolution applies stride only along the frequency axis, reducing the number of frequency tokens before the main TF modeling blocks while preserving the time resolution. The resulting embedded representation is

\[
H \in \mathbb{R}^{B \times F_{\mathrm{emb}} \times T \times C_e}.
\]

The embedded frequency axis is split into low-band and high-band tokens:

\[
H_{\mathrm{low}} = H[\mathcal{I}_{\mathrm{low}},:,:],
\qquad
H_{\mathrm{high}} = H[\mathcal{I}_{\mathrm{high}},:,:],
\]

where \(\mathcal{I}_{\mathrm{low}}=\{1,\ldots,F_{\mathrm{low}}\}\) and \(\mathcal{I}_{\mathrm{high}}=\{F_{\mathrm{low}}+1,\ldots,F_{\mathrm{emb}}\}\). The slicing is performed along the embedded frequency axis, and the batch dimension is omitted for clarity.

The low-band tokens are sent to the encoder, while the high-band tokens bypass the heavy encoder and are used to construct observed high-band query features. In the 40 ms / 20 ms STFT configuration used in our experiments, selecting bins up to \(f_c=5\) kHz corresponds to 201 full-resolution frequency bins and 101 embedded low-band tokens after the frequency-strided stem. Therefore, the number of low-band encoder tokens remains nearly the same in both 16 kHz and 48 kHz settings, while the number of high-band query tokens increases with the full-band frequency range in the 48 kHz setting.

The low-band encoder consists of stacked TF modeling blocks. Each block contains a frequency module and a time module. The frequency module operates along the frequency-token axis at each time frame and consists of efficient convolutional feed-forward processing, frequency-axis self-attention with rotary positional encoding, and another efficient convolutional feed-forward module. The time module applies recurrent temporal modeling independently for each embedded frequency token. We instantiate the time module with two residual unidirectional GRU blocks. The encoder output is

\[
Z = \operatorname{Encoder}(H_{\mathrm{low}})
\in \mathbb{R}^{B \times F_{\mathrm{low}} \times T \times C_e}.
\]

The decoder receives both the low-band encoder representation \(Z\) and the high-band query feature \(Q_h\). After concatenation along the frequency axis, a projection maps the channel dimension from the encoder width \(C_e\) to the decoder width \(C_d\):

\[
D_0 = \operatorname{Proj}([Z; Q_h]_F)
\in \mathbb{R}^{B \times F_{\mathrm{emb}} \times T \times C_d}.
\]

The decoder consists of stacked TF modeling blocks. Each decoder block contains frequency-axis cross-attention, frequency-axis self-attention, efficient convolutional feed-forward processing, and recurrent time modeling. The decoder output remains at the compressed embedded frequency resolution:

\[
D_{\mathrm{emb}}
\in \mathbb{R}^{B \times F_{\mathrm{emb}} \times T \times C_d}.
\]

Before filter estimation, the decoder output is upsampled along the frequency axis to the original STFT frequency resolution:

\[
D_{\mathrm{full}} = \operatorname{Upsample}_{F}(D_{\mathrm{emb}})
\in \mathbb{R}^{B \times F \times T \times C_d}.
\]

The full-resolution decoder feature is then used to estimate local complex TF filters, which are applied to the original noisy STFT. This asymmetric design is central to TF-Rehancer: heavy encoding is concentrated on low-band structure, while the observed high-band path remains a decoder-side observed query representation until decoder refinement.

## 3.3 Low-to-High Embedded Query Refinement

The key architectural idea of TF-Rehancer is low-to-high embedded query refinement. Instead of processing all full-band frequency tokens with the same heavy encoder, TF-Rehancer separates the roles of low-band and high-band representations. The low-band branch forms a guiding representation, while the high-band branch provides observed query information to be refined in the decoder.

The high-band query is derived from the embedded high-band observation \(H_{\mathrm{high}}\). A lightweight local adapter is applied to \(H_{\mathrm{high}}\) and added back residually:

\[
Q_h = H_{\mathrm{high}} + \operatorname{Adapter}_{h}(H_{\mathrm{high}}).
\]

The adapter consists of a local 2-D convolution, SiLU activation, and normalization. This residual design is important because the query is neither an empty learned token nor a generated high-band placeholder. It is derived from the noisy high-band observation after the shared embedding stem. Therefore, \(Q_h\) retains local high-band evidence while applying a lightweight local transformation before decoder refinement.

The decoder input is constructed by concatenating the low-band encoder output \(Z\) and the high-band query \(Q_h\):

\[
D_0 = \operatorname{Proj}([Z; Q_h]_F).
\]

In the decoder cross-attention module, only the high-band decoder tokens are updated using the low-band encoder representation. Let

\[
D_0 = [D_{\mathrm{low}}; D_{\mathrm{high}}]_F.
\]

The low-band decoder tokens \(D_{\mathrm{low}}\) are passed through the cross-attention stage unchanged, while the high-band tokens \(D_{\mathrm{high}}\) are used as queries. Here, \(D_{\mathrm{high}}\) has the decoder channel width \(C_d\), while \(Z\) has the encoder channel width \(C_e\). Therefore, the encoder representation is linearly projected to key/value representations inside the multi-head cross-attention module:

\[
Q = \Pi_q(D_{\mathrm{high}}),
\qquad
K = \Pi_k(Z),
\qquad
V = \Pi_v(Z).
\]

The high-band update is computed as

\[
\tilde{D}_{\mathrm{high}}
=
D_{\mathrm{high}}
+
\operatorname{MHCA}(D_{\mathrm{high}}, Z, Z),
\]

where the projection matrices inside MHCA map the query, key, and value tensors to the decoder attention dimension. The full decoder sequence is then reconstructed as

\[
\tilde{D} = [D_{\mathrm{low}}; \tilde{D}_{\mathrm{high}}]_F.
\]

This mechanism explicitly conditions the high-band query feature on the low-band representation. The low-band encoder output provides structured information extracted from the lower-frequency region, while the high-band query contains noisy upper-band evidence from the input. Therefore, the cross-attention performs refinement of observed high-band features rather than high-band generation from an empty query.

After cross-attention, the decoder applies frequency-axis self-attention over the full embedded frequency sequence. This allows low- and high-band decoder tokens to interact after low-to-high conditioning. The decoder then applies efficient convolutional feed-forward processing and recurrent temporal modeling. Through this sequence, TF-Rehancer first performs directed low-to-high refinement and then models the resulting full-band representation.

## 3.4 Full-Resolution Complex TF Filtering

Although TF-Rehancer performs most TF modeling at compressed embedded frequency resolution, the final filter is estimated at the original STFT frequency resolution. The decoder output \(D_{\mathrm{emb}}\) is first upsampled along the frequency axis:

\[
D_{\mathrm{full}} = \operatorname{Upsample}_{F}(D_{\mathrm{emb}})
\in \mathbb{R}^{B \times F \times T \times C_d}.
\]

The upsampling module consists of a pointwise convolution followed by a transposed convolution along the frequency axis. This restores the feature sequence to the full STFT frequency resolution before filter estimation.

The complex filter head predicts a local complex operator for each time-frequency bin. For a \(3 \times 3\) TF neighborhood, the filter contains nine complex taps corresponding to

\[
\Delta f \in \{-1,0,1\},
\qquad
\Delta t \in \{-1,0,1\}.
\]

A local 2-D convolution over \(D_{\mathrm{full}}\) produces raw filter coefficients. The output is interpreted as one positive scale component and two bounded real-imaginary components for each local tap. A softplus activation is applied to the scale component, and tanh activations are applied to the real-imaginary components:

\[
M = \operatorname{softplus}(A_m),
\]

\[
R,I = \tanh(A_{ri}),
\]

\[
W_{\Delta f,\Delta t,f,t}
=
M_{\Delta f,\Delta t,f,t}
\left(
R_{\Delta f,\Delta t,f,t}
+
j I_{\Delta f,\Delta t,f,t}
\right).
\]

The enhanced spectrum is estimated by applying the predicted complex filter to the original noisy STFT:

\[
\hat{X}_{f,t}
=
\sum_{\Delta f=-1}^{1}
\sum_{\Delta t=-1}^{1}
W_{\Delta f,\Delta t,f,t}
\cdot
Y_{f+\Delta f,t+\Delta t}.
\]

Boundary bins are handled by padding the noisy STFT before collecting the local TF neighborhood.

This filtering formulation differs from direct clean-spectrum mapping. The model does not directly output \(\hat{X}_{f,t}\) from the decoder feature alone. Instead, it estimates a local complex filter and applies it to the observed noisy spectrum. This encourages the network to perform enhancement as a structured refinement of the input STFT, while still allowing phase-aware local correction through complex-valued filtering. After filtering, the enhanced complex spectrum is transformed back to the waveform domain by inverse STFT.

## 3.5 Training Objective

TF-Rehancer is trained using a composite enhancement objective defined over both the STFT and waveform domains. The spectral terms are computed on gamma-compressed complex spectra. For a complex STFT \(X\), the compressed spectrum is

\[
X_c = |X|^{\gamma}\exp(j\angle X),
\qquad \gamma = 0.3.
\]

Equivalently, in complex form,

\[
X_c = |X|^{\gamma-1}X.
\]

As in the input compression, a small \(\epsilon\)-stabilized magnitude is used in implementation and omitted from the notation.

Let \(\hat{X}\) and \(X\) denote the enhanced and clean complex spectra, and let \(\hat{x}\) and \(x\) denote the enhanced and clean waveforms. The total loss is

\[
\mathcal{L}
=
\lambda_{\mathrm{mag}}\mathcal{L}_{\mathrm{mag}}
+
\lambda_{\mathrm{cplx}}\mathcal{L}_{\mathrm{cplx}}
+
\lambda_{\mathrm{cons}}\mathcal{L}_{\mathrm{cons}}
+
\lambda_{\mathrm{wav}}\mathcal{L}_{\mathrm{wav}}
+
\lambda_{\mathrm{pesq}}\mathcal{L}_{\mathrm{pesq}}.
\]

The magnitude loss is defined as

\[
\mathcal{L}_{\mathrm{mag}}
=
\left\|
|\hat{X}_c| - |X_c|
\right\|_2^2.
\]

The complex spectral loss is

\[
\mathcal{L}_{\mathrm{cplx}}
=
\left\|
\operatorname{Re}(\hat{X}_c)-\operatorname{Re}(X_c)
\right\|_2^2
+
\left\|
\operatorname{Im}(\hat{X}_c)-\operatorname{Im}(X_c)
\right\|_2^2.
\]

All squared spectral losses are implemented as mean-squared errors averaged over batch, time, frequency, and component dimensions where applicable. The consistency loss encourages agreement between the waveform-domain output and the STFT-domain target. The enhanced waveform is transformed back into the STFT domain, compressed using the same gamma-compression rule, and compared with the clean compressed spectrum:

\[
\mathcal{L}_{\mathrm{cons}}
=
\left\|
\operatorname{STFT}(\hat{x})_c - X_c
\right\|_2^2.
\]

The waveform loss is

\[
\mathcal{L}_{\mathrm{wav}} = \|\hat{x}-x\|_1.
\]

The waveform L1 loss is averaged over batch and time samples.

For configurations using the PESQ auxiliary term, we define

\[
\mathcal{L}_{\mathrm{pesq}} = \operatorname{PESQ\text{-}Loss}(\hat{x},x).
\]

This term is computed at 16 kHz after resampling to match the PESQ loss implementation. Therefore, it is treated as an auxiliary training signal rather than the primary full-band objective.

We use the following loss weights:

\[
\lambda_{\mathrm{mag}}=0.3,
\quad
\lambda_{\mathrm{cplx}}=0.2,
\quad
\lambda_{\mathrm{cons}}=0.3,
\quad
\lambda_{\mathrm{wav}}=0.2,
\quad
\lambda_{\mathrm{pesq}}=0.001.
\]

All spectral loss terms are computed on gamma-compressed complex STFTs. This keeps the training objective consistent with the power-law compressed spectral representation used for neural conditioning, while the model output is still obtained by complex filtering over the original noisy STFT.
