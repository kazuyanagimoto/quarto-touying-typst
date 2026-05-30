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

-- `::: {.incremental}` reveals each list item one #pause at a time.
-- `.complex-anim` exposes Touying's `uncover`/`only`/`alternatives` methods.
function Div(el)
  if not quarto.doc.is_format("typst") then
    return nil
  end

  if el.classes:includes("incremental") then
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

  if el.classes:includes("complex-anim") then
    local repeat_value = el.attributes["repeat"] or "auto"
    local header = "#slide(repeat: " .. repeat_value ..
      ", self => [\n#let (uncover, only, alternatives) = utils.methods(self)"
    local blocks = pandoc.List({ pandoc.RawBlock('typst', header) })
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock('typst', '\n])'))
    return blocks
  end
end
