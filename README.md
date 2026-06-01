# quarto-touying-typst

[![Render](https://github.com/kazuyanagimoto/quarto-touying-typst/actions/workflows/render.yml/badge.svg)](https://github.com/kazuyanagimoto/quarto-touying-typst/actions/workflows/render.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A drop-in Quarto extension for building slides with
[Touying](https://touying-typ.github.io), the Beamer-like presentation
framework for Typst. This is the *base* extension: it wires Quarto's slide
syntax onto Touying and lets you pick any of Touying's built-in themes.
Theme-specific decks (e.g. the Clean theme) live in their own repositories and
build on top of this one.

> Status: **prototype** (v0.0.1). The bridge and theme selection work; the
> surface area is intentionally small.

![A slide rendered with the metropolis theme](https://kazuyanagimoto.com/quarto-touying-typst/static/thumbnail.png)

## Install

```bash
quarto add kazuyanagimoto/quarto-touying-typst
```

A **theme gallery** lets you flip through the same deck in each built-in theme
right in the browser. Build and preview it locally:

```bash
just decks      # render each theme to a navigable HTML deck (needs `pip install touying`)
just preview    # serve the docs site (home, gallery, tutorial)
```

The navigable decks are produced by keeping the Quarto-generated Typst
(`keep-typ: true`) and running
[touying-exporter](https://github.com/touying-typ/touying-exporter) on it
(`touying compile <file>.typ --format html`).

Or start from the template:

```bash
quarto use template kazuyanagimoto/quarto-touying-typst
```

## Usage

```yaml
---
title: My Talk
subtitle: A subtitle
format: touying-typst
theme: default         # default | simple | metropolis | dewdrop | university | aqua | stargazer | clean
aspect-ratio: "16-9"
author:
  - name: Your Name
    affiliations: Your Institution
institute: Your Institution
date: today
---

# A Section

## A Slide

Content goes here.
```

- `#` (level-1 heading) starts a new **section**
- `##` (level-2 heading) starts a new **slide**

This mirrors Touying's native `=` / `==`, so Quarto's structure maps onto
Touying with no extra markup.

### Heading levels and `shift-heading-level-by`

By default Quarto promotes the shallowest heading to level 1, so a deck that
uses **only** `##` has those `##` turned into section dividers. Two ways to get
slides:

- Put a `#` section before your `##` slides (the convention used throughout
  this README), **or**
- Set `shift-heading-level-by: 0` in the front matter to disable the
  promotion. Then `##` always stays a slide -- handy when porting a reveal.js
  deck that only uses `##`.

```yaml
format: touying-typst
shift-heading-level-by: 0   # `##` stays a slide even without a leading `#`
```

This is Pandoc's
[`--shift-heading-level-by`](https://pandoc.org/MANUAL.html#option--shift-heading-level-by)
option; positive/negative values shift every heading by that amount.

## Options

| Option         | Default      | Description                                            |
| -------------- | ------------ | ----------------------------------------------------- |
| `theme`        | `default`    | Built-in Touying theme to use                         |
| `aspect-ratio` | `16-9`       | Slide aspect ratio (`16-9`, `4-3`)                    |
| `handout`      | `false`      | Collapse all incremental reveals into a handout       |

Available themes (in Touying's order): `default`, `simple`, `metropolis`,
`dewdrop`, `university`, `aqua`, `stargazer`, and `clean`. The default is
`default`.

Colours and fonts can be set with `accent` / `accent2` / `jet` / `sansfont` /
`mainfont` / `fontsize`, or via a [Quarto brand](https://quarto.org/docs/authoring/brand.html)
(`_brand.yml`): `brand.color.*` sets the palette for every theme and
`brand.typography.*` sets the fonts for `clean`. Explicit options win over
`brand`.

`clean` is a richer theme developed in this repo (it will eventually move to its
own repository). Its title slide shows structured authors (name, affiliation,
email, ORCID), and it adds emphasis classes:

| Markup                                          | Renders                         |
| ----------------------------------------------- | ------------------------------- |
| `[text]{.alert}`                                | Accent-coloured emphasis        |
| `[text]{.fg options='fill: rgb("#5D639E")'}`    | Custom-coloured text            |
| `[text]{.bg}`                                    | Highlighted background          |
| `[text]{.small-cite}`                            | Small, muted citation text      |

`.alert` works in every theme; `.fg` / `.bg` / `.button` / `.small-cite` are
theme-independent.

## Reveal.js-style syntax

The goal is for Quarto's presentation syntax to work as-is. Currently bridged:

| Quarto                              | Behaviour                              |
| ----------------------------------- | -------------------------------------- |
| `. . .`                             | Pause (`#pause`)                       |
| `::: {.incremental}`                | Reveal list items one `#pause` at a time |
| `::: {.columns}` / `.column`        | Side-by-side columns (Typst grid)      |
| `::: {.notes}`                      | Speaker notes (hidden on the slide)    |
| `[text]{.button}`                   | Beamer-style button (clickable in a link) |
| `[text]{.only options='"2-"'}` / `.uncover` | Reveal a span/block from a sub-slide on |
| `{{< pause >}}` / `{{< meanwhile >}}` | `#pause` / `#meanwhile`              |
| `{{< appendix >}}`                  | Begin back-matter (freezes the slide counter) |

Columns honour the `width` attribute:

```markdown
:::: {.columns}
::: {.column width="40%"}
Left
:::
::: {.column width="60%"}
Right
:::
::::
```

## Native Touying

Touying code works anywhere, e.g. inline `#pause`. For multi-step reveals with
`uncover` / `only` / `alternatives`:

```markdown
::: {.complex-anim repeat="4"}
At subslide #only("2-")[two and later] and #uncover("3-")[three and later].
:::
```

`[x]{.cmd}` / `::: {.env}` map to Typst calls `#cmd()[x]` / `#env()[…]`
(`.alert` / `.fg` / `.bg` / `.button` / `.only` / `.uncover` are built in). Add
your own with `commands:` / `environments:` document metadata (a list of names,
or `name: typst-function` pairs).

## Adding a theme

Touying ships more theme functions than are wired up here. To expose one, add
it to the two maps in
[`_extensions/touying/typst-template.typ`](_extensions/touying/typst-template.typ)
(its `*-theme` show function and its `title-slide`).

## Relationship to other extensions

- This extension is the Touying counterpart to
  [`projector`](https://github.com/christopherkenny/projector) (which targets
  Polylux).
- [`quarto-clean-typst`](https://github.com/kazuyanagimoto/quarto-clean-typst)
  is a styled theme deck; the long-term plan is for theme repos like it to
  build on this base.

## License

MIT
