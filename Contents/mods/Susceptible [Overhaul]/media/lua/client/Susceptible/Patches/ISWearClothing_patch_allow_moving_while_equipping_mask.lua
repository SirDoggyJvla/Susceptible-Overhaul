require "Susceptible/SusceptibleTrait"

local original_new = ISWearClothing.new;

function ISWearClothing:new(character, item, time)
	local o = original_new(self, character, item, time);
    if SusceptibleMaskItems:getMaskData(item) then
        -- I think your character can focus on the most important thing in their life while moving
        o.stopOnWalk = false;
        o.stopOnRun = false;
    end
    return o
end