local function init()
  local colorbuddy = require 'colorbuddy'
  vim.cmd.colorscheme 'gruvbuddy'
end

return {
  init = init,
}
