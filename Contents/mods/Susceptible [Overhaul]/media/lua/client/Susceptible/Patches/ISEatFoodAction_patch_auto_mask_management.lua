require "TimedActions/ISEatFoodAction"
require "Susceptible/SusceptibleTrait"

-- from SirDoggyJvla
require "ISUI/ISInventoryPaneContextMenu"

-- import localy for performance reasons
local SusceptibleMod = SusceptibleMod

ISEatFoodAction.start_prepatch_susceptible = ISEatFoodAction.start

ISDrinkFromBottle.start_prepatch_susceptible = ISDrinkFromBottle.start

--- Start drinking action
local startDrinkingAction = function(self)
	if SandboxVars.Susceptible.RemoveMaskWhenEating then
		local mask = SusceptibleMod.getEquippedMaskItemAndData(self.character)
		if mask then
			local threat = SusceptibleMod.threatByPlayer[self.character]
			if threat and threat > 0 then
				self:forceStop()
				return
			end

			self:stop()
			self:autoManageMask(mask)
			return
		end
	end

	return self:start_prepatch_susceptible()
end


ISDrinkFromBottle.autoManageMask = function(self,mask)
	ISTimedActionQueue.add(ISUnequipAction:new(self.character, mask, 50))
	ISTimedActionQueue.add(ISDrinkFromBottle:new(self.character, self.item, self.uses))
	ISTimedActionQueue.add(ISWearClothing:new(self.character, mask, 50))
end

--- Start eating action
local startEatAction = function(self)
	if SandboxVars.Susceptible.RemoveMaskWhenEating then
		local mask = SusceptibleMod.getEquippedMaskItemAndData(self.character)
		if mask then
			local threat = SusceptibleMod.threatByPlayer[self.character]
			if threat and threat > 0 then
				self:forceStop()
				return
			end

			self:stop()
			self:autoManageMask(mask)
			return
		end
	end

	return self:start_prepatch_susceptible()
end

ISEatFoodAction.autoManageMask = function(self, mask)
	ISTimedActionQueue.add(ISUnequipAction:new(self.character, mask, 50))
	ISTimedActionQueue.add(ISEatFoodAction:new(self.character, self.item, self.percentage))
	ISTimedActionQueue.add(ISWearClothing:new(self.character, mask, 50))
end

--- Patch actions
local function patchEatFunction()
	-- eating action patch
	ISEatFoodAction.start_prepatch_susceptible = ISEatFoodAction.start
	ISEatFoodAction.start = startEatAction

	-- drinking action patch
	ISDrinkFromBottle.start_prepatch_susceptible = ISDrinkFromBottle.start
	ISDrinkFromBottle.start = startDrinkingAction
end

-- Delay until the world is loading so we get to go first in the execution order vs other mods
-- Important since we plan on fully cancelling the action
Events.OnInitWorld.Add(patchEatFunction)