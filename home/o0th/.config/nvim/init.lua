require("config.lazy")

vim.opt.clipboard:append("unnamedplus")
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.signcolumn = 'yes'
vim.opt.scrolloff = 10
vim.opt.autoindent = true
vim.wo.number = true

vim.keymap.set("i", "jk", "<Esc>", { noremap = true })
vim.keymap.set("v", "y", '"+y', { noremap = true })
