local discipline = require("craftzdog.discipline")

discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"0p')
keymap.set("n", "<Leader>P", '"0P')
keymap.set("v", "<Leader>p", '"0p')
keymap.set("n", "<Leader>c", '"_c')
keymap.set("n", "<Leader>C", '"_C')
keymap.set("v", "<Leader>c", '"_c')
keymap.set("v", "<Leader>C", '"_C')
keymap.set("n", "<Leader>d", '"_d')
keymap.set("n", "<Leader>D", '"_D')
keymap.set("v", "<Leader>d", '"_d')
keymap.set("v", "<Leader>D", '"_D')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Diagnostics
keymap.set("n", "<C-j>", function()
	vim.diagnostic.goto_next()
end, opts)

keymap.set("n", "<leader>r", function()
	require("craftzdog.hsl").replaceHexWithHSL()
end)

keymap.set("n", "<leader>i", function()
	require("craftzdog.lsp").toggleInlayHints()
end)

vim.api.nvim_create_user_command("ToggleAutoformat", function()
	require("craftzdog.lsp").toggleAutoformat()
end, {})

-- Floating terminal
local terminal_state = { buf = -1, win = -1 }

local function set_terminal_float_highlights()
	local normal_float = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
	local float_border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })

	vim.api.nvim_set_hl(0, "FloatingTerminalNormal", {
		bg = "NONE",
		fg = normal_float.fg,
	})
	vim.api.nvim_set_hl(0, "FloatingTerminalBorder", {
		bg = "NONE",
		fg = float_border.fg,
	})
end

set_terminal_float_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_terminal_float_highlights,
})

local function open_float_win(buf)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	})
	vim.wo[win].winhighlight =
		"Normal:FloatingTerminalNormal,NormalFloat:FloatingTerminalNormal,FloatBorder:FloatingTerminalBorder,EndOfBuffer:FloatingTerminalNormal"
	return win
end

local function toggle_floating_terminal()
	if vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_hide(terminal_state.win)
		return
	end
	if vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.win = open_float_win(terminal_state.buf)
		vim.cmd("startinsert")
	else
		local tmp = vim.api.nvim_create_buf(false, true)
		terminal_state.win = open_float_win(tmp)
		vim.fn.termopen(vim.o.shell)
		terminal_state.buf = tmp
		vim.cmd("startinsert")
	end
end

keymap.set("n", "<leader>tt", toggle_floating_terminal, opts)
keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
keymap.set("n", "q", function()
	if vim.api.nvim_win_is_valid(terminal_state.win) and vim.api.nvim_get_current_win() == terminal_state.win then
		vim.api.nvim_win_hide(terminal_state.win)
	end
end, opts)
