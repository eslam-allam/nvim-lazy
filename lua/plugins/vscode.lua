local vsCodePlugins = { "folke/which-key.nvim", "linux-cultist/venv-selector.nvim" }
local pluginsSpecs = {}

for _, plugin in pairs(vsCodePlugins) do
  pluginsSpecs[#pluginsSpecs + 1] = { plugin, optional = true, vscode = true }
end

return pluginsSpecs
