del *.pdf
FOR /R %%i IN (*.aux, *.log, *.lof, *.lot, *.out, *.toc, *.bbl, *.blg) DO DEL "%%i"
