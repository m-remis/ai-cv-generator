# Working in this repo

A CV generator. `me.md` (content) and `style/cv.sty` (appearance) are hand-written, plus `me-<lang>.md` for any extra
language and an optional `assets/photo.jpg`. Everything under `output/` is generated
from them and git-ignored.

`me.md` and `assets/photo.jpg` are git-ignored: they hold real personal data and must
never be committed. The repo ships neither, so a fresh clone has no profile until one
is written.

```
me.md  ──►  output/cv.tex  ──(xelatex)──►  output/cv.pdf
```

Two skills split the work: `.claude/skills/latex-cv/` is the mechanics - `me.md` to LaTeX to PDF, markup, escaping,
compiling - and `.claude/skills/cv-review/` is the judgment about what the CV actually says. Read the relevant one
before starting. Layout, setup and everyday usage are in `README.md`. This file is the part that is neither: the rules,
and the ways this project fails silently.

## Build

```bash
bash .claude/skills/latex-cv/scripts/compile.sh output/cv.tex
```

No TeX on the machine? `tools/Containerfile` has the toolchain; the README shows the two podman commands.

Always rebuild after changing `me.md` or `style/cv.sty`, and check the reported page count. To see the result rather
than assume it: `pdftoppm -r 100 -png output/cv.pdf out`
and look at the image.

## Rules

- **`output/cv.tex` is generated.** Never hand-edit it - it is rewritten from `me.md`
  on every build and your edit will vanish. Fix `me.md` and rebuild.
- **Styling goes in `style/cv.sty`, never in `cv.tex`**, for the same reason.
- **No em dashes, anywhere.** They are a giveaway of generated text. Use a plain hyphen in all prose - in `me.md`,
  `cv.tex`, comments and docs alike. Never `---`.
- **One exception: date ranges take an en dash.** `2022 - 2026` is wrong; write
  `2022 – 2026` in `me.md` and `{2022 -- 2026}` in `cv.tex`. Nowhere else.
- **Never invent CV content.** No employer, date, degree, metric or skill may appear that is not in `me.md`. Report
  gaps; do not fill them.
- **`## Notes (not printed)` in `me.md` is private.** It never reaches the PDF.
- **No identifying details in documentation.** README, AGENTS.md, SKILL.md, `cv.sty`
  and `tools/` use generic examples only - no real employer, name, city or URL. The owner's data belongs in `me.md` and
  `output/` alone.
- **Both engines must keep working.** `compile.sh` falls back from xelatex to pdflatex; that is only safe while `cv.sty`
  keeps a real `\ifPDFTeX` branch.
- **Don't add a second copy of anything.** This repo had duplicated style files and duplicated docs; both were removed.
  Point at the canonical file instead.

## Gotchas, learned the hard way

- **Unescaped `%` does not error - it eats the rest of the line.** `40%` in a bullet compiles cleanly, exit 0, and the
  PDF silently reads "…by 40". Nothing in this repo catches it. Escape `& % $ # _ { }` in everything taken from `me.md`,
  and read the built PDF for text that vanished.
- **Do not "simplify" the font loading.** `cv.sty` loads `texgyreheros` by filename with `Extension=.otf`. The
  obvious-looking `\setmainfont{TeX Gyre Heros}` resolves by fontconfig name, which a bare TeX install does not have -
  the result is
  `nullfont` and a blank PDF, again with no error.
- **`\cvjob` uses `tabular*`, `cvskills` uses `tabular` p-columns.** Both look over-complicated and both are deliberate;
  `cv.sty` explains why at each. `tabularx`,
  `\hfill` and enumitem `description` were each tried and each failed differently. Read the comment before changing
  either.
