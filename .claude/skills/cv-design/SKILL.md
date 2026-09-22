---
name: cv-design
description: Judge and improve how a CV looks - visual hierarchy, layout, spacing, typography, colour, page balance, and what a reader's eye catches in the first few seconds. Use whenever the user asks to make a CV prettier, more eye-catching, more modern, more professional or better looking, asks about fonts, colour, margins, whitespace or layout, says their CV looks flat, plain, cramped, empty or like a template, asks what a recruiter notices first, or asks whether a CV will survive an automated parser. For bullet wording and what to include, use cv-review; for the markup and the build, use latex-cv.
---

# CV layout and design

This skill is about **what the page looks like**. `cv-review` is about what the
CV says; `latex-cv` is the mechanics of turning `me.md` into a PDF. Three
different questions, three files - do not restate the other two here.

The split matters in practice, because most "make it prettier" requests are not
design problems at all. A page looks empty because there is not enough on it; a
bullet looks cramped because it is three lines long. Diagnose before restyling,
and say so when the honest fix is content: **cut content before cutting
spacing** is a repo principle, and tightening leading to hide a thin CV makes it
worse.

## Look at the document before judging it

Design claims made from reading `me.md` are guesses. Build first (`latex-cv` has
the command), then look at it three ways:

```bash
pdftoppm -r 100 -png output/cv.pdf /tmp/cv        # read it as a page
pdftoppm -r 30  -png output/cv.pdf /tmp/cv-small  # the squint test
pdftoppm -gray -r 100 -png output/cv.pdf /tmp/cv-g  # as it prints
```

- **The page**: read it the way a person would.
- **The squint test**: at 30 dpi the words dissolve and only the structure
  survives. Whatever still reads is what a three-second skim gets. If the name
  and the section bands are not the only things left, the hierarchy is too
  flat.
- **Greyscale**: CVs get printed, photocopied and faxed by people who do not
  care about the accent colour. Anything that carries meaning by colour alone
  has to survive this.

And once, for machine legibility:

```bash
pdftotext output/cv.pdf -        # what a parser sees, in its order
```

Text must come out as text, in reading order. If it comes out scrambled,
interleaved or empty, the layout is defeating parsers and no amount of prettiness
compensates.

## The hierarchy that does the work

A reader does not read a CV, they triage it: who is this, what are they, is it
worth reading. The page has to answer those three in the top third or it has not
started.

- **Name, then role, then contact.** A header giving only a name makes the
  reader hunt for what you are, so a role line is usually the highest-value
  addition after the name. It is also a matter of taste, and plenty of people
  want a bare name: raise it once, and if the owner has decided against it,
  that is settled - do not reopen it in later reviews. Where there is no role
  line, check that the first experience entry's title carries the job title
  instead, for the reader and for keyword matching.
- **Three type levels, not five.** Name, section heading, body - with entry
  titles distinguished by weight rather than a fourth size. Every extra size is
  a decision the reader has to make.
- **Weight and colour before size.** Bold at body size anchors a scan without
  spending vertical room. Growing text to signal importance spends the scarcest
  resource on the page.
- **One horizontal band per section heading.** A hairline rule or a colour
  block gives the squint test something to lock onto and costs almost nothing.

## Where attention actually goes

Be honest about the evidence here, because the field is full of confident
numbers. The often-quoted "recruiters spend about seven seconds on a CV" traces
to a small vendor-run eye-tracking study; treat it as a direction, not a
measurement, and never quote it to the user as fact. What is robust enough to
design against:

- **Reading starts top-left and runs down the left edge.** Anything that must be
  seen belongs on the left, high. Right-hand columns are scanned late or not at
  all, which is exactly why dates and locations live there.
- **The eye stops on anything that differs**: bold, a number, a capitalised
  word, a colour. Spend those sparingly. A page where six things shout has
  nothing emphasised.
- **Numbers pull attention disproportionately.** A bullet with a figure in it
  gets read; three abstract bullets around it do not. That is a content fix and
  belongs to `cv-review`, but it is the strongest single lever on what a skim
  catches, so raise it even in a design review.

## Whitespace, rhythm and dead space

Whitespace is structure, not waste. The two failures are opposite and both look
amateurish.

- **Equal gaps between like things.** The space above every section heading
  should be identical, likewise between entries, likewise between a title and
  its bullets. Irregular gaps read as sloppiness even when the reader cannot
  name what is wrong.
- **Dead columns are a giveaway.** When a section uses a right-hand column for
  dates and one whole section leaves it empty, that half of the page reads as a
  mistake. Either give it something real (a stack line, a year, a client type)
  or use a layout without the column for that section.
- **Empty rows are worse than empty columns.** A macro that emits a blank line
  for a field you did not supply puts a hole under every title. Check for it at
  the source rather than padding around it.
- **Line length.** Body text past roughly 100 characters a line tires the eye;
  a CV at typical margins on A4 sits near that limit already, so wide margins
  are not purely decorative.
- **The last page.** A final page a quarter full looks worse than either a full
  page or one less page. `cv-review` owns that call; the design job is to say
  which spacing and layout changes are available **after** the content decision,
  not to shrink type until it fits.

## Colour and type

- **One accent colour, doing one job.** Headings and links, or headings alone.
  A second accent needs a reason a reader can infer in a second.
- **Contrast, checked in greyscale.** A mid-tone accent on white can fall to an
  unreadable grey when printed. Dark, saturated accents survive; pastels do not.
- **Muted for metadata, not for content.** Dates, locations and contact labels
  can drop to a grey. Bullets cannot.
- **One font family.** Vary weight and size within it. A second family is a
  design commitment most CVs do not need and few execute.
- **Sans for screen, either for print.** Most CVs are read on screen. Do not
  churn on this; it is the least consequential choice on the page.

## The tells of a template

These read as generic regardless of how good the content is, and several
actively hurt:

- **Skill bars, star ratings, percentage rings.** Unverifiable, and they claim
  precision nobody believes ("Java 87%"). `cv-review` rejects them on content
  grounds too.
- **Icon salad** in place of labels. A tiny phone glyph is not more legible than
  the word, and it disappears in the text extraction a parser reads.
- **Two-column body layouts.** They look designed and they are the most common
  cause of scrambled parsing. If one is used anyway, verify with `pdftotext`
  that the columns do not interleave.
- **Centred body text, justified text with visible rivers, or full-width photo
  banners.** All three cost legibility for decoration.
- **Margins below about 1 cm.** The page stops breathing, and some printers
  clip it.
- **A timeline graphic** down the side of the dates. It consumes a column to
  restate information already in the dates.

Restraint is what reads as senior. The CVs that look best are almost never the
most decorated ones; they are the ones with a clear hierarchy, generous
consistent spacing and one colour used with discipline.

## Machine legibility

An automated parser reads the text layer, so layout choices are parsing choices:

- Real text, never a rendered image of text.
- A single linear reading order.
- Section headings in ordinary words. Inventive headings are fine for a human
  and invisible to a keyword match.
- Label/value pairs where the value follows its label in the extraction. Check
  with `pdftotext output/cv.pdf -` (no `-layout`) - that is closer to what a
  parser sees than the visual page is.

Say plainly that this is a floor, not a target. Designing for the parser at the
cost of the human reader is the wrong trade, because the human is the one who
decides.

## Applying changes in this repo

- **Styling goes in `style/cv.sty`, never in `output/cv.tex`** - the `.tex` is
  regenerated on every build and edits to it vanish. `AGENTS.md` and `latex-cv`
  both explain this; do not re-derive it.
- Start at the `STYLE KNOBS` block at the top of `cv.sty`. Accent, muted and
  rule colours, the skills label width, name size, photo size and the `geometry`
  margins are all there, and most design requests are one line in that block.
- Changes to the building blocks themselves (`\cvheader`, `\cvjob`, `cvskills`)
  live below the knobs, each with a comment saying why it is built the way it
  is. Read the comment first; several obvious-looking simplifications in this
  file have been tried and each failed differently.
- Rebuild and **look at the result**. A change that compiles is not a change
  that worked.
- Order of operations: content, then structure, then spacing, then colour. Going
  backwards produces a beautifully spaced document that says nothing.

## Reporting a design review

Lead with the thing that costs the most attention, not the easiest fix. Report
in this order:

1. **What a skim misses.** Anything the squint test proves is not landing -
   a missing role line, a flat hierarchy, a heading that does not separate.
2. **Structural faults.** Page balance, dead columns, empty rows, inconsistent
   gaps, anything that breaks parsing.
3. **Polish**, each as a concrete change with the file and the knob: "accent to
   a darker navy in `cv.sty`", not "consider a more professional colour".
4. **What is a content problem wearing a design costume**, handed to
   `cv-review` by name.

Be specific and show the change. "Improve the visual hierarchy" is not a review;
"the role line is absent, add it under the name at 11pt in the accent colour" is.
