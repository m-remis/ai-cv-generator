# CV Generator

A CV built from a plain-text profile. You edit `me.md`; Claude generates the LaTeX and
compiles it to a PDF.

```
me.md  ──►  output/cv.tex  ──(xelatex)──►  output/cv.pdf
```

That is the whole system. Two files are yours: **`me.md`** for content,
**`style/cv.sty`** for appearance. `cv.tex` is generated and should never be hand-edited —
it is rewritten from `me.md` on every build, so the profile and the CV cannot drift apart.
Because styling lives in its own file, rebuilding never touches your design work.

## Layout

```
cv/
├── me.md                       # ← content. The file you edit.
├── style/cv.sty                # ← appearance. Yours; never regenerated.
├── assets/photo.jpg            # ← optional profile picture
├── output/                     # generated, git-ignored
│   ├── cv.tex
│   └── cv.pdf
├── tools/Containerfile         # TeX toolchain, if you'd rather not install one
├── AGENTS.md                   # how coding agents should work in this repo
├── CLAUDE.md                   # points Claude Code at AGENTS.md
└── .claude/skills/latex-cv/    # the skill Claude follows
    ├── SKILL.md                # the workflow, the markup, the rules
    └── scripts/compile.sh      # xelatex → pdflatex fallback, reports page count
```

## Requirements

TeX only:

```bash
sudo dnf install texlive-scheme-medium texlive-xetex    # Fedora
sudo apt install texlive-xetex texlive-fonts-recommended # Debian/Ubuntu
```

Nothing is installed into your TeX tree — `compile.sh` puts `style/` and `assets/`
on `TEXINPUTS`.

### Or use the container

If you'd rather not install TeX, `tools/Containerfile` has the toolchain this was
verified on:

```bash
podman build -t cv-tex tools/
podman run --rm -v "$PWD":/data:z -w /data --entrypoint bash cv-tex \
  -c 'bash .claude/skills/latex-cv/scripts/compile.sh output/cv.tex'
```

## Usage

Edit `me.md`, then ask in Claude Code:

| you say | you get |
|---|---|
| "Build my CV" | `output/cv.tex` + `output/cv.pdf` |
| "I updated me.md, regenerate" | both rewritten from scratch |
| "Make the accent green" | a one-line edit in `style/cv.sty` |
| "Make it one page" | a shorter CV, with a report of what was cut |
| "Tailor it to this job ad: …" | `output/tailored/<company>-<role>/` |

Or by hand:

```bash
bash .claude/skills/latex-cv/scripts/compile.sh output/cv.tex
```

## Editing content

`me.md` is Markdown with `##` headings. Inside an entry, lines starting with `Dates:`,
`Location:`, `Stack:` or `Link:` are metadata; every other `-` line becomes a bullet.

```markdown
### Senior Backend Engineer — Example Ltd.
- Dates: 2019-09 – present
- Location: Anytown, CZ
- Took technical ownership of the payments service; cut p99 latency from 2.4 s
  to 180 ms.
```

A `## Notes (not printed)` section holds private context — target roles, gaps you'd
rather not volunteer — which steers tailoring but never reaches the PDF.

## The profile picture

Optional. Put a photo at `assets/photo.jpg` and the header becomes two-column —
name, title and contacts on the left, photo on the right. Remove the file and the
header goes back to centred text. There is no switch to flip.

The repo ships a placeholder marked **PLACEHOLDER** so the layout is visible; replace
it with your own before sending the CV anywhere. To change the size, or to use a
different filename or format (`.png` and `.pdf` work too), edit the knobs in
`style/cv.sty`:

```latex
\newcommand{\cvphotofile}{photo.jpg}   % in assets/
\newcommand{\cvphotosize}{2.8cm}       % width of the photo
```

A square image works best — the photo is scaled to width and not cropped. Note that
CV photos are expected in much of Europe but discouraged in the US, UK and Ireland,
where they can get an application filtered out.

## Multiple languages

One profile per language: `me.md`, `me-sk.md`, `me-cs.md`. Each generates its own
`output/cv-<lang>.tex` and PDF, and sets the language as a package option so
hyphenation is right:

```latex
\usepackage[slovak]{cv}
```

Non-English hyphenation needs the patterns installed — on Fedora,
`texlive-lang-czechslovak`. Nothing else changes: `compile.sh` already takes a path.

Each language file is yours to edit. Translating one into another is a one-off
starting point, not something regenerated on every build — otherwise your corrected
wording would be overwritten each time.

## Editing style

Open `style/cv.sty`. It starts with a `STYLE KNOBS` block — accent colour, muted
colour, hairline colour, skills label width, name size, photo file and size, and the
`geometry` line for margins. Below that it defines `\cvheader` (name + contact block), the `cvcontacts` block (one contact
per line with an aligned label), `\cvjob` (role, organisation, dates,
location — dates right-aligned), the `cvskills` label/value block, and the heading
and list formats. Changing the look means editing this one file; `cv.tex` never changes.

## Rules the agent follows

Never invents employers, dates, degrees, metrics or skills — gaps get reported, not
filled. Rewording bullets is fine; numbers carry across exactly as written. Page
limits are met by cutting content first and spacing last.

The full workflow and markup reference is `.claude/skills/latex-cv/SKILL.md`.
