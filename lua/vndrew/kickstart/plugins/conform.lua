local conform = require('conform')

local function init()

   vim.keymap.set('n',
      '<leader>f', 
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end, 
      { desc = '[F]ormat buffer' }
    )

    conform.setup({
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
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
      },
    })
end

return {
    init = init
}

-- vim: ts=2 sts=2 sw=2 et
