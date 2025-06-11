---@class FOutputDevice
---@field Log function

local format = string.format

local currentModDirectory = debug.getinfo(1, "S").source:gsub("\\", "/"):match("@?(.+)/[Ss]cripts/")

---@type EPhysicalItemMotionState
local EPhysicalItemMotionState = {
    Simulating = 0,
    PickedUp = 1,
    Slotted = 2,
    NonSimulating = 3,
    Indicator = 4,
    EPhysicalItemMotionState_MAX = 5,
}

local classes = {
    Researchable_Base_Plant_C =
    "/Game/Scenarios/Research_Items/Content/ResearchableItems/Researchable_Base_Plant.Researchable_Base_Plant_C",
    Researchable_Base_Mineral_C =
    "/Game/Scenarios/Research_Items/Content/ResearchableItems/Researchable_Base_Mineral.Researchable_Base_Mineral_C"
}

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

local IsOrganicDestroyerEnabled = options.enabled_organic_destroyer_at_start == true
local IsResearchablePlantDestroyerEnabled = options.enabled_researchable_plant_destroyer_at_start == true
local IsResearchableMineralDestroyerEnabled = options.enabled_researchable_mineral_destroyer_at_start == true

---@param physicalItem APhysicalItem
local function destroyItem(physicalItem)
    if physicalItem and physicalItem:IsValid() then
        -- check that the item is not in a slot
        if not physicalItem.CurrentSlot.Component:IsValid() then
            physicalItem:K2_DestroyActor()
        end
    end
end

---@param physicalItem APhysicalItem
local function destroyItemInResourceRailSlot(physicalItem)
    local i = 0

    LoopAsync(options.delay, function()
        if physicalItem:IsValid() == false or i > options.maxIteration then
            return true
        end

        local slotName = physicalItem.EmplacementData.Slot.SlotName:ToString()

        -- If the resource is in a slot.
        if slotName ~= "None" then
            if slotName == "Resource Rail" then
                ExecuteInGameThread(function()
                    if physicalItem:IsValid() then
                        physicalItem:K2_DestroyActor()
                    end
                end)
                return true
            end
            return true
        end

        i = i + 1
        return false
    end)
end

RegisterHook("/Script/Astro.PhysicalItem:MulticastReleasedFromSlot",
    ---@param self RemoteUnrealParam
    ---@param FromTool RemoteUnrealParam
    ---@param NewOwner RemoteUnrealParam
    function(self, FromTool, NewOwner)
        local physicalItem = self:get() ---@type APhysicalItem
        local fromTool = FromTool:get() ---@type boolean
        local newOwner = NewOwner:get() ---@type boolean

        if (options.enabled_researchable_mineral_destroyer_at_start == true and physicalItem:IsA(classes.Researchable_Base_Mineral_C)) or
            (options.enabled_researchable_plant_destroyer_at_start == true and physicalItem:IsA(classes.Researchable_Base_Plant_C)) then
            ExecuteWithDelay(options.delay_before_deleting_unslotted_item, function()
                if physicalItem:IsValid() and
                    physicalItem.ReplicatedState.MotionState == EPhysicalItemMotionState.Simulating and
                    fromTool == false and
                    newOwner == false then
                    physicalItem:K2_DestroyActor()
                end
            end)
        end
    end)

NotifyOnNewObject("/Game/Items/Nuggets/ResourceNugget13.ResourceNugget13_C",
    ---@param self AResourceNugget13_C
    ---@diagnostic disable-next-line: redundant-parameter
    function(self)
        if IsOrganicDestroyerEnabled == false then return end

        destroyItemInResourceRailSlot(self)
    end)

NotifyOnNewObject(
    "/Game/Scenarios/Research_Items/Content/ResearchableItems/Researchable_Base_Plant.Researchable_Base_Plant_C",
    ---@param self AResearchable_Base_Plant_C
    ---@diagnostic disable-next-line: redundant-parameter
    function(self)
        if IsResearchablePlantDestroyerEnabled == false then return end
        ExecuteInGameThread(function()
            ExecuteWithDelay(options.delay_before_deleting_new_item, function()
                destroyItem(self)
            end)
        end)
    end)

NotifyOnNewObject(
    "/Game/Scenarios/Research_Items/Content/ResearchableItems/Researchable_Base_Mineral.Researchable_Base_Mineral_C",
    ---@param self AResearchable_Base_Mineral_C
    ---@diagnostic disable-next-line: redundant-parameter
    function(self)
        if IsResearchableMineralDestroyerEnabled == false then return end
        ExecuteInGameThread(function()
            ExecuteWithDelay(options.delay_before_deleting_new_item, function()
                destroyItem(self)
            end)
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

---@param items APhysicalItem[]
local function destroyAll(items)
    local destroyed = 0
    if items then
        for index, item in ipairs(items) do
            if not item.CurrentSlot.Component:IsValid() then
                item:K2_DestroyActor()
                destroyed = destroyed + 1
            end
        end
    end

    print(format("Number of items found: %d. Destroyed: %d.", #items, destroyed))
end

local function destroyAllOrganic()
    local resources = FindAllOf("ResourceNugget13_C") ---@type AResourceNugget13_C[]?

    if resources then
        destroyAll(resources)
    end
end

local function destroyAllResearchablePlant()
    local resources = FindAllOf("Researchable_Base_Plant_C") ---@type AResearchable_Base_Plant_C[]?

    if resources then
        destroyAll(resources)
    end
end

local function destroyAllResearchableMineral()
    local resources = FindAllOf("Researchable_Base_Mineral_C") ---@type AResearchable_Base_Mineral_C[]?

    if resources then
        destroyAll(resources)
    end
end

RegisterConsoleCommandHandler(options.commands.destroy_organic.name, function(fullCommand, parameters, outputDevice)
    if #parameters < 1 then
        IsOrganicDestroyerEnabled = not IsOrganicDestroyerEnabled
    else
        local param = parameters[1]

        if includes(options.commands.destroy_organic.parameters.on, param) then
            IsOrganicDestroyerEnabled = true
        elseif includes(options.commands.destroy_organic.parameters.off, param) then
            IsOrganicDestroyerEnabled = false
        elseif includes(options.commands.destroy_organic.parameters.all, param) then
            destroyAllOrganic()
            return true
        else
            outputDevice:Log("Unknown parameter.")
            return false
        end
    end

    local status = IsOrganicDestroyerEnabled == true and "enabled" or "disabled"
    local msg = string.format("Organic destroyer is: %s.", status)
    outputDevice:Log(msg)
    print(msg .. "\n")

    return true
end)

RegisterConsoleCommandHandler(options.commands.destroy_researchable_plant.name,
    function(fullCommand, parameters, outputDevice)
        if #parameters < 1 then
            IsResearchablePlantDestroyerEnabled = not IsResearchablePlantDestroyerEnabled
        else
            local param = parameters[1]

            if includes(options.commands.destroy_researchable_plant.parameters.on, param) then
                IsOrganicDestroyerEnabled = true
            elseif includes(options.commands.destroy_researchable_plant.parameters.off, param) then
                IsOrganicDestroyerEnabled = false
            elseif includes(options.commands.destroy_researchable_plant.parameters.all, param) then
                destroyAllResearchablePlant()
                return true
            else
                outputDevice:Log("Unknown parameter.")
                return false
            end
        end

        local status = IsResearchablePlantDestroyerEnabled == true and "enabled" or "disabled"
        local msg = string.format("Researchable plant destroyer is: %s.", status)
        outputDevice:Log(msg)
        print(msg .. "\n")

        return true
    end)

RegisterConsoleCommandHandler(options.commands.destroy_researchable_mineral.name,
    function(fullCommand, parameters, outputDevice)
        if #parameters < 1 then
            IsResearchableMineralDestroyerEnabled = not IsResearchableMineralDestroyerEnabled
        else
            local param = parameters[1]

            if includes(options.commands.destroy_researchable_mineral.parameters.on, param) then
                IsOrganicDestroyerEnabled = true
            elseif includes(options.commands.destroy_researchable_mineral.parameters.off, param) then
                IsOrganicDestroyerEnabled = false
            elseif includes(options.commands.destroy_researchable_mineral.parameters.all, param) then
                destroyAllResearchableMineral()
                return true
            else
                outputDevice:Log("Unknown parameter.")
                return false
            end
        end

        local status = IsResearchableMineralDestroyerEnabled == true and "enabled" or "disabled"
        local msg = string.format("Researchable mineral destroyer is: %s.", status)
        outputDevice:Log(msg)
        print(msg .. "\n")

        return true
    end)
