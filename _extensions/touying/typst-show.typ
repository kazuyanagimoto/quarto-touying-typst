// PDF metadata ---------------------------------------------------------------
#set document(
  $if(title)$ title: [$title$], $endif$
  $if(by-author)$ author: ($for(by-author)$"$it.name.literal$"$sep$, $endfor$), $endif$
  $if(keywords)$ keywords: ($for(keywords)$"$keywords$"$sep$, $endfor$), $endif$
)

// Select the Touying theme ---------------------------------------------------
#let theme-name = "$if(theme)$$theme$$else$metropolis$endif$"

#show: (touying-themes.at(theme-name)).with(
  aspect-ratio: "$if(aspect-ratio)$$aspect-ratio$$else$16-9$endif$",
  $if(handout)$ config-common(handout: true), $endif$
  config-info(
    title: [$title$],
    $if(subtitle)$ subtitle: [$subtitle$], $endif$
    $if(by-author)$ author: [$for(by-author)$$it.name.literal$$sep$, $endfor$], $endif$
    $if(date)$ date: [$date$], $endif$
    $if(institute)$ institution: [$institute$], $endif$
  ),
)

// Title slide ----------------------------------------------------------------
#(touying-title-slides.at(theme-name))()
