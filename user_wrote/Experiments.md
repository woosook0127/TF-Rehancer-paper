# 4 Experiments

## 4.1 Experimental Setup

### 4.1.1 Datasets and Protocols

We evaluate TF-Rehancer using a 16 kHz wideband benchmark and a 48 kHz controlled ablation setting. The 16 kHz setting uses the official VoiceBank+DEMAND corpus to compare the proposed model with lightweight speech enhancement baselines. The 48 kHz setting uses VCTK clean speech mixed with DNS full-band noise to analyze the architectural components of TF-Rehancer in the 48 kHz full-band setting.

For the 16 kHz comparison, we use the official VoiceBank+DEMAND paired speech enhancement corpus. The official training partition contains 28 speakers and is split into 10,413 training utterances and 1,159 validation utterances using a fixed random seed. Evaluation is performed on the official 824-utterance test set, which contains unseen speakers.

For the 48 kHz ablation study, we synthesize noisy mixtures from VCTK clean speech and DNS full-band noise. Each model is trained for 20 epochs and evaluated on the VoiceBank+DEMAND 48 kHz test set. These experiments are intended for controlled component analysis, not for ranking against external full-band systems.

### 4.1.2 Model Configuration

This chapter evaluates the final TF-Rehancer architecture described in Chapter 3. The main design principle is low-band encoder-guided refinement of observed high-band features in the full-band decoder. The model concentrates heavy encoding on the low-band representation, keeps observed high-band features in the decoder path, refines the decoder representation using the low-band encoder output, and estimates the enhanced spectrum through complex TF filtering over the original noisy STFT.

All TF-Rehancer experiments use a 40 ms analysis window and a 20 ms frame shift. With this setting, both 16 kHz and 48 kHz configurations have a frequency spacing of 25 Hz. The default low-band cutoff is 5 kHz, corresponding to 201 full-resolution frequency bins and 101 embedded low-band tokens after the frequency-strided stem. Thus, the low-band encoder length is nearly fixed across 16 kHz and 48 kHz configurations, while the number of observed high-band decoder tokens increases in the 48 kHz setting.

Model complexity is reported using the number of parameters and model-side multiply-accumulate operations (MACs). Unless otherwise stated, MACs exclude STFT and inverse STFT operations.

### 4.1.3 Evaluation Metrics

Local evaluation uses the checkpoint with the lowest validation loss. The default VoiceBank+DEMAND evaluation set contains 824 utterances.

We use both full-reference and non-intrusive metrics. DNSMOS P.808 and DNSMOS P.835 SIG/BAK/OVRL are computed after resampling the waveform to 16 kHz. SCOREQ is computed in full-reference natural-speech mode after 16 kHz resampling. PESQ-WB, STOI, and ESTOI are also computed after 16 kHz resampling. Unless otherwise specified, SI-SDR is computed at the task sampling rate.

For the 48 kHz analysis, we additionally report full-band spectral metrics because many standard speech enhancement metrics are computed after 16 kHz resampling and do not directly evaluate the upper-frequency region. We report full-band LSD, LSD-H@8k, MCD, and SI-SDR for 48 kHz outputs. LSD-H@8k denotes log-spectral distance computed over the frequency region above approximately 8 kHz. DNSMOS SIG/BAK/OVRL refers to DNSMOS P.835, while CSIG/CBAK/COVL refers to composite full-reference metrics.

## 4.2 16 kHz Speech Enhancement and Efficiency

We first evaluate the 16 kHz configuration on a standard wideband benchmark to compare enhancement quality and computational cost.

**Table 4.X: VoiceBank+DEMAND 16 kHz test results.** BSRNN is included as a paper-reported reference from the FastEnhancer paper. FastEnhancer-S and FastEnhancer-M are evaluated locally using the publicly released checkpoints. TF-Rehancer is evaluated locally on the same 824-utterance VoiceBank+DEMAND test set. MACs are model-side estimates and exclude STFT/iSTFT.

| model | source | Params ↓ | MACs ↓ | DNSMOS P.808 ↑ | DNSMOS SIG ↑ | DNSMOS BAK ↑ | DNSMOS OVRL ↑ | SCOREQ ↓ | SI-SDR ↑ | PESQ-WB ↑ | STOI ↑ | ESTOI ↑ |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| BSRNN | paper-reported reference | 0.334M | **0.245G** | 3.440 | 3.360 | 4.000 | 3.070 | 0.303 | 18.900 | 3.060 | 0.942 | 0.855 |
| FastEnhancer-S | official checkpoint local eval | **0.195M** | 0.664G | **3.504** | 3.394 | 4.030 | 3.115 | 0.265 | 19.166 | 3.186 | 0.947 | 0.866 |
| FastEnhancer-M | official checkpoint local eval | 0.492M | 2.900G | 3.496 | 3.392 | 4.024 | 3.110 | **0.241** | **19.561** | 3.195 | **0.950** | **0.873** |
| TF-Rehancer | local evaluation | 0.470M | 1.890G | 3.487 | **3.405** | **4.042** | **3.129** | 0.244 | 19.438 | **3.334** | 0.950 | 0.872 |

Compared with the locally evaluated FastEnhancer-M checkpoint, TF-Rehancer achieves higher PESQ-WB and DNSMOS SIG/BAK/OVRL with lower model-side MACs and a similar number of parameters. FastEnhancer-M remains better in DNSMOS P.808, SCOREQ, SI-SDR, STOI, and ESTOI. FastEnhancer-S has the smallest parameter count and the highest DNSMOS P.808 score, while TF-Rehancer obtains higher PESQ-WB, DNSMOS SIG/BAK/OVRL, SI-SDR, STOI, and ESTOI at higher computational cost. Therefore, the 16 kHz result supports a competitive quality-efficiency trade-off rather than uniform dominance.

The BSRNN row is included only as a paper-reported reference. TF-Rehancer improves the reported quality and intelligibility metrics over this row, but uses more parameters and MACs.

## 4.3 Full-Band Architecture Ablations

**Table 4.X: 48 kHz architecture ablation on the VoiceBank+DEMAND 48 kHz test set.** All models are trained for 20 epochs using VCTK clean speech and DNS full-band noise and evaluated on the VoiceBank+DEMAND 48 kHz test set. These results are intended for controlled component analysis, not for ranking against external full-band systems.

| model | changed component | PESQ ↑ | STOI ↑ | CSIG ↑ | CBAK ↑ | COVL ↑ | SI-SDR ↑ | LSD ↓ | LSD-H@8k ↓ | MCD ↓ | DNSMOS SIG ↑ | DNSMOS BAK ↑ | DNSMOS OVRL ↑ | DNSMOS P.808 ↑ |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| TF-Rehancer | none | 3.285 | 0.947 | 4.405 | **3.598** | 3.878 | **16.835** | **0.719** | **0.709** | **2.265** | 3.382 | **3.983** | **3.073** | **3.458** |
| w/o decoder MHCA | remove decoder MHCA | **3.294** | **0.948** | **4.436** | 3.585 | **3.899** | 16.379 | 0.737 | 0.735 | 2.283 | **3.390** | 3.963 | 3.069 | **3.458** |
| Direct mapping head | filtering → direct mapping | 3.054 | 0.940 | 4.238 | 3.401 | 3.658 | 14.896 | 0.776 | 0.775 | 2.524 | 3.346 | 3.955 | 3.029 | 3.436 |

The direct mapping head performs worse than complex TF filtering across full-reference, spectral, and non-intrusive metrics. This suggests that filtering-based output estimation is more reliable than direct spectrum mapping in the 48 kHz ablation setting. The w/o decoder MHCA variant shows a mixed trend: it improves PESQ, STOI, CSIG, COVL, and DNSMOS SIG, but degrades SI-SDR, LSD, LSD-H@8k, MCD, and DNSMOS BAK/OVRL. Thus, decoder MHCA should be interpreted as changing the trade-off between perceptual scores and spectral fidelity, rather than as a uniformly beneficial module.

## 4.4 Low-Band Cutoff Sensitivity

**Table 4.X: Low-band cutoff ablation.** All rows use the 48 kHz 20-epoch setting with VCTK clean speech and DNS full-band noise. Parameter counts are identical across cutoff settings and are omitted. MACs are model-side estimates.

| cutoff | MACs ↓ | PESQ ↑ | STOI ↑ | COVL ↑ | SI-SDR ↑ | LSD ↓ | LSD-H@8k ↓ | MCD ↓ | DNSMOS OVRL ↑ | DNSMOS P.808 ↑ |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 8 kHz | 3.81G | **3.305** | 0.946 | **3.896** | 16.503 | 0.752 | 0.748 | 2.382 | **3.076** | 3.456 |
| 7 kHz | 3.54G | 3.294 | 0.947 | 3.878 | 16.111 | 0.753 | 0.752 | 2.347 | 3.066 | 3.451 |
| 6 kHz | 3.28G | 3.293 | 0.947 | 3.888 | 16.747 | 0.721 | **0.708** | **2.257** | 3.070 | **3.458** |
| 5 kHz | 3.02G | 3.285 | 0.947 | 3.878 | **16.835** | **0.719** | 0.709 | 2.265 | 3.073 | **3.458** |
| 4 kHz | 2.76G | 3.271 | 0.947 | 3.869 | 16.286 | 0.733 | 0.725 | 2.312 | 3.070 | 3.454 |
| 3 kHz | **2.50G** | 3.226 | 0.946 | 3.841 | 15.406 | 0.781 | 0.787 | 2.378 | 3.060 | 3.448 |

The cutoff sweep shows a trade-off among computation, perceptual quality, and spectral fidelity. Larger cutoffs increase computation and improve some perceptual scores, whereas smaller cutoffs reduce MACs but can degrade full-band and high-band spectral fidelity. Under the 48 kHz ablation setting, we use 5 kHz as the default cutoff because it provides a balanced operating point between computational cost, SI-SDR, and high-band spectral metrics.
