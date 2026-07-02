---@diagnostic disable-next-line: undefined-global
local vim = vim

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})

require("treesitter-context").setup({
    enable = true,
})
