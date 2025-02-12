---@type Mod_Options
return {
  enabledAtStart = true, -- true | false

  --[[
    You can change commands name if you want.
    Each parameter is a table. This means there are aliases.
    For example, "destroy 1", "destroy on" and "destroy enable" do the same thing.
    ]]

  commands = {
    --[[
        Name: destroy
        Usage: destroy [on | off | all]
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
    destroy = {
      name = "destroy",
      parameters = {
        on = { "1", "on", "enable" },
        off = { "0", "off", "disable" },
        all = { "all" }
      }
    }
  },

  -- You probably do not need to change these.
  delay = 1,
  maxIteration = 100,
}
