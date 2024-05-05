-- Highlight todo, notes, etc in comments
local function init()
  require("todo-comments").setup({ signs = false })
end

return {
  init = init
}
-- vim: ts=2 sts=2 sw=2 et
