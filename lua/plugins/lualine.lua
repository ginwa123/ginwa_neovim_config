local function lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        return "No LSP"
    end
    local names = {}
    for _, client in ipairs(clients) do
        table.insert(names, client.name)
    end
    return " " .. table.concat(names, ", ")
end

local function workspace_root()
    return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

require('lualine').setup({
    options = {
        theme = 'auto',
        component_separators = '',
        section_separators = '',
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = {
            {
                'filename',
                path = 1,
            }
        },
        lualine_x = {
            lsp_status,
            'filetype'
        },
        lualine_y = { 'progress' },
        lualine_z = { workspace_root, 'location' }
    },
})
