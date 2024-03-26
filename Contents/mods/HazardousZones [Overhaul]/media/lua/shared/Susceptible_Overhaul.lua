local Susceptible_Overhaul = {}

-- from SirDoggyJvla: import Susceptible stuff
require "Susceptible/SusceptibleTrait"
local SusUtil = require "Susceptible/SusceptibleUtil"


-- from SirDoggyJvla: creates the mask UI and updates the durability
function Susceptible_Overhaul.maskUI(player,threatLevel,gasMask)
    if player:isDead() then
        return;
    end

	-- retrieve mask item type and info
    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player)

    if not SusceptibleMod.uiByPlayer[player] then
        SusceptibleMod.createMaskUi(player);
    end

	-- makes sure mask item is not broken
    local isBroken = not item or SusUtil.isBroken(item);




	if gasMask and not isBroken then
        -- set mask image
        SusceptibleMod.uiByPlayer[player]:updateMaskImage(item, mask, threatLevel, isBroken)

		-- get item data, notably durabilityMax
		local data = SusUtil.getItemModData(item);
				
		--local durability = SusUtil.getNormalizedDurability(item)
		local durability = data.durability / data.durabilityMax
		
		SusceptibleMod.uiByPlayer[player]:updateMaskInfo(true, durability, 0)
	else
        item = nil
        -- set mask image
        SusceptibleMod.uiByPlayer[player]:updateMaskImage(item, mask, threatLevel, isBroken)

		SusceptibleMod.uiByPlayer[player]:updateMaskInfo(false, 0, 0)
	end

end

-- from SirDoggyJvla: function taken from my CSZ - Overhaul to check if the player has a gasmask 
function Susceptible_Overhaul.isWearingGasMask()
	-- from SirDoggyJvla: almost everything here was modified to adapt to Susceptible mask check
	local item, mask = SusceptibleMod.getEquippedMaskItemAndData(getPlayer());

    if not SusUtil then
        SusUtil = require "Susceptible/SusceptibleUtil"
    end
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

    if not SusUtil then
        SusUtil = require "Susceptible/SusceptibleUtil"
    end
    if not mask or SusUtil.isBroken(item) then
        return false
    end

	-- checks if mask with filter/oxygen is on, else return false for no mask
	if mask.repairType == SusceptibleRepairTypes.OXYGEN then
		return true
	end

	return false
end

function Susceptible_Overhaul.damageMask()
    -- retrieve mask item type and info
    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(getPlayer())
    if not mask then return end

    -- get item data, notably durabilityMax
    local data = SusUtil.getItemModData(item)
    
    -- maskDamageRate / time to drain = durability loss per minute (bcs function everyMinute)
    local maskDamageRate = data.durabilityMax / 60;

    -- calculate durability loss depending on mask type, priotizing oxygen tanks
    if mask.repairType == SusceptibleRepairTypes.OXYGEN and SandboxVars.HazardousZones.DrainageOxyTank then
        local condition = item:getCondition() / item:getConditionMax() + 0.1
        condition = condition * condition
        if condition > 1 then
            condition = 1;
        end

        local conditionMult = 1.0 / condition; -- You're leaking :)
        SusceptibleMod.damageMask(item, mask, conditionMult * maskDamageRate / SandboxVars.HazardousZones.TimetoDrainOxyTank ) -- Constant drain rate for oxygen based protection
    elseif mask.repairType == SusceptibleRepairTypes.FILTER and SandboxVars.HazardousZones.DrainageFilter then
        local damage = maskDamageRate / SandboxVars.HazardousZones.TimetoDrainFilter
        SusceptibleMod.damageMask(item, mask, damage)
    end
end

return Susceptible_Overhaul