-- from SirDoggyJvla: import module
local Susceptible_Overhaul = require "Susceptible_Overhaul"

local HZ = HazardousZones.Client
local HZUtils = HazardousZones.Shared.Utils
local HZConsts = HazardousZones.Constants

local restrictedCells = {
    {{0,0}, {9,52}},
    {{10,0}, {18,18}},
    {{19,0}, {40,16}},
    {{41,0}, {65,3}},
    {{24,17}, {41,21}},
    {{24,22}, {35,24}},
    {{47,4}, {65,52}},
    {{10,44}, {46,52}}
}

function HZUtils:validateCell(cX, cY)
    for _, chunk in pairs(restrictedCells) do
        local x1 = chunk[1][1]
        local y1 = chunk[1][2]
        local x2 = chunk[2][1]
        local y2 = chunk[2][2]

        if ((cX >= x1 and cX <= x2) and (cY >= y1 and cY <= y2)) then return false end
    end

    return true
end

function HZUtils:getRandomSquare()
    local playerObj = getPlayer()
    local metaGrid = getWorld():getMetaGrid()
    local cX = ZombRand(metaGrid:getMinX(), metaGrid:getMaxX())
    local cY = ZombRand(metaGrid:getMinY(), metaGrid:getMaxY())
    local isValidChunk = metaGrid:isValidChunk(cX*30, cY*30)

    if not isValidChunk or not HZUtils:validateCell(cX, cY) then return false end

    return {
        x = cX * 300,
        y = cY * 300,
        z = 0
    }
end

function HZUtils:getFullFilename(fileName)
    return "Exports"..getFileSeparator()..fileName..".json"
end

function HZUtils:readJSON(fileName)
    local r = getModFileReader("HazardousZones", fileName, false);

    if r then
        local lines = "";

        local line = r:readLine()
        while line do
            lines = lines .. line .. "\r\n";
            line = r:readLine()
        end    
        
        r:close();
        if lines == "" then
            return nil;
        end

        return HZUtils.JSON.parse(lines);
    end
    return nil;
end

function HZUtils:writeJSON(fileName, json)
    local createFile = true
    local appendToFile = false
    local writer = getModFileWriter("HazardousZones", fileName, createFile, appendToFile);

    if type(json) ~= "string" then
        json = HZUtils.JSON.stringify(json);
    end

    writer:write(json);
    writer:close();
end

function HZUtils:getRandomEpicentre()
    local sq
    local iteration = 0

    while not sq do
        iteration = iteration + 1
        sq = HZUtils:getRandomSquare()
    end

    if isDebugEnabled() then
        print("[RANDOM ZONES] Got valid square in "..tostring(iteration).." cycles [x="..sq.x..", y="..sq.y..", z="..sq.z.."]")
    end

    return sq
end

function HZUtils:toFixedNumber(number, digits)
    local s = "%."..digits.."f";
    return string.format(s, tostring(number));
end

function HZUtils:getTableLength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function HZUtils:dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. HZUtils:dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function HZUtils:printTable(table)
    print(HZUtils:dump(table))
end

function HZUtils:getEffectByExposure(hazardType, exposureValue)
    local effects = HazardousZones.Constants.EffectsData[hazardType]
    
    if (effects == nil) then return end
    
    local severity = nil
    local effect = nil
    for s, e in pairs(effects) do
        if (exposureValue >= e.exposureLimit) then
            severity = s
            effect = e
        end
    end
    return {
        severity = severity, 
        effect = effect
    }
end

function HZUtils:getRandomBodyPart(player)
    local bodyDamage = player:getBodyDamage()
    return bodyDamage:getBodyPart(BodyPartType.FromIndex(ZombRand(BodyPartType.ToIndex(BodyPartType.MAX))))
end

function HZUtils:getSpecificBodyPart(player, bodyPart)
    local bodyDamage = player:getBodyDamage()
    local part = BodyPartType[bodyPart]
    if part == nil then return end
    return bodyDamage:getBodyPart(part)
end

function HZUtils:arrayContains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    
    return false
end

function HZUtils:arrayIndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function HZUtils:getWornItemByType(player, itemType)
    local items = player:getWornItems()
    for itemIndex = 1, items:size() - 1 do
        local item = items:getItemByIndex(itemIndex)
        if item:getType() == itemType then return item end
    end
    return false
end

function HZUtils:isGasMask(item)
    if not item then return false end
    if item:getCondition() < 3 then return false end
    if HZUtils:arrayContains(HZConsts.ItemTypes.GasMask, item:getType()) then return true end
    if string.find(SandboxVars.HZ.GasMaskTypes, item:getType()) then return true end
    if Susceptible_Overhaul.isWearingGasMask() and not Susceptible_Overhaul.isWearingHazmat() then return true end
    return false
end

function HZUtils:isHazmat(item)
    if not item then return false end
    if item:getCondition() < 3 then return false end
    if item.getHolesNumber and item:getHolesNumber() > 0 then return false end
    if HZUtils:arrayContains(HZConsts.ItemTypes.HazmatSuit, item:getType()) then return true end
    if string.find(SandboxVars.HZ.HazmatSuitTypes, item:getType()) then return true end
    if Susceptible_Overhaul.isWearingHazmat() and not Susceptible_Overhaul.isWearingGasMask() then return true end
    return false
end

function HZUtils:isPlayerUseGasMask(player)
    local items = player:getWornItems()
    
    for itemIndex = 1, items:size() - 1 do
        local item = items:getItemByIndex(itemIndex)
        if HZUtils:isGasMask(item) then 
            return true
        end
    end
    return false
end

function HZUtils:isPlayerUseHazmatSuit(player)
    local items = player:getWornItems()
    
    for itemIndex = 0, items:size() - 1 do
        local item = items:getItemByIndex(itemIndex)
        -- local isHazmat = item and ((HZUtils:arrayContains(HZConsts.ItemTypes.HazmatSuit, item:getType())) or (item:hasTag("HazmatSuit"))) and item:getHolesNumber() == 0
        
        if HZUtils:isHazmat(item) then 
            return true
        end
    end
    return false
end

function HZUtils:isItemHasTagAndActivated(item, tag)
    if not item then return false end
    
    if item
    and item:hasTag(tag) 
    and item:isActivated() 
    and item:getUsedDelta() > 0
    then
        return true
    end
    
    return false
end

function HZUtils:isPlayerHasActivatedItemEquippedByTag(player, tag)
    local attachedItems = player:getAttachedItems()
    local primaryEquippedItem = player:getPrimaryHandItem()
    local secondaryEquippedItem = player:getSecondaryHandItem()
    
    if primaryEquippedItem and HZUtils:isItemHasTagAndActivated(primaryEquippedItem, tag) then
        return primaryEquippedItem
    end
    
    if secondaryEquippedItem and HZUtils:isItemHasTagAndActivated(secondaryEquippedItem, tag) then
        return secondaryEquippedItem
    end
    
    for i = 0, attachedItems:size() - 1 do
        local item = attachedItems:getItemByIndex(i)
        if HZUtils:isItemHasTagAndActivated(item, tag) then
            return item
        end
    end
    
    return
end

function HZUtils:getSoundByHazardTypeAndGain(hazardType, gain)
    local s
    
    if hazardType == "radiation" then
        if gain > 0 and gain <= 25 then
            s = "GeigerLow"
        elseif gain > 25 and gain <= 50 then
            s = "GeigerMedium"
        elseif gain > 50 and gain <= 90 then
            s = "GeigerHigh"
        elseif gain > 90 then
            s = "GeigerHighestAlert"
        end
        
        return s
    elseif hazardType == "biological" then
        if gain > 0 and gain <= 33 then
            s = "GasDetectorLow"
        elseif gain > 33 and gain <= 66 then
            s = "GasDetectorMedium"
        elseif gain > 66 then
            s = "GasDetectorHigh"
        end
        
        return s
    end
    
    return false
end

function HZUtils:doDetector(player, item, hazardType, gain)
    if not item or item == false then return false end
    local s = HZUtils:getSoundByHazardTypeAndGain(hazardType, gain)
    HZ:setDetectorMoodle(item, hazardType, gain)
    sound = HZ:playSound(player, s)
end

function HZUtils:doGeigerFalseAlarmCheck(player, geigerDetector)
    if geigerDetector then 
        HZ:stopAllGeigerSound(player)
        
        local falsePositiveRoll = ZombRand(1,100)
        local falsePositiveGain = ZombRand(25, 90)
        local falsePositiveSettings = HZSettings.Items[geigerDetector:getType()]
        local falsePositiveTrigger = false
        
        if falsePositiveSettings then 
            if falsePositiveRoll < falsePositiveSettings.FalsePositiveRatio then
                if isDebugEnabled() then
                    print(string.format("[Geiger FALSE POSITIVE] %s has triggered a false positive alarm [gain=%d, roll=%d, ratio=%d]", geigerDetector:getType(),falsePositiveGain, falsePositiveRoll, falsePositiveSettings.FalsePositiveRatio))
                end
                HZUtils:doDetector(player, geigerDetector, "radiation", falsePositiveGain)
                falsePositiveTrigger = true
            end
        end
        
        -- normal radiation difference imitation
        if not falsePositiveTrigger then HZUtils:doDetector(player, geigerDetector, "radiation", ZombRand(5, 24)) end
    end
end

function HZUtils:doGasDetectorFalseAlarmCheck(player, gasDetector)
    if gasDetector then 
        HZ:stopAllGasDetectorSound(player)
        
        local falsePositiveRoll = ZombRand(100)
        local falsePositiveGain = ZombRand(25, 90)
        local falsePositiveSettings = HZSettings.Items[gasDetector:getType()]
        local falsePositiveTrigger = false
        
        if falsePositiveSettings then 
            if falsePositiveRoll < falsePositiveSettings.FalsePositiveRatio then
                if isDebugEnabled() then
                    print(string.format("[GasDetector FALSE POSITIVE] %s has triggered a false positive alarm [gain=%d, roll=%d, ratio=%d]", gasDetector:getType(),falsePositiveGain, falsePositiveRoll, falsePositiveSettings.FalsePositiveRatio))
                end
                HZUtils:doDetector(player, gasDetector, "biological", falsePositiveGain)
                falsePositiveTrigger = true
            end
        end
        
        -- normal radiation difference imitation
        if not falsePositiveTrigger then HZUtils:doDetector(player, gasDetector, "biological", ZombRand(5, 24)) end
    end
end

function HZUtils:setSoundAndMoodlesByGains(player, gains)  
    local gasDetector = HZUtils:isPlayerHasActivatedItemEquippedByTag(player, "GasDetector")
    local geigerDetector = HZUtils:isPlayerHasActivatedItemEquippedByTag(player, "GeigerCounter")
    
    HZ:hideAllDetectorMoodle()
    
    for hazardType, gain in pairs(gains) do
        if (hazardType == "radiation") then
            if gain <= 25 then
                -- False positive alarms if enabled
                if SandboxVars.HZ.DetectorFalsePositiveAlarms then
                    HZUtils:doGeigerFalseAlarmCheck(player, geigerDetector)
                else
                    HZ:stopAllGeigerSound(player)
                    HZUtils:doDetector(player, geigerDetector, "radiation", 5)
                end
            else 
                HZ:stopAllGeigerSound(player)
                HZUtils:doDetector(player, geigerDetector, "radiation", gain)
            end
        elseif hazardType == "biological" then
            if gain <= 33 then
                if SandboxVars.HZ.DetectorFalsePositiveAlarms then
                HZUtils:doGasDetectorFalseAlarmCheck(player, gasDetector)
                else
                    HZ:stopAllGasDetectorSound(player)
                    HZUtils:doDetector(player, gasDetector, "biological", 5)
                end
            else
                HZ:stopAllGasDetectorSound(player)
                HZUtils:doDetector(player, gasDetector, "biological", gain)
            end
        end
    end
end

function HZUtils:getRandomMaterialCountByPerkLevel(player, perk, _min, _max, _div)
    local perkLevel = player:getPerkLevel(perk) or 0
    local min = _min or 1
    local max = _max or 10
    local div = _div or 2

    return ZombRand(min, math.ceil((max - math.ceil(max / perkLevel)) / div))
end