
--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the events of the mod of Susceptible [Overhaul].

]]--
--[[ ================================================ ]]--

--- Requires
require "Susceptible_Overhaul_patcher"
require "Susceptible_Overhaul"

--- Import modules
local Susceptible_Overhaul = require "Susceptible_Overhaul_module"

--- Remove the current Susceptible onPlayerUpdate and replace it with my own 
Events.OnPlayerUpdate.Add(SusceptibleMod.onPlayerUpdate)

Events.EveryOneMinute.Add(Susceptible_Overhaul.DamageProtection)

Events.OnPlayerUpdate.Add(Susceptible_Overhaul.OnPlayerUpdate)