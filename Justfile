themes := "default simple metropolis dewdrop university aqua stargazer clean"

# Render the website (docs/: gallery index, tutorial, per-theme example decks)
render:
    quarto render docs

# Live preview of the website
preview:
    quarto preview docs

# Regenerate gallery thumbnails (title slide) from the rendered example PDFs
thumbnails: render
    #!/usr/bin/env bash
    set -euo pipefail
    for th in {{themes}}; do
      pdftoppm -png -singlefile -r 95 -f 1 -l 1 docs/_site/gallery/$th.pdf docs/static/images/$th
      echo "docs/static/images/$th.png"
    done

# Build navigable HTML decks (requires `pip install touying` on PATH)
decks:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p docs/slides
    for th in {{themes}}; do
      quarto render docs/gallery/$th.qmd --to touying-typst -M keep-typ:true
      touying compile docs/gallery/$th.typ --format html --output docs/slides/$th.html
      echo "docs/slides/$th.html"
    done

# Render just the standalone template deck
template:
    quarto render template.qmd --to touying-typst
