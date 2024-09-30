return {
    { -- Autoformat
        'stevearc/conform.nvim',
        lazy = false,
        keys = {
            {
                '<leader>f',
                function()
                    require('conform').format { async = true, lsp_fallback = true }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        config = function()
            local conform = require 'conform'

            local opts = {
                notify_on_error = false,
                format_on_save = function(bufnr)
                    -- Disable "format_on_save lsp_fallback" for languages that don't
                    -- have a well standardized coding style. You can add additional
                    -- languages here or re-enable it for the disabled ones.
                    local disable_filetypes = { c = true, cpp = true }
                    return {
                        timeout_ms = 500,
                        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
                    }
                end,
                formatters_by_ft = {
                    lua = { 'stylua' },
                    python = { 'isort', 'black' },
                },
            }

            vim.api.nvim_create_autocmd('BufWritePre', {
                callback = function(args)
                    conform.format {
                        bufnr = args.buf,
                        lsp_fallback = true,
                        quiet = true,
                    }
                end,
            })

            -- Trim trailing whitespace without affecting cursor position
            vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
                pattern = { '*' },
                callback = function()
                    local save_cursor = vim.fn.getpos '.'
                    pcall(function()
                        vim.cmd [[%s/\s\+$//e]]
                    end)
                    vim.fn.setpos('.', save_cursor)
                end,
            })

            conform.setup(opts)
        end,
    },
}
