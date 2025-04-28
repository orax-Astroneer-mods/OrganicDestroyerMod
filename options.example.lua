---@type Mod_Options
return {
  enabled_organic_destroyer_at_start = true,              -- true | false
  enabled_researchable_plant_destroyer_at_start = true,   -- true | false
  enabled_researchable_mineral_destroyer_at_start = true, -- true | false

  --[[
    You can change commands name if you want.
    Each parameter is a table. This means there are aliases.
    For example, "destroy 1", "destroy on" and "destroy enable" do the same thing.
    ]]

  commands = {
    --[[
        Name: destroy_organic
        Usage: destroy_organic [on | off | all]
          * 1, on, enable
          Enable the mod. New organic resources extracted using Terrain Tool or Drills will be destroyed.
          * 0, off, disable
          Disable the mod.
          * all
          All organic resources not in a slot will be destroyed.
        Examples:
          destroy on
          destroy enable
          destroy off
          destroy all
        ]]
    destroy_organic = {
      name = "destroy_organic",
      parameters = {
        on = { "1", "on", "enable" },
        off = { "0", "off", "disable" },
        all = { "all" }
      }
    },
    --[[
        Name: destroy_researchable_plant
    ]]
    destroy_researchable_plant = {
      name = "destroy_researchable_plant",
      parameters = {
        on = { "1", "on", "enable" },
        off = { "0", "off", "disable" },
        all = { "all" }
      }
    },
    --[[
        Name: destroy_researchable_mineral
    ]]
    destroy_researchable_mineral = {
      name = "destroy_researchable_mineral",
      parameters = {
        on = { "1", "on", "enable" },
        off = { "0", "off", "disable" },
        all = { "all" }
      }
    }
  },

  delay_before_deleting_unslotted_item = 5000,
  delay_before_deleting_new_item = 5000,

  -- You probably do not need to change these.
  delay = 1,
  maxIteration = 100,
}
