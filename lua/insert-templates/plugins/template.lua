return {
  "nvimdev/template.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("template").setup({
      temp_dir = vim.fn.expand("~/.config/nvim/templates"),
      author = "Harmeet Singh",
      email = "harmeetsalech@gmail.com",
    })

    require("telescope").load_extension("find_template")

    -- Keymap: pick template and insert into current buffer.
    -- Auto-sets the buffer's filetype to match the chosen template so that
    -- template.nvim's get_tpl() (which filters by buffer filetype) succeeds
    -- even in scratch buffers or buffers with a mismatched filetype.
    vim.keymap.set("n", "<leader>tt", function()
      local target_buf = vim.api.nvim_get_current_buf()
      local target_win = vim.api.nvim_get_current_win()

      if not vim.bo[target_buf].modifiable or vim.bo[target_buf].readonly or vim.bo[target_buf].buftype ~= "" then
        vim.notify("[template] Current buffer is not modifiable; nothing to insert into.", vim.log.levels.WARN)
        return
      end

      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local make_entry = require("telescope.make_entry")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local temp = require("template")

      local results = {}
      for _, files in pairs(temp.get_temp_list()) do
        vim.list_extend(results, files)
      end

      pickers
        .new({}, {
          prompt_title = "Insert Template",
          results_title = "templates",
          finder = finders.new_table({
            results = results,
            entry_maker = make_entry.gen_from_file({}),
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.file_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              if not entry then
                return
              end

              -- Make sure the captured buffer/window are still alive,
              -- then route the :Template command at them explicitly.
              if not vim.api.nvim_buf_is_valid(target_buf) or not vim.api.nvim_win_is_valid(target_win) then
                vim.notify("[template] Target buffer/window no longer valid.", vim.log.levels.WARN)
                return
              end

              vim.api.nvim_set_current_win(target_win)

              local path = entry.path or entry[1]
              local ft = vim.filetype.match({ filename = path })
              if ft and vim.bo[target_buf].filetype ~= ft then
                vim.bo[target_buf].filetype = ft
              end

              local tmp_name = vim.fn.fnamemodify(path, ":t:r")
              vim.cmd("Template " .. tmp_name)
            end)
            return true
          end,
        })
        :find()
    end, { desc = "Insert template" })
  end,
}
