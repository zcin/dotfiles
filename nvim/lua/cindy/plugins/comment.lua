return {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
        -- import comment plugin safely
        local comment = require("Comment")

        local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

        -- enable comment
        comment.setup({
            -- Add space between comment and the line
            padding = true,
            -- Whether the cursor should stay at its current position
            sticky = true,
            pre_hook = ts_context_commentstring.create_pre_hook(),
        })
    end,
}
