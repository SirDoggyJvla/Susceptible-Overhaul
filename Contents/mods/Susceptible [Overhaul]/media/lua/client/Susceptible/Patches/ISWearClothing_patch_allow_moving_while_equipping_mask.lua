require "Susceptible/SusceptibleTrait"

local original_new = ISWearClothing.new;

-- import localy for performance reasons
local SusceptibleMaskItems = SusceptibleMaskItems

function ISWearClothing:new(character, item, time)
	local o = original_new(self, character, item, time);
    if SandboxVars.Susceptible.AllowMaskRemovalDuringWalk and SusceptibleMaskItems:getMaskData(item) then
        -- I think your character can focus on the most important thing in their life while moving
        o.stopOnWalk = false;
        o.stopOnRun = false;
    end
    return o
end