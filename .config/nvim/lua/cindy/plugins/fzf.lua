return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = function()
        local fzf = require("fzf-lua")
        return {
            { "<C-p>", fzf.files, desc = "Find files" },
            { "<leader>fs", fzf.live_grep, desc = "Live grep" },
            { "<leader>fc", fzf.grep_cword, desc = "Grep word under cursor" },
            { "<leader>fr", fzf.lsp_references, desc = "LSP references" },
        }
    end,
    config = function()
        local fzf = require("fzf-lua")

        fzf.setup({
            actions = {
                files = {
                    true, -- inherit defaults
                    ["ctrl-s"] = false,
                    ["ctrl-x"] = fzf.actions.file_split,
                    ["ctrl-v"] = fzf.actions.file_vsplit,
                },
            },
            grep = {
                hidden = true,
            },
        })
    end,
}
