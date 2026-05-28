# TF-Rehancer Thesis Workspace

This repository is the LaTeX workspace for Wooseok's TF-Rehancer master thesis, based on the Sogang University thesis template.

## Source Template

Template:

```text
git@github.com:IIP-Sogang/SGU_thesis_template.git
```

Template commit inspected before import:

```text
3fdfc20efe2b82be6f1efa5949bd4bd4426a397c
```

Local fixes applied:

1. `Makefile` uses `/usr/bin/pdflatex` and `/usr/bin/bibtex` to avoid a local PATH/kpathsea issue where `pdflatex` was resolved as `./pdflatex`.
2. `setup/SGUThesis.cls` loads `etoolbox` because the class uses `\AfterEndPreamble`.
3. `.gitignore` ignores root `thesis.pdf` so compiled PDFs are not accidentally committed.

## Build

Local Linux build:

```bash
make thesis
```

Clean:

```bash
make clean
```

Required local package:

```bash
sudo apt-get install -y texlive-lang-korean
```

Manual build fallback:

```bash
/usr/bin/pdflatex thesis
/usr/bin/bibtex thesis
/usr/bin/pdflatex thesis
/usr/bin/pdflatex thesis
/usr/bin/pdflatex thesis
```

## Overleaf

Recommended Overleaf setup:

1. Create a new Overleaf project from this GitHub repository.
2. Set main file to `thesis.tex`.
3. Use `pdfLaTeX` first.
4. Use Overleaf mostly for compile/PDF preview.
5. Keep long-form edits in local Git/Codex workflow and push changes.

## Current Status

Initial import still contains the original sample thesis text and sample figures. TF-Rehancer-specific chapters will replace these files gradually.

Planned chapter mapping:

| file | target content |
|---|---|
| `text/chapter1.tex` | Introduction |
| `text/chapter2.tex` | Related Work |
| `text/chapter3.tex` | Proposed Method |
| `text/chapter4.tex` | Experiments |
| `text/chapter5.tex` | Results and Discussion |
| `text/conclusion.tex` | Conclusion |
| `text/appendix.tex` | Appendix |

Primary research draft source:

```text
/home/wooseok/project/TF_Renhancer/project_analysis/paper/2026-05-27_tf_rehancer_paper_draft_v0.md
```

