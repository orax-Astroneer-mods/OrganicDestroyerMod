---@class FOutputDevice
---@field Log function

local format = string.format

local currentModDirectory = debug.getinfo(1, "S").source:match("@?(.+\\Mods\\[^\\]+)")

---@param filename string
---@return boolean
local function isFileExists(filename)
    local file = io.open(filename, "r")
    if file ~= nil then
        io.close(file)
        return true
    else
        return false
    end
end

local function loadOptions()
    local file = format([[%s\options.lua]], currentModDirectory)

    if not isFileExists(file) then
        local cmd = format([[copy "%s\options.example.lua" "%s\options.lua"]],
            currentModDirectory,
            currentModDirectory)

        print("Copy example options to options.lua. Execute command: " .. cmd .. "\n")

        os.execute(cmd)
    end

    return dofile(file)
end

---@type Mod_Options
local options = loadOptions()

local IsDestroyEnabled = options.enabledAtStart == true

-- ---@param self AResourceNugget13_C
-- ---@diagnostic disable-next-line: redundant-parameter
-- NotifyOnNewObject("/Game/Items/Nuggets/ResourceNugget13.ResourceNugget13_C", function(self)
--     if IsDestroyEnabled == false then return end
--     ExecuteWithDelay(options.delay1, function()
--         if self:IsValid() and self.EmplacementData.Slot.SlotName:ToString() == "Resource Rail" then
--             ExecuteWithDelay(options.delay2, function()
--                 if self:IsValid() then
--                     self:K2_DestroyActor()
--                 end
--             end)
--         end
--     end)
-- end)

---@param self AResourceNugget13_C
---@diagnostic disable-next-line: redundant-parameter
NotifyOnNewObject("/Game/Items/Nuggets/ResourceNugget13.ResourceNugget13_C", function(self)
    if IsDestroyEnabled == false then return end

    local i = 0
    LoopAsync(options.delay,
        function()
            if self:IsValid() == false or i > options.maxIteration then
                return true
            end

            local slotName = self.EmplacementData.Slot.SlotName:ToString()

            -- If the resource is in a slot.
            if slotName ~= "None" then
                if slotName == "Resource Rail" then
                    ExecuteInGameThread(function()
                        if self:IsValid() then
                            self:K2_DestroyActor()
                        end
                    end)
                    return true
                end
                return true
            end

            i = i + 1
            return false
        end)
end)

---@param t table
---@param str string
local function includes(t, str)
    for index, value in ipairs(t) do
        if value == str then
            return true
        end
    end
    return false
end

local function destroyAll()
    local destroyed = 0
    local resources = FindAllOf("ResourceNugget13_C") ---@type AResourceNugget13_C[]?

    if resources then
        for index, res in ipairs(resources) do
            if not res.CurrentSlot.Component:IsValid() then
                res:K2_DestroyActor()
                destroyed = destroyed + 1
            end
        end
    end

    print(format("Number of resources found: %d. Destroyed: %d.", #resources, destroyed))
end

RegisterConsoleCommandHandler(options.commands.destroy.name, function(fullCommand, parameters, outputDevice)
    if #parameters < 1 then
        IsDestroyEnabled = not IsDestroyEnabled
    else
        local param = parameters[1]

        if includes(options.commands.destroy.parameters.on, param) then
            IsDestroyEnabled = true
        elseif includes(options.commands.destroy.parameters.off, param) then
            IsDestroyEnabled = false
        elseif includes(options.commands.destroy.parameters.all, param) then
            destroyAll()
            return true
        else
            outputDevice:Log("Unknown parameter.")
            return false
        end
    end

    local status = IsDestroyEnabled == true and "enabled" or "disabled"
    local msg = string.format("Organic Destroyer is: %s.", status)
    outputDevice:Log(msg)
    print(msg .. "\n")

    return true
end)
