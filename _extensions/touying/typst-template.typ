#import "@preview/touying:0.7.4": *

// Inline helpers (theme-independent) -----------------------------------------
// `.fg` / `.bg` colour the text / its background.
#let fg = (fill: rgb("e64173"), it) => text(fill: fill, it)
#let bg = (fill: rgb("e64173"), it) => highlight(fill: fill, radius: 2pt, extent: 0.2em, it)

// Accent colours for the inline helpers below, held in plain states so `button`
// and `small-cite` can read them from a `context` -- and therefore be used
// inside `#only` / `#uncover` / `context`, where `touying-fn-wrapper` marks are
// unsupported. `theme-show` seeds these from the deck's `accent` / `jet`; when
// unset they fall back to the base pink (matching `fg` / `bg`).
#let _base-primary = state("touying-base-primary", rgb("e64173"))
#let _base-foreground = state("touying-base-foreground", rgb("131516"))

// Beamer-style goto button (like `\beamergotobutton`). Its colour follows the
// deck `accent`. `context`-based, so it works anywhere -- including inside
// `#only` / `#uncover` / `context`.
#let button(body) = context box(
  fill: _base-primary.get(),
  inset: (x: 0.35em, y: 0.2em),
  radius: 0.5em,
  baseline: 0.05em,
)[
  #set text(
    size: 0.55em,
    fill: white,
    weight: "regular",
    top-edge: "cap-height",
    bottom-edge: "baseline",
  )
  // Vector triangle (font-independent), matching the white button text.
  #box(baseline: 0em, polygon(
    fill: white,
    (0em, 0em), (0.5em, 0.3em), (0em, 0.6em),
  ))~#body
]

// `.small-cite` -- small, muted inline text for citations/sources. Also
// `context`-based so it can be used inside animations.
#let small-cite(it) = context text(
  size: 0.7em,
  fill: _base-foreground.get().lighten(30%),
  it,
)

// Generic title slide for themes that have no config-info-driven one ---------
// (e.g. `simple`, `default`). Reads from `self.info`.
#let generic-title-slide() = touying-slide-wrapper(self => {
  let info = self.info
  let get(key) = info.at(key, default: none)
  let primary = self.colors.at("primary", default: rgb("#04364A"))
  let dark = self.colors.at("neutral-darkest", default: rgb("#000000"))
  let body = {
    set align(center + horizon)
    block(text(size: 1.8em, weight: "bold", fill: primary, get("title")))
    if get("subtitle") != none {
      block(text(size: 1.2em, fill: primary, get("subtitle")))
    }
    set text(fill: dark)
    if get("author") != none { block(above: 1.5em, get("author")) }
    if get("institution") != none { block(text(size: 0.8em, get("institution"))) }
    if get("date") != none { block(text(size: 0.8em, get("date"))) }
  }
  touying-slide(self: self, config: config-common(freeze-slide-counter: true), body)
})

// Selectable built-in themes -------------------------------------------------
// The bundled Touying themes. Styled themes (e.g. `clean`) live in their own
// Typst Universe packages and are used through the external-theme path
// (`include-in-header` + `theme-typst`), exactly like any third-party theme --
// this keeps the base free of any theme package's pinned Touying version.
#let touying-themes = (
  default: themes.default.default-theme,
  simple: themes.simple.simple-theme,
  metropolis: themes.metropolis.metropolis-theme,
  dewdrop: themes.dewdrop.dewdrop-theme,
  university: themes.university.university-theme,
  aqua: themes.aqua.aqua-theme,
  stargazer: themes.stargazer.stargazer-theme,
)
#let touying-title-slides = (
  default: generic-title-slide,
  simple: generic-title-slide,
  metropolis: themes.metropolis.title-slide,
  dewdrop: themes.dewdrop.title-slide,
  university: themes.university.title-slide,
  aqua: themes.aqua.title-slide,
  stargazer: themes.stargazer.title-slide,
)

// Theme dispatcher -----------------------------------------------------------
// Normalises a common set of options onto each theme, so the show rule in
// typst-show.typ stays theme-agnostic. The SAME path serves built-in themes and
// external ones (a theme function from `include-in-header` / `theme-typst`):
// colours map onto the standard Touying palette via `config-colors`, and a
// theme's own extra knobs (fonts, etc.) are set with `.with(...)` in the header.
// `foreground` is the body text colour, `accent` the primary, `accent2` the
// secondary. Colour/font options come from explicit YAML or, as a fallback,
// from `brand` (see typst-show.typ).
#let theme-show(
  name,
  aspect-ratio: "16-9",
  handout: false,
  accent: none,
  accent2: none,
  foreground: none,
  ..info-args,
) = {
  // `name` is a built-in theme name (string) or an external theme function.
  let base = if type(name) == function { name } else { touying-themes.at(name) }
  let named = (aspect-ratio: aspect-ratio)
  let cfg = (config-info(..info-args),)
  if handout { cfg.push(config-common(handout: true)) }
  let colors = (:)
  if accent != none { colors.insert("primary", accent) }
  if accent2 != none { colors.insert("secondary", accent2) }
  if foreground != none { colors.insert("neutral-darkest", foreground) }
  if colors.len() > 0 { cfg.push(config-colors(..colors)) }
  let themed = base.with(..named, ..cfg)
  // Seed the base helper colours (`button` / `small-cite`) from the same
  // accent / foreground, before the theme renders its slides.
  body => {
    if accent != none { _base-primary.update(accent) }
    if foreground != none { _base-foreground.update(foreground) }
    themed(body)
  }
}
