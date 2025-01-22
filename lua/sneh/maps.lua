vim.g.mapleader = " "

local function map(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.silent = true
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Save
map("n", "<leader>w", "<CMD>update<CR>")

-- Quit
map("n", "<leader>q", "<CMD>q<CR>")

-- Exit insert mode
map("i", "jk", "<ESC>")

-- NeoTree
map("n", "<leader>e", "<CMD>Neotree toggle<CR>")
map("n", "<leader>r", "<CMD>Neotree focus<CR>")

-- New Windows
map("n", "<leader>o", "<CMD>vsplit<CR>")
map("n", "<leader>p", "<CMD>split<CR>")

-- Window Navigation
map("n", "<leader><Left>", "<C-w>h")
map("n", "<leader><Right>", "<C-w>l")
map("n", "<leader><Up>", "<C-w>k")
map("n", "<leader><Down>", "<C-w>j")

-- Resize Windows
-- map("n", "<C-Left>", "<C-w><")
-- map("n", "<C-Right>", "<C-w>>")
-- map("n", "<C-Up>", "<C-w>+")
-- map("n", "<C-Down>", "<C-w>-")

-- Telescope
map("n", "<leader>p", "<CMD>Telescope find_files<CR>", { desc = "Fuzzy find files in cwd" })
map("n", "<leader>f", "<CMD>Telescope live_grep<CR>", { desc = "Find string in cwd" })
map("n", "<leader>fb", "<CMD>Telescope buffers<CR>", { desc = "Fuzzy find opened files" })
map("n", "<leader>gs", "<CMD>Telescope git_status<CR>", { desc = "Show git file diffs" })
map("n", "<leader>gc", "<CMD>Telescope git_commits<CR>", { desc = "Browse git commits" })

-- Custom
vim.keymap.set("n", "<leader><LEFT>", vim.cmd.Ex)