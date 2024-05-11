-- [[ Configure plugins ]]
local plugin_dir = 'vndrew/plugins'
require(plugin_dir .. '/cmp')
require(plugin_dir .. '/colorbuddy')
require(plugin_dir .. '/comment')
require(plugin_dir .. '/conform')
require(plugin_dir .. '/debug')
require(plugin_dir .. '/gitsigns')
require(plugin_dir .. '/indent_line')
require(plugin_dir .. '/lint')
require(plugin_dir .. '/lspconfig')
require(plugin_dir .. '/mini')
require(plugin_dir .. '/telescope')
require(plugin_dir .. '/todo-comments')
require(plugin_dir .. '/treesitter')
require(plugin_dir .. '/which-key')
-- require 'vndrew/kickstart.plugins.neo-tree'
-- require 'vndrew/kickstart/plugins/tokyonight'

-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
--    This is the easiest way to modularize your config.
--
--  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
--    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
-- { import = 'custom.plugins' },

-- vim: ts=2 sts=2 sw=2 et
