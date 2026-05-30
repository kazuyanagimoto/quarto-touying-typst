-- Universal Touying animation shortcodes.
-- These work with every Touying theme (the reducer is theme-independent).

function pause()
    return pandoc.RawBlock('typst', '#pause')
end

function meanwhile()
    return pandoc.RawBlock('typst', '#meanwhile')
end

-- Manual vertical space, e.g. {{< v 1em >}}
function v(args)
    return pandoc.RawInline('typst', '#v(' .. args[1] .. ')')
end
