local treesitter = require 'nvim-treesitter.configs'
local treesitter_context = require 'treesitter-context'

-- [[ Configure Treesitter ]] See `:help nvim-treesitter`

-- There are additional nvim-treesitter modules that you can use to interact
-- with nvim-treesitter. You should go explore a few and see what interests you:
--
--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
local M = {}

M.setup = function()
    local group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true })

    treesitter.setup {
        auto_install = false,
        ensure_installed = {},
        highlight = {
            enable = true,
            -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
            --  If you are experiencing weird indenting issues, add the language to
            --  the list of additional_vim_regex_highlighting and disabled languages for indent.
            additional_vim_regex_highlighting = { 'ruby' },
        },
        ignore_install = {},
        indent = { enable = true, disable = { 'ruby' } },
        modules = {},
        sync_install = false,
    }

    treesitter_context.setup()

    local syntax_on = {
        elixir = true,
    }

    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        callback = function(args)
            local bufnr = args.buf
            local ft = vim.bo[bufnr].filetype
            pcall(vim.treesitter.start)

            if syntax_on[ft] then
                vim.bo[bufnr].syntax = 'on'
            end
        end,
    })
end

M.setup()

return M
