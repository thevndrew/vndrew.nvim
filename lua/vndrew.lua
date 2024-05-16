local function init()
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "
  -- vim.g.mapleader = ","
  -- vim.g.maplocalleader = ","

  -- [[ Configure plugins ]]
  require("utils").glob_require "plugins"
end

return {
  init = init,
}
