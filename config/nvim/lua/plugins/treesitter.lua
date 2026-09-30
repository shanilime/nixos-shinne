-- nvim-treesitter перешёл на новую ветку main с полностью переписанным API.
-- Старый require("nvim-treesitter.configs").setup({...}) больше не существует.
-- Теперь: установка парсеров явная, а highlight/indent включаются через
-- стандартный API самого Neovim (vim.treesitter.*), а не через сам плагин.

local ensure_installed = {
    "json",
    "python",
    "javascript",
    "query",
    "typescript",
    "tsx",
    "php",
    "yaml",
    "html",
    "css",
    "markdown",
    "markdown_inline",
    "bash",
    "lua",
    "vim",
    "vimdoc",
    "c",
    "dockerfile",
    "gitignore",
    "astro",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
        local ts = require("nvim-treesitter")

        ts.setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        ts.install(ensure_installed)

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
            local lang = vim.treesitter.language.get_lang(args.match) or args.match
            if vim.treesitter.language.add(lang) then
                vim.treesitter.start(args.buf, lang)
                end
                end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            callback = function()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
        require("nvim-treesitter-textobjects").setup({
            select = {
                lookahead = true,
            },
        })

        local select = require("nvim-treesitter-textobjects.select")
        vim.keymap.set({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer", "textobjects")
        end)
        vim.keymap.set({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner", "textobjects")
        end)
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        ft = { "html", "xml", "astro", "javascript", "typescript", "javascriptreact", "typescriptreact" },
        config = function()
        require("nvim-ts-autotag").setup()
        end,
    },
}
