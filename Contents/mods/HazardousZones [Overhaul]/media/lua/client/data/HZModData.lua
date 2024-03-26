-- from SirDoggyJvla: import module
local Susceptible_Overhaul = require "Susceptible_Overhaul"

local HZ = HazardousZones.Client
local HZUtils = HazardousZones.Shared.Utils
local HZConsts = HazardousZones.Constants
local HZItemSettings = HazardousZones.Settings.Items

local function getPlayerModData() 
    local player = getPlayer()
    local playerModData = player:getModData()
    
    if playerModData.HazardousZones == nil then
        playerModData.HazardousZones = {
            exposures = {},
            protections = {}
        }
    end
    
    return playerModData.HazardousZones
end

function HZ:modifyPlayerExposure(hazardType, exposure, reason)
    local exposures = HZ:getPlayerExposures()
    local protections = HZ:calculateProtections(hazardType);
    local increment = exposure - (protections * exposure);

    if increment < 0 then increment = 0 end

    if not exposures[hazardType] then
        exposures[hazardType] = increment  
    else
        exposures[hazardType] = exposures[hazardType] + increment
    end

    if isDebugEnabled() then
        local debugText = string.format("[PLAYER EXPOSURE:MODIFY] The player is exposed to %s hazard and got %s RAD. Protections: %s, Reason: %s", hazardType, tostring(exposure), tostring(protections), reason)
        print(debugText)
    end
end

function HZ:getIncrementWithoutProtections(zoneData, gradualModifier)
    local increment = zoneData.hazard.exposurePerInGameMinute;

    if zoneData.gradualExposure then increment = increment - (increment * gradualModifier) end

    print("radinczd "..tostring(zoneData.gradualExposure))

    if increment < 0 then increment = 0 end

    return increment;
end

function HZ:increasePlayerExposure(zoneData, gradualModifier)
    local exposures = HZ:getPlayerExposures()
    local hazardType = zoneData.hazard.type

    local protections = HZ:calculateProtections(hazardType);
    
    local increment = zoneData.hazard.exposurePerInGameMinute - (protections * zoneData.hazard.exposurePerInGameMinute);
    
    if zoneData.gradualExposure then increment = increment - (increment * gradualModifier) end
    
    if zoneData.gradualExposure then
        print ("increment="..increment..", epm="..zoneData.hazard.exposurePerInGameMinute..", gM="..gradualModifier)
    end
    
    if increment < 0 then increment = 0 end
    
    if not exposures[hazardType] then
        exposures[hazardType] = increment  
    else
        exposures[hazardType] = exposures[hazardType] + increment
    end

    local radInc = HZ:getIncrementWithoutProtections(zoneData, gradualModifier)

    print("radinc "..tostring(radInc))

    HZ:setExpData(hazardType, radInc)
    
    if (isDebugEnabled()) then
        local debugText = "The player is exposed to "..hazardType.." [increment="..increment.." protections="..protections.." exposure="..exposures[hazardType].."]"
        if zoneData.gradualExposure then debugText = debugText .. "[gradual=" .. gradualModifier .. "]" end
        print(debugText);
    end
end

function HZ:decreasePlayerExposure(hazardType, decrement, reason)
    local exposures = HZ:getPlayerExposures()
    if not exposures[hazardType] then
        return
    else
        exposures[hazardType] = exposures[hazardType] - decrement
    
        if exposures[hazardType] < 0 then 
            exposures[hazardType] = 0 
        end

        if isDebugEnabled() then
            print("[EXPOSURE DECREASE] Decreasing "..hazardType.." exposure for the player [decrement="..decrement..", newvalue="..exposures[hazardType]..", reason="..reason.."]")
        end
    end
end

function HZ:removePlayerExposures(hazardType)
    local modData = getPlayerModData()
    modData.exposures = {}
    print("all exposures has been removed from player")
end

function HZ:getPlayerExposures() 
    local modData = getPlayerModData()
    if modData.exposures then 
        if isDebugEnabled() then
            HZUtils:printTable(modData.exposures)
        end
        return modData.exposures
    else 
        return
    end
end

function HZ:setPlayerExposure(hazardType, exposure)
    local modData = getPlayerModData()
    local exposures = modData.exposures

    exposures[hazardType] = exposure
end

function HZ:getPlayerProtections()
    local modData = getPlayerModData()
    if modData.protections then 
        if isDebugEnabled() then
            HZUtils:printTable(modData.protections)
        end
        return modData.protections
    else 
        return {}
    end
end

function HZ:removePlayerProtections(hazardType, protectionType)
    local modData = getPlayerModData()
    if hazardType == "all" then 
        if isDebugEnabled() then print("Protections has been removed from player") end
        modData.protections = {}
        HZ:setIndralineMoodle(0.5)
        HZ:setIodineMoodle(0.5)
    else
        if modData.protections[hazardType] and modData.protections[hazardType][protectionType] then
            modData.protections[hazardType][protectionType] = nil
        end
    end
end

function HZ:applyProtectionModifiers(player, baseValue, modifiers)
    if not modifiers then return baseValue end
    
    local moddedValue = baseValue
    local modifierSum = 0
    
    -- checking modifiers by traits
    if modifiers.bytraits then
        for trait, modifier in pairs(modifiers.bytraits) do
            if player:HasTrait(string.lower(trait)) then
                modifierSum = modifierSum + modifier
            end
        end
        moddedValue = moddedValue + (moddedValue * modifierSum)
    end
    
    return moddedValue
end

-- runs only when a player is inside a zone

function HZ:calculateProtections(hazardType)
    local protections = HZ:getPlayerProtections()
    local currentTime = getGameTime():getWorldAgeHours()
    local timeDelta = 0
    local protection = 0
    local player = getPlayer()

    if protections and HZUtils:getTableLength(protections) > 0 and protections[hazardType] then 
        for itemType, pr in pairs(protections[hazardType]) do
            if HZItemSettings[itemType] and HZItemSettings[itemType].protections[hazardType] then
                local itemSettings = HZItemSettings[itemType]
                local protectionSettings = HZItemSettings[itemType].protections[hazardType]
                timeDelta = currentTime - pr.usedAt

                if (timeDelta <= itemSettings.duration) then
                    local itemProtectionValue = HZ:applyProtectionModifiers(player, protectionSettings.value, protectionSettings.modifiers)
                    protection = protection + itemProtectionValue
                end

                if isDebugEnabled() then
                    print("[CALCULATE PROTECTIONS] item="..itemType..", sum="..tostring(protection))
                end
            else
                if isDebugEnabled() then
                    print("[CALCULATE PROTECTIONS] No protection data found for item="..itemType)
                end
            end
        end
    end

    local activeProtection = 0

    local gasMask = Susceptible_Overhaul.isWearingGasMask()
    local hazmat = Susceptible_Overhaul.isWearingHazmat()

    if hazmat then
        if hazardType == 'radiation' then
            activeProtection = SandboxVars.HZ.HazmatSuitRadiationProtectionValue
        elseif hazardType == 'biological' then
            activeProtection = SandboxVars.HZ.HazmatSuitBiologicalProtectionValue
        end
        Susceptible_Overhaul.damageMask()
    elseif gasMask then
        if hazardType == 'radiation' then
            activeProtection = SandboxVars.HZ.GasMaskRadiationProtectionValue
        elseif hazardType == 'biological' then
            activeProtection = SandboxVars.HZ.GasMaskBiologicalProtectionValue
        end
        Susceptible_Overhaul.damageMask()
    end

    protection = protection + activeProtection

    if protection > SandboxVars.HZ.ItemProtectionCap then protection = SandboxVars.HZ.ItemProtectionCap end

    if isDebugEnabled() then
        print(string.format("value=%s activeProtection=%s cap=%s", tostring(protection), tostring(activeProtection), tostring(SandboxVars.HZ.ItemProtectionCap)));
    end

    return protection
end

-- Checking protection values from consumables like iodine pills and syringes, etc

function HZ:checkProtections(player)
    local modData = getPlayerModData()
    local protections = HZ:getPlayerProtections()
    local currentTime = getGameTime():getWorldAgeHours()
    local timeDelta = 0
    
    if not protections or not HZUtils:getTableLength(protections) then return 0 end

    for hazardType, data in pairs(protections) do 
        if not hazardType or not data then return end
        
        for itemType, protection in pairs(data) do
            local itemSettings = HZItemSettings[itemType]
            
            if not itemSettings then return end

            timeDelta = itemSettings.duration - (currentTime - protection.usedAt)

            local isItemWearedOff = timeDelta <= 0
            
            if isDebugEnabled() then
                print("[CHECK PROTECTIONS] timeDelta for "..itemType.."="..timeDelta)
            end

            if isItemWearedOff then
                local reduction = itemSettings.reductions[hazardType]
                
                if not reduction then 
                    if isDebugEnabled() then
                        print("[CHECK PROTECTIONS] Cannot find exposure reduction data for itemType="..itemType..", hazardType="..hazardType)
                    end
                    return 
                end

                local value = reduction.value

                -- if we have any reduction modifiers (by traits for example) we are applying them onto value
                if reduction.modifiers then
                    value = HZ:applyEffectModifiers(player, value, reduction.modifiers)
                end

                HZ:decreasePlayerExposure(hazardType, value, itemType)
                HZ:removePlayerProtections(hazardType, itemType)
            end

            HZ:setConsumableMoodleByTimeDelta(itemType, timeDelta)
        end
    end
end

function HZ:getGains() 
    local modData = getPlayerModData();
    if isDebugEnabled() then
        print(string.format("[GAINS] rad=%s, bio=%s", modData.gains.radiation, modData.gains.biological))
    end
    return modData.gains
end

function HZ:resetGains() 
    local modData = getPlayerModData();
    
    modData.gains = {
        radiation = 0,
        biological = 0
    } 

    if isDebugEnabled() then
        print("[GAINS] Reset...")
    end
end

function HZ:increaseGain(hazardType, gain) 
    local modData = getPlayerModData();
    
    if not modData.gains then 
        HZ:resetGain()
    end
    
    modData.gains[hazardType] = modData.gains[hazardType] + gain;
end

function HZ:setExpData(hazardType, exposure) 
    local modData = getPlayerModData();
    
    if not modData.expData then 
        modData.expData = {}
    end
    
    modData.expData[hazardType] = exposure;
end

function HZ:getExpData() 
    local modData = getPlayerModData();
    return modData.expData
end

function HZ:resetExpData() 
    local modData = getPlayerModData();
    
    modData.expData = {
        radiation = 0,
        biological = 0
    } 

    if isDebugEnabled() then
        print("[EXPDATA] Reset...")
    end
end

function HZ:setKnowledgeData(knowledge)
    local modData = getPlayerModData()
    
    if not modData.knowledges then
        modData.knowledges = {}
    end

    modData.knowledges[knowledge] = {
        createdAt = getGameTime():getWorldAgeHours()
    }
end

function HZ:getKnowledgeData(knowledge)
    local modData = getPlayerModData()

    if not modData.knowledges or not modData.knowledges[knowledge] then return nil end
    
    return modData.knowledges[knowledge]
end

function HZ:removeKnowledgeData(knowledge)
    local modData = getPlayerModData()

    modData.knowledges[knowledge] = nil
end

function HZ:getPlayerSettings()
    local modData = getPlayerModData();

    if not modData.settings then
        modData.settings = {}
    end

    return modData.settings;
end