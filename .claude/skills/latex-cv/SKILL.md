---
name: latex-cv
description: Build or update a CV/resume PDF from a me.md profile file using LaTeX. Use when the user asks to build, regenerate, restyle, shorten or tailor their CV or resume.
---

# LaTeX CV

```
me.md  ──►  output/cv.tex  ──(xelatex)──►  output/cv.pdf
           (generated)
style/cv.sty - styling, hand-edited, never regenerated
```

`me.md` is the content. `style/cv.sty` is the appearance. `cv.tex` is generated from
`me.md` on every build and must never be hand-edited - that is what keeps the profile and the CV in step.

## Build

1. Read `me.md` in the working folder. If it is missing, interview the user and write one in the format below. Never
   invent content.
2. Write `output/cv.tex` from scratch using the markup below.
3. Compile: `bash .claude/skills/latex-cv/scripts/compile.sh output/cv.tex`
   It puts `style/` and `assets/` on TEXINPUTS, tries xelatex then pdflatex, and prints the page count.
4. Report the page count and anything you cut or assumed.

## The markup

```latex
\documentclass[10pt,a4paper]{article}
\usepackage{cv}
\begin{document}

    \cvheader{Name}{%
        \begin{cvcontacts}
            \cvcontact{Location}{City, Country}
            \cvcontact{Email}{\href{mailto:...}{...}}
            \cvcontact{Web}{\href{https://...}{example.com}}
            \cvcontact{LinkedIn}{\href{https://...}{linkedin.com/in/...}}
        \end{cvcontacts}%
    }


    \section{Profile}
    A paragraph.


    \section{Professional Experience}
    \cvjob{Role}{Organisation}{Sep 2019 -- present}{City, Country}
    \begin{itemize}
        \item Achievement.
    \end{itemize}


    \section{Technical Expertise}
    \begin{cvskills}
        Programming & Java, Kotlin \\
        Data        & PostgreSQL, Redis \\
    \end{cvskills}

\end{document}
```

`\cvjob` right-aligns the dates and location. Pass `{}` for a field you do not have.
`cvskills` is the aligned label/value block - use it for Skills, Languages, or any section of that shape. Escape `&`
inside a cell as `\&`.

Contacts stack one per line with aligned labels - one `\cvcontact{label}{value}` per item, in whatever order suits. Use
short labels (Location, Email, Phone, Web, LinkedIn, GitHub); the label column sizes itself to the longest one. Omit
anything `me.md` does not have rather than printing an empty row.

**Escape everything taken from `me.md`:** `& % $ # _ { }` → `\& \% \$ \# \_ \{ \}`;
`~` → `\textasciitilde{}`, `^` → `\textasciicircum{}`. So `C#` → `C\#`, `R&D` → `R\&D`,
`100%` → `100\%`. A missed `%` does not error - it silently comments out the rest of the line, so check the PDF for text
that vanished.

## `me.md` format

Markdown with `##` headings. `# Name` is the H1; `## Contact`, `## Summary`,
`## Experience`, `## Education`, `## Skills` map to the obvious places, and any other
`##` heading becomes its own `\section` where it sits in the file.

`## Title` is **not rendered** in the current style - the header is the name and the contact block only. Keep it in
`me.md` (it is useful context when tailoring); just do not emit it. To put it back, add a `\cvcontact{Role}{...}` row to
the contact block.

Inside an entry:

```markdown
### Role - Organisation

- Dates: 2019-09 - present
- Location: Anytown, Country
- An achievement bullet.
```

`Dates:`, `Location:`, `Link:`, `Stack:` are metadata and feed `\cvjob`'s arguments; every other `-` line is a bullet.
Render dates in the CV's language and local convention: `Sep 2019 -- present`, `09/2019 -- present`. Date ranges are the
one place an en dash (`--`) belongs; everywhere else use a plain hyphen and never an em dash or `---` (see AGENTS.md).

`## Notes (not printed)` is private context for tailoring and never reaches the PDF. HTML comments are never content,
even when a line inside one starts with `##`.

## The profile picture

Optional and automatic: if `assets/photo.jpg` exists, `\cvheader` lays the header out two-column with the photo on the
right; if not, it centres the text. Nothing in
`cv.tex` changes either way, so never add `\includegraphics` to it yourself. The filename and size are knobs in
`style/cv.sty`.

The repo ships `assets/photo-placeholder.jpg`, visibly marked. If that is what is in
place when building a CV the user intends to send, say
so - do not let it ship silently.

## Multiple languages

One profile file per language - no extra machinery:

| profile    | generates                        | style line in the `.tex`  |
|------------|----------------------------------|---------------------------|
| `me.md`    | `output/cv.tex` → `cv.pdf`       | `\usepackage{cv}`         |
| `me-sk.md` | `output/cv-sk.tex` → `cv-sk.pdf` | `\usepackage[slovak]{cv}` |
| `me-cs.md` | `output/cv-cs.tex` → `cv-cs.pdf` | `\usepackage[czech]{cv}`  |

The package option is passed to babel for hyphenation. It needs the patterns installed (Fedora:
`texlive-lang-czechslovak`). Options accumulate, so
`\usepackage[czech,shorthands=off]{cv}` works - worth knowing because Czech babel makes `"` an active character.

Translate the section headings too:

| English                 | Czech                | Slovak              |
|-------------------------|----------------------|---------------------|
| Profile                 | Profil               | Profil              |
| Professional Experience | Pracovní zkušenosti  | Pracovné skúsenosti |
| Selected Work           | Vybrané projekty     | Vybrané projekty    |
| Technical Expertise     | Technické dovednosti | Technické zručnosti |
| Languages               | Jazyky               | Jazyky              |
| Education               | Vzdělání             | Vzdelanie           |

Dates follow local convention: `Sep 2019 - present` in English, `09/2019 -
současnost` (cs) or `09/2019 -- súčasnosť` (sk). Never translate proper nouns, company names or technology names.

**Each language file is hand-owned, not generated.** Translating `me.md` into
`me-sk.md` is a one-off bootstrap; after that both are sources. They will drift - that is the accepted cost of this
approach. When the user edits one, say plainly which other language files are now behind, and offer to update them.
Never regenerate a translated profile from the English one without being asked: it would discard hand-corrected wording.

## Restyling

Appearance changes go in `style/cv.sty` and must not touch `cv.tex`. Colour, margins, name size and the skills label
width are in the `STYLE KNOBS` block at the top.

## Content quality

This skill covers the mechanics. For judgment about *what the CV says* - bullet wording, what to leave out, length
norms, reviewing against a job ad - use the
`cv-review` skill. Do not duplicate its guidance here.

## Shortening to a page limit

Cut the weakest bullets first (oldest roles first), then collapse old roles, then drop sections the target does not care
about, then tighten wording. Adjust spacing last, in
`cv.sty`, and no further than 10pt text or 1.3cm margins. Below that, say it needs a real cut instead.

## Tailoring to a job ad

Reorder and reweight real experience: promote matching work, expand those bullets, compress the rest. Never add
experience `me.md` does not support - report gaps instead. Write to `output/tailored/<company>-<role>/` and compile with
`CV_ROOT=$PWD`. Leave `output/cv.pdf` alone.

## Rules

- Never invent employers, dates, degrees, metrics or skills.
- Rewording bullets is fine; numbers carry across exactly as written.
- Preserve the user's language unless asked otherwise.
- If a compile fails, show the log lines rather than guessing twice.
