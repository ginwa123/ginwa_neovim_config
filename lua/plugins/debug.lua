---@diagnostic disable-next-line: undefined-global
local vim = vim


local dap = require('dap')

-- Mason installs netcoredbg in the Mason bin directory
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
					csproj = csproj,
				})
			end
		end
	end

	return projects
end

-- Helper function to find test projects (csproj files)
local function find_test_projects()
	local cwd = vim.fn.getcwd()
	local test_projects = {}

	-- Find all .csproj files recursively
	local csproj_files = vim.fn.glob(cwd .. '/**/*.csproj', false, true)

	for _, csproj in ipairs(csproj_files) do
		local project_name = vim.fn.fnamemodify(csproj, ':t:r')

		-- Check if project name contains common test indicators
		if project_name:match('[Tt]est') or project_name:match('[Ss]pec') then
			local project_dir = vim.fn.fnamemodify(csproj, ':h')

			table.insert(test_projects, {
				name = project_name,
				dir = project_dir,
				csproj = csproj,
			})
		end
	end

	return test_projects
end

-- Helper function to find build target (solution or project)
local function find_build_target()
	local cwd = vim.fn.getcwd()
	local sln_files = vim.fn.glob(cwd .. '/*.sln', false, true)

	if #sln_files == 1 then
		return sln_files[1]
	elseif #sln_files > 1 then
		-- Multiple solution files - let user choose
		local choices = {}
		for i, sln in ipairs(sln_files) do
			table.insert(choices, string.format("%d. %s", i, vim.fn.fnamemodify(sln, ':t')))
		end

		local choice = vim.fn.inputlist(vim.list_extend({ "Select solution to build:" }, choices))

		if choice > 0 and choice <= #sln_files then
			return sln_files[choice]
		else
			return nil
		end
	else
		-- No solution file - try to find current project
		local current_dir = vim.fn.expand('%:p:h')
		local search_dir = current_dir

		for _ = 1, 10 do
			local csproj = vim.fn.glob(search_dir .. '/*.csproj', false, true)
			if #csproj > 0 then
				return csproj[1]
			end
			search_dir = vim.fn.fnamemodify(search_dir, ':h')
			if search_dir == '/' then break end
		end
	end

	return nil
end


dap.configurations.cs = {
	{
		type = "coreclr",
		name = "launch - netcoredbg",
		request = "launch",
		program = function()
			local co = coroutine.running()

			local build_target = find_build_target()

			if not build_target then
				vim.notify("No solution or project file found", vim.log.levels.ERROR)
				return nil
			end

			-- Async build
			vim.notify('Building ' .. vim.fn.fnamemodify(build_target, ':t') .. '...', vim.log.levels.INFO)

			vim.system({ 'dotnet', 'build', build_target , '-c', 'Debug' }, {
				cwd = vim.fn.getcwd(),
				text = true,
			}, function(result)
				vim.schedule(function()
					if result.code ~= 0 then
						vim.notify('Build failed:\n' .. (result.stderr or result.stdout or ''),
							vim.log.levels.ERROR)
						coroutine.resume(co, nil)
						return
					end

					vim.notify('Build successful!', vim.log.levels.INFO)
					-- Find all available projects
					local projects = find_projects()

					if #projects == 0 then
						vim.notify("No compiled projects found", vim.log.levels.ERROR)
						coroutine.resume(co,
							vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/',
								'file'))
						return
					end

					-- If only one project, use it
					if #projects == 1 then
						vim.notify("Launching: " .. projects[1].dll, vim.log.levels.INFO)
						coroutine.resume(co, projects[1].dll)
						return
					end

					-- Multiple projects: let user choose
					local choices = {}
					for i, proj in ipairs(projects) do
						table.insert(choices, proj.name)
					end

					vim.ui.select(choices, {
						prompt = 'Select project to debug:',
					}, function(choice)
						if choice then
							for _, proj in ipairs(projects) do
								if proj.name == choice then
									vim.notify("Launching: " .. proj.dll,
										vim.log.levels.INFO)
									coroutine.resume(co, proj.dll)
									return
								end
							end
						else
							coroutine.resume(co, nil)
						end
					end)
				end)
			end)

			return coroutine.yield()
		end,
		cwd = '${workspaceFolder}',
		stopAtEntry = false,
	},

	{
		type = "coreclr",
		name = "test - netcoredbg current line function",
		request = "attach",

		processId = function()
			local co = coroutine.running()

			-- Get the test information (reuse the logic from args function)
			local current_file = vim.fn.expand('%:p')
			local cursor_line = vim.fn.line('.')

			if not current_file:match('Test') and not current_file:match('Tests') then
				vim.notify("Not in a test file", vim.log.levels.WARN)
				coroutine.resume(co, nil)
				return coroutine.yield()
			end

			-- Find test method
			local function find_test_method()
				local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
				local test_method = nil
				local test_class = nil
				local test_attr_line = nil

				for i = cursor_line, 1, -1 do
					local line = lines[i]
					if line:match('%[Test') then
						test_attr_line = i
						break
					end
				end

				if not test_attr_line then
					vim.notify("No [Test] attribute found above cursor", vim.log.levels.WARN)
					return nil
				end

				for i = test_attr_line, math.min(test_attr_line + 10, #lines) do
					local line = lines[i]
					if not test_method then
						local patterns = {
							'async%s+Task[%w<>]*%s+([%w_]+)%s*%(',
							'Task[%w<>]*%s+([%w_]+)%s*%(',
							'void%s+([%w_]+)%s*%(',
						}
						for _, pattern in ipairs(patterns) do
							local method = line:match(pattern)
							if method then
								test_method = method
								break
							end
						end
					end
					if test_method then
						break
					end
				end

				for i = test_attr_line, 1, -1 do
					local line = lines[i]
					local class = line:match('class%s+([%w_]+)')
					if class then
						test_class = class
						break
					end
				end

				if test_method and test_class then
					return string.format("%s.%s", test_class, test_method)
				end
				return nil
			end

			local test_filter = find_test_method()

			if not test_filter then
				vim.notify("Could not find test method at cursor.", vim.log.levels.WARN)
				coroutine.resume(co, nil)
				return coroutine.yield()
			end

			vim.notify("Found test: " .. test_filter, vim.log.levels.INFO)

			-- Find test project
			local test_projects = find_test_projects()

			if #test_projects == 0 then
				local projects = find_projects()
				for _, proj in ipairs(projects) do
					local tests_dir = proj.dir .. '/Tests'
					if vim.fn.isdirectory(tests_dir) == 1 then
						table.insert(test_projects, {
							name = proj.name .. ' (Tests)',
							dir = proj.dir,
							csproj = proj.csproj,
							is_embedded_tests = true,
						})
					end
				end
			end

			if #test_projects == 0 then
				vim.notify("No test projects or Tests folder found", vim.log.levels.WARN)
				coroutine.resume(co, nil)
				return coroutine.yield()
			end

			local selected_project = nil
			for _, proj in ipairs(test_projects) do
				if current_file:find(proj.dir, 1, true) then
					selected_project = proj
					break
				end
			end

			if not selected_project then
				selected_project = test_projects[1]
			end

			-- Build the test project first
			vim.notify('Building ' .. selected_project.name .. '...', vim.log.levels.INFO)

			vim.system({ 'dotnet', 'build', selected_project.csproj, '-c', 'Debug' }, {
				cwd = vim.fn.getcwd(),
				text = true,
			}, function(result)
				vim.schedule(function()
					if result.code ~= 0 then
						vim.notify(
							'Build failed:\n' ..
							(result.stderr or result.stdout or ''),
							vim.log.levels.ERROR)
						coroutine.resume(co, nil)
						return
					end

					vim.notify('Build successful! Starting test: ' .. test_filter,
						vim.log.levels.INFO)

					-- Capture test output for display
					local test_output = {}

					-- Start dotnet test in background and get its PID
					-- Use jobstart to have better control over the process
					local job_id = vim.fn.jobstart({
						'dotnet', 'test', selected_project.csproj,
						'--no-build',
						'--filter',
						'FullyQualifiedName~' .. test_filter,
						'--',
						'RunConfiguration.DebugCodeAnalysis=true',
						'--logger:console;verbosity=detailed'
					}, {
						cwd = vim.fn.getcwd(),
						env = vim.tbl_extend('keep', vim.fn.environ(), {
							VSTEST_HOST_DEBUG = '1'
						}),
						stdout_buffered = false,
						stderr_buffered = false,
						on_stdout = function(j, data)
							for _, line in ipairs(data) do
								if line ~= '' then
									table.insert(test_output, line)
									-- Show output in real-time
									vim.schedule(function()
										-- vim.notify(line, vim.log.levels.INFO)
									end)
								end
							end
						end,
						on_stderr = function(j, data)
							for _, line in ipairs(data) do
								if line ~= '' then
									table.insert(test_output, line)
									-- Show errors in real-time
									vim.schedule(function()
										-- vim.notify(line, vim.log.levels.ERROR)
									end)
								end
							end
						end,
						on_exit = function(j, code)
							local msg = string.format("Test process exited with code: %d",
								code)
							-- vim.schedule(function()
							-- 	vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
							-- end)

							-- Save output to a file for later review
							local output_file = vim.fn.getcwd() .. '/test-output.log'
							local f = io.open(output_file, 'w')
							if f then
								for _, line in ipairs(test_output) do
									f:write(line .. '\n')
								end
								f:close()

								-- Store the output file path for easy access
								vim.g.test_output_file = output_file

								-- Automatically open the output in a buffer
								vim.schedule(function()
									-- vim.notify("Test output saved to: " .. output_file, vim.log.levels.INFO)
									vim.cmd('edit ' .. output_file)
								end)
							end
						end
					})

					-- Function to find testhost process
					local function find_testhost_pid()
						-- Look for testhost processes
						local output = vim.fn.systemlist("pgrep -f 'testhost'")

						if #output > 0 then
							-- Return the first testhost PID found
							return tonumber(output[1])
						end
						return nil
					end

					-- Poll for testhost process with timeout
					local start_time = os.time()
					local timeout = 15 -- 15 second timeout

					local function check_for_process()
						local pid = find_testhost_pid()
						if pid then
							vim.notify("Found testhost process with PID: " .. pid,
								vim.log.levels.INFO)
							coroutine.resume(co, pid)
							return true
						end

						if os.time() - start_time > timeout then
							vim.notify("Timeout waiting for testhost process",
								vim.log.levels.ERROR)
							coroutine.resume(co, nil)
							return true
						end

						-- Schedule next check
						vim.defer_fn(check_for_process, 500) -- Check every 500ms
						return false
					end

					-- Start checking for the process
					-- Add a small initial delay to let testhost initialize
					vim.defer_fn(check_for_process, 1000) -- Wait 1 second before first check
				end)
			end)

			return coroutine.yield()
		end,

		args = function()
			-- Args are not needed since we're attaching to an existing process
			-- The processId function handles building and starting the test
			return {}
		end,
		cwd = '${workspaceFolder}',
		stopAtEntry = false,
		-- Critical: Tell .NET to wait for debugger attachment
		env = {
			VSTEST_HOST_DEBUG = "1",
		},
	},
	{
		type = "coreclr",
		name = "test - netcoredbg all tests in file",
		request = "attach",

		processId = function()
			local co = coroutine.running()

			-- Get the test information
			local current_file = vim.fn.expand('%:p')

			if not current_file:match('Test') and not current_file:match('Tests') then
				vim.notify("Not in a test file", vim.log.levels.WARN)
				coroutine.resume(co, nil)
				return coroutine.yield()
			end

			-- Find test class and all test methods in the file
			local function find_test_info()
				local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
				local test_class = nil
				local test_methods = {}

				-- Look for class name
				for _, line in ipairs(lines) do
					local class = line:match('class%s+([%w_]+)')
					if class then
						test_class = class
						break
					end
				end

				-- Find all test methods (methods with [Test] or [TestCase] attribute)
				local i = 1
				while i <= #lines do
					local line = lines[i]

					-- Check if this line has a [Test] or [TestCase] attribute
					if line:match('%[Test%]') or line:match('%[TestCase') then
						-- Look ahead for the method name in the next few lines
						for j = i + 1, math.min(i + 10, #lines) do
							local method_line = lines[j]
							-- Match method patterns
							local patterns = {
								'async%s+Task[%w<>]*%s+([%w_]+)%s*%(',
								'Task[%w<>]*%s+([%w_]+)%s*%(',
								'void%s+([%w_]+)%s*%(',
								'public%s+async%s+Task[%w<>]*%s+([%w_]+)%s*%(',
								'public%s+Task[%w<>]*%s+([%w_]+)%s*%(',
								'public%s+void%s+([%w_]+)%s*%(',
							}

							for _, pattern in ipairs(patterns) do
								local method = method_line:match(pattern)
								if method then
									table.insert(test_methods, method)
									break
								end
							end

							-- If we found a method, break the inner loop
							if #test_methods > 0 and test_methods[#test_methods] then
								break
							end
						end
					end

					i = i + 1
				end

				return test_class, test_methods
			end

			local test_class, all_test_methods = find_test_info()

			if not test_class then
				vim.notify("Could not find test class in file.", vim.log.levels.WARN)
				coroutine.resume(co, nil)
				return coroutine.yield()
			end

			vim.notify(
				"Found test class: " .. test_class .. " with " .. #all_test_methods .. " test methods",
				vim.log.levels.INFO)

			-- Find test project
			local test_projects = find_test_projects()

			if #test_projects == 0 then
				local projects = find_projects()
				for _, proj in ipairs(projects) do
					local tests_dir = proj.dir .. '/Tests'
					if vim.fn.isdirectory(tests_dir) == 1 then
						table.insert(test_projects, {
							name = proj.name .. ' (Tests)',
							dir = proj.dir,
							csproj = proj.csproj,
							is_embedded_tests = true,
						})
					end
				end
			end

			if #test_projects == 0 then
				vim.notify("No test projects or Tests folder found", vim.log.levels.WARN)
				coroutine.resume(co, nil)
				return coroutine.yield()
			end

			local selected_project = nil
			for _, proj in ipairs(test_projects) do
				if current_file:find(proj.dir, 1, true) then
					selected_project = proj
					break
				end
			end

			if not selected_project then
				selected_project = test_projects[1]
			end

			-- Build the test project first
			vim.notify('Building ' .. selected_project.name .. '...', vim.log.levels.INFO)

			vim.system({ 'dotnet', 'build', selected_project.csproj, '-c', 'Debug' }, {
				cwd = vim.fn.getcwd(),
				text = true,
			}, function(result)
				vim.schedule(function()
					if result.code ~= 0 then
						vim.notify(
							'Build failed:\n' ..
							(result.stderr or result.stdout or ''),
							vim.log.levels.ERROR)
						coroutine.resume(co, nil)
						return
					end

					vim.notify('Build successful! Starting all tests in class: ' .. test_class,
						vim.log.levels.INFO)

					-- Capture test output for display
					local test_output = {}

					-- Start dotnet test with class filter (runs all methods in the class)
					local job_id = vim.fn.jobstart({
						'dotnet', 'test', selected_project.csproj,
						'--no-build',
						'--filter',
						'FullyQualifiedName~' .. test_class,
						'--',
						'RunConfiguration.DebugCodeAnalysis=true',
						'--logger:console;verbosity=detailed'
					}, {
						cwd = vim.fn.getcwd(),
						env = vim.tbl_extend('keep', vim.fn.environ(), {
							VSTEST_HOST_DEBUG = '1'
						}),
						stdout_buffered = false,
						stderr_buffered = false,
						on_stdout = function(j, data)
							for _, line in ipairs(data) do
								if line ~= '' then
									table.insert(test_output, line)
								end
							end
						end,
						on_stderr = function(j, data)
							for _, line in ipairs(data) do
								if line ~= '' then
									table.insert(test_output, line)
								end
							end
						end,
						on_exit = function(j, code)
							-- Parse test results
							local function format_test_results(output, all_methods)
								local formatted = {}
								local failed_results = {}
								local failed_method_names = {}
								local total_tests = 0
								local passed_count = 0
								local failed_count = 0
								local skipped_count = 0
								local duration = "N/A"

								-- Parse output for test results
								for i, line in ipairs(output) do
									-- Look for failed test with format: "  Failed TestName [time]"
									local failed_match = line:match '^%s*Failed%s+([%w_]+)%s*%[([^%]]+)%]'
									if failed_match then
										local test_name = failed_match
										local test_duration = line:match '%[([^%]]+)%]' or
										    "N/A"

										-- Store the failed test name for filtering later
										table.insert(failed_method_names,
											test_name)

										-- Try to capture error details from next few lines
										local error_msg = ""
										local actual_value = ""
										local expected_value = ""

										for j = i + 1, math.min(i + 15, #output) do
											local curr_line = output[j]

											-- Look for "Expected:" line
											if curr_line:match('Expected:') then
												expected_value =
												    curr_line:match(
													    'Expected:%s*(.+)') or
												    ""
												expected_value =
												    expected_value:gsub(
													    "^%s+", "")
												    :gsub("%s+$",
													    "")
											end

											-- Look for "But was:" line (NUnit format)
											if curr_line:match('But was:') then
												actual_value = curr_line
												    :match(
													    'But was:%s*(.+)') or
												    ""
												actual_value =
												    actual_value:gsub(
													    "^%s+",
													    ""):gsub(
													    "%s+$",
													    "")
											end

											-- Look for "Actual:" line (alternative format)
											if curr_line:match('Actual:') then
												actual_value = curr_line
												    :match(
													    'Actual:%s*(.+)') or
												    ""
												actual_value =
												    actual_value:gsub(
													    "^%s+",
													    ""):gsub(
													    "%s+$",
													    "")
											end

											-- Stop if we hit the next test result or stack trace number
											if curr_line:match('^%s*Failed%s+[%w_]') or curr_line:match('^%d+%)') then
												break
											end
										end

										table.insert(failed_results, {
											name = test_name,
											duration = test_duration,
											expected = expected_value,
											actual = actual_value
										})
									end

									-- Capture summary line: "Failed!  - Failed:     4, Passed:    11, Skipped:     0, Total:    15, Duration: 1 s"
									if line:match('Failed:%s*%d+') or line:match('Passed:%s*%d+') then
										failed_count = tonumber(line:match(
											    'Failed:%s*(%d+)')) or
										    failed_count
										passed_count = tonumber(line:match(
											    'Passed:%s*(%d+)')) or
										    passed_count
										skipped_count = tonumber(line:match(
											    'Skipped:%s*(%d+)')) or
										    skipped_count
										total_tests = tonumber(line:match(
											'Total:%s*(%d+)')) or total_tests

										-- Extract duration from summary line
										local dur = line:match(
											    'Duration:%s*([%d%.]+%s*[smh]+)') or
										    line:match('Duration:%s*([%d:%.]+)')
										if dur then
											duration = dur
										end
									end
								end

								-- Determine passed tests by filtering out failed ones
								local passed_methods = {}
								for _, method in ipairs(all_methods) do
									local is_failed = false
									for _, failed_name in ipairs(failed_method_names) do
										if method == failed_name then
											is_failed = true
											break
										end
									end
									if not is_failed then
										table.insert(passed_methods, method)
									end
								end

								-- Build formatted output
								table.insert(formatted,
									"╔════════════════════════════════════════════════════════════════════════╗")
								table.insert(formatted,
									"║                          TEST RESULTS SUMMARY                          ║")
								table.insert(formatted,
									"╠════════════════════════════════════════════════════════════════════════╣")
								table.insert(formatted,
									string.format("║  Class: %-62s ║", test_class))
								table.insert(formatted,
									string.format("║  Total Tests: %-56d ║",
										total_tests))
								table.insert(formatted,
									string.format("║  ✓ Passed: %-59d ║",
										passed_count))
								table.insert(formatted,
									string.format("║  ✗ Failed: %-59d ║",
										failed_count))
								if skipped_count > 0 then
									table.insert(formatted,
										string.format("║  ⊘ Skipped: %-58d ║",
											skipped_count))
								end
								table.insert(formatted,
									string.format("║  Duration: %-57s ║", duration))
								table.insert(formatted,
									"╚════════════════════════════════════════════════════════════════════════╝")
								table.insert(formatted, "")

								-- Show passed tests with method names
								if #passed_methods > 0 then
									table.insert(formatted,
										string.format(
											"✓ PASSED TESTS: %d test%s passed",
											#passed_methods,
											#passed_methods == 1 and "" or
											"s"))
									table.insert(formatted,
										"═══════════════════════════════════════════════════════════════════════════")
									for i, method in ipairs(passed_methods) do
										table.insert(formatted,
											string.format("%d. ✓ %s", i,
												method))
									end
									table.insert(formatted, "")
								end

								-- Show failed tests with details
								if #failed_results > 0 then
									table.insert(formatted, "✗ FAILED TESTS:")
									table.insert(formatted,
										"═══════════════════════════════════════════════════════════════════════════")
									for i, result in ipairs(failed_results) do
										table.insert(formatted,
											string.format("%d. ✗ %s [%s]",
												i, result.name,
												result.duration))

										if result.expected and result.expected ~= "" then
											table.insert(formatted,
												string.format(
													"   Expected: %s",
													result.expected))
										end

										if result.actual and result.actual ~= "" then
											table.insert(formatted,
												string.format(
													"   Actual:   %s",
													result.actual))
										end

										table.insert(formatted, "")
									end
								end

								-- Add separator before raw output
								table.insert(formatted, "")
								table.insert(formatted,
									"═══════════════════════════════════════════════════════════════════════════")
								table.insert(formatted,
									"                            RAW TEST OUTPUT                                ")
								table.insert(formatted,
									"═══════════════════════════════════════════════════════════════════════════")
								table.insert(formatted, "")

								-- Add raw output
								for _, line in ipairs(output) do
									table.insert(formatted, line)
								end

								return formatted
							end

							local formatted_output = format_test_results(test_output,
								all_test_methods)

							-- Save formatted output to a file
							local output_file = vim.fn.getcwd() .. '/test-output.log'
							local f = io.open(output_file, 'w')
							if f then
								for _, line in ipairs(formatted_output) do
									f:write(line .. '\n')
								end
								f:close()

								vim.g.test_output_file = output_file

								-- Open the output in a buffer with nice formatting
								vim.schedule(function()
									vim.cmd('edit ' .. output_file)
									-- Set filetype for potential syntax highlighting
									vim.cmd('setlocal filetype=testresult')
									vim.cmd('setlocal nowrap')
								end)
							end
						end
					})

					-- Function to find testhost process
					local function find_testhost_pid()
						local output = vim.fn.systemlist("pgrep -f 'testhost'")

						if #output > 0 then
							return tonumber(output[1])
						end
						return nil
					end

					-- Poll for testhost process with timeout
					local start_time = os.time()
					local timeout = 15

					local function check_for_process()
						local pid = find_testhost_pid()
						if pid then
							vim.notify("Found testhost process with PID: " .. pid,
								vim.log.levels.INFO)
							coroutine.resume(co, pid)
							return true
						end

						if os.time() - start_time > timeout then
							vim.notify("Timeout waiting for testhost process",
								vim.log.levels.ERROR)
							coroutine.resume(co, nil)
							return true
						end

						vim.defer_fn(check_for_process, 500)
						return false
					end

					vim.defer_fn(check_for_process, 1000)
				end)
			end)

			return coroutine.yield()
		end,

		args = function()
			return {}
		end,
		cwd = '${workspaceFolder}',
		stopAtEntry = false,
		env = {
			VSTEST_HOST_DEBUG = "1",
		},
	},
	{
		type = "coreclr",
		name = "test - netcoredbg all tests in workspace",
		request = "attach",

		processId = function()
			local co = coroutine.running()

			vim.notify("Finding all test projects in workspace...", vim.log.levels.INFO)

			-- Find all test projects in the workspace
			local test_projects = find_test_projects()

			if #test_projects == 0 then
				local projects = find_projects()
				for _, proj in ipairs(projects) do
					local tests_dir = proj.dir .. '/Tests'
					if vim.fn.isdirectory(tests_dir) == 1 then
						table.insert(test_projects, {
							name = proj.name .. ' (Tests)',
							dir = proj.dir,
							csproj = proj.csproj,
							is_embedded_tests = true,
						})
					end
				end
			end

			if #test_projects == 0 then
				vim.notify("No test projects found in workspace", vim.log.levels.WARN)
				coroutine.resume(co, nil)
				return coroutine.yield()
			end

			vim.notify(string.format("Found %d test project(s)", #test_projects), vim.log.levels.INFO)

			-- Find solution file or use workspace root
			local function find_solution_or_root()
				local cwd = vim.fn.getcwd()
				local sln_files = vim.fn.globpath(cwd, '*.sln', false, true)

				if #sln_files > 0 then
					return sln_files[1]
				end

				return nil
			end

			local solution_file = find_solution_or_root()

			-- Build all test projects first
			vim.notify('Building all test projects...', vim.log.levels.INFO)

			-- Function to build projects
			local function build_projects(callback)
				if solution_file then
					-- Build the entire solution
					vim.system({ 'dotnet', 'build', solution_file, '-c', 'Debug' }, {
						cwd = vim.fn.getcwd(),
						text = true,
					}, function(result)
						vim.schedule(function()
							if result.code ~= 0 then
								vim.notify(
									'Solution build failed:\n' ..
									(result.stderr or result.stdout or ''),
									vim.log.levels.ERROR)
								callback(false)
							else
								vim.notify('Solution build successful!',
									vim.log.levels.INFO)
								callback(true)
							end
						end)
					end)
				else
					-- Build each test project individually
					local build_index = 1
					local function build_next()
						if build_index > #test_projects then
							vim.schedule(function()
								vim.notify('All test projects built successfully!',
									vim.log.levels.INFO)
								callback(true)
							end)
							return
						end

						local proj = test_projects[build_index]
						vim.notify('Building ' .. proj.name .. '...', vim.log.levels.INFO)

						vim.system({ 'dotnet', 'build', proj.csproj, '-c', 'Debug' }, {
							cwd = vim.fn.getcwd(),
							text = true,
						}, function(result)
							vim.schedule(function()
								if result.code ~= 0 then
									vim.notify(
										'Build failed for ' ..
										proj.name .. ':\n' ..
										(result.stderr or result.stdout or ''),
										vim.log.levels.ERROR)
									callback(false)
								else
									build_index = build_index + 1
									build_next()
								end
							end)
						end)
					end

					build_next()
				end
			end

			build_projects(function(success)
				if not success then
					coroutine.resume(co, nil)
					return
				end

				vim.schedule(function()
					vim.notify('Starting all tests in workspace...', vim.log.levels.INFO)

					-- Capture test output for display
					local test_output = {}
					local output_file = vim.fn.getcwd() .. '/test-output-workspace.log'

					-- Progress tracking
					local tests_completed = 0
					local tests_passed = 0
					local tests_failed = 0
					local last_progress_update = os.time()
					local current_assembly = nil

					-- Prepare test command
					local test_cmd = { 'dotnet', 'test' }

					if solution_file then
						table.insert(test_cmd, solution_file)
					end

					-- Add common arguments
					table.insert(test_cmd, '--no-build')
					table.insert(test_cmd, '--')
					table.insert(test_cmd, 'RunConfiguration.DebugCodeAnalysis=true')
					table.insert(test_cmd, '--logger:console;verbosity=detailed')

					-- Start dotnet test
					local job_id = vim.fn.jobstart(test_cmd, {
						cwd = vim.fn.getcwd(),
						env = vim.tbl_extend('keep', vim.fn.environ(), {
							VSTEST_HOST_DEBUG = '1'
						}),
						stdout_buffered = false,
						stderr_buffered = false,
						on_stdout = function(j, data)
							for _, line in ipairs(data) do
								if line ~= '' then
									table.insert(test_output, line)

									-- Track progress from output
									local now = os.time()

									-- Detect test assembly being run
									local assembly = line:match(
										'Test run for ([^%s]+%.dll)')
									if assembly then
										current_assembly = assembly:match(
											'([^/\\]+)$')
										vim.schedule(function()
											vim.notify(
												string.format(
													"Running tests: %s",
													current_assembly),
												vim.log.levels.INFO)
										end)
									end

									-- Count completed tests (passed or failed)
									if line:match('^%s*Passed%s+') or line:match('^%s*Failed%s+') then
										tests_completed = tests_completed + 1

										if line:match('^%s*Passed%s+') then
											tests_passed = tests_passed + 1
										elseif line:match('^%s*Failed%s+') then
											tests_failed = tests_failed + 1
										end

										-- Update progress every 2 seconds or every 10 tests
										if (now - last_progress_update >= 2) or (tests_completed % 10 == 0) then
											last_progress_update = now
											vim.schedule(function()
												local status_icon =
												    tests_failed > 0 and
												    "⚠" or
												    "✓"
												vim.notify(
													string.format(
														"%s Progress: %d tests | ✓ %d passed | ✗ %d failed",
														status_icon,
														tests_completed,
														tests_passed,
														tests_failed),
													vim.log.levels
													.INFO)
											end)
										end
									end
								end
							end
						end,
						on_stderr = function(j, data)
							for _, line in ipairs(data) do
								if line ~= '' then
									table.insert(test_output, line)
								end
							end
						end,
						on_exit = function(j, code)
							-- Parse test results and create formatted summary
							local function format_test_results(output)
								local formatted = {}
								local failed_results = {}
								local test_summaries = {}
								local total_tests = 0
								local passed_count = 0
								local failed_count = 0
								local skipped_count = 0
								local duration = "N/A"
								local current_asm = nil

								-- Parse output for test results
								for i, line in ipairs(output) do
									local assembly = line:match(
										'Test run for ([^%s]+%.dll)')
									if assembly then
										current_asm = assembly:match(
											'([^/\\]+)$')
									end

									local failed_match = line:match '^%s*Failed%s+([%w_]+)%s*%[([^%]]+)%]'
									if failed_match then
										local test_name = failed_match
										local test_duration = line:match '%[([^%]]+)%]' or
										    "N/A"

										local actual_value = ""
										local expected_value = ""

										for j = i + 1, math.min(i + 15, #output) do
											local curr_line = output[j]

											if curr_line:match('Expected:') then
												expected_value =
												    curr_line:match(
													    'Expected:%s*(.+)') or
												    ""
												expected_value =
												    expected_value:gsub(
													    "^%s+", "")
												    :gsub("%s+$",
													    "")
											end

											if curr_line:match('But was:') then
												actual_value = curr_line
												    :match(
													    'But was:%s*(.+)') or
												    ""
												actual_value =
												    actual_value:gsub(
													    "^%s+",
													    ""):gsub(
													    "%s+$",
													    "")
											end

											if curr_line:match('Actual:') then
												actual_value = curr_line
												    :match(
													    'Actual:%s*(.+)') or
												    ""
												actual_value =
												    actual_value:gsub(
													    "^%s+",
													    ""):gsub(
													    "%s+$",
													    "")
											end

											if curr_line:match('^%s*Failed%s+[%w_]') or curr_line:match('^%d+%)') then
												break
											end
										end

										table.insert(failed_results, {
											name = test_name,
											duration = test_duration,
											expected = expected_value,
											actual = actual_value,
											assembly = current_asm or
											    "Unknown"
										})
									end

									if line:match('Failed!') or line:match('Passed!') then
										local proj_failed = tonumber(line:match(
											'Failed:%s*(%d+)')) or 0
										local proj_passed = tonumber(line:match(
											'Passed:%s*(%d+)')) or 0
										local proj_skipped = tonumber(line:match(
											'Skipped:%s*(%d+)')) or 0
										local proj_total = tonumber(line:match(
											'Total:%s*(%d+)')) or 0
										local proj_dur = line:match(
											    'Duration:%s*([%d%.]+%s*[smh]+)') or
										    line:match('Duration:%s*([%d:%.]+)')

										if proj_total > 0 then
											table.insert(test_summaries, {
												assembly = current_asm or
												    "Unknown",
												failed = proj_failed,
												passed = proj_passed,
												skipped = proj_skipped,
												total = proj_total,
												duration = proj_dur or
												    "N/A"
											})
										end

										failed_count = failed_count + proj_failed
										passed_count = passed_count + proj_passed
										skipped_count = skipped_count +
										    proj_skipped
										total_tests = total_tests + proj_total
									end
								end

								-- Build summary
								table.insert(formatted,
									"╔════════════════════════════════════════════════════════════════════════╗")
								table.insert(formatted,
									"║                    WORKSPACE TEST RESULTS SUMMARY                      ║")
								table.insert(formatted,
									"╠════════════════════════════════════════════════════════════════════════╣")
								table.insert(formatted,
									string.format("║  Total Tests: %-56d ║",
										total_tests))
								table.insert(formatted,
									string.format("║  ✓ Passed: %-59d ║",
										passed_count))
								table.insert(formatted,
									string.format("║  ✗ Failed: %-59d ║",
										failed_count))
								if skipped_count > 0 then
									table.insert(formatted,
										string.format("║  ⊘ Skipped: %-58d ║",
											skipped_count))
								end
								table.insert(formatted,
									"╚════════════════════════════════════════════════════════════════════════╝")
								table.insert(formatted, "")

								-- Show per-project summaries
								if #test_summaries > 0 then
									table.insert(formatted, "PER-PROJECT RESULTS:")
									table.insert(formatted,
										"═══════════════════════════════════════════════════════════════════════════")
									for _, summary in ipairs(test_summaries) do
										table.insert(formatted,
											string.format("📦 %s",
												summary.assembly))
										table.insert(formatted,
											string.format(
												"   Total: %d | ✓ Passed: %d | ✗ Failed: %d | Duration: %s",
												summary.total,
												summary.passed,
												summary.failed,
												summary.duration))
										table.insert(formatted, "")
									end
								end

								-- Show failed tests with details
								if #failed_results > 0 then
									table.insert(formatted, "✗ FAILED TESTS:")
									table.insert(formatted,
										"═══════════════════════════════════════════════════════════════════════════")

									local by_assembly = {}
									for _, result in ipairs(failed_results) do
										if not by_assembly[result.assembly] then
											by_assembly[result.assembly] = {}
										end
										table.insert(
											by_assembly[result.assembly],
											result)
									end

									for assembly, results in pairs(by_assembly) do
										table.insert(formatted,
											string.format("📦 %s:", assembly))
										for i, result in ipairs(results) do
											table.insert(formatted,
												string.format(
													"   %d. ✗ %s [%s]",
													i, result.name,
													result.duration))

											if result.expected and result.expected ~= "" then
												table.insert(formatted,
													string.format(
														"      Expected: %s",
														result.expected))
											end

											if result.actual and result.actual ~= "" then
												table.insert(formatted,
													string.format(
														"      Actual:   %s",
														result.actual))
											end

											table.insert(formatted, "")
										end
									end
								end

								if passed_count > 0 and failed_count == 0 then
									table.insert(formatted, "✓ ALL TESTS PASSED!")
									table.insert(formatted,
										"═══════════════════════════════════════════════════════════════════════════")
									table.insert(formatted,
										string.format(
											"🎉 All %d tests passed successfully!",
											passed_count))
									table.insert(formatted, "")
								end

								-- Add separator before raw output
								table.insert(formatted, "")
								table.insert(formatted,
									"═══════════════════════════════════════════════════════════════════════════")
								table.insert(formatted,
									"                            RAW TEST OUTPUT                                ")
								table.insert(formatted,
									"═══════════════════════════════════════════════════════════════════════════")
								table.insert(formatted, "")

								-- Add raw output
								for _, line in ipairs(output) do
									table.insert(formatted, line)
								end

								return formatted
							end

							local formatted_output = format_test_results(test_output)

							-- Save formatted output to file
							local f = io.open(output_file, 'w')
							if f then
								for _, line in ipairs(formatted_output) do
									f:write(line .. '\n')
								end
								f:close()

								vim.g.test_output_file = output_file

								-- Open the output in a buffer
								vim.schedule(function()
									vim.cmd('edit ' .. output_file)
									vim.cmd('setlocal filetype=testresult')
									vim.cmd('setlocal nowrap')

									if failed_count > 0 then
										vim.notify(
											string.format(
												"✗ Tests completed: %d passed, %d failed - see %s",
												passed_count,
												failed_count,
												output_file),
											vim.log.levels
											.WARN)
									else
										vim.notify(
											string.format(
												"✓ All %d tests passed! - see %s",
												passed_count, output_file),
											vim.log.levels.INFO)
									end
								end)
							end
						end
					})

					-- Function to find testhost process
					local function find_testhost_pid()
						local output = vim.fn.systemlist("pgrep -f 'testhost'")
						if #output > 0 then
							return tonumber(output[1])
						end
						return nil
					end

					-- Poll for testhost process with timeout
					local start_time = os.time()
					local timeout = 30

					local function check_for_process()
						local pid = find_testhost_pid()
						if pid then
							vim.notify("Found testhost process with PID: " .. pid,
								vim.log.levels.INFO)
							coroutine.resume(co, pid)
							return true
						end

						if os.time() - start_time > timeout then
							vim.notify("Timeout waiting for testhost process",
								vim.log.levels.ERROR)
							coroutine.resume(co, nil)
							return true
						end

						vim.defer_fn(check_for_process, 500)
						return false
					end

					vim.defer_fn(check_for_process, 1000)
				end)
			end)

			return coroutine.yield()
		end,

		args = function()
			return {}
		end,
		cwd = '${workspaceFolder}',
		stopAtEntry = false,
		env = {
			VSTEST_HOST_DEBUG = "1",
		},
	},

	{
		type = "coreclr",
		name = "attach - netcoredbg",
		request = "attach",
		processId = require('dap.utils').pick_process,
	},
}

-- Zig configurations
dap.adapters.lldb = {
	type = 'executable',
	command = '/usr/sbin/lldb-dap',
	name = 'lldb'
}

dap.configurations.zig = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			local co = coroutine.running()

			vim.notify('Building with ReleaseFast...', vim.log.levels.INFO)

			vim.system({ 'zig', 'build', '-Doptimize=ReleaseFast' }, {
				cwd = vim.fn.getcwd(),
				text = true,
			}, function(result)
				vim.schedule(function()
					if result.code ~= 0 then
						vim.notify('Build failed: ' .. (result.stderr or ''),
							vim.log.levels.ERROR)
						coroutine.resume(co, nil)
						return
					end

					vim.notify('Build successful!', vim.log.levels.INFO)
					local bin_path = vim.fn.getcwd() .. '/zig-out/bin/'

					if vim.fn.isdirectory(bin_path) == 0 then
						vim.notify('zig-out/bin directory not found.', vim.log.levels.ERROR)
						coroutine.resume(co, nil)
						return
					end

					local executables = vim.fn.readdir(bin_path, function(item)
						local full_path = bin_path .. item
						return vim.fn.executable(full_path) == 1
					end)

					if #executables == 0 then
						vim.notify('No executables found in zig-out/bin/', vim.log.levels.WARN)
						coroutine.resume(co, nil)
						return
					end

					if #executables == 1 then
						vim.notify('Launching: ' .. executables[1], vim.log.levels.INFO)
						coroutine.resume(co, bin_path .. executables[1])
						return
					end

					vim.ui.select(executables, {
						prompt = 'Select executable to debug:',
					}, function(choice)
						if choice then
							coroutine.resume(co, bin_path .. choice)
						else
							coroutine.resume(co, nil)
						end
					end)
				end)
			end)

			return coroutine.yield()
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
	{
		name = "Debug Test",
		type = "lldb",
		request = "launch",
		program = function()
			local co = coroutine.running()

			vim.notify('Building tests with ReleaseFast...', vim.log.levels.INFO)

			vim.system({ 'zig', 'build', 'test', '-Doptimize=ReleaseFast' }, {
				cwd = vim.fn.getcwd(),
				text = true,
			}, function(result)
				vim.schedule(function()
					if result.code ~= 0 then
						vim.notify('Build failed: ' .. (result.stderr or ''),
							vim.log.levels.ERROR)
						coroutine.resume(co, nil)
						return
					end

					vim.notify('Build successful!', vim.log.levels.INFO)
					local test_exe = vim.fn.getcwd() .. '/zig-out/bin/test'

					if vim.fn.filereadable(test_exe) == 0 then
						vim.notify('Test executable not found at: ' .. test_exe,
							vim.log.levels.ERROR)
						coroutine.resume(co, nil)
						return
					end

					vim.notify('Test executable ready!', vim.log.levels.INFO)
					coroutine.resume(co, test_exe)
				end)
			end)

			return coroutine.yield()
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}

-- Enable detailed DAP logging first
require('dap').set_log_level('TRACE')

dap.adapters.delve = {
	type = 'server',
	port = '${port}',
	executable = {
		command = 'dlv',
		args = { 'dap', '-l', '127.0.0.1:${port}' },
	},
	options = {
		initialize_timeout_sec = 20,
	}
}

-- Helper: auto-find main.go (interactive picker for multiple matches).
-- Returns the chosen main.go path. Falls back to the current buffer
-- when nothing is found or the user cancels.
-- Used by both "Debug main (auto-find)" and "Debug main (auto-find) with arguments".
local function find_main_go()
	local cmd = 'find ' ..
	    vim.fn.shellescape(vim.fn.getcwd()) .. ' -name "main.go" -type f 2>/dev/null | head -10'
	local handle = io.popen(cmd)

	if not handle then
		vim.notify("Failed to search for main.go", vim.log.levels.ERROR)
		return vim.fn.expand("%:p")
	end

	local result = handle:read("*a")
	handle:close()

	local files = {}
	for file in result:gmatch("[^\n]+") do
		table.insert(files, file)
	end

	if #files == 0 then
		vim.notify("No main.go found, using current file", vim.log.levels.WARN)
		return vim.fn.expand("%:p")
	elseif #files == 1 then
		vim.notify("Debugging: " .. files[1], vim.log.levels.INFO)
		return files[1]
	else
		print("Multiple main.go files found:")
		for i, file in ipairs(files) do
			print(string.format("[%d] %s", i, file))
		end
		local choice = vim.fn.input('Select file (1-' .. #files .. '): ')
		local idx = tonumber(choice)
		if idx and files[idx] then
			vim.notify("Debugging: " .. files[idx], vim.log.levels.INFO)
			return files[idx]
		else
			vim.notify("Invalid choice, using first file", vim.log.levels.WARN)
			return files[1]
		end
	end
end

-- Helper: find the Go test function at cursor (or above cursor).
-- Walks upward from the cursor to the nearest `func Xxx(...)` declaration.
-- Returns the function name (e.g. "TestFoo") if a test-like function
-- (Test*, Benchmark*, Fuzz*, Example*) is found, otherwise nil.
-- Warns the user when the buffer/file/function isn't suitable so the
-- caller can decide whether to fall back to running the whole package.
local function find_go_test_at_cursor()
	local current_file = vim.fn.expand('%:p')
	if not current_file:match('_test%.go$') then
		vim.notify("Not in a _test.go file", vim.log.levels.WARN)
		return nil
	end

	local cursor_line = vim.fn.line('.')
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- Walk upward from cursor to find the enclosing func declaration.
	local func_name = nil
	for i = cursor_line, 1, -1 do
		local line = lines[i]
		local name = line:match('^func%s+([%w_]+)%s*%(')
		if name then
			func_name = name
			break
		end
	end

	if not func_name then
		vim.notify("No func found above cursor", vim.log.levels.WARN)
		return nil
	end

	-- Only return test-like functions (Test, Benchmark, Fuzz, Example).
	-- Plain helpers like `func setupTest()` are excluded intentionally.
	if func_name:match('^Test')
	   or func_name:match('^Benchmark')
	   or func_name:match('^Fuzz')
	   or func_name:match('^Example') then
		return func_name
	end

	vim.notify("Function '" .. func_name .. "' is not a test function",
		vim.log.levels.WARN)
	return nil
end

-- Captured by the args() function of "test - delve current line function"
-- so the post-session `go test -v` job (see listener below) knows which
-- test to run and which package directory to use. Lives at module scope
-- so the args() closure (defined further down) can write to it and the
-- event_terminated listener can read it.
local current_test_run = nil

dap.configurations.go = {
	{
		type = "delve",
		name = "Attach to Process",
		mode = "local",
		request = "attach",
		processId = require('dap.utils').pick_process,
	},
	{
		type = "delve",
		name = "Debug with arguments",
		request = "launch",
		program = "${file}",
		args = function()
			local args_string = vim.fn.input('Arguments: ')
			return vim.split(args_string, " +")
		end,
	},
	{
		type = "delve",
		name = "Debug main (auto-find)",
		request = "launch",
		program = find_main_go,
	},
	{
		type = "delve",
		name = "Debug main (auto-find) with arguments",
		request = "launch",
		program = find_main_go,
		args = function()
			local args_string = vim.fn.input('Arguments: ')
			return vim.split(args_string, " +")
		end,
	},
	{
		type = "delve",
		name = "Debug main (specify directory)",
		request = "launch",
		program = "${workspaceFolder}/backend_go/cmd/agent-bond",
		cwd = "${workspaceFolder}/backend_go",
	},
	{
		type = "delve",
		name = "test - delve current line function",
		request = "launch",
		mode = "test",
		-- IMPORTANT: use ${fileDirname} (the package directory), NOT
		-- ${file} (the single test file). When go test -c is given a
		-- single file, Go compiles it as the synthetic
		-- "command-line-arguments" package and CANNOT see symbols
		-- defined in sibling files in the same directory (e.g. shared
		-- mocks, fixtures, helpers like `mockSqlDb` or `validChargeCodes`
		-- that live in a sibling *_test.go file). Passing the directory
		-- tells go test -c to compile the whole package, so every
		-- helper is available, then -test.run narrows execution to
		-- just the function at the cursor.
		program = "${fileDirname}",
		args = function()
			local func_name = find_go_test_at_cursor()
			if not func_name then
				-- Fallback: run all tests in the package (Delve behaviour
				-- when -test.run is omitted).
				return {}
			end
			vim.notify("Running test: " .. func_name, vim.log.levels.INFO)
			-- Capture for the post-session `go test -v` job (see the
			-- flush_test_output listener below) that writes the verbose
			-- test result to ./test-output.log. Captured here because
			-- args() is the only place where we know both the test
			-- function name AND the package directory at launch time.
			current_test_run = {
				func_name = func_name,
				package_dir = vim.fn.expand('%:p:h'),
			}
			-- -test.run "^TestXxx$" matches ONLY this function (anchored
			-- with ^/$). -test.v gives us per-test verbose output.
			return { "-test.run", "^" .. func_name .. "$", "-test.v" }
		end,
	},
}

-- Better error handling
dap.listeners.after['event_initialized']['my_config'] = function()
	vim.notify("DAP initialized successfully", vim.log.levels.INFO)
end

dap.listeners.after['event_terminated']['my_config'] = function()
	vim.notify("Debug session terminated", vim.log.levels.INFO)
end

dap.listeners.after['event_exited']['my_config'] = function(session, body)
	if body and body.exitCode and body.exitCode ~= 0 then
		vim.notify("Debug exited with code: " .. body.exitCode, vim.log.levels.ERROR)
	end
end

-- Add command to view DAP logs
vim.api.nvim_create_user_command('DapLog', function()
	local log_path = vim.fn.stdpath('cache') .. '/dap.log'
	vim.cmd('edit ' .. log_path)
end, {})

-- Capture test output for "test - delve current line function".
-- Mirrors the C# netcoredbg version's UX (test-output.log auto-opened
-- in a buffer): when the Delve debug session ends, run `go test -v`
-- as a SEPARATE job against the same test/package, capture its
-- output, and write it to ./test-output.log so the user can read the
-- final result (=== RUN / --- PASS / --- FAIL / t.Log* lines).
--
-- Why run a separate `go test -v` instead of listening to nvim-dap's
-- event_output events? Because Delve only forwards its own REPL banner
-- as output events while the test binary is paused at a breakpoint —
-- the test binary's stdout (which is what `go test -v` produces) is
-- NOT reliably forwarded during interactive debugging. Running
-- `go test -v` ourselves once the debug session is over guarantees we
-- always get the final result, regardless of how the user stepped.
--
-- current_test_run (declared above) is populated by the args() function
-- in dap.configurations.go — that's the only point where we know both
-- the test function name AND the package directory at launch time.
local function capture_test_output(run)
	local func_name = run.func_name
	local package_dir = run.package_dir

	-- Build: go test -v -run '^FuncName$' .
	-- `.` means "the current package" (combined with cwd=package_dir).
	-- -v gives verbose output with === RUN / --- PASS / --- FAIL lines.
	local cmd = { 'go', 'test', '-v' }
	if func_name and func_name ~= '' then
		table.insert(cmd, '-run')
		table.insert(cmd, '^' .. func_name .. '$')
	end
	table.insert(cmd, '.')

	local output_file = vim.fn.getcwd() .. '/test-output.log'
	local lines = {}  -- accumulated by on_stdout / on_stderr; used by on_exit
	vim.fn.jobstart(cmd, {
		cwd = package_dir,
		stdout_buffered = false,
		stderr_buffered = false,
		-- `data` is a list[str] (one chunk per read cycle). Empty strings
		-- are inserted by Neovim as separators; we filter them so the
		-- file isn't padded with blank lines.
		on_stdout = function(_, data)
			for _, line in ipairs(data) do
				if line ~= '' then
					table.insert(lines, line)
				end
			end
		end,
		on_stderr = function(_, data)
			for _, line in ipairs(data) do
				if line ~= '' then
					table.insert(lines, line)
				end
			end
		end,
		on_exit = function(_, code)
			local f = io.open(output_file, 'w')
			if f then
				for _, line in ipairs(lines) do
					f:write(line)
					f:write('\n')
				end
				f:close()
				vim.g.test_output_file = output_file
				vim.schedule(function()
					vim.cmd('edit ' .. output_file)
				end)
			end
			-- Surface a quick PASS/FAIL/WARN notify too, mirroring the
			-- C# version's "Test process exited with code: N" pattern.
			vim.schedule(function()
				vim.notify(
					string.format('Test %s: exit code %d (output: %s)',
						func_name or '<unknown>', code, output_file),
					code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
			end)
		end,
	})
end

dap.listeners.after['event_terminated']['flush_test_output'] = function(session, _)
	if not session.config or session.config.name ~= 'test - delve current line function' then
		return
	end
	if not current_test_run then return end
	local run = current_test_run
	current_test_run = nil  -- consume so a subsequent session starts fresh
	capture_test_output(run)
end

-- Add command to test if delve works
vim.api.nvim_create_user_command('DapTestDelve', function()
	local main_file = '/home/ginwa/personal2/agent_bond/backend_go/cmd/agent-bond/main.go'
	vim.notify("Testing delve with: " .. main_file, vim.log.levels.INFO)

	-- Test if file exists and has main function
	local f = io.open(main_file, "r")
	if not f then
		vim.notify("File not found: " .. main_file, vim.log.levels.ERROR)
		return
	end

	local content = f:read("*a")
	f:close()

	if not content:match("func main%(%)") then
		vim.notify("No main() function found in file", vim.log.levels.ERROR)
		return
	end

	vim.notify("File looks good, trying to compile...", vim.log.levels.INFO)

	-- Try to build it
	local dir = vim.fn.fnamemodify(main_file, ':h')
	local cmd = string.format('cd %s && go build -o /tmp/test_build 2>&1', vim.fn.shellescape(dir))
	local result = vim.fn.system(cmd)

	if vim.v.shell_error == 0 then
		vim.notify("Build successful! ✓", vim.log.levels.INFO)
	else
		vim.notify("Build failed:\n" .. result, vim.log.levels.ERROR)
	end
end, {})

local signs = {
	DapBreakpoint = {
		text = '●',
		texthl = 'DapBreakpoint',
		linehl = 'DapBreakpointLine',
		numhl = 'DapBreakpoint'
	},
	DapBreakpointCondition = {
		text = '◆',
		texthl = 'DapBreakpointCondition',
		linehl = 'DapBreakpointLine',
		numhl = 'DapBreakpointCondition'
	},
	DapBreakpointRejected = {
		text = '○',
		texthl = 'DapBreakpointRejected',
		linehl = '',
		numhl = ''
	},
	DapStopped = {
		text = '▶',
		texthl = 'DapStopped',
		linehl = 'DapStoppedLine',
		numhl = 'DapStopped'
	},
	DapLogPoint = {
		text = '◉',
		texthl = 'DapLogPoint',
		linehl = '',
		numhl = 'DapLogPoint'
	}
}

-- Apply sign definitions
for sign_name, sign_config in pairs(signs) do
	vim.fn.sign_define(sign_name, sign_config)
end

-- Enhanced color highlights with better contrast and visual hierarchy
local highlights = {
	DapBreakpoint = { fg = '#e51400', bold = true },
	DapBreakpointCondition = { fg = '#f0c674', bold = true },
	DapBreakpointRejected = { fg = '#5c6370', italic = true },
	DapStopped = { fg = '#98c379', bold = true },
	DapLogPoint = { fg = '#61afef', bold = true },

	-- Line highlights for better context visibility
	DapBreakpointLine = { bg = '#3d1f1f' },
	DapStoppedLine = { bg = '#2b3d2b' }
}

for hl_group, hl_config in pairs(highlights) do
	vim.api.nvim_set_hl(0, hl_group, hl_config)
end

require("nvim-dap-virtual-text").setup()

-- Command to view test output
vim.api.nvim_create_user_command('ViewTestOutput', function()
	local output_file = vim.g.test_output_file or (vim.fn.getcwd() .. '/test-output.log')

	if vim.fn.filereadable(output_file) == 1 then
		vim.cmd('edit ' .. output_file)
	else
		vim.notify("No test output file found", vim.log.levels.WARN)
	end
end, {})

-- Keybinding to view test output (use '<leader>go' = 'go' for 'go output')
vim.keymap.set('n', '<leader>go', function()
	if vim.g.test_output_file then
		vim.cmd('edit ' .. vim.g.test_output_file)
	else
		vim.notify("No test output available yet", vim.log.levels.INFO)
	end
end, { desc = 'View test output' })
