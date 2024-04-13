--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the EquipSusceptibleProtection keybinds by using Eggon's Hotkeys framework.

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local ipairs = ipairs -- ipairs function
local pairs = pairs -- pairs function
local print = print -- print function

--- Import modules
local Susceptible_Overhaul = require "Susceptible_Overhaul_module"
local SusUtil = require "Susceptible/SusceptibleUtil"
local DelayedAction = require "Susceptible/Actions/DelayedCodeExecutionTimedAction"

-- priority load
require "Susceptible/SusceptibleMaskData_additions"
require "--EHK_Init"

-- import localy for performance reasons
local SusceptibleMaskItems = SusceptibleMaskItems
local SusceptibleRepairTypes = SusceptibleRepairTypes
local SusceptibleMod = SusceptibleMod


--#region local functions from ISInventoryPaneContextMenu_patch_add_filter_repair_options.lua

local MAX_BLEACH_USES = 20

local function getConditionPercent(item)
	local cond = SusUtil.getNormalizedDurability(item);
	cond = math.floor(cond * 100);
	return cond.."%";
end

local function createDelayedAction(player, func)
	return DelayedAction:new(player, func, 120);
end

local animateHead = function(action)
	action:setActionAnim("WearClothing");
	action:setAnimVariable("WearClothingLocation", "Face")
end

local animateBody = function(action)
	action:setActionAnim("WearClothing");
	action:setAnimVariable("WearClothingLocation", "Waist")
end

local animateHands = function(action)
	action:setActionAnim("EquipItem");
end

local function addRemoveFilter(mask, filter, player)
	if SusUtil.containsFilter(mask) then
		SusUtil.removeFilter(mask, player);
	end
	if filter then
		SusUtil.insertFilter(mask, filter, player);
	end
end

local function addRemoveFilterDelayed(mask, filter, player)
	local delayedAction = DelayedAction:new(player, function(action) addRemoveFilter(mask, filter, player) end, 120);
	delayedAction:setOnStart(animateHead);
	ISTimedActionQueue.add(delayedAction);
end

local function addRemoveOxygen(mask, oxygen, player)
	if SusUtil.containsOxygen(mask) then
		SusUtil.removeOxygen(mask, player);
	end
	if oxygen then
		SusUtil.insertOxygen(mask, oxygen, player);
	end
end

local function addRemoveOxygenDelayed(mask, oxygen, player)
	local delayedAction = DelayedAction:new(player, function(action) addRemoveOxygen(mask, oxygen, player) end, 120);
	delayedAction:setOnStart(animateBody);
	ISTimedActionQueue.add(delayedAction);
end

local function repairWithClothMask(fullMask, clothMask, player)
	SusUtil.repairWith(fullMask, clothMask, 1/3, player);
end

local function repairWithClothMaskDelayed(mask, clothMask, player)
	local delayedAction = DelayedAction:new(player, function(action) repairWithClothMask(mask, clothMask, player) end, 120);
	if mask:isEquipped() then
		delayedAction:setOnStart(animateHead);
	else
		delayedAction:setOnStart(animateHands);
	end
	ISTimedActionQueue.add(delayedAction);
end

local function repairWithBleach(mask, bleach, player)
	SusUtil.repair(mask, 1);

	local bleachData = bleach:getModData();
	if bleachData.useCount + 1 >= MAX_BLEACH_USES then
		bleach:Use();
	else
		bleachData.useCount = bleachData.useCount + 1;
	end

	mask:setCondition(mask:getCondition() - 1);

	if mask:isEquipped() then
		local body = player:getBodyDamage();
		body:setPoisonLevel(math.min(body:getPoisonLevel() + 25, 35));
	end
end

local function repairWithBleachDelayed(mask, bleach, player)
	local delayedAction = DelayedAction:new(player, function(action) repairWithBleach(mask, bleach, player) end, 120);
	if mask:isEquipped() then
		delayedAction:setOnStart(animateHead);
	else
		delayedAction:setOnStart(animateHands);
	end
	ISTimedActionQueue.add(delayedAction);
end

--#endregion

--- Two different actions available to the player:
--- - If player has a protection, unequip it
--- - Else, equip available protection
Susceptible_Overhaul.equipSusceptibleProtection = function()
    print("run function")
    -- get player info
    local player = getPlayer()
    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player)

    -- if player has mask, unequip it
    if mask then
        ISTimedActionQueue.add(ISUnequipAction:new(player, item, 50))
        return
    end

    -- retrieve available protection without specific choice for type
    item, mask = Susceptible_Overhaul.getProtectionInInventory(player,nil)

    if mask then
        ISTimedActionQueue.add(ISWearClothing:new(player, item, 50))
    else
        player:Say(getText("UI_say_equipSusceptibleProtection"))
    end
end

Susceptible_Overhaul.changeFilterOxygenTank = function()
    -- get player info
    local player = getPlayer()
    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player)

    -- if player has mask, unequip it
    if mask then
        local recharge = false
        local type = nil
        if mask.repairType == SusceptibleRepairTypes.FILTER then
            recharge = Susceptible_Overhaul.getRecharge(player,SusceptibleRepairTypes.FILTER)
            type = "Filter"
        elseif mask.repairType == SusceptibleRepairTypes.OXYGEN then
            recharge = Susceptible_Overhaul.getRecharge(player,SusceptibleRepairTypes.OXYGEN)
            type = "Oxygen"
        elseif mask.repairType == SusceptibleRepairTypes.WASH then
            recharge = Susceptible_Overhaul.getRecharge(player,SusceptibleRepairTypes.WASH)
            type = "Wash"
            print(recharge)
        elseif mask.repairType == SusceptibleRepairTypes.CLOTH then
            recharge = Susceptible_Overhaul.getRecharge(player,SusceptibleRepairTypes.CLOTH)
            type = "Cloth"
        end
        if type == "Filter" then
            if recharge then
                addRemoveFilterDelayed(item,recharge,player)
            else
                player:Say(getText("UI_say_changeFilter"))
            end
        elseif type == "Oxygen" then
            if recharge then
                addRemoveOxygenDelayed(item,recharge,player)
            else
                player:Say(getText("UI_say_changeOxygenTank"))
            end
        elseif type == "Wash" then
            if recharge then
                repairWithBleachDelayed(item,recharge,player)
            else
                player:Say(getText("UI_say_changeWash"))
            end
        elseif type == "Cloth" then
            if recharge then
                repairWithClothMaskDelayed(item,recharge,player)
            else
                player:Say(getText("UI_say_changeCloth"))
            end
        end
    else
        player:Say(getText("UI_say_equipSusceptibleProtection"))
    end
end