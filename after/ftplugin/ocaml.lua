local set = vim.opt_local

set.shiftwidth = 4

vim.keymap.set("n", "<space>cp", require("ocaml.mappings").dune_promote_file, { buffer = 0 })
