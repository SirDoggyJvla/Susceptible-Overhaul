require "TimedActions/ISEatFoodAction"
require "Susceptible/SusceptibleTrait"

-- from SirDoggyJvla
require "ISUI/ISInventoryPaneContextMenu"

-- import localy for performance reasons
local SusceptibleMod = SusceptibleMod

--#region Patch ISDrinkFromBottle to remove mask

ISDrinkFromBottle.start_prepatch_susceptible = ISDrinkFromBottle.start

--- Start drinking action
local startDrinkingAction = function(self)
	if SandboxVars.Susceptible.RemoveMaskWhenEating then
		local mask = SusceptibleMod.getEquippedMaskItemAndData(self.character)
		if mask then
			if SusceptibleMod.isPlayerSusceptible(self.character) then
				local threat = SusceptibleMod.threatByPlayer[self.character]
				if threat and threat > 0 then
					self:forceStop()
					return
				end
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

--#endregion

--#region Patch drinking from a water source to remove mask

ISTakeWaterAction.start_prepatch_susceptible = ISTakeWaterAction.start

--- Start drinking action
local startDrinkingFromWorldAction = function(self)
	-- differenciate between drink water and take water in container
	if SandboxVars.Susceptible.RemoveMaskWhenEating and not self.item then 
		local mask = SusceptibleMod.getEquippedMaskItemAndData(self.character)
		if mask then
			if SusceptibleMod.isPlayerSusceptible(self.character) then
				local threat = SusceptibleMod.threatByPlayer[self.character]
				if threat and threat > 0 then
					self:forceStop()
					return
				end
			end

			self:stop()
			self:autoManageMask(mask)
			return
		end
	end

	return self:start_prepatch_susceptible()
end


ISTakeWaterAction.autoManageMask = function(self,mask)
	ISTimedActionQueue.add(ISUnequipAction:new(self.character, mask, 50))
	ISTimedActionQueue.add(ISTakeWaterAction:new(self.character, self.item, self.waterUnit,self.waterObject,nil,self.oldItem))
	ISTimedActionQueue.add(ISWearClothing:new(self.character, mask, 50))
end

--#endregion

--#region Patch ISEatFoodAction to remove mask

ISEatFoodAction.start_prepatch_susceptible = ISEatFoodAction.start

--- Start eating action
local startEatAction = function(self)
	if SandboxVars.Susceptible.RemoveMaskWhenEating then
		local mask = SusceptibleMod.getEquippedMaskItemAndData(self.character)
		if mask then
			if SusceptibleMod.isPlayerSusceptible(self.character) then
				local threat = SusceptibleMod.threatByPlayer[self.character]
				if threat and threat > 0 then
					self:forceStop()
					return
				end
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

--#endregion

--#region Patch ISTakePillAction to remove mask

ISTakePillAction.start_prepatch_susceptible = ISTakePillAction.start

--- Start eating action
local startTakePillAction = function(self)
	if SandboxVars.Susceptible.RemoveMaskWhenEating then
		local mask = SusceptibleMod.getEquippedMaskItemAndData(self.character)
		if mask then
			if SusceptibleMod.isPlayerSusceptible(self.character) then
				local threat = SusceptibleMod.threatByPlayer[self.character]
				if threat and threat > 0 then
					self:forceStop()
					return
				end
			end

			self:stop()
			self:autoManageMask(mask)
			return
		end
	end

	return self:start_prepatch_susceptible()
end

ISTakePillAction.autoManageMask = function(self, mask)
	ISTimedActionQueue.add(ISUnequipAction:new(self.character, mask, 50))
	ISTimedActionQueue.add(ISTakePillAction:new(self.character, self.item, self.maxTime))
	ISTimedActionQueue.add(ISWearClothing:new(self.character, mask, 50))
end

--#endregion

--- Patch actions
local function patchEatFunction()
	-- drinking action patch
	ISDrinkFromBottle.start_prepatch_susceptible = ISDrinkFromBottle.start
	ISDrinkFromBottle.start = startDrinkingAction

	-- drinking from context menu patch
	ISTakeWaterAction.start_prepatch_susceptible = ISTakeWaterAction.start
	ISTakeWaterAction.start = startDrinkingFromWorldAction

	-- eating action patch
	ISEatFoodAction.start_prepatch_susceptible = ISEatFoodAction.start
	ISEatFoodAction.start = startEatAction

	-- eating action patch
	ISTakePillAction.start_prepatch_susceptible = ISTakePillAction.start
	ISTakePillAction.start = startTakePillAction
end

-- Delay until the world is loading so we get to go first in the execution order vs other mods
-- Important since we plan on fully cancelling the action
Events.OnInitWorld.Add(patchEatFunction)