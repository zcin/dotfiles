return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    config = function()
        -- import nvim-treesitter plugin
        local treesitter = require("nvim-treesitter.configs")

        -- configure treesitter
        treesitter.setup({
            highlight = { enable = true },
            indent = { enable = true },
            autotag = { enable = true },
            ensure_installed = {
                "python",
                "json",
                "yaml",
                "markdown",
                "bash",
                "lua",
                "vim",
                "vimdoc",
                "luadoc",
                "dockerfile",
                "go",
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        })
    end,
}
