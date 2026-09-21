#!/usr/bin/env bash
# Compile a CV .tex to PDF. Tries xelatex, falls back to pdflatex, reports the
# page count. Puts the CV folder's style/ and assets/ on TEXINPUTS so
# \usepackage{cv} and the profile photo resolve without installing anything
# into the TeX tree.
#
# Usage: bash compile.sh [path/to/cv.tex]      (default: output/cv.tex)
#        CV_ROOT=/path/to/cv-folder bash compile.sh ...
#          Needed only when cv.tex is not directly inside <CV_ROOT>/output/,
#          e.g. a tailored variant in output/tailored/<company>-<role>/.

set -uo pipefail

TEX_PATH="${1:-output/cv.tex}"
[[ -f "$TEX_PATH" ]] || { echo "compile.sh: no such file: $TEX_PATH" >&2; exit 2; }

TEX_DIR="$(cd "$(dirname "$TEX_PATH")" && pwd)"
TEX_FILE="$(basename "$TEX_PATH")"
JOB="${TEX_FILE%.tex}"
LOG="$TEX_DIR/$JOB.log"

# The CV folder holds style/ (required) and assets/ (optional — the photo).
CV_ROOT="${CV_ROOT:-$(cd "$TEX_DIR/.." && pwd)}"
if [[ ! -d "$CV_ROOT/style" ]]; then
  echo "compile.sh: no style directory at $CV_ROOT/style" >&2
  echo "  set CV_ROOT to the CV folder (the one holding style/cv.sty)" >&2
  exit 2
fi
export TEXINPUTS="$CV_ROOT/style:$CV_ROOT/assets:${TEXINPUTS:-}"

engines=()
command -v xelatex  >/dev/null 2>&1 && engines+=(xelatex)
command -v pdflatex >/dev/null 2>&1 && engines+=(pdflatex)

if [[ ${#engines[@]} -eq 0 ]]; then
  echo "compile.sh: neither xelatex nor pdflatex is installed." >&2
  echo "  Fedora: sudo dnf install texlive-scheme-medium texlive-xetex" >&2
  echo "  Debian: sudo apt install texlive-xetex texlive-fonts-recommended" >&2
  echo "  Or use the container: see tools/Containerfile" >&2
  exit 3
fi

for engine in "${engines[@]}"; do
  echo "compile.sh: trying $engine (CV_ROOT=$CV_ROOT) ..."
  ok=1
  for _ in 1 2; do   # second pass settles hyperref and the page count
    if ! (cd "$TEX_DIR" && "$engine" -interaction=nonstopmode -halt-on-error \
            -file-line-error -jobname="$JOB" "$TEX_FILE" >/dev/null 2>&1); then
      ok=0; break
    fi
  done

  if [[ $ok -eq 1 && -f "$TEX_DIR/$JOB.pdf" ]]; then
    pages="$(sed -n 's/.*Output written on .*(\([0-9][0-9]*\) page.*/\1/p' "$LOG" | tail -1)"
    [[ -z "$pages" ]] && pages="?"
    echo "compile.sh: OK  engine=$engine  pages=$pages  ->  $TEX_DIR/$JOB.pdf"
    (cd "$TEX_DIR" && rm -f "$JOB.aux" "$JOB.out" "$JOB.toc" "$JOB.fls" \
                            "$JOB.fdb_latexmk" "$JOB.synctex.gz")
    exit 0
  fi

  echo "compile.sh: $engine failed." >&2
  echo "--- first errors from $JOB.log ---" >&2
  grep -nE -A3 -m5 '^!|^[^ :]+:[0-9]+: ' "$LOG" 2>/dev/null | head -30 >&2 \
    || echo "(no error lines in log)" >&2
done

echo "compile.sh: all engines failed for $TEX_PATH" >&2
exit 1
