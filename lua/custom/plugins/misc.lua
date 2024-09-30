return {
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    'tpope/vim-fugitive',
    {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {},
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    },

    -- "gc" to comment visual regions/lines
    -- NOTE: nixCats: nix downloads it with a different file name.
    -- tell lazy about that.
    { 'numToStr/Comment.nvim', name = 'comment.nvim', opts = {} },
}
