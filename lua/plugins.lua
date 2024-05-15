-- [[ Configure plugins ]]
local function configure(plugin)
  require('plugins/' .. plugin)
end

configure 'cmp'
configure 'colorbuddy'
configure 'comment'
configure 'conform'
configure 'debug'
configure 'gitsigns'
configure 'indent_line'
configure 'lint'
configure 'lspconfig'
configure 'mini'
configure 'telescope'
configure 'todo-comments'
configure 'treesitter'
configure 'which-key'

-- configure 'neo-tree'
-- configure 'tokyonight'

-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
--    This is the easiest way to modularize your config.
--
--  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
--    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
-- { import = 'custom.plugins' },

-- vim: ts=2 sts=2 sw=2 et
