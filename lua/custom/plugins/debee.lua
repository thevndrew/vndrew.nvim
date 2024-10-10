return {
    {
        'kndndrj/nvim-dbee',
        enabled = require('nixCatsUtils').enableForCategory 'debee',
        dependencies = { 'MunifTanjim/nui.nvim' },
        build = function()
            if not require('nixCatsUtils').isNixCats then
                require('dbee').install()
            end
        end,
        config = function()
            local source = require 'dbee.sources'

            require('dbee').setup {
                sources = {
                    source.MemorySource:new({
                        ---@diagnostic disable-next-line: missing-fields
                        {
                            type = 'postgres',
                            name = 'my_db',
                            url = 'postgresql://user:password@localhost:5432/my_db',
                        },
                    }, 'my_db'),
                },
            }

            vim.keymap.set('n', '<space>od', function()
                require('dbee').open()
            end, { desc = 'Open debee' })

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
        end,
    },
}
