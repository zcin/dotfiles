vim.cmd("let g:netrw_liststyle = 3")

vim.opt.relativenumber = true
vim.opt.number = true

-- tabs & indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

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

-- scroll stuff
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

-- disable mouse
vim.opt.mouse = ""

-- esc delay
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0
