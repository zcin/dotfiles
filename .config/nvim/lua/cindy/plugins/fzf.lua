return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
        local fzf = require("fzf-lua")
        local config = fzf.config
        local actions = fzf.actions

        config.defaults.actions.files["ctrl-s"] = false
        config.defaults.actions.files["ctrl-h"] = actions.file_split
        config.defaults.actions.files["ctrl-v"] = actions.file_vsplit
    end,
    config = function()
        -- calling `setup` is optional for customization
        require("fzf-lua").setup({})

        vim.keymap.set("n", "<C-p>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
        vim.keymap.set("n", "<leader>fs", "<cmd>lua require('fzf-lua').live_grep()<CR>", { silent = true })
        vim.keymap.set("n", "<leader>fc", "<cmd>lua require('fzf-lua').grep_cword()<CR>", { silent = true })
        vim.keymap.set("n", "<leader>fr", "<cmd>lua require('fzf-lua').lsp_references()<CR>", { silent = true })
    end
}
