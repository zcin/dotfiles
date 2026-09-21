local parsers = {
    "bash",
    "c",
    "cpp",
    "dockerfile",
    "go",
    "json",
    "jsonnet",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "vim",
    "yaml",
}

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    config = function()
        local treesitter = require("nvim-treesitter")

        -- Installation is asynchronous by default. Wait here so a file opened
        -- during first startup can enable its parser in the FileType callback.
        treesitter.install(parsers):wait(300000)

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if not lang or not vim.tbl_contains(parsers, lang) then
                    return
                end

                if pcall(vim.treesitter.start, args.buf, lang) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                    vim.keymap.set({ "n", "x" }, "<C-space>", function()
                        vim.treesitter.select("parent")
                    end, { buffer = args.buf, desc = "Select parent syntax node" })

                    vim.keymap.set("x", "<BS>", function()
                        vim.treesitter.select("child")
                    end, { buffer = args.buf, desc = "Select child syntax node" })
                end
            end,
        })

        require("nvim-ts-autotag").setup()
    end,
}
