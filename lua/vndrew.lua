local function init()
    vim.g.mapleader = ' '
    vim.g.maplocalleader = ' '
    -- vim.g.mapleader = ","
    -- vim.g.maplocalleader = ","

    require 'plugins'
end

return {
    init = init,
}
