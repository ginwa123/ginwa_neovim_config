---@diagnostic disable-next-line: undefined-global
local vim = vim


vim.keymap.set("n", "<leader>rh", function()
  local file = vim.fn.expand("%:p")

  vim.system(
    { "python3", file }, -- ganti bun -> python3
    { text = true },
    function(result)
      vim.schedule(function()
        vim.cmd("enew")

        local lines = {}
        for line in (result.stdout or ""):gmatch("[^\r\n]+") do
          table.insert(lines, line)
        end

        -- kalau ada error, tampilkan juga stderr
        if result.stderr and result.stderr ~= "" then
          table.insert(lines, "")
          table.insert(lines, "=== STDERR ===")
          for line in result.stderr:gmatch("[^\r\n]+") do
            table.insert(lines, line)
          end
        end

        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.bo.buftype = "nofile"
        vim.bo.filetype = "python" -- bisa juga "json" kalau output json
      end)
    end
  )
end, { desc = "Run current python file (async)" })
