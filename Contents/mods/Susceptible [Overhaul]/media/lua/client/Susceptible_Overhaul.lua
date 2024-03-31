
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
---
---@param drain_oxygen boolean
---@param drain_filter boolean
---@param oxygenTank_drainage double
---@param filter_drainage double
Susceptible_Overhaul.damageMask = function(drain_oxygen,drain_filter,oxygenTank_drainage,filter_drainage)
    -- retrieve mask item type and info
    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(getPlayer())
    if not mask then return end

    -- get item data, notably durabilityMax
    local data = SusUtil.getItemModData(item)

    -- maskDamageRate / time to drain = durability loss per minute (bcs function everyMinute)
    local maskDamageRate = data.durabilityMax / 60;

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