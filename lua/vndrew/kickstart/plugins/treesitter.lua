local treesitter = require 'nvim-treesitter.configs'
local treesitter_context = require 'treesitter-context'

local function init()
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

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
end

return {
  init = init,
}

-- vim: ts=2 sts=2 sw=2 et
