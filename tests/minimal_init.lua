-- Minimal init for headless plenary test runs.
-- Usage: nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

local data_path = vim.fn.stdpath("data")

-- Add plenary to rtp so tests can require it.
-- Assumes plenary is installed at one of the standard lazy/packer paths.
local plenary_paths = {
	data_path .. "/lazy/plenary.nvim",
	data_path .. "/site/pack/packer/start/plenary.nvim",
}

for _, p in ipairs(plenary_paths) do
	if vim.fn.isdirectory(p) == 1 then
		vim.opt.rtp:prepend(p)
		break
	end
end

-- Add this plugin itself.
vim.opt.rtp:prepend(vim.fn.getcwd())
