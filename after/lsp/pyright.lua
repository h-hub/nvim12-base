
local function set_python_path(opts)
  local path = opts.args
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "pyright" })

  for _, client in ipairs(clients) do
    client.config.settings = client.config.settings or {}
    client.config.settings.python = client.config.settings.python or {}
    client.config.settings.python.pythonPath = path

  client:notify("workspace/didChangeConfiguration", {
        settings = client.config.settings,
      })
    end
end

return {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
	settings = {
		python = {
      pythonPath=".venv/bin/python",
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
			},
		},
	},
	on_attach = function(client, bufnr)
		vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
			client:exec_cmd({
				command = "pyright.organizeimports",
				arguments = { vim.uri_from_bufnr(bufnr) },
			})
		end, {
			desc = "Organize Imports",
		})
		vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
			desc = "Reconfigure pyright with the provided python path",
			nargs = 1,
			complete = "file",
		})
	end,
}
