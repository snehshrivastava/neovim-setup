-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
	-- NOTE: Yes, you can install new plugins here!
	"mfussenegger/nvim-dap",
	-- NOTE: And you can specify dependencies as well
	dependencies = {
		-- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",
		{
			"williamboman/mason.nvim",
			opts = { ensure_installed = { "java-debug-adapter", "java-test", "js-debug-adapter" } },
		},
        {
            "mfussenegger/nvim-dap",
            optional = true,
            opts = function()
              -- Simple configuration to attach to remote java debug process
              -- Taken directly from https://github.com/mfussenegger/nvim-dap/wiki/Java
              local dap = require("dap")
              dap.configurations.java = {
                {
                  type = "java",
                  request = "attach",
                  name = "Debug (Attach) - Remote",
                  hostName = "127.0.0.1",
                  port = 5005,
                },
              }
            end,
            dependencies = {
              {
                "williamboman/mason.nvim",
                opts = { ensure_installed = { "java-debug-adapter", "java-test" } },
              },
            },
          },

		-- Required dependency for nvim-dap-ui
		"nvim-neotest/nvim-nio",

		-- Installs the debug adapters for you
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- Add your own debuggers here
		"leoluz/nvim-dap-go",
	},
	keys = {
		-- Basic debugging keymaps, feel free to change to your liking!
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Debug: Start/Continue",
		},
		{
			"<F1>",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: Step Into",
		},
		{
			"<F2>",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: Step Over",
		},
		{
			"<F3>",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: Step Out",
		},
		{
			"<leader>b",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Debug: Toggle Breakpoint",
		},
		{
			"<leader>B",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Debug: Set Breakpoint",
		},
		-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
		{
			"<F7>",
			function()
				require("dapui").toggle()
			end,
			desc = "Debug: See last session result.",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		-- -----------------------------------

        dap.adapters.java = function(callback)
            vim.lsp.buf.execute_command({
                command = "vscode.java.startDebugSession"
            }) -- not sure how to get the port from this command
            callback({
                type = "server";
                host = "127.0.0.1";
                port = 5005;
            })
        end
          dap.configurations.java = {
            {
              type = 'java',
              name = 'Debug (Attach)',
              request = 'attach',
              hostName = '127.0.0.1',
              port = 5005,
            },
          }
       
        local custom_adapter = 'pwa-node-custom'
        dap.adapters[custom_adapter] = function(cb, config)
            if config.preLaunchTask then
                local async = require('plenary.async')
                local notify = require('notify').async

                async.run(function()
                    ---@diagnostic disable-next-line: missing-parameter
                    notify('Running [' .. config.preLaunchTask .. ']').events.close()
                end, function()
                    vim.fn.system(config.preLaunchTask)
                    config.type = 'pwa-node'
                    dap.run(config)
                end)
            end
        end

        -- language config
        for _, language in ipairs({ 'typescript', 'javascript' }) do
            dap.configurations[language] = {
                {
                    name = 'Launch',
                    type = 'pwa-node',
                    request = 'launch',
                    program = '${file}',
                    rootPath = '${workspaceFolder}',
                    cwd = '${workspaceFolder}',
                    sourceMaps = true,
                    skipFiles = { '<node_internals>/**' },
                    protocol = 'inspector',
                    console = 'integratedTerminal',
                },
                {
                    name = 'Attach to node process',
                    type = 'pwa-node',
                    request = 'attach',
                    rootPath = '${workspaceFolder}',
                    processId = require('dap.utils').pick_process,
                },
                {
                    name = 'Debug Main Process (Electron)',
                    type = 'pwa-node',
                    request = 'launch',
                    program = '${workspaceFolder}/node_modules/.bin/electron',
                    args = {
                        '${workspaceFolder}/dist/index.js',
                    },
                    outFiles = {
                        '${workspaceFolder}/dist/*.js',
                    },
                    resolveSourceMapLocations = {
                        '${workspaceFolder}/dist/**/*.js',
                        '${workspaceFolder}/dist/*.js',
                    },
                    rootPath = '${workspaceFolder}',
                    cwd = '${workspaceFolder}',
                    sourceMaps = true,
                    skipFiles = { '<node_internals>/**' },
                    protocol = 'inspector',
                    console = 'integratedTerminal',
                },
                {
                    name = 'Compile & Debug Main Process (Electron)',
                    type = custom_adapter,
                    request = 'launch',
                    preLaunchTask = 'npm run build-ts',
                    program = '${workspaceFolder}/node_modules/.bin/electron',
                    args = {
                        '${workspaceFolder}/dist/index.js',
                    },
                    outFiles = {
                        '${workspaceFolder}/dist/*.js',
                    },
                    resolveSourceMapLocations = {
                        '${workspaceFolder}/dist/**/*.js',
                        '${workspaceFolder}/dist/*.js',
                    },
                    rootPath = '${workspaceFolder}',
                    cwd = '${workspaceFolder}',
                    sourceMaps = true,
                    skipFiles = { '<node_internals>/**' },
                    protocol = 'inspector',
                    console = 'integratedTerminal',
                },
            }
        end

		---------------------------------

		-- Set up the Python adapter and configuration for nvim-dap
		dap.adapters.python = function(cb, config)
			if config.request == "attach" then
				local port = (config.connect or config).port
				cb({
					type = "server",
					port = assert(port, "`connect.port` is required for a python `attach` configuration"),
					host = (config.connect or config).host or "127.0.0.1",
				})
			else
				cb({
					type = "executable",
					command = "~/.virtualenvs/debugpy/bin/python",
					args = { "-m", "debugpy.adapter" },
				})
			end
		end

		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "FastAPI",
				module = "uvicorn",
				args = { "main:app", "-h", "0.0.0.0", "-p", "8002" },
				env = function()
					local variables = {
						PYTHONPATH = "/Users/pwd/Codes/makelele/src",
					}
					for k, v in pairs(vim.fn.environ()) do
						table.insert(variables, string.format("%s=%s", k, v))
					end
					return variables
				end,
				subProcess = false,
			},
			{
				type = "python",
				request = "launch",
				name = "Python File",
				program = "${file}",
				console = "internalConsole",
				pythonPath = function(adapter)
					return "/Users/pwd/Codes/saa/.venv/bin/python"
				end,
			},
		}

		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				"delve",
			},
		})

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			-- Set icons to characters that are more likely to work in every terminal.
			--    Feel free to remove or use ones that you like more! :)
			--    Don't feel like these are good choices.
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
		})

		-- Change breakpoint icons
		-- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
		-- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
		-- local breakpoint_icons = vim.g.have_nerd_font
		--     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
		--   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
		-- for type, icon in pairs(breakpoint_icons) do
		--   local tp = 'Dap' .. type
		--   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
		--   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
		-- end

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		-- Install golang specific config
		require("dap-go").setup({
			delve = {
				-- On Windows delve must be run attached or it crashes.
				-- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
				detached = vim.fn.has("win32") == 0,
			},
		})
	end,
}
