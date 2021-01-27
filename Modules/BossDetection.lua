local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local BossDetection = SwitchSwitch:NewModule("BossDetection", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local InstancesToDetect = {}
local CurrentInstanceData = {}
local CurrentBossesDefeated = {}

function BossDetection:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:HookScript(GameTooltip, "OnTooltipSetUnit")
end

function BossDetection:OnDisable()
    self:Unhook(GameTooltip, "OnTooltipSetUnit")
    self:UnregisterEvent("PLAYER_STARTED_MOVING")
    self:UnregisterEvent("PLAYER_STOPPED_MOVING")
    self:UnregisterEvent("BOSS_KILL")
    self:CancelAllTimers()
end

function BossDetection:RegisterInstance(InstanceID, InstanceData)
    InstancesToDetect[InstanceID] = InstanceData
    if(InstanceData == nil) then
        SwitchSwitch:DebugPrint("Deregistering instance " .. InstanceID)
    else
        SwitchSwitch:DebugPrint("Registering instance " .. InstanceID)
    end
end

function BossDetection:RegisterBoss(InstanceID, BossID, BossData)
    if(BossID == nil) then
        self:RegisterInstance(InstanceID, InstancesToDetect[InstanceID] or {})
        return
    end

    InstancesToDetect[InstanceID] = InstancesToDetect[InstanceID] or {}
    InstancesToDetect[InstanceID][BossID] = BossData
    if(BossData == nil) then
        SwitchSwitch:DebugPrint("Deregistering boss for instance " .. InstanceID .. " with id " .. BossID)
    else
        SwitchSwitch:DebugPrint("Registering boss for instance " .. InstanceID .. " with id " .. BossID)
    end
end

function BossDetection:OnTooltipSetUnit(tooltip) 
    if(UnitAffectingCombat("player")) then
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
        if(CurrentInstanceData[npcID] ~= nil) then
            local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
            self:SendMessage("SWITCHSWITCH_BOSS_DETECTED", current_instanceID, current_difficultyID, npcID)
            SwitchSwitch:DebugPrint("---- Detected Boss:" .. current_instanceID .. ", " .. current_difficultyID .. ", " .. npcID )
        end
    end
end

function BossDetection:PLAYER_ENTERING_WORLD()
    local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
    if(select(1, IsInInstance())) then

        local shouldDetectBosses = false
        for detecteableInstancID, data in pairs(InstancesToDetect) do
            if(detecteableInstancID == current_instanceID) then
                self.awaitingMovement = true
                shouldDetectBosses = true
                CurrentInstanceData = data or {}
                SwitchSwitch:DebugPrint("---- Detected Instance:" .. current_instanceID .. ", " .. current_difficultyID .. " Waiting Movement to start suggestion if neceesary")
                break
            end
        end

        if(not shouldDetectBosses) then
            self:UnregisterEvent("PLAYER_STARTED_MOVING")
            self:UnregisterEvent("PLAYER_STOPPED_MOVING")
            self:UnregisterEvent("BOSS_KILL")
            -- Need to call it maually to make sure we are stoping timers
            self:PLAYER_STOPPED_MOVING()
            return
        end
        
        -- We cannot use zone IDs or stuff like that for boss detection so we will try to check evey second during movement if we can to change talents
        -- as we can also not rely on players standing still when entering boss area
        self:RegisterEvent("PLAYER_STARTED_MOVING")
        self:RegisterEvent("PLAYER_STOPPED_MOVING")
        self:RegisterEvent("BOSS_KILL")
    else
        -- We are not in instance so lets disable any checking
        self:UnregisterEvent("PLAYER_STARTED_MOVING")
        self:UnregisterEvent("PLAYER_STOPPED_MOVING")
        self:UnregisterEvent("BOSS_KILL")
        -- Need to call it maually to make sure we are stoping timers
        self:PLAYER_STOPPED_MOVING()
    end
end

function BossDetection:PLAYER_STARTED_MOVING()
    self:ScheduleRepeatingTimer("DoCheckWork", 1.5)
    if(self.awaitingMovement) then
        local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
        self.awaitingMovement = false
        self:SendMessage("SWITCHSWITCH_BOSS_DETECTED", current_instanceID, current_difficultyID, nil)
        SwitchSwitch:DebugPrint("---- Detected Instance:" .. current_instanceID .. ", " .. current_difficultyID )
        self:BOSS_KILL()
    end
end

function BossDetection:PLAYER_STOPPED_MOVING()
    self:CancelAllTimers()
    self:DoCheckWork()
end

function BossDetection:BOSS_KILL()
    local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
    CurrentBossesDefeated = self:GetKilledBossesInInstance(current_instanceID, current_difficultyID, CurrentInstanceData)
end


function BossDetection:DoCheckWork()
    -- This might be a bit expensive so we do not want to do it in combat
    if(UnitAffectingCombat("player")) then
        return
    end

    local map = C_Map.GetBestMapForUnit("player")
    local x, y = self:GetPlayerMapPos(map)
    local _, _, current_difficultyID, _, _, _, _, current_instanceID, _, _ = GetInstanceInfo()
    
    if(not x) then
        x = -1
        y = -1
    end

    for bossID, data in pairs(CurrentInstanceData) do
        if(data.ZoneID == map) then
            -- This will return if not all requirements are defeated so the resolution before will not happen
            local canBeKilled = true
            if(SwitchSwitch:table_has_value(CurrentBossesDefeated, bossID)) then
                canBeKilled = false
            end

            if(canBeKilled and type(data.requieres) == "table" and #data.requieres > 0) then
                for i, requiredBossID in ipairs(data.requieres) do
                    if(not SwitchSwitch:table_has_value(CurrentBossesDefeated, requiredBossID)) then
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
                    _, _, isKilled, _ = GetSavedInstanceEncounterInfo(i, encounterIndex)
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