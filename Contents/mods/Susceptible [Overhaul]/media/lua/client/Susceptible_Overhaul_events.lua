
--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the events of the mod of Susceptible - Overhaul.

]]--
--[[ ================================================ ]]--

--- Requires
require "Susceptible_Overhaul_patcher"

--- Remove the current Susceptible onPlayerUpdate and replace it with my own 
Events.OnPlayerUpdate.Remove(SusceptibleMod.onPlayerUpdate)
Events.OnPlayerUpdate.Add(SusceptibleMod.onPlayerUpdate)