return {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("obsidian").setup({
            workspaces = {
                {
                    name = "main",
                    path = "~/vaults/main",
                },
            },
            open_app_foreground = true,
            daily_notes = {
                folder = "daily",
            },
        })

        vim.keymap.set("n", "<leader>ob", ":ObsidianOpen<CR>")
        vim.keymap.set("n", "<leader>ot", ":ObsidianToday<CR>")
    end,
}
