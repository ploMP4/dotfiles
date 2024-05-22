local config_dir = "custom/lspconfig"
local config = {}

local function load_configurations()
	local config_files = vim.fn.globpath(vim.fn.stdpath("config") .. "/lua/" .. config_dir, "*.lua", false, true)
	for _, file in ipairs(config_files) do
		local module_name = file:match("([^/]+)%.lua$")
		if module_name ~= "init" then
			local full_module_name = config_dir .. "." .. module_name
			local ok, module = pcall(require, full_module_name)
			if ok then
				config[module_name] = module
			else
				vim.api.nvim_err_writeln("Error loading " .. full_module_name .. "\n\n" .. module)
			end
		end
	end
end

load_configurations()

return config
