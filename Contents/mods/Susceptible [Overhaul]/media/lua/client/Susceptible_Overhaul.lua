
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

local player = player or nil

--- Retrieves SusceptibleUtil and patches SusUtil.isBroken with an improved method to check for holes in the protections if activated in the sandbox options.
local function OnGameStart()
    -- modules
    SusUtil = require "Susceptible/SusceptibleUtil"
    UiUtil = require "Susceptible/UiUtil"

    player = getPlayer()

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
            or item:getHolesNumber() > 0 -- from SirDoggyJvla: makes sure hazmat doesn't have holes
            then
                return true;
            elseif data.durabilityMax then
                return data.durability <= 0;
            end
            return false;
        end
    end
end

--- Add and remove Events to allow reload of lua files in-game.
Events.OnGameStart.Remove(OnGameStart)
Events.OnGameStart.Add(OnGameStart)

function SusceptibleMod.onPlayerUpdate(player)
    if not SusceptibleMod.isPlayerSusceptible(player) then
        SusceptibleMod.updateMaskInfoDisplay(player, 0)
        return
    elseif not SusceptibleMod.shouldPlayerUpdate(player) then
        return
    end

    local infectionRoll = ZombRandFloat(0.0, 1.0);
    local threatLevel, paranoiaLevel = SusceptibleMod.calculateThreat(player, infectionDistance);

    SusceptibleMod.updateMaskInfoDisplay(player, threatLevel + paranoiaLevel);
    SusceptibleMod.threatByPlayer[player] = threatLevel;

    local activeThreatLevel = SusceptibleMod.reduceThreatWithMask(player, threatLevel);
    if activeThreatLevel > 0 then

        local stress = player:getStats():getStress();
        if stress < 1 then
            player:getStats():setStress(stress + activeThreatLevel/50);
        end

        local infectionChance = SusceptibleMod.calculateInfectionChance(player, activeThreatLevel);
        --print(infectionChance)

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

Events.OnPlayerUpdate.Remove(SusceptibleMod.onPlayerUpdate)
Events.OnPlayerUpdate.Add(SusceptibleMod.onPlayerUpdate)

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
    end

    -- verify player is not in danger, else set threatLevel to 2 to trigger
    -- the toxic interface from Susceptible
    local check = nil
    for k in pairs(modData["Susceptible_Overhaul"].InDanger) do
        check = true
        break
    end
    if check then
        threatLevel = 2
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

-- from SirDoggyJvla: function taken from my CSZ - Overhaul to check if the player has a gasmask 
function Susceptible_Overhaul.isWearingGasMask()
	-- from SirDoggyJvla: almost everything here was modified to adapt to Susceptible mask check
	local item, mask = SusceptibleMod.getEquippedMaskItemAndData(getPlayer());

    if not mask or SusUtil.isBroken(item) then
        return false
    end

	-- checks if mask with filter/oxygen is on, else return false for no mask
	if mask.repairType == SusceptibleRepairTypes.FILTER then
		return true
	end

	return false
end

-- from SirDoggyJvla: function taken from my CSZ - Overhaul to check if the player has a hazmat
function Susceptible_Overhaul.isWearingHazmat()
	-- from SirDoggyJvla: almost everything here was modified to adapt to Susceptible mask check
	local item, mask = SusceptibleMod.getEquippedMaskItemAndData(getPlayer());
    if not mask or SusUtil.isBroken(item) then
        return false
    end

	-- checks if mask with filter/oxygen is on, else return false for no mask
	if mask.repairType == SusceptibleRepairTypes.OXYGEN then
		return true
	end

	return false
end

function Susceptible_Overhaul.damageMask(drain_oxygen,drain_filter,oxygenTank_drainage,filter_drainage)
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