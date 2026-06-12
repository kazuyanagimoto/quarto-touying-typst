# quarto-touying-typst

[![Render](https://github.com/kazuyanagimoto/quarto-touying-typst/actions/workflows/render.yml/badge.svg)](https://github.com/kazuyanagimoto/quarto-touying-typst/actions/workflows/render.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A drop-in Quarto extension for building slides with
[Touying](https://touying-typ.github.io), the Beamer-like presentation framework
for Typst. It wires Quarto's slide syntax onto Touying and lets you pick any
built-in Touying theme -- or bring your own.

> Status: **prototype** (v0.0.2). The surface area is intentionally small.

![The metropolis title slide rendered with this extension](https://kazuyanagimoto.com/quarto-touying-typst/static/thumbnail.png)

## Install

```bash
quarto add kazuyanagimoto/quarto-touying-typst
```

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
theme: metropolis
author:
  - name: Your Name
    affiliations: Your Institution
date: today
---
# A Section

## A Slide

Content goes here.
```

`#` starts a new **section** and `##` starts a new **slide**, mirroring Touying's
native `=` / `==`.

## Themes and options

| Option         | Default   | Description                                |
| -------------- | --------- | ------------------------------------------ |
| `theme`        | `default` | Built-in theme to use                      |
| `aspect-ratio` | `16-9`    | Slide aspect ratio (`16-9`, `4-3`)         |
| `handout`      | `false`   | Collapse incremental reveals into a handout |

Eight themes ship in the box: `default`, `simple`, `metropolis`, `dewdrop`,
`university`, `aqua`, `stargazer`, and `clean`. Colours and fonts are tuned with
`accent` / `accent2` / `jet` / `mainfont` / `sansfont` / `monofont` / `fontsize`,
or a [Quarto brand](https://quarto.org/docs/authoring/brand.html).

**Custom and external themes** work too: any Touying theme, one you wrote or one
from [Typst Universe](https://typst.app/universe), via `include-in-header` plus a
`theme-typst` option.

## What you can do

- Pauses (`. . .`), incremental lists, and multi-step reveals (`.only` /
  `.uncover` / `.complex-anim`)
- Side-by-side `.columns`
- Emphasis classes: `.alert`, `.fg`, `.bg`, `.button`, `.small-cite`
- Shortcodes: `{{< pause >}}`, `{{< meanwhile >}}`, `{{< appendix >}}`
- Map any span or div to a Typst function with `commands:` / `environments:`
- Everything standard Quarto + Typst: equations, code, tables, figures

See the **[Tutorial](https://kazuyanagimoto.com/quarto-touying-typst/tutorial.html)**
for a full walkthrough, and the
**[Gallery](https://kazuyanagimoto.com/quarto-touying-typst/gallery.html)** to
flip through every theme in the browser.

## Relationship to other extensions

- This extension is the Touying counterpart to
  [`projector`](https://github.com/christopherkenny/projector) (which targets
  Polylux).
- [`quarto-clean-typst`](https://github.com/kazuyanagimoto/quarto-clean-typst)
  is a styled theme deck; the long-term plan is for theme repos like it to build
  on this base.
