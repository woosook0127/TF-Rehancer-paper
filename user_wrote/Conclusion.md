# 5 Conclusion

## 5.1 Summary

This paper presented TF-Rehancer, a time-frequency-domain speech enhancement architecture for efficient full-band processing. The main idea is low-band encoder-guided full-band decoder refinement: TF-Rehancer concentrates heavier modeling on low-band speech structure, keeps observed upper-band evidence in the decoder path, and estimates the enhanced spectrum through complex time-frequency filtering over the original noisy STFT.

The experiments show that TF-Rehancer provides a competitive quality-efficiency trade-off on the 16 kHz VoiceBank+DEMAND benchmark. Compared with the locally evaluated FastEnhancer-M checkpoint, TF-Rehancer improves PESQ-WB and DNSMOS SIG/BAK/OVRL with fewer model-side MACs and a similar number of parameters, while FastEnhancer-M remains stronger in DNSMOS P.808, SCOREQ, SI-SDR, STOI, and ESTOI. In the controlled 48 kHz ablation setting, direct spectrum mapping degrades full-reference, spectral, and non-intrusive metrics compared with complex TF filtering, suggesting that filtering-based output estimation is more reliable for the proposed architecture. The decoder MHCA ablation shows a mixed trend, indicating that cross-attention changes the trade-off between perceptual scores and spectral fidelity rather than providing a uniformly beneficial gain. The low-band cutoff analysis further shows that 5 kHz provides a balanced operating point between computational cost, waveform fidelity, and high-band spectral behavior.

Overall, these results support low-band encoder-guided full-band decoder refinement as an efficient design direction for full-band speech enhancement. The architecture preserves observed upper-band information, avoids heavy full-band encoding, and uses full-resolution complex TF filtering to produce the enhanced spectrum.

## 5.2 Limitations and Future Work

The 48 kHz experiments in this work are designed for controlled component analysis, not for ranking against external full-band speech enhancement systems. A protocol-aligned 48 kHz comparison with strong full-band baselines remains necessary to establish broader performance claims. Future work should therefore evaluate TF-Rehancer and competing full-band systems under a shared training and evaluation protocol, including aligned metric computation and runtime measurement.

Several architectural questions also remain open. The present ablation supports filtering-based output estimation and characterizes the effect of decoder MHCA, but it does not fully separate the contribution of the lightweight high-band adaptation from the subsequent decoder refinement. A focused ablation that removes or replaces the local high-band adapter while preserving the observed high-band embedding would clarify this component. In addition, the low-band cutoff was selected as a balanced operating point under the 48 kHz ablation setting; broader datasets, noise conditions, and sampling rates may require adaptive or data-dependent cutoff strategies.

Finally, practical deployment requires further validation beyond model-side MACs. Future work should include real-time runtime profiling, latency analysis, and evaluation on device-oriented scenarios. Extension to multi-channel or reverberant conditions is another possible direction.
