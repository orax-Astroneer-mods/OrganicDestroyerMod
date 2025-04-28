---@meta _

---@class (exact) Mod_Options
---@field enabled_organic_destroyer_at_start boolean
---@field enabled_researchable_plant_destroyer_at_start boolean
---@field enabled_researchable_mineral_destroyer_at_start boolean
---@field commands Mod_Options_Commands
---@field delay integer
---@field maxIteration integer
---@field delay_before_deleting_unslotted_item integer
---@field delay_before_deleting_new_item integer

---@class (exact) Mod_Options_Commands
---@field destroy_organic Mod_Options_CommandSpec
---@field destroy_researchable_plant Mod_Options_CommandSpec
---@field destroy_researchable_mineral Mod_Options_CommandSpec

---@class (exact) Mod_Options_CommandSpec
---@field name string
---@field parameters table
