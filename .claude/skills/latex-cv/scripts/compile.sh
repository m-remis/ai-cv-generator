#!/usr/bin/env bash
# Compile a CV .tex to PDF.
#
# Uses a local TeX installation if there is one. If there is not, it builds
# and runs the container in tools/Containerfile instead, so a fresh clone
# works with nothing installed but podman or docker.
#
# Usage: bash compile.sh [path/to/cv.tex]      (default: output/cv.tex)
#
#   CV_ROOT=/path       the CV folder holding style/ and assets/. Needed only
#                       when cv.tex is not directly inside <CV_ROOT>/output/,
#                       e.g. a tailored variant in output/tailored/<name>/.
#   CV_ENGINE=local     never containerise; fail if TeX is missing
#   CV_ENGINE=container force the container even if local TeX exists
#   CV_IMAGE=name       image tag to use/build (default cv-tex:latest)

set -uo pipefail

TEX_PATH="${1:-output/cv.tex}"
[[ -f "$TEX_PATH" ]] || { echo "compile.sh: no such file: $TEX_PATH" >&2; exit 2; }

TEX_DIR="$(cd "$(dirname "$TEX_PATH")" && pwd)"
TEX_FILE="$(basename "$TEX_PATH")"
JOB="${TEX_FILE%.tex}"
LOG="$TEX_DIR/$JOB.log"

CV_ROOT="${CV_ROOT:-$(cd "$TEX_DIR/.." && pwd)}"
if [[ ! -d "$CV_ROOT/style" ]]; then
  echo "compile.sh: no style directory at $CV_ROOT/style" >&2
  echo "  set CV_ROOT to the CV folder (the one holding style/cv.sty)" >&2
  exit 2
fi

CV_ENGINE="${CV_ENGINE:-auto}"
CV_IMAGE="${CV_IMAGE:-cv-tex:latest}"

have_local_tex() { command -v xelatex >/dev/null 2>&1 || command -v pdflatex >/dev/null 2>&1; }

# ---------------------------------------------------------------- container --
container_runtime() {
  for rt in podman docker; do command -v "$rt" >/dev/null 2>&1 && { echo "$rt"; return; }; done
}

image_exists() {
  case "$1" in
    podman) podman image exists "$CV_IMAGE" ;;
    docker) docker image inspect "$CV_IMAGE" >/dev/null 2>&1 ;;
  esac
}

run_in_container() {
  local rt="$1"
  if ! image_exists "$rt"; then
    echo "compile.sh: no TeX on this machine - building the $CV_IMAGE image."
    echo "compile.sh: first run only, takes a few minutes."
    if ! "$rt" build -t "$CV_IMAGE" "$CV_ROOT/tools"; then
      echo "compile.sh: image build failed" >&2
      return 1
    fi
  fi
  # :z relabels for SELinux; harmless to skip where SELinux is not enforcing
  local mount="$CV_ROOT:/cv"
  if command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled 2>/dev/null; then
    mount="$mount:z"
  fi
  local rel_tex="${TEX_DIR#"$CV_ROOT"/}/$TEX_FILE"
  "$rt" run --rm -v "$mount" -w /cv --entrypoint bash "$CV_IMAGE" \
    -c "CV_ENGINE=local CV_ROOT=/cv bash .claude/skills/latex-cv/scripts/compile.sh '$rel_tex'"
}

# -------------------------------------------------------------------- local --
run_local() {
  export TEXINPUTS="$CV_ROOT/style:$CV_ROOT/assets:${TEXINPUTS:-}"
  local engines=()
  command -v xelatex  >/dev/null 2>&1 && engines+=(xelatex)
  command -v pdflatex >/dev/null 2>&1 && engines+=(pdflatex)

  for engine in "${engines[@]}"; do
    echo "compile.sh: trying $engine (CV_ROOT=$CV_ROOT) ..."
    local ok=1
    for _ in 1 2; do   # second pass settles hyperref and the page count
      if ! (cd "$TEX_DIR" && "$engine" -interaction=nonstopmode -halt-on-error \
              -file-line-error -jobname="$JOB" "$TEX_FILE" >/dev/null 2>&1); then
        ok=0; break
      fi
    done

    if [[ $ok -eq 1 && -f "$TEX_DIR/$JOB.pdf" ]]; then
      local pages
      pages="$(sed -n 's/.*Output written on .*(\([0-9][0-9]*\) page.*/\1/p' "$LOG" | tail -1)"
      [[ -z "$pages" ]] && pages="?"
      echo "compile.sh: OK  engine=$engine  pages=$pages  ->  $TEX_DIR/$JOB.pdf"
      (cd "$TEX_DIR" && rm -f "$JOB.aux" "$JOB.out" "$JOB.toc" "$JOB.fls" \
                              "$JOB.fdb_latexmk" "$JOB.synctex.gz")
      return 0
    fi

    echo "compile.sh: $engine failed." >&2
    echo "--- first errors from $JOB.log ---" >&2
    grep -nE -A3 -m5 '^!|^[^ :]+:[0-9]+: ' "$LOG" 2>/dev/null | head -30 >&2 \
      || echo "(no error lines in log)" >&2
  done
  return 1
}

# ------------------------------------------------------------------ dispatch --
case "$CV_ENGINE" in
  local)
    have_local_tex || { echo "compile.sh: CV_ENGINE=local but no xelatex or pdflatex found" >&2; exit 3; }
    run_local; exit $?
    ;;
  container)
    rt="$(container_runtime)"
    [[ -n "$rt" ]] || { echo "compile.sh: CV_ENGINE=container but neither podman nor docker is installed" >&2; exit 3; }
    run_in_container "$rt"; exit $?
    ;;
  auto)
    if have_local_tex; then
      run_local && exit 0
      echo "compile.sh: local TeX failed; not falling back to the container (fix the error above)" >&2
      exit 1
    fi
    rt="$(container_runtime)"
    if [[ -n "$rt" ]]; then
      run_in_container "$rt"; exit $?
    fi
    echo "compile.sh: no TeX and no container runtime found." >&2
    echo "  Install either:" >&2
    echo "    podman   (recommended - compile.sh builds the image for you)" >&2
    echo "    or TeX:  sudo dnf install texlive-scheme-medium texlive-xetex texlive-extsizes" >&2
    echo "             sudo apt install texlive-xetex texlive-fonts-recommended texlive-latex-extra" >&2
    exit 3
    ;;
  *)
    echo "compile.sh: unknown CV_ENGINE '$CV_ENGINE' (use auto, local or container)" >&2
    exit 2
    ;;
esac
