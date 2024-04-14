require "Susceptible/SusceptibleTrait"

-- import localy for performance reasons
local SusceptibleMaskItems = SusceptibleMaskItems
local SusceptibleRepairTypes = SusceptibleRepairTypes

local original_new = ISWearClothing.new;
function ISWearClothing:new(character, item, time)
	local o = original_new(self, character, item, time);
    local data = SusceptibleMaskItems:getMaskData(item)
    if SandboxVars.Susceptible.AllowMaskRemovalDuringWalk and data and data.repairType ~= SusceptibleRepairTypes.OXYGEN then
        -- I think your character can focus on the most important thing in their life while moving
        o.stopOnWalk = false;
        o.stopOnRun = false;
    end
    return o
end