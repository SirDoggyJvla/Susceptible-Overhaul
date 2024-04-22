--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the core of the mod of Susceptible [Overhaul].

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local table = table -- Lua's table module
local ipairs = ipairs -- ipairs function
local pairs = pairs -- pairs function
local ZombRand = ZombRand -- java function
local print = print -- print function
local tostring = tostring --tostring function

--- Import modules
local Susceptible_Overhaul = require "Susceptible_Overhaul_module"
local SusUtil = require "Susceptible/SusceptibleUtil"
require "Susceptible/SusceptibleMaskData_additions"

-- localy import data
local SusceptibleMaskItems = SusceptibleMaskItems
local SusceptibleRepairTypes = SusceptibleRepairTypes
local SusceptibleMod = SusceptibleMod

local priority_mask = {
    ["Oxygen"] = 1,
    ["Filter"] = 2,
	["Cloth"] = 3,
	["Wash"] = 4,
}

--- Checks if player has a protection in its inventory based on given `type`.
--- If no `type` is given (`nil`) then it checks for any type of protection.
---
--- If no protection is found, it outputs 2 `false` `boolean`.
---@param player IsoPlayer
---@param protectionType string [opt]
---@return InventoryItem|boolean item, table|boolean mask
Susceptible_Overhaul.getProtectionInInventory = function(player,protectionType)
    -- get inventory items
    local items = player:getInventory():getItems()

    -- initialize
    local item = false
    local mask = false
    local found_item
    local found_mask

    -- start lowest priority
    local priority
    local found_priority = 5

    -- cycle through inventory to find best protection
    for i = 0,items:size() - 1 do
        item = items:get(i)
        if item:IsClothing() then
            mask = SusceptibleMaskItems:getMaskData(item)
            if mask then
                if not protectionType then
                    priority = priority_mask[mask.repairType] or 4 --default is cloth if is mask
                    if priority < found_priority then
                        found_item = item
                        found_mask = mask
                        found_priority = priority
                    end
                elseif mask.repairType == SusceptibleRepairTypes[protectionType] then
                    break
                end
            end
        end
    end

    if found_item then
        item = found_item
        mask = found_mask
    end

    return item, mask
end

--- Checks if player has a protection in its inventory based on given `type`.
--- If no `type` is given (`nil`) then it checks for any type of protection.
---
--- If no protection is found, it outputs 2 `false` `boolean`.
---@param player IsoPlayer
---@param protectionType string [opt]
---@return InventoryItem|nil recharge
Susceptible_Overhaul.getRecharge = function(player,protectionType)
    local inv = player:getInventory()

    local recharge = nil
    if protectionType == "Oxygen" then
        recharge = inv:getFirstTypeRecurse("OxygenTank")
    elseif protectionType == "Filter" then
        recharge = inv:getFirstTypeRecurse("GasmaskFilter")
    elseif protectionType == "Wash" then
        recharge = inv:getFirstTypeRecurse("Bleach")
        if recharge then
            local data = recharge:getModData()
            if not data.useCount then
                data.useCount = 0
            end
        end
    elseif protectionType == "Cloth" then
        recharge = SusUtil.findAllClothMasks(inv)
        if recharge then
            recharge = recharge:get(0)
        end
    end

    return recharge
end

--#region isWearing functions

--- Checks if player has a cloth mask and outputs the result. 
---
--- `player` is optional and will be retrieved by the code if not provided.
--- Just make sure to run this function client side or `getPlayer()` will not 
--- give out anything and the function will be skipped.
---@param player IsoPlayer   [opt]
---@return boolean isWearingClothMask
Susceptible_Overhaul.isWearingClothMask = function(player)
    player = player or getPlayer()
    if not player then return false end

    -- retrieves item and mask protections if worn by player
	local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player);
    if not mask or SusUtil.isBroken(item) then
        return false
    end

	-- checks if mask with filter is on, else return false for no gasmask
	if mask.repairType == SusceptibleRepairTypes.CLOTH then
		return true
	end

	return false
end

--- Checks if player has a wash mask and outputs the result. 
---
--- `player` is optional and will be retrieved by the code if not provided.
--- Just make sure to run this function client side or `getPlayer()` will not 
--- give out anything and the function will be skipped.
---@param player IsoPlayer   [opt]
---@return boolean isWearingWashMask
Susceptible_Overhaul.isWearingWashMask = function(player)
    player = player or getPlayer()
    if not player then return false end

    -- retrieves item and mask protections if worn by player
	local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player);
    if not mask or SusUtil.isBroken(item) then
        return false
    end

	-- checks if mask with filter is on, else return false for no gasmask
	if mask.repairType == SusceptibleRepairTypes.WASH then
		return true
	end

	return false
end

--- Checks if player has a gas mask and outputs the result. 
---
--- `player` is optional and will be retrieved by the code if not provided.
--- Just make sure to run this function client side or `getPlayer()` will not 
--- give out anything and the function will be skipped.
---@param player IsoPlayer   [opt]
---@return boolean isWearingGasmask
Susceptible_Overhaul.isWearingGasMask = function(player)
    player = player or getPlayer()
    if not player then return false end

    -- retrieves item and mask protections if worn by player
	local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player);
    if not mask or SusUtil.isBroken(item) then
        return false
    end

	-- checks if mask with filter is on, else return false for no gasmask
	if mask.repairType == SusceptibleRepairTypes.FILTER then
		return true
	end

	return false
end

--- Checks if player has a hazmat and outputs the result. 
---
--- `player` is optional and will be retrieved by the code if not provided.
--- Just make sure to run this function client side or `getPlayer()` will not 
--- give out anything and the function will be skipped.
---@param player IsoPlayer   [opt]
---@return boolean isWearingHazmat
Susceptible_Overhaul.isWearingHazmat = function(player)
    player = player or getPlayer()
    if not player then return false end

    -- retrieves item and mask protections if worn by player
	local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player);
    if not mask or SusUtil.isBroken(item) then
        return false
    end

	-- checks if mask with oxygen is on, else return false for no hazmat
	if mask.repairType == SusceptibleRepairTypes.OXYGEN then
		return true
	end

	return false
end

--- Checks if player has a protection and outputs the result. 
---
--- `player` is optional and will be retrieved by the code if not provided.
--- Just make sure to run this function client side or `getPlayer()` will not 
--- give out anything and the function will be skipped.
---@param player IsoPlayer   [opt]
---@return boolean isWearingProtection
Susceptible_Overhaul.isWearingProtection = function(player)
    player = player or getPlayer()
    if not player then return false end

    -- retrieves item and mask protections if worn by player
	local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player)
    if not mask or SusUtil.isBroken(item) then
        return false
    end

	-- checks if mask with filter is on, else return false for no gasmask
	if mask.repairType == SusceptibleRepairTypes.CLOTH
    or mask.repairType == SusceptibleRepairTypes.WASH
    or mask.repairType == SusceptibleRepairTypes.FILTER
    or mask.repairType == SusceptibleRepairTypes.OXYGEN
    then
		return true
	end

	return false
end
--#endregion

--- Damages the player protection if he's in a situation that should drain the protection.
Susceptible_Overhaul.DamageProtection = function()
    local player = getPlayer()
    -- retrieve mask item type and info
    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player)
    if not mask then return end

    -- get item data, notably durabilityMax
    local data = SusUtil.getItemModData(item)

    -- maskDamageRate / time to drain = durability loss per minute (bcs function everyMinute)
    local maskDamageRate = data.durabilityMax / 60;

    -- check mod data
    local modData = player:getModData()
    if not modData["Susceptible_Overhaul"] then
        modData["Susceptible_Overhaul"] = {}
    end
    if not modData["Susceptible_Overhaul"].DamageProtection then
        modData["Susceptible_Overhaul"].DamageProtection = {}
    end

    for _,v in pairs(modData["Susceptible_Overhaul"].DamageProtection) do
        local drain_oxygen = v.drain_oxygen
        local drain_filter = v.drain_filter
        local oxygenTank_drainage = v.oxygenTank_drainage
        local filter_drainage = v.filter_drainage

        -- calculate durability loss depending on mask type, priotizing oxygen tanks
        if mask.repairType == SusceptibleRepairTypes.OXYGEN and drain_oxygen then
            local condition = item:getCondition() / item:getConditionMax() + 0.1
            condition = condition * condition
            if condition > 1 then
                condition = 1;
            end

            local conditionMult = 1.0 / condition; -- You're leaking :)
            SusceptibleMod.damageMask(item, mask, conditionMult * maskDamageRate / oxygenTank_drainage ) -- Constant drain rate for oxygen based protection
        elseif mask.repairType == SusceptibleRepairTypes.FILTER and drain_filter then
            local damage = maskDamageRate / filter_drainage
            SusceptibleMod.damageMask(item, mask, damage)
        end
    end
end

local multiplier_mask = {
    ["Oxygen"] = 0.5,
    ["Filter"] = 1.1,
	["Cloth"] = 0.8,
	["Wash"] = 0.5,
}

--- OnPlayerUpdate do:
---
--- - Exhaust player if he's wearing a mask
---@param player IsoPlayer
Susceptible_Overhaul.OnPlayerUpdate = function(player)
    if not SandboxVars.Susceptible.HardBreathing then return end

    -- get mask and skip if no mask
    local _, mask = SusceptibleMod.getEquippedMaskItemAndData(player)
    if not mask then return end

    -- get mask multi
    local multi_mask = multiplier_mask[mask.repairType] or 1

    -- base penalization
    local penalization = 0.001

    -- get timeDelta + fitness level multipliers
    local timeDelta = getGameTime():getMultiplier() --normalize it
    local multi = ((15 - player:getPerkLevel(Perks.Fitness))/10)^3 * timeDelta * multi_mask

    -- apply penalization based on current movement state
    if player:isPlayerMoving() then
        -- Check:
        -- walk
        -- run
        -- sprint
        if not player:isRunning() and not player:isForceSprint() then
            penalization = 0.005
        elseif player:isRunning() and not player:isForceSprint() then
            penalization = 0.015
        else
            penalization = 0.030
        end
    elseif not player:isSitOnGround() then
        penalization = 0.002
    end

    -- apply multiplier
    penalization = penalization/60 * multi
    player:exert(penalization)
end