#import "@preview/touying:0.7.3": *

// Selectable built-in Touying themes ----------------------------------------
// Add a theme here to make it available through the `theme:` YAML option.
// Each entry needs the theme's show function and its `title-slide`.
#let touying-themes = (
  metropolis: themes.metropolis.metropolis-theme,
  university: themes.university.university-theme,
  dewdrop: themes.dewdrop.dewdrop-theme,
  aqua: themes.aqua.aqua-theme,
  stargazer: themes.stargazer.stargazer-theme,
)
#let touying-title-slides = (
  metropolis: themes.metropolis.title-slide,
  university: themes.university.title-slide,
  dewdrop: themes.dewdrop.title-slide,
  aqua: themes.aqua.title-slide,
  stargazer: themes.stargazer.title-slide,
)
