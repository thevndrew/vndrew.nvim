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

-- vim: ts=2 sts=2 sw=2 et
