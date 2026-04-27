# insert-templates.nvim

Telescope-driven template inserter for Neovim. Pick a template, insert it into the current buffer.

## Requirements

- Neovim >= 0.10
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [template.nvim](https://github.com/nvimdev/template.nvim)

## Install (lazy.nvim)

Add to a file in `~/.config/nvim/lua/plugins/` (e.g. `insert-templates.lua`):

```lua
return {
  {
    "hrmeetsingh/insert-templates.nvim",
    dependencies = {
      "nvimdev/template.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
  { import = "insert-templates.plugins" },
}
```

- The first entry fetches the plugin and its dependencies
- The `import` line tells lazy.nvim to load the bundled plugin spec that registers the keymap

## Templates directory

- Default = `~/.config/nvim/templates`
- Sample templates ship under `templates/` in this repo
- To use shipped samples:

```sh
mkdir -p ~/.config/nvim/templates
cp ~/.local/share/nvim/lazy/insert-templates.nvim/templates/* ~/.config/nvim/templates/
```

## Keymap

- `<leader>tt` — open Telescope picker listing all templates
- Select a template — buffer filetype auto-set to match, template text inserted at cursor
- Non-modifiable buffers (help, terminal, etc.) are rejected with a warning

## Creating a new template from the picker

Type a filename (including extension, e.g. `react_comp.tsx`) into the Telescope prompt. If no
existing template matches, pressing `<CR>` creates the file in your templates directory and opens
it for editing in a vertical split. Save with `:w` as normal.

If a file with that name already exists, a prompt asks whether to **Overwrite**, **Open**, or
**Cancel**.

Filenames containing `/` or `..` are rejected to prevent writing outside the templates directory.

## Customize

Override `author` and `email` by creating your own spec file (e.g. `~/.config/nvim/lua/plugins/template-config.lua`):

```lua
return {
  "nvimdev/template.nvim",
  opts = {
    temp_dir = vim.fn.expand("~/.config/nvim/templates"),
    author = "Your Name",
    email = "you@example.com",
  },
}
```

## Template variables

Supported by `template.nvim`:

- `{{_date_}}` — current date/time
- `{{_file_name_}}` — buffer filename (no extension)
- `{{_upper_file_}}` — uppercase filename
- `{{_camel_file_}}` — CamelCase filename
- `{{_author_}}` — author from setup
- `{{_email_}}` — email from setup
- `{{_cursor_}}` — cursor position after insert
- `{{_variable_}}` — prompts for input
- `{{_tomorrow_}}` — tomorrow's date
- `{{_lua:expr_}}` — evaluate arbitrary Lua expression

## Running tests

Requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) installed (e.g. via lazy.nvim).

```sh
make test
```

Tests live in `tests/insert-templates/create_spec.lua` and use plenary's busted runner.

## Architecture

```
lua/insert-templates/
  plugins/template.lua   — lazy spec, Telescope picker, keymap
  create.lua             — validate_filename, open_new_template (testable in isolation)

tests/
  minimal_init.lua       — headless bootstrap (adds plugin + plenary to rtp)
  insert-templates/
    create_spec.lua      — plenary busted specs for create.lua
```

`template.lua` owns the picker and delegates all create-template logic to `create.lua`.
`create.lua` has no Telescope dependency, making it straightforward to test headlessly.

## License

MIT
