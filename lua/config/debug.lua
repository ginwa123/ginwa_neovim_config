-- Debugging configuration for C#/.NET

local dap = require('dap')

-- Mason installs netcoredbg in the Mason bin directory
-- This will find it automatically
dap.adapters.coreclr = {
	type = 'executable',
	command = 'netcoredbg',
	args = { '--interpreter=vscode' }
}

-- Helper function to find all projects in solution
local function find_projects()
	local cwd = vim.fn.getcwd()
	local projects = {}

	-- Find all .csproj files recursively
	local csproj_files = vim.fn.glob(cwd .. '/**/*.csproj', false, true)

	for _, csproj in ipairs(csproj_files) do
		local project_dir = vim.fn.fnamemodify(csproj, ':h')
		local project_name = vim.fn.fnamemodify(csproj, ':t:r')

		-- Find the debug directories for this project
		local debug_dirs = vim.fn.glob(project_dir .. '/bin/Debug/net*', false, true)

		for _, debug_dir in ipairs(debug_dirs) do
			local dll_path = string.format('%s/%s.dll', debug_dir, project_name)
			if vim.fn.filereadable(dll_path) == 1 then
				table.insert(projects, {
					name = project_name,
					dll = dll_path,
					dir = project_dir,
				})
			end
		end
	end

	return projects
end

dap.configurations.cs = {
	{
		type = "coreclr",
		name = "launch - netcoredbg",
		request = "launch",
		program = function()
			local cwd = vim.fn.getcwd()

			-- Find solution or project file to build
			local sln_files = vim.fn.glob(cwd .. '/*.sln', false, true)
			local build_target = ''

			if #sln_files == 1 then
				-- Single solution file - use it
				build_target = sln_files[1]
			elseif #sln_files > 1 then
				-- Multiple solution files - let user choose
				local choices = {}
				for i, sln in ipairs(sln_files) do
					table.insert(choices, string.format("%d. %s", i, vim.fn.fnamemodify(sln, ':t')))
				end

				local choice = vim.fn.inputlist(vim.list_extend({ "Select solution to build:" }, choices))

				if choice > 0 and choice <= #sln_files then
					build_target = sln_files[choice]
				else
					vim.notify("Invalid selection", vim.log.levels.ERROR)
					return nil
				end
			else
				-- No solution file - try to find current project
				local current_file = vim.fn.expand('%:p')
				local current_dir = vim.fn.expand('%:p:h')

				-- Search upward for .csproj file
				local search_dir = current_dir
				for _ = 1, 10 do -- Search up to 10 levels
					local csproj = vim.fn.glob(search_dir .. '/*.csproj', false, true)
					if #csproj > 0 then
						build_target = csproj[1]
						break
					end
					search_dir = vim.fn.fnamemodify(search_dir, ':h')
					if search_dir == '/' then break end
				end

				if build_target == '' then
					vim.notify("No solution or project file found", vim.log.levels.ERROR)
					return nil
				end
			end

			-- Build the selected target
			vim.notify("Building " .. vim.fn.fnamemodify(build_target, ':t') .. "...", vim.log.levels.INFO)
			local build_result = vim.fn.system('dotnet build "' .. build_target .. '"')

			if vim.v.shell_error ~= 0 then
				vim.notify("Build failed:\n" .. build_result, vim.log.levels.ERROR)
				return nil
			end

			-- Find all available projects
			local projects = find_projects()

			if #projects == 0 then
				vim.notify("No compiled projects found", vim.log.levels.ERROR)
				return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
			end

			-- If only one project, use it
			if #projects == 1 then
				vim.notify("Launching: " .. projects[1].dll, vim.log.levels.INFO)
				return projects[1].dll
			end

			-- Multiple projects: let user choose
			local choices = {}
			for i, proj in ipairs(projects) do
				table.insert(choices, string.format("%d. %s", i, proj.name))
			end

			local choice = vim.fn.inputlist(vim.list_extend({ "Select project to debug:" }, choices))

			if choice > 0 and choice <= #projects then
				vim.notify("Launching: " .. projects[choice].dll, vim.log.levels.INFO)
				return projects[choice].dll
			else
				vim.notify("Invalid selection", vim.log.levels.ERROR)
				return nil
			end
		end,
		cwd = '${workspaceFolder}',
		stopAtEntry = false,
	},
	{
		type = "coreclr",
		name = "attach - netcoredbg",
		request = "attach",
		processId = require('dap.utils').pick_process,
	},
}
--
-- dap.adapters['pwa-node'] = {
-- 	type = 'server',
-- 	port = '${port}',
-- 	executable = {
-- 		command = 'js-debug-adapter',
-- 		args = { '${port}' },
-- 	},
-- }
--



-- Bun adapter configuration

-- dap.adapters.bun = function(callback, config)
--   callback({
--     type = 'server',
--     host = config.host or '127.0.0.1',
--     port = config.port or 6499
--   })
-- end
--
-- dap.configurations.typescript = {
--   {
--     name = 'Attach to Bun Inspector',
--     type = 'bun',
--     request = 'attach',
--     port = 6499,
--     host = '127.0.0.1',
--     localRoot = '${workspaceFolder}',
--     remoteRoot = '${workspaceFolder}',
--   },
-- }
--
-- dap.configurations.javascript = dap.configurations.typescript
-- Better breakpoint signs
vim.fn.sign_define('DapBreakpoint', {
	text = '🔴',
	texthl = 'DapBreakpoint',
	linehl = '',
	numhl = 'DapBreakpoint'
})

vim.fn.sign_define('DapBreakpointCondition', {
	text = '🟡',
	texthl = 'DapBreakpoint',
	linehl = '',
	numhl = 'DapBreakpoint'
})

vim.fn.sign_define('DapBreakpointRejected', {
	text = '⚪',
	texthl = 'Comment',
	linehl = '',
	numhl = ''
})

vim.fn.sign_define('DapStopped', {
	text = '▶️',
	texthl = 'DapStopped',
	linehl = 'Visual',
	numhl = 'DapStopped'
})

vim.fn.sign_define('DapLogPoint', {
	text = '💬',
	texthl = 'DapLogPoint',
	linehl = '',
	numhl = ''
})

-- Color highlights for better visibility
vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400', bold = true })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#00ff00', bold = true })
vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bold = true })

-- Enhanced keymaps
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Continue/Start' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function()
	require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Debug: Conditional Breakpoint' })

vim.keymap.set('n', '<leader>bc', function()
	require('dap').clear_breakpoints()
	vim.notify('All breakpoints cleared', vim.log.levels.INFO)
end, { desc = 'Debug: Clear All Breakpoints' })

vim.keymap.set('n', 'gb', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
