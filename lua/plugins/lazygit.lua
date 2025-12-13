-- Git-related plugin configurations

require("lazygit")

vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
