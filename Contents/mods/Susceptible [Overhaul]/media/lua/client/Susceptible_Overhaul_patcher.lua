--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the patches to functions of Susceptible by the mod Susceptible - Overhaul.

]]--
--[[ ================================================ ]]--

--- Import modules
local SusUtil = require "Susceptible/SusceptibleUtil"
require "Susceptible/SusceptibleMaskData_additions"

-- localy import data
local SusceptibleMaskItems = SusceptibleMaskItems
local SusceptibleRepairTypes = SusceptibleRepairTypes

--- Modify `SusceptibleMod.onPlayerUpdate` with my own.
--- Add UI to player even if not Susceptible.
---
---@param player IsoPlayer
function SusceptibleMod.onPlayerUpdate(player)
    --- Add the UI to the player anyway
    if not SusceptibleMod.isPlayerSusceptible(player) then
        SusceptibleMod.updateMaskInfoDisplay(player, 0)
        return
    elseif not SusceptibleMod.shouldPlayerUpdate(player) then
        return
    end

    local infectionRoll = ZombRandFloat(0.0, 1.0);
    local threatLevel, paranoiaLevel = SusceptibleMod.calculateThreat(player);

    SusceptibleMod.updateMaskInfoDisplay(player, threatLevel + paranoiaLevel);
    SusceptibleMod.threatByPlayer[player] = threatLevel;

    local activeThreatLevel = SusceptibleMod.reduceThreatWithMask(player, threatLevel);
    if activeThreatLevel > 0 then

        local stress = player:getStats():getStress();
        if stress < 1 then
            player:getStats():setStress(stress + activeThreatLevel/50);
        end

        local infectionChance = SusceptibleMod.calculateInfectionChance(player, activeThreatLevel);

        if infectionRoll < infectionChance then
            if SusceptibleMod.tryLuckySave(player, activeThreatLevel) then
                return;
            end

            if SandboxVars.Susceptible.InstantDeath then
                player:Kill(player);
            else
                SusceptibleMod.infectPlayer(player)
            end
        end
    end
end

--- Modify `SusceptibleMod.updateMaskInfoDisplay` with my own.
--- Forces UI to danger if set by another mod.
---
---@param player IsoPlayer
---@param threatLevel double
function SusceptibleMod.updateMaskInfoDisplay(player, threatLevel)
    if player:isDead() then
        return;
    end

    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player)

    -- check mod data
    local modData = player:getModData()
    if not modData["Susceptible_Overhaul"] then
        modData["Susceptible_Overhaul"] = {}
        modData["Susceptible_Overhaul"].InDanger = {}
        modData["Susceptible_Overhaul"].DamageProtection = {}
    end

    -- verify player is not in danger, else set threatLevel to 2 to trigger
    -- the toxic interface from Susceptible
    local check = nil
    for k in pairs(modData["Susceptible_Overhaul"].InDanger) do
        check = true
        break
    end
    if check then
        threatLevel = 2 -- force danger icon to show that way
    end

    if not SusceptibleMod.uiByPlayer[player] then
        SusceptibleMod.createMaskUi(player);
    end

    local quality = 99999;
    if mask and mask.quality then
        quality = mask.quality;
    end

    local isBroken = not item or SusUtil.isBroken(item);
    local threatValue = threatLevel;
    if not isBroken then
        threatValue = threatLevel / (quality * SandboxVars.Susceptible.MaskFilteringPower);
    end

    SusceptibleMod.uiByPlayer[player]:updateMaskImage(item, mask, threatValue, isBroken)

    if item and not isBroken then
        SusceptibleMod.uiByPlayer[player]:updateMaskInfo(true, SusUtil.getNormalizedDurability(item), threatValue)
    else
        SusceptibleMod.uiByPlayer[player]:updateMaskInfo(false, 0, threatLevel*2.5)
    end
end

--- Patch various functions depending on conditions and Sandbox options.
local function OnGameStart()
    -- rewrite Susceptible's function isBroken to check if hazmat has holes
    if SandboxVars.Susceptible.FailIfHoles then
        DebugLog.log("Susceptible_Overhaul: Overwriting SusceptibleUtil.isBroken")

        function SusUtil.isBroken(item)
            if item:getCondition() <= 0 then
                return true;
            end

            local data = SusUtil.getItemModData(item);

            local maskInfo = SusceptibleMaskItems:getMaskData(item);
            if not maskInfo 
            or maskInfo.repairType == SusceptibleRepairTypes.OXYGEN and not data.hasOxygenTank -- if no oxygen tank
            or item:getHolesNumber() > 0 -- makes sure hazmat doesn't have holes
            then
                return true;
            elseif data.durabilityMax then
                return data.durability <= 0;
            end
            return false;
        end
    end

    if SandboxVars.Susceptible.RealisticMode then
        DebugLog.log("Susceptible_Overhaul: Overwriting SusceptibleUtil.onPlayerGasMaskDrain")

        function SusceptibleMod.onPlayerGasMaskDrain(player)
            if not player then
                return;
            end

            local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player);
            if mask and not SusUtil.isBroken(item) then
                local damage = ( SandboxVars.Susceptible.TimeForNaturalDrain * (2 - player:getStats():getEndurance()) )^3
                SusceptibleMod.damageMask(item, mask, damage);
            end
        end
    else
        DebugLog.log("Susceptible_Overhaul: Removing SusceptibleUtil.onGasMaskDrain")

        Events.EveryTenMinutes.Remove(SusceptibleMod.onGasMaskDrain)
    end
end

Events.OnGameStart.Add(OnGameStart)