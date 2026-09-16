return {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    cond = vim.fn.isdirectory(vim.fn.expand("~/vault")) == 1,
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<leader>ob", "<CMD>ObsidianOpen<CR>", desc = "Obsidian Open" },
        { "<leader>ot", "<CMD>ObsidianToday<CR>", desc = "Obsidian Today" },
    },
    opts = {
        workspaces = {
            {
                name = "main",
                path = "~/vault",
            },
        },
        open_app_foreground = true,
        daily_notes = {
            folder = "daily",
        },
    },
}
