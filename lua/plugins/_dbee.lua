-- For now, I'm going to stick with dadbod,
-- but if the completion continues to improve I will probably switch
require('dbee').install()
local source = require 'dbee.sources'
require('dbee').setup {
    sources = {
        source.MemorySource:new({
            ---@diagnostic disable-next-line: missing-fields
            {
                type = 'postgres',
                name = 'mixery',
                url = 'postgresql://tjdevries:password@localhost:5432/mixery',
            },
        }, 'mixery'),
    },
}

vim.keymap.set('n', '<space>od', function()
    require('dbee').open()
end)

---@diagnostic disable-next-line: param-type-mismatch
local base = vim.fs.joinpath(vim.fn.stdpath 'state', 'dbee', 'notes')
local pattern = string.format('%s/.*', base)
vim.filetype.add {
    extension = {
        sql = function(path, _)
            if path:match(pattern) then
                return 'sql.dbee'
            end

            return 'sql'
        end,
    },

    pattern = {
        [pattern] = 'sql.dbee',
    },
}
