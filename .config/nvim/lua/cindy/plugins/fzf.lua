return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        -- calling `setup` is optional for customization
        require("fzf-lua").setup({})

        vim.keymap.set("n", "<C-p>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
        vim.keymap.set("n", "<leader>fs", "<cmd>lua require('fzf-lua').live_grep()<CR>", { silent = true })
        vim.keymap.set("n", "<leader>fc", "<cmd>lua require('fzf-lua').grep_cword()<CR>", { silent = true })
        vim.keymap.set("n", "<leader>fr", "<cmd>lua require('fzf-lua').lsp_references()<CR>", { silent = true })
    end
}
