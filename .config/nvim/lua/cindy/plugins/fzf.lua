return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = function()
        local fzf = require("fzf-lua")

        local priority_dirs = { "model-serving/serving-engine", "wheelhouse/deptrees" }

        local function in_universe()
            return vim.fn.getcwd():find("universe") ~= nil
        end

        local function files_with_priority()
            if not in_universe() then
                return fzf.files()
            end
            local excludes = {}
            for _, d in ipairs(priority_dirs) do
                table.insert(excludes, "--exclude " .. d)
            end
            fzf.files({
                cmd = "fd --type f . " .. table.concat(priority_dirs, " ") .. " && fd --type f . " .. table.concat(excludes, " "),
            })
        end

        local function grep_with_priority()
            if not in_universe() then
                return fzf.live_grep()
            end
            fzf.live_grep({
                cmd = vim.fn.expand("~/scripts/priority-grep.sh") .. " <query>",
            })
        end

        return {
            { "<C-p>", files_with_priority, desc = "Find files" },
            { "<leader>fs", grep_with_priority, desc = "Live grep" },
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
