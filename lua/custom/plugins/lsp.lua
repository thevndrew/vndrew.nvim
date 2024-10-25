return {
    { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            {
                'williamboman/mason.nvim',
                -- NOTE: nixCats: use lazyAdd to only enable mason if nix wasnt involved.
                -- because we will be using nix to download things instead.
                enabled = require('nixCatsUtils').lazyAdd(true, false),
                config = true,
            }, -- NOTE: Must be loaded before dependants
            {
                'williamboman/mason-lspconfig.nvim',
                -- NOTE: nixCats: use lazyAdd to only enable mason if nix wasnt involved.
                -- because we will be using nix to download things instead.
                enabled = require('nixCatsUtils').lazyAdd(true, false),
            },
            {
                'WhoIsSethDaniel/mason-tool-installer.nvim',
                -- NOTE: nixCats: use lazyAdd to only enable mason if nix wasnt involved.
                -- because we will be using nix to download things instead.
                enabled = require('nixCatsUtils').lazyAdd(true, false),
            },

            -- Useful status updates for LSP.
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            { 'https://git.sr.ht/~whynothugo/lsp_lines.nvim' },
            { 'b0o/schemastore.nvim' },

            -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
            -- used for completion, annotations and signatures of Neovim apis
            {
                'folke/lazydev.nvim',
                ft = 'lua',
                opts = {
                    library = {
                        -- adds type hints for nixCats global
                        { path = (require('nixCats').nixCatsPath or '') .. '/lua', words = { 'nixCats' } },
                    },
                },
            },
            -- kickstart.nvim was still on neodev. lazydev is the new version of neodev
        },
        config = function()
            -- Brief aside: **What is LSP?**
            --
            -- LSP is an initialism you've probably heard, but might not understand what it is.
            --
            -- LSP stands for Language Server Protocol. It's a protocol that helps editors
            -- and language tooling communicate in a standardized fashion.
            --
            -- In general, you have a "server" which is some tool built to understand a particular
            -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
            -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
            -- processes that communicate with some "client" - in this case, Neovim!
            --
            -- LSP provides Neovim with features like:
            --  - Go to definition
            --  - Find references
            --  - Autocompletion
            --  - Symbol Search
            --  - and more!
            --
            -- Thus, Language Servers are external tools that must be installed separately from
            -- Neovim. This is where `mason` and related plugins come into play.
            --
            -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
            -- and elegantly composed help section, `:help lsp-vs-treesitter`

            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                    -- to define small helper and utility functions so you don't have to repeat yourself.
                    --
                    -- In this case, we create a function that lets us more easily define mappings specific
                    -- for LSP related items. It sets the mode, buffer and description for us each time.
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    map('<leader>td', function()
                        local state = not vim.diagnostic.is_enabled()
                        print('Toggling diagnostics ' .. (state and 'On' or 'Off'))
                        vim.diagnostic.enable(state)
                    end, 'Toggle LSP diagnostics')

                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.
                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                    -- Find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

                    -- Fuzzy find all the symbols in your current workspace.
                    --  Similar to document symbols, except searches over your entire project.
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                    -- Rename the variable under your cursor.
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                    -- Opens a popup that displays documentation about the word under your cursor
                    --  See `:help K` for why this keymap.
                    map('K', vim.lsp.buf.hover, 'Hover Documentation')

                    -- WARN: This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header.
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- The following autocommand is used to enable inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

            -- Enable the following language servers
            --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
            --
            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            -- NOTE: nixCats: there is help in nixCats for lsps at `:h nixCats.LSPs` and also `:h nixCats.luaUtils`

            -- servers.clangd = {},
            -- servers.gopls = {},
            -- servers.pyright = {},
            -- servers.rust_analyzer = {},
            -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
            --
            -- Some languages (like typescript) have entire language plugins that can be useful:
            --    https://github.com/pmizio/typescript-tools.nvim
            --
            -- But for many setups, the LSP (`tsserver`) will work just fine
            -- servers.tsserver = {},
            --
            local function get_hostname()
                local f = io.popen 'hostname'
                local hostname = f:read '*a' or ''
                f:close()
                hostname = string.gsub(hostname, '\n$', '')
                return hostname
            end

            local flake_path = vim.fn.expand '$HOME/nix-config'
            local servers = {
                -- clangd = {},
                -- gopls = {},
                -- rust_analyzer = {},
                -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
                --
                -- Some languages (like typescript) have entire language plugins that can be useful:
                --    https://github.com/pmizio/typescript-tools.nvim
                --
                -- But for many setups, the LSP (`tsserver`) will work just fine
                -- tsserver = {},
                --

                bashls = 'bash-language-server',
                gopls = 'gopls',
                rust_analyzer = 'rust-analyzer',
                svelte = 'svelteserver',
                templ = 'templ',
                cssls = 'vscode-css-language-server',

                -- Probably want to disable formatting for this lang server
                ts_ls = 'typescript-language-server',

                pyright = 'pyright-langserver',

                lua_ls = {
                    bin_name = 'lua-language-server',
                    -- cmd = {...},
                    -- filetypes = { ...},
                    -- capabilities = {},
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                            diagnostics = {
                                globals = { 'nixCats' },
                                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                                disable = { 'missing-fields' },
                            },
                        },
                    },
                },

                nixd = {
                    bin_name = 'nixd',
                    cmd = { 'nixd' },
                    settings = {
                        nixd = {
                            nixpkgs = {
                                expr = 'import <nixpkgs> { }',
                            },
                            formatting = {
                                command = { 'alejandra' }, -- or nixfmt or nixpkgs-fmt
                            },
                            options = require('nixCatsUtils').lazyAdd({}, {
                                nixos = {
                                    expr = '(builtins.getFlake "' .. flake_path .. '").nixosConfigurations.' .. get_hostname() .. '.options',
                                },
                                home_manager = {
                                    expr = '(builtins.getFlake "' .. flake_path .. '").homeConfigurations.' .. vim.env.USER .. '.options',
                                },
                            }),
                        },
                    },
                },

                nil_ls = {
                    bin_name = 'nil',
                    autostart = true,
                    cmd = { 'nil' },
                    settings = {
                        ['nil'] = {
                            formatting = {
                                command = { 'alejandra' },
                            },
                        },
                    },
                },

                jsonls = {
                    bin_name = 'vscode-json-language-server',
                    settings = {
                        json = {
                            schemas = require('schemastore').json.schemas(),
                            validate = { enable = true },
                        },
                    },
                },

                yamlls = {
                    bin_name = 'yaml-language-server',
                    settings = {
                        yaml = {
                            schemaStore = {
                                enable = false,
                                url = '',
                            },
                            schemas = require('schemastore').yaml.schemas(),
                        },
                    },
                },

                ocamllsp = {
                    bin_name = 'ocamllsp',
                    manual_install = true,
                    settings = {
                        codelens = { enable = true },
                    },

                    filetypes = {
                        'ocaml',
                        'ocaml.interface',
                        'ocaml.menhir',
                        'ocaml.cram',
                    },
                },

                clangd = {
                    bin_name = 'clangd',
                    init_options = { clangdFileStatus = true },
                    filetypes = { 'c' },
                },
            }

            -- NOTE: nixCats: nixd is not available on mason.
            if require('nixCatsUtils').isNixCats then
                -- servers.nixd = {}
            else
                -- servers.rnix = {}
                -- servers.nil_ls = {}
            end

            -- NOTE: nixCats: if nix, use lspconfig instead of mason
            -- You could MAKE it work, using lspsAndRuntimeDeps and sharedLibraries in nixCats
            -- but don't... its not worth it. Just add the lsp to lspsAndRuntimeDeps.
            if require('nixCatsUtils').isNixCats then
                for server_name, config in pairs(servers) do
                    if type(config) == 'string' then
                        config = { bin_name = config }
                    end

                    -- Only configure if LSP is present
                    if vim.fn.executable(config.bin_name) == 1 then
                        config = vim.tbl_deep_extend('force', {}, {
                            capabilities = capabilities,
                        }, config)

                        require('lspconfig')[server_name].setup(config)
                    end
                end
            else
                -- NOTE: nixCats: and if no nix, do it the normal way

                -- Ensure the servers and tools above are installed
                --  To check the current status of installed tools and/or manually install
                --  other tools, you can run
                --    :Mason
                --
                --  You can press `g?` for help in this menu.
                require('mason').setup()

                -- You can add other tools here that you want Mason to install
                -- for you, so that they are available from within Neovim.
                local ensure_installed = vim.tbl_keys(servers or {})
                vim.list_extend(ensure_installed, {
                    'stylua', -- Used to format Lua code
                })
                require('mason-tool-installer').setup { ensure_installed = ensure_installed }

                require('mason-lspconfig').setup {
                    handlers = {
                        function(server_name)
                            local server = servers[server_name] or {}

                            if type(server) == 'string' then
                                server = { bin_name = server }
                            end

                            -- Only configure if LSP is present
                            if vim.fn.executable(server.bin_name) == 1 then
                                -- This handles overriding only values explicitly passed
                                -- by the server configuration above. Useful when disabling
                                -- certain features of an LSP (for example, turning off formatting for tsserver)
                                server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                                require('lspconfig')[server_name].setup(server)
                            end
                        end,
                    },
                }
            end
        end,
    },
}
