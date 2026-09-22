---
name: cv-review
description: Judge and improve CV/resume content - bullet wording, what to include or leave out, length, section order, and how well it matches a job ad. Use when the user asks whether their CV is any good, to review or critique it, to tighten or rewrite bullets, to make it stronger, or what to cut. For building the PDF, use latex-cv instead.
---

# CV content review

This skill is about **what the CV says**. `latex-cv` is about turning `me.md`
into a PDF; use that for anything mechanical.

Never invent content to satisfy any rule here. If a bullet has no number because
the user never gave one, it stays without a number.

## Bullets

The test for every experience bullet: **does it say what changed, and can it be
checked?**

- **Result first, method second.** "Cut p99 from 2.4 s to 180 ms by rebuilding
  the settlement pipeline", not "Rebuilt the settlement pipeline, which cut
  p99…".
- **Delete filler openers.** "Responsible for", "Worked on", "Helped with",
  "Tasked with", "Participated in" - all describe presence, not contribution.
  Cut the opener and start at the verb.
- **Two lines maximum.** A three-line bullet is two bullets or one that needs
  cutting.
- **Count**: 4-6 for the current role, 2-3 for the one before, 1-2 for anything
  older.
- **No duplicated verbs** down a list - five bullets starting "Developed" read
  as one bullet.
- **Keep the user's numbers exactly.** Never round, scale, or invent one.
  "Roughly five million users" stays roughly five million users.

Flag, do not silently fix, any bullet that claims something the profile cannot
support.

## What to leave out

- **Skill rating bars, percentages, star ratings.** Unverifiable and read as
  padding. A category list is the honest form.
- **Date of birth, marital status, nationality, full street address.** Illegal
  to ask for in several jurisdictions and never useful; city and country are
  enough.
- **"References available on request."** Assumed, and it costs a line.
- **Clichés with no content**: passionate, results-driven, team player,
  self-starter, detail-oriented, think outside the box. If a trait matters, show
  it in a bullet.
- **Every technology ever touched.** A skills list that includes things the user
  cannot discuss in an interview is a liability, not coverage.

## Length and shape

- **Two pages is standard for a senior engineer in Europe**; one page is the
  norm in the US regardless of seniority, and expected anywhere under ~5 years'
  experience.
- **Never 1.3 pages.** A second page that is a quarter full looks worse than
  either cutting to one or filling to two. Say so when the build lands there.
- **Reverse chronological**, most recent first.
- **Section order follows the target**, not habit. For an engineering role:
  summary, experience, skills, education. Education climbs only for recent
  graduates or when the role asks for a specific qualification.
- **Roles older than ~10 years** collapse into a single "Earlier experience"
  line each, or disappear.
- Gaps: the CV does not have to explain them. Do not invent an explanation, and
  do not pad dates to hide one.

## Regional differences

- **Photo**: normal in Germany, Austria, Switzerland, Czechia, Slovakia;
  discouraged in the US, UK and Ireland, where it can get an application
  filtered out.
- **"CV" vs "résumé"**: the US "resume" is a targeted 1-page document; the
  European CV is a fuller 2-page record. Match the market being applied to.
- **Dates**: `Sep 2019 - present` in English, `09/2019 - present` elsewhere. Be
  consistent within a document.

## Reviewing against a job ad

1. List the ad's stated requirements - hard requirements separately from
   nice-to-haves.
2. Mark each: **covered** (with the bullet that proves it), **partially
   covered**, or **absent from the profile**.
3. Report the absent ones plainly. Do not invent experience, and do not stretch
   a tangential bullet to look like a match.
4. Then reorder and reweight what genuinely matches: promote it, expand those
   bullets, compress the rest. Mirror the ad's vocabulary only where it is
   honestly true of the user.

Hand back the gap list as well as the tailored CV - knowing which two
requirements are unmet is worth more than a CV that pretends otherwise.

## When reviewing a whole CV

Read the built PDF, not just `me.md` - length, balance and what a skim catches
are only visible in the rendered document. Report in this order:

1. Anything factually risky or unsupportable.
2. Shape: length, page balance, section order.
3. The three weakest bullets, with rewrites.
4. Anything to cut.

Be specific. "Tighten your bullets" is not a review; quoting the bullet and
showing the shorter version is.
