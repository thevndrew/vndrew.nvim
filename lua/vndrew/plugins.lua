-- [[ Configure plugins ]]

local function init()
  require('vndrew/kickstart/plugins/cmp').init()
  require('vndrew/kickstart/plugins/colorbuddy').init()
  require('vndrew/kickstart/plugins/comment').init()
  require('vndrew/kickstart/plugins/conform').init()
  require('vndrew/kickstart/plugins/debug').init()
  require('vndrew/kickstart/plugins/gitsigns').init()
  require('vndrew/kickstart/plugins/indent_line').init()
  require('vndrew/kickstart/plugins/lint').init()
  require('vndrew/kickstart/plugins/lspconfig').init()
  require('vndrew/kickstart/plugins/mini').init()
  require('vndrew/kickstart/plugins/telescope').init()
  require('vndrew/kickstart/plugins/todo-comments').init()
  require('vndrew/kickstart/plugins/treesitter').init()
  require('vndrew/kickstart/plugins/which-key').init()
  -- require 'vndrew/kickstart.plugins.neo-tree'.init()
  -- require 'vndrew/kickstart/plugins/tokyonight'.init()
end

return {
  init = init,
}

-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
--    This is the easiest way to modularize your config.
--
--  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
--    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
-- { import = 'custom.plugins' },

-- vim: ts=2 sts=2 sw=2 et
