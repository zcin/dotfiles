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
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
        -- Wrap settings
        vim.opt_local.wrap = true
        vim.opt_local.textwidth = 80
        
        -- Tab settings
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.expandtab = true
    end,
})
