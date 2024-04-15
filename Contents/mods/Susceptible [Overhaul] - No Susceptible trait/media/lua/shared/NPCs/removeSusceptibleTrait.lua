--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file removes the Susceptible trait from the game when loaded.

]]--
--[[ ================================================ ]]--

require "createSusceptibleTrait"

local function initSusceptibleTrait()
    TraitFactory.addTrait("Susceptible", getText("UI_trait_Susceptible"), -11, getText("UI_trait_SusceptibleDesc"), true, false);
end

Events.OnGameBoot.Add(initSusceptibleTrait);