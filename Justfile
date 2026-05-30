themes := "metropolis university dewdrop aqua stargazer simple default"

# Render the website (gallery index + per-theme example decks)
render:
    quarto render

# Live preview of the gallery
preview:
    quarto preview

# Regenerate gallery thumbnails (slide 3) from the rendered example PDFs
thumbnails: render
    #!/usr/bin/env bash
    set -euo pipefail
    for th in {{themes}}; do
      pdftoppm -png -singlefile -r 95 -f 3 -l 3 _site/examples/$th.pdf images/$th
      echo "images/$th.png"
    done

# Build navigable HTML decks (requires `pip install touying` on PATH)
decks:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p slides
    for th in {{themes}}; do
      quarto render examples/$th.qmd --to touying-typst -M keep-typ:true -o $th.pdf
      touying compile examples/$th.typ --format html --output slides/$th.html
      echo "slides/$th.html"
    done

# Render just the standalone template deck
template:
    quarto render template.qmd --to touying-typst
