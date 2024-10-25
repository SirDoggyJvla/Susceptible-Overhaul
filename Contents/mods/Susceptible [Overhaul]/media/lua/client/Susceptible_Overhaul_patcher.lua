--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the patches to functions of Susceptible by the mod Susceptible [Overhaul].

]]--
--[[ ================================================ ]]--

--- Import modules
local SusUtil = require "Susceptible/SusceptibleUtil"
require "Susceptible/SusceptibleTrait"
require "Susceptible/SusceptibleMaskData_additions"

-- localy import data
local SusceptibleMaskItems = SusceptibleMaskItems
local SusceptibleRepairTypes = SusceptibleRepairTypes

Events.OnPlayerUpdate.Remove(SusceptibleMod.onPlayerUpdate)

if getActivatedMods():contains("Bandits") then

    print("PATCHING SusceptibleMod.zombieIsValid")

    local zombieIsValid_original = SusceptibleMod.zombieIsValid
    function SusceptibleMod.zombieIsValid(player, zombie, distance, playerIsOutside)
        local brain = BanditBrain.Get(zombie)
        if zombie:getVariableBoolean("Bandit") or brain then
            return false
        end
        local gmd = GetBanditModData()
        if gmd.Queue[BanditUtils.GetCharacterID(zombie)] then
            return false
        end

        return zombieIsValid_original(player, zombie, distance, playerIsOutside)
    end

    function SusceptibleMod.calculateThreat(player)
        local infectionDistance = SusceptibleMod.calculateInfectionDistance(player);
        local isOutside = player:isOutside();
    
        local threatLevel = 0;
        local paranoiaLevel = 0;
    
        local multiplier = 1;
        if player:getVehicle() then
            multiplier = SusceptibleMod.calculateVehicleInfectionMultiplier(player, player:getVehicle());
        end
        
        if multiplier == 0 then
            return 0, 0;
        end
    
        local zeds = getCell():getZombieList();
        if zeds:size() > 0 then
            for i = 0, zeds:size() - 1 do
                local zombie = zeds:get(i);
                local distance = player:DistTo(zombie);
                if distance <= infectionDistance then
                    if SusceptibleMod.zombieIsValid(player, zombie, distance, isOutside) then
                        if distance < 1 then
                            threatLevel = threatLevel + 2;
                        else
                            threatLevel = threatLevel + (2 / (0.75 + distance * 0.25));
                        end
                    end
                end
            end
        end
    
        return threatLevel * multiplier, paranoiaLevel * multiplier;
    end

end



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
    end
    if not modData["Susceptible_Overhaul"].InDanger then
        modData["Susceptible_Overhaul"].InDanger = {}
    end

    -- verify player is not in danger, else set threatLevel to 2 to trigger
    -- the toxic interface from Susceptible
    local check = nil
    for _ in pairs(modData["Susceptible_Overhaul"].InDanger) do
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

    if SandboxVars.Susceptible.NaturalDrain then
        DebugLog.log("Susceptible_Overhaul: Overwriting SusceptibleMod.onPlayerGasMaskDrain")

        function SusceptibleMod.onPlayerGasMaskDrain(player)
            if not player then
                return;
            end

            local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player);
            if mask and not SusUtil.isBroken(item) then
                local damage = ( SandboxVars.Susceptible.TimeForNaturalDrain * math.exp(2 - player:getStats():getEndurance()) )^3
                SusceptibleMod.damageMask(item, mask, damage);
            end
        end
    else
        DebugLog.log("Susceptible_Overhaul: Removing SusceptibleMod.onGasMaskDrain")

        Events.EveryTenMinutes.Remove(SusceptibleMod.onGasMaskDrain)
    end
end

Events.OnGameStart.Add(OnGameStart)