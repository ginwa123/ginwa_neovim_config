-- Gitsigns
--
-- Besides signs/hunks this shows inline blame (`current_line_blame = true`).
-- gitsigns has no `<branch>` placeholder, so the formatter below is a function:
-- it resolves `sha -> branch` with git (cached, one call per commit) and puts
-- the branch of the *blamed commit* in front of the usual blame text.

local api = vim.api

-- sha -> label ('main', 'main (+2)', ...). '' means "no branch found".
local branch_cache = {}
-- cwd -> current branch ('' when HEAD is detached)
local head_cache = {}

--- Run git synchronously. Returns nil on failure.
---@param args string[]
---@param cwd string
---@return string?
local function git(args, cwd)
	local ok, obj = pcall(function()
		return vim.system(args, { cwd = cwd, text = true }):wait(500)
	end)
	if not ok or type(obj) ~= 'table' or obj.code ~= 0 then
		return nil
	end
	return obj.stdout or ''
end

---@param cwd string
---@return string
local function current_branch(cwd)
	if head_cache[cwd] == nil then
		local out = git({ 'git', 'symbolic-ref', '--quiet', '--short', 'HEAD' }, cwd)
		head_cache[cwd] = out and vim.trim(out) or ''
	end
	return head_cache[cwd]
end

--- Branches that contain `sha`; current branch first, the rest as `(+N)`.
---@param sha string
---@param cwd string
---@return string
local function branch_label(sha, cwd)
	local cached = branch_cache[sha]
	if cached then
		return cached
	end

	---@param pattern string
	---@return string[]
	local function branches_containing(pattern)
		local out = git({
			'git', 'for-each-ref',
			'--sort=-committerdate',
			'--format=%(refname:short)',
			'--contains', sha,
			pattern,
		}, cwd)
		if not out or vim.trim(out) == '' then
			return {}
		end
		return vim.split(out, '\n', { trimempty = true })
	end

	local names = branches_containing('refs/heads')
	if #names == 0 then
		-- local branch was deleted / only fetched copies still have the commit
		names = branches_containing('refs/remotes')
	end

	local current = current_branch(cwd)
	if current ~= '' then
		for i, name in ipairs(names) do
			if name == current then
				table.remove(names, i)
				table.insert(names, 1, name)
				break
			end
		end
	end

	local label = ''
	if #names > 0 then
		label = names[1]
		if #names > 1 then
			label = ('%s (+%d)'):format(label, #names - 1)
		end
	end

	branch_cache[sha] = label
	return label
end

---@param name string Git user name from `git config user.name`.
---@param info table gitsigns blame info.
---@return table list of [text, highlight] chunks.
local function blame_with_branch(name, info)
	-- Same layout as the gitsigns default, so only the branch is new.
	local ok, text = pcall(function()
		return require('gitsigns.blame_formatter').expand_string(
			' <author>, <author_time:%R> - <summary> ',
			name,
			info,
			{ self_author_text = 'You' }
		)
	end)
	if not ok then
		-- gitsigns internals moved: degrade to a plain, unhighlighted message
		text = (' %s, %s - %s '):format(
			info.author or '?',
			info.author_time and os.date('%Y-%m-%d', info.author_time) or '?',
			info.summary or ''
		)
	end

	local chunks = {}

	local bufname = api.nvim_buf_get_name(0)
	local cwd = bufname ~= '' and vim.fs.dirname(bufname) or nil
	local label = info.sha and cwd and branch_label(info.sha, cwd) or ''
	if label ~= '' then
		chunks[#chunks + 1] = { (' [%s]'):format(label), 'GitSignsBlameBranch' }
	end

	chunks[#chunks + 1] = { text, 'GitSignsCurrentLineBlame' }
	return chunks
end

api.nvim_set_hl(0, 'GitSignsBlameBranch', { link = 'Directory', default = true })

local function clear_branch_cache()
	branch_cache = {}
	head_cache = {}
end

api.nvim_create_augroup('gitsigns_blame_branch', { clear = true })
api.nvim_create_autocmd({ 'BufWritePost', 'FocusGained' }, {
	group = 'gitsigns_blame_branch',
	desc = 'Clear branch cache used by the gitsigns inline blame',
	callback = clear_branch_cache,
})
api.nvim_create_user_command('BlameBranchRefresh', clear_branch_cache, {
	desc = 'Re-resolve branch names shown by the gitsigns inline blame',
})

-- Gitsigns
require('gitsigns').setup({
	-- signs = {
	-- 	add          = { text = '+' },
	-- 	change       = { text = '~' },
	-- 	delete       = { text = '_' },
	-- 	topdelete    = { text = '‾' },
	-- 	changedelete = { text = '~' },
	-- },
	current_line_blame = true, -- Set to true to show blame inline
	current_line_blame_formatter = blame_with_branch,
	current_line_blame_opts = {
		-- ignore_whitespace = true, -- This option specifically enables ignoring whitespace for current line blame
	},
})
