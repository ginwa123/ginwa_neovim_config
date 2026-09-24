-- Gitsigns
--
-- Besides signs/hunks this shows inline blame (`current_line_blame = true`).
-- gitsigns has no `<branch>` placeholder, so the formatter below is a function:
-- it resolves `sha -> branch` with git (cached, once per commit) and puts the
-- branch of the *blamed commit* in front of the usual blame text.
--
-- The *closest* branch wins. A merged commit is "contained" by every branch
-- that has it, so a long-lived `staging`/`main` usually shows up as well -
-- those tips are just far ahead. `git name-rev` picks the branch the commit
-- actually lives on instead, e.g. `feat/checkout` and not `staging`.

local api = vim.api

-- sha -> branch name ('' when the commit is on no branch/ref).
local branch_cache = {}

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

---@class BlameBranch
---@field ref string full ref name, usable with `name-rev --refs=`
---@field name string short name, for display

--- Branches that contain `sha`, local first, remotes only if there is none.
---@param sha string
---@param cwd string
---@return BlameBranch[]
local function branches_containing(sha, cwd)
	---@param pattern string
	---@return BlameBranch[]
	local function collect(pattern)
		local out = git({
			'git', 'for-each-ref',
			'--format=%(refname)',
			'--contains', sha,
			pattern,
		}, cwd)
		if not out or vim.trim(out) == '' then
			return {}
		end

		local branches = {}
		for _, ref in ipairs(vim.split(out, '\n', { trimempty = true })) do
			branches[#branches + 1] = {
				ref = ref,
				name = ref:gsub('^refs/heads/', ''):gsub('^refs/remotes/', ''),
			}
		end
		return branches
	end

	local branches = collect('refs/heads')
	if #branches > 0 then
		return branches
	end
	-- local branch deleted / only fetched copies still have the commit
	return collect('refs/remotes')
end

--- Branch the commit belongs to: the closest one containing it.
---@param sha string
---@param cwd string
---@return string
local function branch_label(sha, cwd)
	local cached = branch_cache[sha]
	if cached then
		return cached
	end

	local label = ''
	local branches = branches_containing(sha, cwd)

	if #branches > 0 then
		-- Of the containing branches, name-rev returns the nearest tip, e.g.
		-- `feat/checkout~1`. The ~N is the distance to the branch tip; branch
		-- names cannot contain ~ or ^, so the plain name is the prefix.
		local args = { 'git', 'name-rev', '--name-only', '--no-undefined' }
		for _, branch in ipairs(branches) do
			args[#args + 1] = '--refs=' .. branch.ref
		end
		args[#args + 1] = sha

		local out = git(args, cwd)
		local closest = out and vim.trim(out) or ''
		label = closest:match('^[^~^]+') or branches[1].name
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
		-- gitsigns internals moved: degrade to a plain message
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
