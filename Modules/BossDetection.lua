local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local BossDetection = SwitchSwitch:NewModule("BossDetection", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0", "AceBucket-3.0")
local CurrentInstanceData = {}
local CurrentInstanceBossesDefeated = {}

local ActiveDetection = {
    ["types"] = {
        -- Simple array of types returned by GetInstanceData()
    },
    ["instances"] = {
        -- Will contain two sub-arrais of ids:
        -- difficulites -> Array of difficulties IDs to detect
        -- bossIDs -> array of bossIDs to detect
    }
}
local InstancesData = {}

function BossDetection:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:HookScript(GameTooltip, "OnTooltipSetUnit")
end

function BossDetection:OnDisable()
    self:Unhook(GameTooltip, "OnTooltipSetUnit")
    self:UnregisterEvent("PLAYER_STARTED_MOVING")
    self:UnregisterEvent("PLAYER_STOPPED_MOVING")
    self:UnregisterBucket("BOSS_KILL")
    self:CancelAllTimers()
end

function BossDetection:RegisterInstance(InstanceID, data)
    InstancesData[InstanceID] = data
end

function BossDetection:SetDetectingInstanceTypeEnabled(typeString, enabled)
    if(enabled) then
        if(not SwitchSwitch:table_has_value(ActiveDetection.types, typeString)) then
            table.insert(ActiveDetection.types, typeString)
            SwitchSwitch:DebugPrint("Registered instance type: " .. tostring(typeString))
        end
    else
        SwitchSwitch:table_remove_value(ActiveDetection.types, typeString)
        SwitchSwitch:DebugPrint("De-registered instance type: " .. tostring(typeString))
    end
end

-- Pass -1 for all dificulties
function BossDetection:SetDetectionForInstanceEnabled(InstanceID, difficultyID, enabled)
    if(type(InstancesData[InstanceID]) ~= "table") then
        SwitchSwitch:DebugPrint("Trying to detect a instance of which we do not have data.")
        return
    end

    -- Make sure that the array exits as below we are expeting the array to not be null or any other value
    local instanceDetectionData = ActiveDetection.instances[InstanceID] or {}
    if(type(instanceDetectionData["difficulites"]) ~= "table") then
        instanceDetectionData["difficulites"] = {}
    end

    if(enabled) then
        if(not SwitchSwitch:table_has_value(instanceDetectionData["difficulites"], difficultyID) and not SwitchSwitch:table_has_value(instanceDetectionData["difficulites"], -1)) then
            table.insert( instanceDetectionData["difficulites"], difficultyID )
            SwitchSwitch:DebugPrint("Registered difficulty for instance id("..tostring(InstanceID).."): " .. tostring(difficultyID))
        end
    else
        SwitchSwitch:table_remove_value(instanceDetectionData["difficulites"], difficultyID)
        SwitchSwitch:DebugPrint("De-registered difficulty for instance id("..tostring(InstanceID).."): " .. tostring(difficultyID))
    end

    -- Set the new data to the list, if the instanceID is empty lets just delete the entry so we do not even bother checking difficulties and bossIDs
    ActiveDetection.instances[InstanceID] = instanceDetectionData
    if(next(ActiveDetection.instances[InstanceID]["bossIDs"] or {},nil) == nil and next(ActiveDetection.instances[InstanceID]["difficulites"],nil) == nil) then
        ActiveDetection.instances[InstanceID] = nil
    end
end

function BossDetection:SetDetectionForBossEnabled(BossID, InstanceID, enabled)
    if(type(InstancesData[InstanceID]) ~= "table") then
        SwitchSwitch:DebugPrint("Trying to detect a instance of which we do not have data.")
        return
    end

    -- Make sure that the array exits as below we are expeting the array to not be null or any other value
    local instanceDetectionData = ActiveDetection.instances[InstanceID] or {}
    if(type(instanceDetectionData["bossIDs"]) ~= "table") then
        instanceDetectionData["bossIDs"] = {}
    end

    if(enabled) then
        if(not SwitchSwitch:table_has_value(instanceDetectionData["bossIDs"], BossID)) then
            table.insert( instanceDetectionData["bossIDs"], BossID)
            SwitchSwitch:DebugPrint("Register boss with id: " .. tostring(BossID))
        end
    else
        SwitchSwitch:table_remove_value(instanceDetectionData["bossIDs"], BossID)
        SwitchSwitch:DebugPrint("De-register boss with id: " .. tostring(BossID))
    end

    -- Set the new data to the list, if the instanceID is empty lets just delete the entry so we do not even bother checking difficulties and bossIDs
    ActiveDetection.instances[InstanceID] = instanceDetectionData
    if(next(ActiveDetection.instances[InstanceID]["bossIDs"], nil) == nil and next(ActiveDetection.instances[InstanceID]["difficulites"] or {}, nil) == nil) then
        ActiveDetection.instances[InstanceID] = nil
    end
end

function BossDetection:OnTooltipSetUnit(tooltip)
    if(UnitAffectingCombat("player") or UnitIsDeadOrGhost("player")) then
        return
    end

    local _, unit = tooltip:GetUnit()
    if(not unit) then
        return
    end

    local guid = UnitGUID(unit)
    local npcType,_,_,_,_,npcID = strsplit("-", guid)
    if(not npcID) then
        return
    end
    npcID = tonumber(npcID)

    if (npcType and (npcType == "Creature" or npcType == "Vehicle")) then
        local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
        local activeDetectionInstanceData = ActiveDetection.instances[current_instanceID] or {}
        -- We will only send the message if we are actually wanting to detect this boss, to avoid firing if we do not really want to detect as the data might be set correctly
        -- causing a suggesiton to pop up even if we dont want to
        if(SwitchSwitch:table_has_value(activeDetectionInstanceData["bossIDs"] or {}, npcID) and not SwitchSwitch:table_has_value(CurrentInstanceBossesDefeated, npcID)) then
            self:SendMessage("SWITCHSWITCH_BOSS_DETECTED", current_instanceID, current_difficultyID, npcID)
            SwitchSwitch:DebugPrint("---- Detected Boss:" .. current_instanceID .. ", " .. current_difficultyID .. ", " .. npcID )
        end
    end
end

function BossDetection:PLAYER_ENTERING_WORLD()
    local _, current_instanceType, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
    if(select(1, IsInInstance())) then

        if(SwitchSwitch:table_has_value(ActiveDetection.types, current_instanceType)) then
            self:SendMessage("SWITCHSWITCH_INSTANCE_TYPE_DETECTED", current_instanceType)
        end

        local shouldDetectBosses = false
        for detecteableID, data in pairs(ActiveDetection.instances) do
            if(detecteableID == current_instanceID) then
                self.awaitingMovement = next(data["difficulites"] or {},nil) ~= nil
                self.awaitingBossDetection =  next(data["bossIDs"] or {}, nil) ~= nil
                if(self.awaitingMovement or self.awaitingBossDetection) then
                    shouldDetectBosses = true
                    CurrentInstanceData = InstancesData[detecteableID] or {}
                    SwitchSwitch:DebugPrint("---- Detected Instance:" .. current_instanceID .. ", " .. current_difficultyID .. " Waiting Movement to start suggestion if neceesary")
                    break
                end
            end
        end

        if(not shouldDetectBosses) then
            self:UnregisterEvent("PLAYER_STARTED_MOVING")
            self:UnregisterEvent("PLAYER_STOPPED_MOVING")
            self:UnregisterBucket("BOSS_KILL")
            -- Need to call it maually to make sure we are stoping timers
            self:PLAYER_STOPPED_MOVING()
            return
        end

        -- We cannot use zone IDs or stuff like that for boss detection so we will try to check evey second during movement if we can to change talents
        -- as we can also not rely on players standing still when entering boss area
        self.NeedsBossKillUpdate = true
        self:RegisterEvent("PLAYER_STARTED_MOVING")
        self:RegisterEvent("PLAYER_STOPPED_MOVING")
        self:RegisterBucketEvent("BOSS_KILL", 1.0, "BOSS_KILL")
    else
        -- We are not in instance so lets disable any checking
        self:UnregisterEvent("PLAYER_STARTED_MOVING")
        self:UnregisterEvent("PLAYER_STOPPED_MOVING")
        self:UnregisterBucket("BOSS_KILL")
        -- Need to call it maually to make sure we are stoping timers
        self:PLAYER_STOPPED_MOVING()
    end
end

function BossDetection:PLAYER_STARTED_MOVING()
    -- First we need to update all bosses killed in the current instance
    -- This function is called multiple times so we want to update it only once
    if(self.NeedsBossKillUpdate == true) then
        self:BOSS_KILL()
        self.NeedsBossKillUpdate = false
    end

    if(self.awaitingMovement) then
        local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
        local instanceDetectionData = ActiveDetection.instances[current_instanceID] or {}
        if(SwitchSwitch:table_has_value(instanceDetectionData["difficulites"] or {}, current_difficultyID) or SwitchSwitch:table_has_value(instanceDetectionData["difficulites"] or {}, -1)) then
            self.awaitingMovement = false
            self:SendMessage("SWITCHSWITCH_BOSS_DETECTED", current_instanceID, current_difficultyID, nil)
            SwitchSwitch:DebugPrint("---- Detected Instance:" .. current_instanceID .. ", " .. current_difficultyID )
        end
    end

    if(self.awaitingBossDetection) then
        self:ScheduleRepeatingTimer("DoCheckWork", 1.5)
    end
end

function BossDetection:PLAYER_STOPPED_MOVING()
    self:CancelAllTimers()
    self:DoCheckWork()
end

function BossDetection:BOSS_KILL()
    local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
    CurrentInstanceBossesDefeated = self:GetKilledBossesInInstance(current_instanceID, current_difficultyID, CurrentInstanceData)
    SwitchSwitch:DebugPrint("Bosses defeated list:")
    SwitchSwitch:DebugPrintTable(CurrentInstanceBossesDefeated)
end


function BossDetection:DoCheckWork()
    -- This might be a bit expensive so we do not want to do it in combat
    if(UnitAffectingCombat("player")) then
        return
    end

    local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
    local instanceDetectionData = ActiveDetection.instances[current_instanceID] or {}
    if(type(instanceDetectionData["bossIDs"]) ~= "table") then
        return
    end

    local map = C_Map.GetBestMapForUnit("player")
    local x, y = self:GetPlayerMapPos(map)
    if(not x) then
        x = -1
        y = -1
    end

    for i,bossID in ipairs(instanceDetectionData["bossIDs"]) do
        local data = CurrentInstanceData[bossID] or {}
        if(data.ZoneID == map) then
            -- This will return if not all requirements are defeated so the resolution before will not happen
            local canBeKilled = true
            if(SwitchSwitch:table_has_value(CurrentInstanceBossesDefeated, bossID)) then
                canBeKilled = false
            end

            if(canBeKilled and type(data.requieres) == "table" and #data.requieres > 0) then
                for i, requiredBossID in ipairs(data.requieres) do
                    if(not SwitchSwitch:table_has_value(CurrentInstanceBossesDefeated, requiredBossID)) then
                        canBeKilled = false
                        break
                    end
                end
            end

            -- IF the boss can not be killed we dont want to suggest a talent as the boss might be down or requirements have not been met
            if (canBeKilled) then
                if(data.position ~= nil) then
                    if(data.position.x1 >= x and data.position.y1 <= y and data.position.x2 <= x and data.position.y2 >= y) then
                        self:SendMessage("SWITCHSWITCH_BOSS_DETECTED", current_instanceID, current_difficultyID, bossID)
                        SwitchSwitch:DebugPrint("---- Detected Boss Cords:" .. current_instanceID .. ", " .. current_difficultyID .. ", " .. bossID )
                    end
                else
                    self:SendMessage("SWITCHSWITCH_BOSS_DETECTED", current_instanceID, current_difficultyID, bossID)
                    SwitchSwitch:DebugPrint("---- Detected Boss Zone:" .. current_instanceID .. ", " .. current_difficultyID .. ", " .. bossID )
                end
            end
        end
    end
end

function BossDetection:GetInstanceIDFromSavedOutIndex(index)
    local link = GetSavedInstanceChatLink(index) or ""
    local id, name = link:match(":(%d+):%d+:%d+\124h%[(.+)%]\124h")
    if(not id) then
        return 0
    end
    id = tonumber(id)
    return id
end

function BossDetection:GetPlayerMapPos(mapID)
    local x, y = UnitPosition('player')
	if not x  or not mapID then return end

    local _, pos1 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
    local _, pos2 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
    if not pos1 or not pos2 then return end

    pos2:Subtract(pos1)
    x = x - pos1.x
    y = y - pos1.y
    return (y/pos2.y)*100, (x/pos2.x)*100
end


function BossDetection:GetKilledBossesInInstance(instacneID, difficultyID, instanceData)
    local rtvData = {}
    for i = 1, GetNumSavedInstances() do
        local _, _, _, saved_difficultyID, locked, _, _, _, _, _, saved_numEncounters, _, _ = GetSavedInstanceInfo(i)
        if(locked and difficultyID == saved_difficultyID) then
            local saved_instanceID = self:GetInstanceIDFromSavedOutIndex(i)
            if(instacneID == saved_instanceID) then
                for encounterIndex=1, saved_numEncounters do
                    local _, _, isKilled, _ = GetSavedInstanceEncounterInfo(i, encounterIndex)
                    for bossID,data in pairs(instanceData) do
                        if(data.jurnalIndex == encounterIndex and isKilled) then
                            table.insert( rtvData, bossID )
                            break
                        end
                    end
                end
                break
            end
        end
    end

    return rtvData
end