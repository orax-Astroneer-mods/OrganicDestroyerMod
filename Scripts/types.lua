---@meta _

---@class (exact) Mod_Options
---@field enabledAtStart boolean
---@field commands Mod_Options_Commands
---@field delay integer
---@field maxIteration integer

---@class (exact) Mod_Options_Commands
---@field destroy Mod_Options_CommandSpec

---@class (exact) Mod_Options_CommandSpec
---@field name string
---@field parameters table
