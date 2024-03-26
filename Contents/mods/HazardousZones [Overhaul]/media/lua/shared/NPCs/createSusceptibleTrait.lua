local function initSusceptibleTrait()
	if getActivatedMods():contains("HazardousZones_Overhaul_NoSusceptibleTrait") == false then
		TraitFactory.addTrait("Susceptible", getText("UI_trait_Susceptible"), -11, getText("UI_trait_SusceptibleDesc"), false, false);
	end
end

Events.OnGameBoot.Add(initSusceptibleTrait);