return {
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>')
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require('gitsigns').setup {
                on_attach = function(bufnr)
                    local gitsigns = require('gitsigns')

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation: ]c for next hunk, [c for previous hunk
                    map('n', ']c', function()
                        if vim.wo.diff then
                            vim.cmd.normal({ ']c', bang = true })
                        else
                            gitsigns.nav_hunk('next')
                        end
                    end)

                    map('n', '[c', function()
                        if vim.wo.diff then
                            vim.cmd.normal({ '[c', bang = true })
                        else
                            gitsigns.nav_hunk('prev')
                        end
                    end)

                    -- Preview hunk
                    map('n', '<leader>gp', gitsigns.preview_hunk)

                    -- Shows popup window of blamed commit for that line.
                    -- Can use Ctrl-w w to enter that window and scroll around, then hit q to exit
                    map('n', '<leader>gb', function() gitsigns.blame_line { full = true } end)

                    -- 'ga' to add hunk, 'gr' to reset hunk, 'gu' to undo hunk
                    map('n', '<leader>ga', gitsigns.stage_hunk)      -- "git add"
                    map('n', '<leader>gr', gitsigns.undo_stage_hunk) -- "git reset"
                    map('n', '<leader>gu', gitsigns.reset_hunk)      -- "git undo"

                    -- 'ga' to add hunk, 'gr' to reset hunk, 'gu' to undo hunk
                    map('v', '<leader>ga', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)      -- "git add"
                    map('v', '<leader>gr', function() gitsigns.undo_stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end) -- "git reset"
                    map('v', '<leader>gu', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)      -- "git undo"

                    -- Toggle git blame virtual text (at end of line)
                    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)

                    -- Open vertical split showing `git diff` against last commit (HEAD~1)
                    map('n', '<leader>gd', function() gitsigns.diffthis('~') end)

                    -- Show (or hide) deleted lines in the buffer as virtual text
                    map('n', '<leader>td', gitsigns.toggle_deleted)
                end
            }
        end,
    }
}
