-- Tests for lua/insert-templates/create.lua
-- Run with: make test

local create = require("insert-templates.create")

-- Helpers -------------------------------------------------------------------

local function tmp_dir()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	return dir
end

local function file_exists(path)
	return vim.fn.filereadable(path) == 1
end

-- t1: valid new name → file created at temp_dir, buffer opened in vsplit ----

describe("create.open_new_template", function()
	it("t1: creates file and opens vsplit for a valid new filename", function()
		local dir = tmp_dir()
		local filename = "my_comp.tsx"
		local expected_path = dir .. "/" .. filename

		-- Track vsplit calls
		local opened_path = nil
		local orig_cmd = vim.cmd
		vim.cmd = function(cmd)
			if type(cmd) == "string" then
				local p = cmd:match("^vsplit%s+(.+)$")
				if p then
					opened_path = p
					return
				end
			end
			orig_cmd(cmd)
		end

		local ok, err = create.open_new_template(filename, dir)

		vim.cmd = orig_cmd

		assert.is_true(ok, err)
		assert.is_true(file_exists(expected_path), "file should exist at " .. expected_path)
		assert.equals(expected_path, opened_path)
	end)

	-- t2: invalid filename (no extension) → returns error, no file created ----

	it("t2: returns error for filename without extension", function()
		local dir = tmp_dir()
		local ok, err = create.open_new_template("noextension", dir)

		assert.is_false(ok)
		assert.is_not_nil(err)
		-- No file should have been created
		assert.equals(0, vim.fn.filereadable(dir .. "/noextension"))
	end)

	it("t2b: returns error for empty filename", function()
		local dir = tmp_dir()
		local ok, err = create.open_new_template("", dir)

		assert.is_false(ok)
		assert.is_not_nil(err)
	end)

	-- t3: existing file → calls vim.ui.select with correct items --------------

	it("t3: existing file triggers vim.ui.select with Overwrite/Open/Cancel", function()
		local dir = tmp_dir()
		local filename = "existing.lua"
		local path = dir .. "/" .. filename
		vim.fn.writefile({ "-- existing" }, path)

		local select_items = nil
		local orig_select = vim.ui.select
		vim.ui.select = function(items, opts, cb)
			select_items = items
			-- simulate user choosing Cancel to avoid side effects
			cb(nil, nil)
		end

		create.open_new_template(filename, dir)

		vim.ui.select = orig_select

		assert.is_not_nil(select_items)
		assert.truthy(vim.tbl_contains(select_items, "Overwrite"))
		assert.truthy(vim.tbl_contains(select_items, "Open"))
		assert.truthy(vim.tbl_contains(select_items, "Cancel"))
	end)

	-- t4: buffer path after vsplit equals temp_dir/<name> --------------------

	it("t4: path passed to vsplit matches temp_dir/filename", function()
		local dir = tmp_dir()
		local filename = "service.go"
		local expected_path = dir .. "/" .. filename

		local vsplit_path = nil
		local orig_cmd = vim.cmd
		vim.cmd = function(cmd)
			if type(cmd) == "string" then
				local p = cmd:match("^vsplit%s+(.+)$")
				if p then
					vsplit_path = p
					return
				end
			end
			orig_cmd(cmd)
		end

		create.open_new_template(filename, dir)

		vim.cmd = orig_cmd

		assert.equals(expected_path, vsplit_path)
	end)
end)

-- t5: validate_filename utility (used by picker integration) ----------------

describe("create.validate_filename", function()
	it("t5a: accepts filename with extension", function()
		local ok, err = create.validate_filename("react_comp.tsx")
		assert.is_true(ok)
		assert.is_nil(err)
	end)

	it("t5b: rejects empty string", function()
		local ok, err = create.validate_filename("")
		assert.is_false(ok)
		assert.is_not_nil(err)
	end)

	it("t5c: rejects filename with no dot / no extension", function()
		local ok, err = create.validate_filename("noext")
		assert.is_false(ok)
		assert.is_not_nil(err)
	end)

	it("t5d: rejects filename ending with a dot (empty extension)", function()
		local ok, err = create.validate_filename("file.")
		assert.is_false(ok)
		assert.is_not_nil(err)
	end)

	it("t5e: rejects filename containing a path separator", function()
		local ok, err = create.validate_filename("subdir/evil.lua")
		assert.is_false(ok)
		assert.is_not_nil(err)
	end)

	it("t5f: rejects filename containing path traversal (..)", function()
		local ok, err = create.validate_filename("../../../etc/passwd")
		assert.is_false(ok)
		assert.is_not_nil(err)
	end)
end)
