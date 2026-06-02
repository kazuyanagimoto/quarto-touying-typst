-- Configurable Typst commands (inline spans) and environments (block divs).
-- Ported from quarto-clean-typst. A `[x]{.cmd}` span becomes `#cmd()[x]` and a
-- `::: {.env}` div becomes `#env()[ .. ]`; an `options` attribute is passed as
-- the Typst call's arguments. Add your own with the `commands:` / `environments:`
-- document metadata (a list of names, or name: typst-function pairs).

local classEnvironments = pandoc.MetaMap({
  ["only"] = "only",
  ["uncover"] = "uncover",
  ["align"] = "align",
})
local classCommands = pandoc.MetaMap({
  ["alert"] = "alert",
  ["fg"] = "fg",
  ["bg"] = "bg",
  ["button"] = "button",
  ["small-cite"] = "small-cite",
  ["only"] = "only",
  ["uncover"] = "uncover",
})

-- helper that identifies arrays
local function tisarray(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

local function readInto(target, value)
  if value == nil then return end
  if tisarray(value) then
    for _, v in ipairs(value) do
      local name = pandoc.utils.stringify(v)
      target[name] = name
    end
  else
    for k, v in pairs(value) do
      target[pandoc.utils.stringify(k)] = pandoc.utils.stringify(v)
    end
  end
end

local function readEnvsAndCommands(meta)
  readInto(classEnvironments, meta['environments'])
  readInto(classCommands, meta['commands'])
  return meta
end

local function endTypstBlock(blocks)
  local lastBlock = blocks[#blocks]
  if lastBlock.t == "Para" or lastBlock.t == "Plain" then
    lastBlock.content:insert(pandoc.RawInline('typst', '\n]'))
    return blocks
  else
    blocks:insert(pandoc.RawBlock('typst', ']\n'))
    return blocks
  end
end

local function writeEnvironments(el)
  if not quarto.doc.is_format("typst") then
    return nil
  end
  for k, v in pairs(classEnvironments) do
    if el.attr.classes:includes(k) then
      local blocks = pandoc.List({
        pandoc.RawBlock('typst', '#' .. pandoc.utils.stringify(v) .. '('),
      })
      local opts = el.attr.attributes['options']
      if opts then
        blocks:insert(pandoc.RawBlock('typst', opts))
      end
      blocks:insert(pandoc.RawBlock('typst', ')['))
      blocks:extend(el.content)
      return endTypstBlock(blocks)
    end
  end

  -- `.complex-anim` exposes Touying's `uncover`/`only`/`alternatives` methods.
  if el.classes:includes("complex-anim") then
    local repeat_value = el.attr.attributes["repeat"] or "auto"
    local typst_command = "#slide(repeat: " .. repeat_value ..
      ", self => [\n#let (uncover, only, alternatives) = utils.methods(self)"
    local blocks = pandoc.List({ pandoc.RawBlock('typst', typst_command) })
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock('typst', '\n])'))
    return blocks
  end
end

local function writeCommands(el)
  if not quarto.doc.is_format("typst") then
    return nil
  end
  for k, v in pairs(classCommands) do
    if el.attr.classes:includes(k) then
      local inlines = pandoc.List({
        pandoc.RawInline('typst', '#' .. pandoc.utils.stringify(v) .. '('),
      })
      local opts = el.attr.attributes['options']
      if opts then
        inlines:insert(pandoc.RawInline('typst', opts))
      end
      inlines:insert(pandoc.RawInline('typst', ')['))
      inlines:extend(el.content)
      inlines:insert(pandoc.RawInline('typst', ']'))
      return inlines
    end
  end
end

-- Two passes: read metadata first, then transform divs/spans.
return {
  { Meta = readEnvsAndCommands },
  { Div = writeEnvironments, Span = writeCommands },
}
