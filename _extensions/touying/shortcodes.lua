-- Universal Touying animation shortcodes.
-- These work with every Touying theme (the reducer is theme-independent).

-- Begin the appendix: freezes the slide counter so appendix slides don't
-- count toward the total shown in footers.
function appendix()
    return pandoc.RawBlock('typst', '#show: appendix')
end

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
