#import "@preview/touying:0.7.3": *

// Beamer-style goto button (like `\beamergotobutton`). Picks up the active
// theme's primary colour via `touying-fn-wrapper`. Themes may override it.
#let _button(self: none, body) = box(
  fill: self.colors.primary,
  inset: (x: 0.5em, y: 0.3em),
  radius: 0.25em,
  baseline: 0.25em,
)[
  #set text(size: 0.7em, fill: white)
  #sym.triangle.filled.r~#body
]
#let button(body) = touying-fn-wrapper(_button.with(body))

// Generic title slide for themes that have no config-info-driven one --------
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

// Selectable built-in Touying themes ----------------------------------------
// Add a theme here to make it available through the `theme:` YAML option.
#let touying-themes = (
  metropolis: themes.metropolis.metropolis-theme,
  university: themes.university.university-theme,
  dewdrop: themes.dewdrop.dewdrop-theme,
  aqua: themes.aqua.aqua-theme,
  stargazer: themes.stargazer.stargazer-theme,
  simple: themes.simple.simple-theme,
  default: themes.default.default-theme,
)
// Each entry is a 0-arg function producing the title slide. Themes whose own
// `title-slide` reads from `config-info` use it directly; the rest fall back
// to `generic-title-slide`.
#let touying-title-slides = (
  metropolis: themes.metropolis.title-slide,
  university: themes.university.title-slide,
  dewdrop: themes.dewdrop.title-slide,
  aqua: themes.aqua.title-slide,
  stargazer: themes.stargazer.title-slide,
  simple: generic-title-slide,
  default: generic-title-slide,
)
