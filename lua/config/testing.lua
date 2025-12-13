-- Testing configuration with neotest

-- Helper function to find nearest project or solution
local function find_nearest_project_or_solution()
  local current_file = vim.fn.expand('%:p')
  local search_dir = vim.fn.expand('%:p:h')

  -- Search upward for .csproj or .sln file (max 10 levels)
  for _ = 1, 10 do
    -- First try to find .csproj (project-level is more reliable)
    local csproj = vim.fn.glob(search_dir .. '/*.csproj', false, true)
    if #csproj > 0 then
      return search_dir
    end

    -- Then try .sln
    local sln = vim.fn.glob(search_dir .. '/*.sln', false, true)
    if #sln == 1 then  -- Only if there's exactly ONE solution
      return search_dir
    end

    search_dir = vim.fn.fnamemodify(search_dir, ':h')
    if search_dir == '/' then break end
  end

  return vim.fn.getcwd()
end

-- Make function globally available for keybindings
_G.find_nearest_project_or_solution = find_nearest_project_or_solution

require("neotest").setup({
  adapters = {
    require("neotest-dotnet")({
      discovery_root = "project",  -- Use project level
      dap = { justMyCode = false }
    })
  },
  log_level = vim.log.levels.DEBUG
})

-- Smart test runner that CDs to the correct directory
local function run_test_with_correct_cwd(scope)
  local project_root = find_nearest_project_or_solution()
  local original_cwd = vim.fn.getcwd()

  -- Change to project directory
  vim.api.nvim_set_current_dir(project_root)

  -- Run the test
  if scope == "nearest" then
    require("neotest").run.run()
  elseif scope == "file" then
    require("neotest").run.run(vim.fn.expand("%"))
  elseif scope == "project" then
    require("neotest").run.run(project_root)
  end

  -- Restore original directory after a short delay
  vim.defer_fn(function()
    vim.api.nvim_set_current_dir(original_cwd)
  end, 100)
end

-- Make function globally available for keybindings
_G.run_test_with_correct_cwd = run_test_with_correct_cwd

-- Test keymaps
-- vim.keymap.set("n", "<leader>tt", function() run_test_with_correct_cwd("nearest") end, { desc = "Run nearest test" })
-- vim.keymap.set("n", "<leader>tf", function() run_test_with_correct_cwd("file") end, { desc = "Run current file tests" })
vim.keymap.set("n", "<leader>tp", function()
  run_test_with_correct_cwd("project")
  vim.defer_fn(function()
    require("neotest").summary.open()
    require("neotest").output_panel.open()
  end, 100) -- 100ms delay
end, { desc = "Run project tests" })

vim.keymap.set("n", "<leader>ts", function()
  local neotest = require("neotest")

  -- Check if summary window exists
  local summary_open = false
  local output_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match("Neotest Summary") then
      summary_open = true
    elseif buf_name:match("Neotest Output") then
      output_open = true
    end
  end

  -- If both are open, close both. If either is closed, open both.
  if summary_open and output_open then
    neotest.summary.close()
    neotest.output_panel.close()
  else
    neotest.summary.open()
    neotest.output_panel.open()
  end
end, { desc = "Toggle test summary and output" })-- Debug current directory


vim.keymap.set("n", "<leader>td", function()
  local root = find_nearest_project_or_solution()
  vim.notify("Project root: " .. root, vim.log.levels.INFO)
end, { desc = "Show test project root" })
