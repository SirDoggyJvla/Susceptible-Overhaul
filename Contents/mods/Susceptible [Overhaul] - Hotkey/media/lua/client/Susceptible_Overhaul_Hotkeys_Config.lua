--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file sends the key configs to Eggon's Hotkeys.

]]--
--[[ ================================================ ]]--

--- Import modules
local Susceptible_Overhaul = require "Susceptible_Overhaul_module"
require "Susceptible_Overhaul_Hotkeys"

local function equipSusceptibleProtection()
    Susceptible_Overhaul.equipSusceptibleProtection()
end

local function changeFilterOxygenTank()
    Susceptible_Overhaul.changeFilterOxygenTank()
end

local keyConfigs = {
    equipSusceptibleProtection = {
	    isHotAction = true,
        isFlexKey = true,
		action = equipSusceptibleProtection,
		displayName = getText("UI_optionscreen_binding_equipSusceptibleProtection"),
        keyCode = 0,
    },
    changeFilterOxygenMask = {
        isHotAction = true,
        isFlexKey = true,
		action = changeFilterOxygenTank,
		displayName = getText("UI_optionscreen_binding_equipSusceptibleProtection2"),
        keyCode = 0,
    },
}
EHK_Plugin:AddConfigs(keyConfigs)