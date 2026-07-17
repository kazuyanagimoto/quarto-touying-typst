-- Bridge filter: maps Quarto's presentation syntax onto Touying primitives.

-- A Markdown horizontal rule (`---`) starts a new slide, matching Touying's
-- `horizontal-line-to-pagebreak`. Quarto's Typst writer renders `---` as a
-- drawn `#horizontalrule` line, which Touying does NOT treat as a slide break,
-- so emit a literal `---` (Touying's recognised horizontal-line marker) instead.
function HorizontalRule()
  if quarto.doc.is_format("typst") then
    return pandoc.RawBlock("typst", "---")
  end
end

-- `. . .` on its own line becomes a Touying pause.
function Para(el)
  if quarto.doc.is_format("typst") then
    local t = pandoc.utils.stringify(el)
    if t:match("^%. ?%. ?%.$") then
      return pandoc.RawBlock("typst", "#pause")
    end
  end
end

-- Inline commands (`.alert` / `.fg` / `.bg` / `.button` / ...) and block
-- environments (`.only` / `.uncover` / `.complex-anim` / ...) are handled by
-- environment.lua.

-- `::: {.columns}` / `::: {.column width="40%"}` -> a Typst grid.
local function columns_grid(el)
  local widths = {}
  local cells = pandoc.List({})
  for _, child in ipairs(el.content) do
    if child.t == "Div" and child.classes:includes("column") then
      table.insert(widths, child.attributes["width"] or "1fr")
      cells:insert(pandoc.RawBlock('typst', '['))
      cells:extend(child.content)
      cells:insert(pandoc.RawBlock('typst', '],'))
    end
  end
  local header = '#grid(columns: (' .. table.concat(widths, ", ") ..
    '), column-gutter: 1em, align: top,'
  local blocks = pandoc.List({ pandoc.RawBlock('typst', header) })
  blocks:extend(cells)
  blocks:insert(pandoc.RawBlock('typst', ')'))
  return blocks
end

-- `::: {.incremental}` reveals each list item one #pause at a time.
local function incremental(el)
  local out = {}
  for _, item in ipairs(el.content) do
    if item.t == "BulletList" or item.t == "OrderedList" then
      for j, list_item in ipairs(item.content) do
        local text = pandoc.utils.stringify(list_item[1])
        if j < #item.content then
          text = text .. " #pause"
        end
        list_item[1] = pandoc.RawInline('typst', text)
      end
    end
    table.insert(out, item)
  end
  return pandoc.Div(out, el.attr)
end

function Div(el)
  if not quarto.doc.is_format("typst") then
    return nil
  end
  -- Speaker notes are not shown on the slide (matches reveal.js behaviour).
  if el.classes:includes("notes") then
    return pandoc.List({})
  end
  if el.classes:includes("columns") then
    return columns_grid(el)
  end
  if el.classes:includes("incremental") then
    return incremental(el)
  end
end
