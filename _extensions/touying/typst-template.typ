#import "@preview/touying:0.7.3": *

// Inline helpers (theme-independent) -----------------------------------------
// `.fg` / `.bg` colour the text / its background.
#let fg = (fill: rgb("e64173"), it) => text(fill: fill, it)
#let bg = (fill: rgb("e64173"), it) => highlight(fill: fill, radius: 2pt, extent: 0.2em, it)

// Beamer-style goto button (like `\beamergotobutton`). Picks up the active
// theme's primary colour via `touying-fn-wrapper`. Themes may override it.
#let _button(self: none, body) = box(
  fill: self.colors.primary,
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
  #sym.triangle.filled.r~#body
]
#let button(body) = touying-fn-wrapper(_button.with(body))

// `.small-cite` -- small, muted inline text for citations/sources.
#let _small-cite(self: none, it) = text(
  size: 0.7em,
  fill: self.colors.neutral-darkest.lighten(30%),
  it,
)
#let small-cite(it) = touying-fn-wrapper(_small-cite.with(it))

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

// ============================================================================
// Clean theme (inlined for now). Origin: kazuyanagimoto/touying-quarto-clean.
// Once published to Typst Universe this whole block becomes a single import.
// Helpers are prefixed `clean-` to avoid clashing with the base symbols above.
// ============================================================================
#let clean-new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  let main-body = {
    set align(left + horizon)
    set text(size: 2em, fill: self.colors.primary, weight: "bold", font: self.store.font-family-heading)
    utils.display-current-heading(level: 1)
  }
  self = utils.merge-dicts(
    self,
    config-page(margin: (left: 2em, top: -0.25em)),
  )
  touying-slide(self: self, main-body)
})

#let clean-slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(inset: (x: 2em, top: 1.5em))
    set text(
      size: 1.4em,
      fill: self.colors.neutral-darkest,
      weight: self.store.font-weight-heading,
      font: self.store.font-family-heading,
    )
    utils.call-or-display(self, self.store.header)
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  }

  // Set the slide
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

#let clean-theme(
  aspect-ratio: "16-9",
  handout: false,
  header: utils.display-current-heading(level: 2),
  footer: [],
  font-size: 20pt,
  font-family-heading: ("Roboto"),
  font-family-body: ("Roboto"),
  font-weight-heading: "light",
  font-weight-body: "light",
  font-weight-title: "light",
  font-weight-subtitle: "light",
  font-size-title: 1.4em,
  font-size-subtitle: 1em,
  color-jet: rgb("131516"),
  color-accent: rgb("107895"),
  color-accent2: rgb("9a2515"),
  ..args,
  body,
) = {
  set text(size: font-size, font: font-family-body, fill: color-jet,
           weight: font-weight-body)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: clean-slide,
      new-section-slide-fn: clean-new-section-slide,
      handout: handout,
      enable-frozen-states-and-counters: false, // https://github.com/touying-typ/touying/issues/72
      show-hide-set-list-marker-none: true,
      show-strong-with-alert: false
    ),
    config-methods(
      init: (self: none, body) => {
        show link: set text(fill: self.colors.primary)
        // Unordered List
        set list(
          indent: 1em,
          marker: (text(fill: self.colors.primary)[ #sym.triangle.filled.r ],
                    text(fill: self.colors.primary)[ #sym.arrow]),
        )
        // Ordered List
        set enum(
          indent: 1em,
          full: true, // necessary to receive all numbers at once, so we can know which level we are at
          numbering: (..nums) => {
            let nums = nums.pos()
            let num = nums.last()
            let level = nums.len()

            // format for current level
            let format = ("1.", "i.", "a.").at(calc.min(2, level - 1))
            let result = numbering(format, num)
            text(fill: self.colors.primary, result)
          }
        )
        // Slide Subtitle
        show heading.where(level: 3): title => {
          set text(
            size: 1.1em,
            fill: self.colors.primary,
            font: font-family-body,
            weight: "light",
            style: "italic",
          )
          block(inset: (top: -0.5em, bottom: 0.25em))[#title]
        }

        set bibliography(title: none)

        body
      },
      alert: (self: none, it) => text(fill: self.colors.secondary, it),
    ),
    config-colors(
      primary: color-accent,
      secondary: color-accent2,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: color-jet,
    ),
    // save the variables for later use
    config-store(
      header: header,
      footer: footer,
      font-family-heading: font-family-heading,
      font-family-body: font-family-body,
      font-size-title: font-size-title,
      font-size-subtitle: font-size-subtitle,
      font-weight-heading: font-weight-heading,
      font-weight-title: font-weight-title,
      font-weight-subtitle: font-weight-subtitle,
      ..args.named(),
    ),
    // forward positional config-* args (e.g. config-info from the dispatcher)
    ..args.pos(),
  )

  body
}

// ORCID iD icon, bundled inline as SVG (no fontawesome / font download needed).
#let orcid-svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 256 256\"><path fill=\"#A6CE39\" d=\"M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z\"/><path fill=\"#FFFFFF\" d=\"M86.3,186.2H70.9V79.1h15.4v48.4V186.2z\"/><path fill=\"#FFFFFF\" d=\"M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,53.6h-41.8V79.1z M124.3,172.4h24.5c34.9,0,42.9-26.5,42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z\"/><path fill=\"#FFFFFF\" d=\"M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1C84.2,46.7,88.7,51.3,88.7,56.8z\"/></svg>"
#let orcid-icon = box(baseline: 0.15em, image(bytes(orcid-svg), format: "svg", height: 0.95em))

#let clean-title-slide(
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set align(left + horizon)
    block(
      inset: (y: 1em),
      [#text(size: self.store.font-size-title,
             fill: self.colors.neutral-darkest,
             weight: self.store.font-weight-title,
             font: self.store.font-family-heading,
             info.title)
       #if info.subtitle != none {
        linebreak()
        v(-0.3em)
        text(size: self.store.font-size-subtitle,
             style: "italic",
             fill: self.colors.primary,
             weight: self.store.font-weight-subtitle,
             font: self.store.font-family-body,
             info.subtitle)
      }]
    )

    set text(fill: self.colors.neutral-darkest)

    let authors = info.at("authors-data", default: none)
    if authors != none {
      let count = authors.len()
      let ncols = calc.min(count, 3)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 1.5em,
        ..authors.map(author =>
            align(left)[
              #text(size: 1em, weight: "regular")[#author.name]
              #if author.orcid != [] {
                link("https://orcid.org/" + author.orcid.text)[#orcid-icon]
              } \
              #text(size: 0.7em, style: "italic")[
                #show link: set text(size: 0.9em, fill: self.colors.neutral-darkest)
                #link("mailto:" + author.email.children.map(email => email.text).join())[#author.email]
              ] \
              #text(size: 0.8em, style: "italic")[#author.affiliation]
            ]
        )
      )
    }

    if info.date != none {
      block(if type(info.date) == datetime { info.date.display(self.datetime-format) } else { info.date })
    }
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true)
  )
  touying-slide(self: self, body)
})

// Selectable themes ----------------------------------------------------------
// Built-in Touying themes plus the in-repo `clean` theme.
#let touying-themes = (
  default: themes.default.default-theme,
  simple: themes.simple.simple-theme,
  metropolis: themes.metropolis.metropolis-theme,
  dewdrop: themes.dewdrop.dewdrop-theme,
  university: themes.university.university-theme,
  aqua: themes.aqua.aqua-theme,
  stargazer: themes.stargazer.stargazer-theme,
  clean: clean-theme,
)
#let touying-title-slides = (
  default: generic-title-slide,
  simple: generic-title-slide,
  metropolis: themes.metropolis.title-slide,
  dewdrop: themes.dewdrop.title-slide,
  university: themes.university.title-slide,
  aqua: themes.aqua.title-slide,
  stargazer: themes.stargazer.title-slide,
  clean: clean-title-slide,
)

// Theme dispatcher -----------------------------------------------------------
// Normalises a common set of options onto each theme's own interface, so the
// show rule in typst-show.typ stays theme-agnostic.
// Colour/font options come from explicit YAML or, as a fallback, from `brand`
// (see typst-show.typ). `foreground` is the body text colour, `accent` the
// primary, `accent2` the secondary.
#let theme-show(
  name,
  aspect-ratio: "16-9",
  handout: false,
  accent: none,
  accent2: none,
  foreground: none,
  sansfont: none,
  mainfont: none,
  fontsize: none,
  font-weight-heading: none,
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
    if foreground != none { named.insert("color-jet", foreground) }
    if sansfont != none { named.insert("font-family-heading", sansfont) }
    if mainfont != none { named.insert("font-family-body", mainfont) }
    if fontsize != none { named.insert("font-size", fontsize) }
    if font-weight-heading != none { named.insert("font-weight-heading", font-weight-heading) }
  } else {
    // Built-in themes take config-* positional args. Colours map onto the
    // touying palette; built-in themes don't expose font knobs.
    if handout { cfg.push(config-common(handout: true)) }
    let colors = (:)
    if accent != none { colors.insert("primary", accent) }
    if accent2 != none { colors.insert("secondary", accent2) }
    if foreground != none { colors.insert("neutral-darkest", foreground) }
    if colors.len() > 0 { cfg.push(config-colors(..colors)) }
  }
  base.with(..named, ..cfg)
}
