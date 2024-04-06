
--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the core of the mod of Susceptible - Overhaul.

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
        modData["Susceptible_Overhaul"].DamageProtection = {}
    end

    for k,v in pairs(modData["Susceptible_Overhaul"].DamageProtection) do
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