return {
    "AckslD/swenv.nvim",
    config = function()
        require("swenv").setup({
            -- Should return a list of tables with a `name` and a `path` entry each.
            -- Gets the argument `venvs_path` set below.
            -- By default just lists the entries in `venvs_path`.
            get_venvs = function(_)
                local venvs = {}
                -- Check for .venv in cwd
                local cwd_venv = vim.fn.getcwd() .. "/.venv"
                if vim.fn.isdirectory(cwd_venv) == 1 then
                    table.insert(venvs, { name = ".venv (cwd)", path = cwd_venv })
                end
                -- Check for .venv in rexie workspaces
                for _, path in ipairs(vim.fn.glob("~/rexie/*/workspaces/*/.venv", false, true)) do
                    local name = path:match("workspaces/(.-)/.venv$")
                    table.insert(venvs, { name = name, path = path })
                end
                return venvs
            end,
            -- Something to do after setting an environment, for example call vim.cmd.LspRestart
            post_set_venv = function()
                vim.lsp.stop_client(vim.lsp.get_clients())
                vim.cmd("edit")
            end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "python" },
            callback = function()
                require("swenv.api").auto_venv()
            end,
        })

        -- set keymaps
        vim.keymap.set(
            "n",
            "<leader>vs",
            "<cmd>lua require('swenv.api').pick_venv()<cr>",
            { desc = "Choose virtual environment" }
        )
    end,
}
