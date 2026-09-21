# Working in this repo

A CV generator. `me.md` (content) and `style/cv.sty` (appearance) are hand-written;
`output/` is generated from them.

```
me.md  ──►  output/cv.tex  ──(xelatex)──►  output/cv.pdf
```

The CV-generation workflow and the LaTeX markup reference live in
`.claude/skills/latex-cv/SKILL.md`. Read it before generating or editing a CV.
This file covers working in the repo generally.

## Build

```bash
bash .claude/skills/latex-cv/scripts/compile.sh output/cv.tex
```

No TeX on the machine? `tools/Containerfile` has the toolchain:

```bash
podman build -t cv-tex tools/
podman run --rm -v "$PWD":/data:z -w /data --entrypoint bash cv-tex \
  -c 'bash .claude/skills/latex-cv/scripts/compile.sh output/cv.tex'
```

Always rebuild after changing `me.md` or `style/cv.sty`, and check the reported page
count. To see the result rather than assume it: `pdftoppm -r 100 -png output/cv.pdf out`
and look at the image.

## Rules

- **`output/cv.tex` is generated.** Never hand-edit it — it is rewritten from `me.md`
  on every build and your edit will vanish. Fix `me.md` and rebuild.
- **Styling goes in `style/cv.sty`, never in `cv.tex`**, for the same reason.
- **Never invent CV content.** No employer, date, degree, metric or skill may appear
  that is not in `me.md`. Report gaps; do not fill them.
- **`## Notes (not printed)` in `me.md` is private.** It never reaches the PDF.
- **No identifying details in documentation.** README, AGENTS.md, SKILL.md, `cv.sty`
  and `tools/` use generic examples only — no real employer, name, city or URL. The
  owner's data belongs in `me.md` and `output/` alone.
- **Don't add a second copy of anything.** This repo had duplicated style files and
  duplicated docs; both were removed. Point at the canonical file instead.

## Gotchas, learned the hard way

- **Unescaped `%` does not error.** It comments out the rest of the line, so text
  silently disappears from the PDF. Escape `& % $ # _ { }` in everything taken from
  `me.md`, and check the PDF for missing text.
- **Load fonts by filename, not fontconfig name.** `\setmainfont{TeX Gyre Heros}`
  falls back to `nullfont` on a bare TeX install and yields a blank PDF with no error.
  `cv.sty` uses the `texgyreheros` + `Extension=.otf` form; keep it.
- **Two-column entry lines use `tabular*`, not `tabularx` or `\hfill`.** An `X`
  column is a paragraph box whose first baseline `\linespread` shifts, which put
  dates a few points above the line they belonged to. `\hfill` fails differently:
  `\raggedright` makes `\rightskip` stretchable, so right-hand text lands mid-line
  instead of flush right. `tabularx` also cannot be wrapped in a `\newenvironment`
  at all — it scans for its own `\end{tabularx}`.
- **The profile photo is optional.** `\cvheader` branches on `IfFileExists`; there is
  no flag. `assets/photo.jpg` currently holds a placeholder marked PLACEHOLDER — say
  so if it is still in place when building a CV that will be sent.
- **Both engines must keep working.** `compile.sh` falls back from xelatex to
  pdflatex, which is only safe because `cv.sty` has a real `\ifPDFTeX` branch.

## Layout

```
me.md                     content — the source of truth
me-<lang>.md              optional: one profile per extra language
style/cv.sty              appearance — hand-edited, never regenerated
assets/photo.jpg          optional profile picture
output/                   generated, git-ignored
tools/Containerfile       TeX toolchain
.claude/skills/latex-cv/  SKILL.md (workflow + markup), scripts/compile.sh
```
