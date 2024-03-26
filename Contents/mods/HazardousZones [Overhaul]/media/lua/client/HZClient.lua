-- from SirDoggyJvla: import module
local HZ_Overhaul = require "Susceptible_Overhaul"

if isServer() then
    return
end

local HZ         = HazardousZones.Client
local HZUtils    = HazardousZones.Shared.Utils
local HZConsts   = HazardousZones.Constants
local HZSettings = HazardousZones.Settings
local HZData     = HazardousZones.Data

local function calculateDamageByExposures()
    local playerExposures = HZ:getPlayerExposures()

    if not playerExposures then return end

    for hazardType, exposureValue in pairs(playerExposures) do
        local exposureEffectData = HZUtils:getEffectByExposure(hazardType, exposureValue)
        if (exposureEffectData == nil) then
            if isDebugEnabled() then
                print("No effect found with given hazard type. [hazardType="..hazardType.."]")
            end
        end
        if (exposureEffectData ~= nil and exposureEffectData.effect ~= nil and exposureEffectData.severity ~= "none") then
            if (isDebugEnabled()) then
                print("Calculating damages by exposures. [type="..hazardType..", severity="..exposureEffectData.severity..", exposure="..exposureValue.."]");
            end
            HZ:executeEffect(exposureEffectData.effect)
        else
            -- no need to do anything 
        end
    end
end

local function onGameBoot()
    print ('=== THANKS FOR USING HAZARDOUS ZONE | '..string.upper(getWorld():getGameMode())..' ===')
end

local function onGameStart()
    if isServer() then return end

    if isClient() then
        print("=== REQUESTING ZONES FROM SERVER ===")
        ModData.request('HZ.Zones')
        ModData.request('HZ.RndZones')
    else
        print("=== REQUESTING ZONES FROM LOCAL MOD DATA ===")
        HazardousZones.Data.Zones = ModData.getOrCreate('HZ.Zones')
        HazardousZones.Data.RndZones = ModData.getOrCreate('HZ.RndZones')
    end
end

local function onCreatePlayer()
    if isDebugEnabled() then
        print ('create player callback')
    end
end

local function onEveryOneMinute()
    local player = getPlayer()

    HZ:resetGains()
    HZ:resetExpData()

    local gasMask = HZ_Overhaul.isWearingGasMask()
    local hazmat = HZ_Overhaul.isWearingHazmat()

    if gasMask or hazmat then
        gasMask = true
    end

    HZ_Overhaul.maskUI(player,0,gasMask)

    if player:isGodMod() or player:isDead() then
        if isDebugEnabled() then
            print("Ignoring collision check and damage calculation because player is admin or dead")
        end
    else
        -- detecting collision and calculating damages
        HZ:detectCollision()
        calculateDamageByExposures()
    end

    local gains = HZ:getGains()
    HZUtils:setSoundAndMoodlesByGains(player, gains)
end

local function onEveryTenMinutes()
    local player = getPlayer()

    HZ:checkProtections(player)

    if isDebugEnabled() then
        print('10 minutes has gone')
    end
end

local function onInitGlobalModData()
    if getWorld():getGameMode() ~= "Multiplayer" then
        print("[HZCLIENT:INIT_MOD_DATA]")
        HZData.Zones = ModData.getOrCreate("HZ.Zones")
        HZData.RndZones = ModData.getOrCreate("HZ.RndZones")
    end
end

local function onClothingUpdated(player) 
    if HZUtils:isPlayerUseGasMask(player) then
        HZ:setGasMaskMoodle(1)
    else
        HZ:setGasMaskMoodle(0.5)
    end
    
    if HZUtils:isPlayerUseHazmatSuit(player) then
        HZ:setHazmatSuitMoodle(1)
    else
        HZ:setHazmatSuitMoodle(0.5)
    end
end

Events.OnClothingUpdated.Add(onClothingUpdated)
Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameBoot.Add(onGameBoot)
Events.OnGameStart.Add(onGameStart)
Events.EveryOneMinute.Add(onEveryOneMinute)
Events.EveryTenMinutes.Add(onEveryTenMinutes)
Events.OnInitGlobalModData.Add(onInitGlobalModData)