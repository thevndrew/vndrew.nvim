-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

local set = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- vim.g.mapleader = ","
-- vim.g.maplocalleader = ","

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
set("n", "<c-h>", "<c-w><c-h>", { desc = "Move focus to the left window" })
set("n", "<c-l>", "<c-w><c-l>", { desc = "Move focus to the right window" })
set("n", "<c-j>", "<c-w><c-j>", { desc = "Move focus to the lower window" })
set("n", "<c-k>", "<c-w><c-k>", { desc = "Move focus to the upper window" })

set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- Toggle hlsearch if it's on, otherwise just do "enter"
set("n", "<CR>", function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.opt.hlsearch:get() then
    vim.cmd.nohl()
    return ""
  else
    return "<CR>"
  end
end, { expr = true })

-- Normally these are not good mappings, but I have left/right on my thumb
-- cluster, so navigating tabs is quite easy this way.
set("n", "<left>", "gT")
set("n", "<right>", "gt")

-- There are builtin keymaps for this now, but I like that it shows
-- the float when I navigate to the error - so I override them.
set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- These mappings control the size of splits (height/width)
set("n", "<M-,>", "<c-w>5<")
set("n", "<M-.>", "<c-w>5>")
set("n", "<M-t>", "<C-W>+")
set("n", "<M-s>", "<C-W>-")

set("n", "<M-j>", function()
  if vim.opt.diff:get() then
    vim.cmd [[normal! ]c]]
  else
    vim.cmd [[m .+1<CR>==]]
  end
end)

set("n", "<M-k>", function()
  if vim.opt.diff:get() then
    vim.cmd [[normal! [c]]
  else
    vim.cmd [[m .-2<CR>==]]
  end
end)

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
