-- insert-templates/create.lua
-- Isolated logic for creating a new template file from the picker.
-- All public functions return (ok, err) so they are easily unit-testable.

local M = {}

-- validate_filename returns (true, nil) when `name` is a non-empty string
-- that contains at least one dot with a non-empty extension segment and
-- contains no path separators or traversal sequences.
function M.validate_filename(name)
	if not name or name == "" then
		return false, "filename is empty"
	end
	if name:find("/") or name:find("%.%.") then
		return false, "filename must not contain '/' or '..'"
	end
	local ext = name:match("%.([^%.]+)$")
	if not ext or ext == "" then
		return false, "filename has no extension (e.g. use 'my_template.lua')"
	end
	return true, nil
end

-- open_new_template handles the full create-or-conflict flow:
--   1. validate filename
--   2. if file exists → vim.ui.select (Overwrite / Open / Cancel)
--   3. if new → write empty file
--   4. open in vertical split
--
-- `filename` – basename with extension, e.g. "react_comp.tsx"
-- `temp_dir` – absolute path to the templates directory
--
-- Returns (true, nil) on success or (false, err_string) on validation failure.
-- The conflict prompt is async (vim.ui.select), so callers should not expect
-- the buffer to be open synchronously when a conflict is resolved.
function M.open_new_template(filename, temp_dir)
	local ok, err = M.validate_filename(filename)
	if not ok then
		return false, err
	end

	local path = temp_dir .. "/" .. filename

	if vim.fn.filereadable(path) == 1 then
		vim.ui.select({ "Overwrite", "Open", "Cancel" }, {
			prompt = "'" .. filename .. "' already exists:",
		}, function(choice)
			if choice == "Overwrite" then
				vim.fn.writefile({}, path)
				vim.cmd("vsplit " .. vim.fn.fnameescape(path))
			elseif choice == "Open" then
				vim.cmd("vsplit " .. vim.fn.fnameescape(path))
			end
			-- Cancel: do nothing
		end)
		return true, nil
	end

	-- New file: touch it so it exists on disk before opening.
	local write_ok = vim.fn.writefile({}, path)
	if write_ok ~= 0 then
		return false, "could not create file: " .. path
	end

	vim.cmd("vsplit " .. vim.fn.fnameescape(path))
	return true, nil
end

return M
