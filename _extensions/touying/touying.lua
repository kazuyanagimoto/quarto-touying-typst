-- Bridge filter: maps Quarto's presentation syntax onto Touying primitives.

-- `. . .` on its own line becomes a Touying pause.
function Para(el)
  if quarto.doc.is_format("typst") then
    local t = pandoc.utils.stringify(el)
    if t:match("^%. ?%. ?%.$") then
      return pandoc.RawBlock("typst", "#pause")
    end
  end
end

-- `[text]{.button}` renders a Beamer-style button (clickable inside a link).
function Span(el)
  if quarto.doc.is_format("typst") and el.classes:includes("button") then
    local inlines = pandoc.List({ pandoc.RawInline('typst', '#button[') })
    inlines:extend(el.content)
    inlines:insert(pandoc.RawInline('typst', ']'))
    return inlines
  end
end

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

-- `.complex-anim` exposes Touying's `uncover`/`only`/`alternatives` methods.
local function complex_anim(el)
  local repeat_value = el.attributes["repeat"] or "auto"
  local header = "#slide(repeat: " .. repeat_value ..
    ", self => [\n#let (uncover, only, alternatives) = utils.methods(self)"
  local blocks = pandoc.List({ pandoc.RawBlock('typst', header) })
  blocks:extend(el.content)
  blocks:insert(pandoc.RawBlock('typst', '\n])'))
  return blocks
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
  if el.classes:includes("complex-anim") then
    return complex_anim(el)
  end
end
