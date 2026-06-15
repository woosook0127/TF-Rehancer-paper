# Filter Tap Ablation Table

- Anchor: `project_analysis/analyze_results/v5_auto_eval_20260615/v5_anchor_filtering_vctkdns48_warmup40_best_full/full_se_metrics_n824.csv`
- Tap ablation: `project_analysis/analyze_results/v5_filter_tap_retest_20260615`
- Evaluation: VoiceBank+DEMAND 48 kHz test set, `n=824`
- Failures: `{}` for all rows
- Rounding: STOI/ESTOI keep 3 decimals; other metrics keep 2 decimals.
- Note: `LSD-H` is omitted.

## Markdown Table

| Method | Tap | ep | DNSMOS(P.808) | SIG | BAK | OVL | SI-SDR | PESQ | STOI | ESTOI | CSIG | CBAK | COVL | LSD | MCD |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Default TF | 3 x 3 | 22 | 3.45 | 3.38 | **3.98** | **3.07** | **16.70** | **3.29** | **0.948** | **0.868** | 4.40 | **3.59** | 3.88 | 0.73 | **2.28** |
| F-only | 1 x 3 | 22 | 3.45 | 3.38 | 3.96 | 3.06 | 16.09 | 3.28 | 0.947 | **0.868** | 4.39 | 3.57 | 3.87 | **0.72** | 2.31 |
| F-only | 1 x 5 | 18 | **3.46** | **3.39** | 3.94 | 3.06 | 15.24 | 3.28 | 0.946 | 0.866 | **4.42** | 3.53 | **3.89** | 0.76 | 2.40 |
| F-only | 1 x 7 | 22 | **3.46** | 3.38 | 3.95 | 3.05 | 16.18 | 3.26 | 0.947 | 0.867 | 4.40 | 3.56 | 3.86 | 0.74 | 2.32 |
| T-only | 3 x 1 | 15 | 3.44 | 3.37 | 3.94 | 3.04 | 15.57 | 3.20 | 0.945 | 0.861 | 4.38 | 3.49 | 3.82 | 0.80 | 2.49 |
| T-only | 5 x 1 | 30 | 3.44 | 3.38 | 3.88 | 3.01 | 13.83 | 3.20 | 0.946 | 0.865 | 4.35 | 3.42 | 3.80 | 0.78 | 2.53 |

## LaTeX Draft

```latex
\begin{table}[ht!]
    \centering
    \providecommand{\best}[1]{\textbf{#1}}
    \small
    \setlength{\tabcolsep}{1.0pt}
    \renewcommand{\arraystretch}{1.15}
    \resizebox{\textwidth}{!}{
    \begin{tabular}{lccccccccccccccc}
        \hline
        \multirow{2}{*}{Method} & \multirow{2}{*}{Tap} & \multirow{2}{*}{ep} & \multirow{1}{*}{DNSMOS} & \multicolumn{3}{c}{DNSMOS(P.835)} & \multirow{2}{*}{SI-SDR$\uparrow$} & \multirow{2}{*}{PESQ$\uparrow$} & \multirow{2}{*}{STOI$\uparrow$} & \multirow{2}{*}{ESTOI$\uparrow$} & \multirow{2}{*}{CSIG$\uparrow$} & \multirow{2}{*}{CBAK$\uparrow$} & \multirow{2}{*}{COVL$\uparrow$} & \multirow{2}{*}{LSD$\downarrow$} & \multirow{2}{*}{MCD$\downarrow$} \\
        & & & (P.808)$\uparrow$ & SIG$\uparrow$ & BAK$\uparrow$ & OVL$\uparrow$ & & & & & & & & & \\
        \hline
        Default TF & 3 x 3 & 22 & 3.45 & 3.38 & \best{3.98} & \best{3.07} & \best{16.70} & \best{3.29} & \best{0.948} & \best{0.868} & 4.40 & \best{3.59} & 3.88 & 0.73 & \best{2.28} \\
        F-only & 1 x 3 & 22 & 3.45 & 3.38 & 3.96 & 3.06 & 16.09 & 3.28 & 0.947 & \best{0.868} & 4.39 & 3.57 & 3.87 & \best{0.72} & 2.31 \\
        F-only & 1 x 5 & 18 & \best{3.46} & \best{3.39} & 3.94 & 3.06 & 15.24 & 3.28 & 0.946 & 0.866 & \best{4.42} & 3.53 & \best{3.89} & 0.76 & 2.40 \\
        F-only & 1 x 7 & 22 & \best{3.46} & 3.38 & 3.95 & 3.05 & 16.18 & 3.26 & 0.947 & 0.867 & 4.40 & 3.56 & 3.86 & 0.74 & 2.32 \\
        T-only & 3 x 1 & 15 & 3.44 & 3.37 & 3.94 & 3.04 & 15.57 & 3.20 & 0.945 & 0.861 & 4.38 & 3.49 & 3.82 & 0.80 & 2.49 \\
        T-only & 5 x 1 & 30 & 3.44 & 3.38 & 3.88 & 3.01 & 13.83 & 3.20 & 0.946 & 0.865 & 4.35 & 3.42 & 3.80 & 0.78 & 2.53 \\
        \hline
    \end{tabular}
    }
    \caption[Filter tap ablation]{Filter tap ablation on the VoiceBank+DEMAND 48 kHz test set. The default row uses a 3 x 3 time-frequency filtering neighborhood. The F-only rows use frequency-only neighborhoods, and the T-only rows use time-only neighborhoods.}
    \label{tab:filter_tap_ablation}
\end{table}
```

## Short Reading

Default `3 x 3` remains strongest for SI-SDR, PESQ, STOI, ESTOI, BAK/OVL, CBAK, and MCD. F-only variants are competitive on several perceptual/composite scores, especially `1 x 5`, but lose SI-SDR and MCD. T-only variants are clearly weaker.
