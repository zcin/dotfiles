-- set netrw to tree style view (style 3)
vim.cmd("let g:netrw_liststyle = 3")

-- show line number
vim.opt.number = true

-- tabs & indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- automatically indents new lines intelligently
vim.opt.smartindent = true

-- disable linewrapping
vim.opt.wrap = false

-- disable swap files
vim.opt.swapfile = false
vim.opt.backup = false

-- search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- keeps 8 lines visible above/below cursor
vim.opt.scrolloff = 8

-- always keep space for sign column
vim.opt.signcolumn = "yes"

-- disable mouse
vim.opt.mouse = ""

-- esc delay
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0

-- keep windows balanced
vim.opt.equalalways = true
vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*",
    command = "wincmd =",
})

-- obsidian / markdown
vim.opt.conceallevel = 2
vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = { '*.md' },
    callback = function()
        vim.opt_local.wrap = true    -- Enable soft wrap for markdown files
        -- Optionally set textwidth for formatting
        vim.opt_local.textwidth = 80 -- Or your preferred width
    end,
})
