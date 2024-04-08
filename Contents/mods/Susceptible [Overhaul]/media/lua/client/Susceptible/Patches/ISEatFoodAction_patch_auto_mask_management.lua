require "TimedActions/ISEatFoodAction"
require "Susceptible/SusceptibleTrait"

ISEatFoodAction.start_prepatch_susceptible = ISEatFoodAction.start;

local startEatAction = function(self)
	local mask = SusceptibleMod.getEquippedMaskItemAndData(self.character);
	if mask then
		local threat = SusceptibleMod.threatByPlayer[self.character];
		if threat and threat > 0 then
			self:forceStop();
			return;
		end

		self:stop();
		self:autoManageMask(mask);
		return;
	end

	return self:start_prepatch_susceptible();
end


ISEatFoodAction.autoManageMask = function(self, mask)
	ISTimedActionQueue.add(ISUnequipAction:new(self.character, mask, 50));
	ISTimedActionQueue.add(ISEatFoodAction:new(self.character, self.item, self.percentage));
	ISTimedActionQueue.add(ISWearClothing:new(self.character, mask, 50));
end

local function patchEatFunction()
	ISEatFoodAction.start_prepatch_susceptible = ISEatFoodAction.start;
	ISEatFoodAction.start = startEatAction
end

-- Delay until the world is loading so we get to go first in the execution order vs other mods
-- Important since we plan on fully cancelling the action
Events.OnInitWorld.Add(patchEatFunction)