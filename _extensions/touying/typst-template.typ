#import "@preview/touying:0.7.3": *
#import "touying-clean.typ" as clean

// Inline helpers (theme-independent) -----------------------------------------
// `.fg` / `.bg` colour the text / its background.
#let fg = (fill: rgb("e64173"), it) => text(fill: fill, it)
#let bg = (fill: rgb("e64173"), it) => highlight(fill: fill, radius: 2pt, extent: 0.2em, it)

// Beamer-style goto button (like `\beamergotobutton`). Picks up the active
// theme's primary colour via `touying-fn-wrapper`. Themes may override it.
#let _button(self: none, body) = box(
  fill: self.colors.primary.lighten(70%),
  inset: (x: 0.5em, y: 0.15em),
  radius: 0.6em,
  baseline: 0.2em,
)[
  #set text(size: 0.55em, fill: self.colors.primary, weight: "medium")
  #sym.triangle.filled.r~#body
]
#let button(body) = touying-fn-wrapper(_button.with(body))

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

// Selectable themes ----------------------------------------------------------
// Built-in Touying themes plus the in-repo `clean` theme.
#let touying-themes = (
  metropolis: themes.metropolis.metropolis-theme,
  university: themes.university.university-theme,
  dewdrop: themes.dewdrop.dewdrop-theme,
  aqua: themes.aqua.aqua-theme,
  stargazer: themes.stargazer.stargazer-theme,
  simple: themes.simple.simple-theme,
  default: themes.default.default-theme,
  clean: clean.clean-theme,
)
#let touying-title-slides = (
  metropolis: themes.metropolis.title-slide,
  university: themes.university.title-slide,
  dewdrop: themes.dewdrop.title-slide,
  aqua: themes.aqua.title-slide,
  stargazer: themes.stargazer.title-slide,
  simple: generic-title-slide,
  default: generic-title-slide,
  clean: clean.title-slide,
)

// Theme dispatcher -----------------------------------------------------------
// Normalises a common set of options onto each theme's own interface, so the
// show rule in typst-show.typ stays theme-agnostic.
#let theme-show(
  name,
  aspect-ratio: "16-9",
  handout: false,
  accent: none,
  accent2: none,
  sansfont: none,
  mainfont: none,
  fontsize: none,
  ..info-args,
) = {
  let base = touying-themes.at(name)
  let named = (aspect-ratio: aspect-ratio)
  let cfg = (config-info(..info-args),)
  if name == "clean" {
    // The clean theme exposes its own named options.
    named.insert("handout", handout)
    if accent != none { named.insert("color-accent", accent) }
    if accent2 != none { named.insert("color-accent2", accent2) }
    if sansfont != none { named.insert("font-family-heading", sansfont) }
    if mainfont != none { named.insert("font-family-body", mainfont) }
    if fontsize != none { named.insert("font-size", fontsize) }
  } else {
    // Built-in themes take config-* positional args.
    if handout { cfg.push(config-common(handout: true)) }
    let colors = (:)
    if accent != none { colors.insert("primary", accent) }
    if accent2 != none { colors.insert("secondary", accent2) }
    if colors.len() > 0 { cfg.push(config-colors(..colors)) }
  }
  base.with(..named, ..cfg)
}
