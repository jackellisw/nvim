return {
	{
		dir = vim.fn.expand("~/Code/personal/nvim-ai-code-review/specs/hodor-nvim-opus-4-6"),
		name = "hodor.nvim",
		enabled = function()
			return vim.fn.isdirectory(vim.fn.expand("~/Code/personal/nvim-ai-code-review/specs/hodor-nvim-opus-4-6")) == 1
		end,
		dependencies = { "MunifTanjim/nui.nvim" },
		cmd = { "Hodor", "HodorSubmit", "HodorBase", "HodorComment", "HodorToggleView" },
		keys = {
			{ "<leader>hr", "<cmd>Hodor<cr>", desc = "JWE review: open" },
			{ "<leader>hs", "<cmd>HodorSubmit<cr>", desc = "JWE review: submit" },
		},
		config = function()
			require("hodor").setup({
				opencode = {
					host = "127.0.0.1",
					port = 4096,
				},
			})
		end,
	},
}
