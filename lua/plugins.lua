-- [[ Configure plugins ]]
local plugins = {
  "cmp",
  "colorbuddy",
  "comment",
  "conform",
  "debug",
  "gitsigns",
  "indent_line",
  "lint",
  "lspconfig",
  "mini",
  "telescope",
  "todo-comments",
  "treesitter",
  "which-key",
}

for _, plugin in pairs(plugins) do
  require("plugins/" .. plugin)
end
