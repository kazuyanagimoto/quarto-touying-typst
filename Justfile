themes := "default simple metropolis dewdrop university aqua stargazer"
# Standalone showcase decks (full feature tour + external-theme examples).
extras := "full clean bamboo flow"

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
    for th in {{themes}} {{extras}}; do
      pdftoppm -png -singlefile -r 95 -f 1 -l 1 docs/_site/gallery/$th.pdf docs/static/images/$th
      echo "docs/static/images/$th.png"
    done

# Build navigable HTML decks (requires `pip install touying` on PATH).
# Renders the whole project (not single files) so Quarto honours `freeze`: the
# R-backed `full` deck builds from its committed `_freeze/` results and no R
# toolchain is needed. `keep-typ` leaves each deck's `.typ` for touying-exporter.
decks:
    #!/usr/bin/env bash
    set -euo pipefail
    quarto render docs -M keep-typ:true
    mkdir -p docs/slides
    for th in {{themes}} {{extras}}; do
      touying compile docs/gallery/$th.typ --format html --output docs/slides/$th.html
      echo "docs/slides/$th.html"
    done

# Render just the standalone template deck
template:
    quarto render template.qmd --to touying-typst
