--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the EquipSusceptibleProtection keybinds by using Mod Options framework.

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

-- import localy for performance reasons
local SusceptibleMod = SusceptibleMod


--#region local functions from ISInventoryPaneContextMenu_patch_add_filter_repair_options.lua

local MAX_BLEACH_USES = 20

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

    -- if item or mask in inventory, equip it
    -- else say player doesn't have a mask available
    if mask then
        ISTimedActionQueue.add(ISWearClothing:new(player, item, 50))
    else
        player:Say(getText("UI_say_equipSusceptibleProtection"))
    end
end

local repairFunctions = {
    ["Filter"] = addRemoveFilterDelayed,
    ["Oxygen"] = addRemoveOxygenDelayed,
    ["Wash"] = repairWithBleachDelayed,
    ["Cloth"] = repairWithClothMaskDelayed,
}
local sayNoRepair = {
    ["Filter"] = getText("UI_say_changeFilter"),
    ["Oxygen"] = getText("UI_say_changeOxygenTank"),
    ["Wash"] = getText("UI_say_changeWash"),
    ["Cloth"] = getText("UI_say_changeCloth"),
}

Susceptible_Overhaul.changeFilterOxygenTank = function()
    -- get player info
    local player = getPlayer()
    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player)

    -- if player has mask, check if recharge and repair or say no recharge if none
    if mask then
        -- get type repair and recharge if available
        local type = mask.repairType or "Cloth"
        local recharge = Susceptible_Overhaul.getRecharge(player,type)

		-- transfer recharge in main inventory if not in it
		ISInventoryPaneContextMenu.transferIfNeeded(player, recharge)

        -- for each type of repair, repair protection or if no recharge then say it
        if recharge then
            repairFunctions[type](item,recharge,player)
        else
            player:Say(sayNoRepair[type])
        end

    -- player doesn't have a mask, equip one
    -- if no mask available then say it
    else
        Susceptible_Overhaul.equipSusceptibleProtection()
    end
end

--- Add the keybinds 
if ModOptions and ModOptions.AddKeyBinding then
    local equipSusceptibleProtection = {
        key = Keyboard.KEY_M,  --default
        name = "equipSusceptibleProtection",  -- just id (user won't see this name)
    }

    local changeFilterOxygenTank = {
        key = Keyboard.KEY_L,  --default
        name = "changeFilterOxygenTank",  -- just id (user won't see this name)
    }

    local function SO_keyPress(keynum)
        if keynum == equipSusceptibleProtection.key then
            Susceptible_Overhaul.equipSusceptibleProtection()
        elseif keynum == changeFilterOxygenTank.key then
            Susceptible_Overhaul.changeFilterOxygenTank()
        end
    end
    Events.OnKeyPressed.Add(SO_keyPress)

    ModOptions:AddKeyBinding("[Susceptible]",equipSusceptibleProtection)
    ModOptions:AddKeyBinding("[Susceptible]",changeFilterOxygenTank)
end