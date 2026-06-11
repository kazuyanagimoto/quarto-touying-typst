// PDF metadata ---------------------------------------------------------------
#set document(
  $if(title)$ title: [$title$], $endif$
  $if(by-author)$ author: ($for(by-author)$"$it.name.literal$"$sep$, $endfor$), $endif$
  $if(keywords)$ keywords: ($for(keywords)$"$keywords$"$sep$, $endfor$), $endif$
)

// Apply the selected theme through the dispatcher ----------------------------
#let theme-name = "$if(theme)$$theme$$else$default$endif$"

// Fonts: explicit option first, then `brand`. Set at the document root so they
// reach EVERY theme -- the built-in Touying themes set text size/weight but not
// the font family, so they inherit these. (The `clean` theme reads the same
// values through its own store, so the values agree and there is no conflict.)
$if(mainfont)$#set text(font: ("$mainfont$",))
$elseif(brand.typography.base.family)$#set text(font: $brand.typography.base.family$)
$endif$
$if(sansfont)$#show heading: set text(font: ("$sansfont$",))
$elseif(brand.typography.headings.family)$#show heading: set text(font: $brand.typography.headings.family$)
$endif$
$if(monofont)$#show raw: set text(font: ("$monofont$",))
$elseif(brand.typography.monospace.family)$#show raw: set text(font: $brand.typography.monospace.family$)
$endif$

#show: theme-show(
  theme-name,
  aspect-ratio: "$if(aspect-ratio)$$aspect-ratio$$else$16-9$endif$",
  $if(handout)$ handout: true, $endif$
  // Colours and fonts: explicit option first, then `brand` (_brand.yml) ------
  $if(accent)$ accent: rgb("$accent$"),
  $elseif(brand.color.primary)$ accent: brand-color.primary,
  $endif$
  $if(accent2)$ accent2: rgb("$accent2$"),
  $elseif(brand.color.secondary)$ accent2: brand-color.secondary,
  $endif$
  $if(jet)$ foreground: rgb("$jet$"),
  $elseif(brand.color.foreground)$ foreground: brand-color.foreground,
  $endif$
  $if(sansfont)$ sansfont: ("$sansfont$",),
  $elseif(brand.typography.headings.family)$ sansfont: $brand.typography.headings.family$,
  $endif$
  $if(mainfont)$ mainfont: ("$mainfont$",),
  $elseif(brand.typography.base.family)$ mainfont: $brand.typography.base.family$,
  $endif$
  $if(fontsize)$ fontsize: $fontsize$,
  $elseif(brand.typography.base.size)$ fontsize: $brand.typography.base.size$,
  $endif$
  $if(font-weight-heading)$ font-weight-heading: "$font-weight-heading$",
  $elseif(brand.typography.headings.weight)$ font-weight-heading: $brand.typography.headings.weight$,
  $endif$
  // Info shared by every theme's title slide ---------------------------------
  title: [$title$],
  $if(subtitle)$ subtitle: [$subtitle$], $endif$
  $if(by-author)$ author: [$for(by-author)$$it.name.literal$$sep$, $endfor$], $endif$
  // `authors`: content names (Touying convention, used by university/stargazer)
  $if(by-author)$ authors: ($for(by-author)$[$it.name.literal$], $endfor$), $endif$
  // `authors-data`: structured authors for the clean theme's rich title slide
  $if(by-author)$
  authors-data: (
    $for(by-author)$
    (
      name: [$it.name.literal$],
      affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
      email: [$it.email$],
      orcid: [$it.orcid$],
    ),
    $endfor$
  ),
  $endif$
  $if(date)$ date: [$date$], $endif$
  $if(institute)$ institution: [$institute$], $endif$
)

// Title slide ----------------------------------------------------------------
#(touying-title-slides.at(theme-name))()
