--############################################
-- Namespace
--############################################
local namespace = select(2, ...)

--@debug@
_G.SwitchSwitch = namespace;
--@end-debug@

--############################################
-- Addon Setup & Lib Setup
--############################################
local SwitchSwitch = LibStub("AceAddon-3.0"):NewAddon("SwitchSwitch", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceBucket-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SwitchSwitch")
local AceGUI = LibStub("AceGUI-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")

-- The namespace table is passed to all files so we add anything we want global to it
namespace[1] = SwitchSwitch
namespace[2] = L
namespace[3] = AceGUI
namespace[4] = LibDBIcon

SwitchSwitch.InternalVersion = 30
SwitchSwitch.defaultProfileName = "custom"
SwitchSwitch.CurrentActiveTalentsProfile = SwitchSwitch.defaultProfileName

--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
-- Function to print a debug message
function SwitchSwitch:DebugPrint(...)
    if(type(self.db) ~= "table" or self.db.profile.debug) then
        self:Print(string.join(" ", "|cFFFF0000(DEBUG)|r", tostringall(... or "nil")))
    end
end


function SwitchSwitch:DebugPrintTable(tbl, indent)
    if(type(self.db) == "table" and not self.db.profile.debug) then
        return
    end

    if(tbl == nil) then
        self:DebugPrint("Table is null")
        return
    end

    if not indent or indent <= 1 then
        indent = 1
        self:DebugPrint("Table:")
        print("{")
    end

    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            local formatting =  string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                print(formatting .. "{")
                self:DebugPrintTable(v, indent+1)
            else
                print(formatting .. tostring(v))
            end
        end
    end
    print(string.rep("  ", max(indent - 1, 0)) .. "}")
end

-- Function to print a message to the chat.
function SwitchSwitch:Print(...)
    local msg = string.join(" ","|cFF029CFC[SwitchSwitch]|r", tostringall(... or "nil"));
    DEFAULT_CHAT_FRAME:AddMessage(msg);
end

--Print a table, if the value of a key is a talbe recursivly call the function again
function SwitchSwitch:PrintTable(tbl, indent)
    if not indent then indent = 0 end
    if type(tbl) == 'table' then
        for k, v in pairs(tbl) do
            local formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                self:Print(formatting)
                self:PrintTable(v, indent+1)
            else
                self:Print(formatting .. tostring(v))
            end
        end
    end
end

function SwitchSwitch:GetCurrentSpec()
    return select(1, PlayerUtil.GetCurrentSpecID())
    -- Old Way: return select(1, GetSpecializationInfo(GetSpecialization()))
end

function SwitchSwitch:GetPlayerClass()
    return PlayerUtil.GetClassID()
    -- Old way: return select(3, UnitClass("player"))
end

-- String helpers
function SwitchSwitch:findLastInString(str, value)
    local i=str:match(".*"..value.."()")
    if i==nil then return nil else return i-1 end
end

function SwitchSwitch:Repeats(s,c)
    local _,n = s:gsub(c,"")
    return n
end

function SwitchSwitch:deepcopy(o, seen)
    seen = seen or {}
    if o == nil then return nil end
    if seen[o] then return seen[o] end

    local no
    if type(o) == 'table' then
      no = {}
      seen[o] = no

      for k, v in next, o, nil do
        no[self:deepcopy(k, seen)] = self:deepcopy(v, seen)
      end
      setmetatable(no, self:deepcopy(getmetatable(o), seen))
    else -- number, string, boolean, etc
      no = o
    end
    return no
end

function SwitchSwitch:tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function SwitchSwitch:table_has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function SwitchSwitch:table_remove_value(tab, val)
    local removePos = -1
    for pos, data in ipairs(tab) do
        if(data == val) then
            removePos = pos
            break;
        end
    end

    if(removePos ~= -1) then
        table.remove(tab, removePos)
        return true
    end
    return false
end

-------------------------------------------------------------------- Talent table edition
-------- TODO: Is it necesary? Blizzard can already store 10 talents setups
function SwitchSwitch:DoesClassProfilesTableExits(class)
    if(class == nil) then
        return false
    end

    if(self.db.global.TalentProfiles[class] == nil) then
        return false
    end

    return true
end

function SwitchSwitch:DoesSpecProfilesTableExits(class, spec)
    if(not self:DoesClassProfilesTableExits(class)) then
        return false
    end

    if(spec == nil) then
        return false
    end

    if(self.db.global.TalentProfiles[class][spec] == nil) then
        return false
    end

    return true
end

function SwitchSwitch:GetProfilesTable(class, spec)
    local profileTable = {}
    class = class or self:GetPlayerClass()
    spec = spec or self:GetCurrentSpec()

    if(spec ~= nil and class ~= nil) then
        if(not self:DoesClassProfilesTableExits(class)) then
            self.db.global.TalentProfiles[class] = {}
        end

        if(not self:DoesSpecProfilesTableExits(class, spec)) then
            self.db.global.TalentProfiles[class][spec] = {}
        end

        profileTable = self.db.global.TalentProfiles[class][spec]
    end

    return profileTable
end

function SwitchSwitch:GetCurrentSpecProfilesTable()
    return self:GetProfilesTable()
end

function SwitchSwitch:DoesProfileExits(name, class, spec)
    -- When iterating we want to also lower both sides this will help with collisions where the user might type it upper or lower case mixed
    if(name == nil) then
        return false
    end

    name = name:lower()
    for k,v in pairs(self:GetProfilesTable(class, spec)) do
        if(k:lower() == name) then
            return true
        end
    end

    return false
end

function SwitchSwitch:GetProfileData(name, class, spec)
    if(name == nil) then
        return nil
    end

    spec = spec or self:GetCurrentSpec()
    class = class or self:GetPlayerClass()
    local t = self:GetProfilesTable(class, spec)
    name = name:lower()

    if(not self:DoesProfileExits(name, class, spec)) then
        t[name] = {}
    end

    return t[name]
end

function SwitchSwitch:SetProfileData(name, newTable, class, spec)
    if(name == nil) then
        return nil
    end

    spec = spec or self:GetCurrentSpec()
    class = class or self:GetPlayerClass()
    local t = self:GetProfilesTable(class, spec)
    name = name:lower()
    t[name] = newTable
end

function SwitchSwitch:DeleteProfileData(name, class, spec)
    if(self:DoesProfileExits(name, class, spec)) then
        name = name:lower()

        -- Delete from the profiles table
        self:SetProfileData(name, nil, class, spec)
        self:DebugPrint("Deleted")
        -- Delete from suggestion
        local suggestions = self:GetProfilesSuggestionTable(class, spec)
        for instanceID, instanceSuggestionData in pairs(suggestions) do
            if(type(instanceID) == "string") then
                if(name == instanceSuggestionData["all"]) then
                    instanceSuggestionData["all"] = nil
                end
            else
                for suggestionType, profilesList in pairs(instanceSuggestionData) do
                    for id, suggestedProfileName in pairs(profilesList) do
                        if(name == suggestedProfileName) then
                            profilesList[id] = nil
                        end
                    end
                end
            end
        end
        -- Delete from gear sets
        if(type(self.db.char.gearSets[self:GetCurrentSpec()]) == "table") then
            self.db.char.gearSets[self:GetCurrentSpec()][name] = nil
        end
        -- Update current actvie profile
        if(name == SwitchSwitch.CurrentActiveTalentsProfile) then
            SwitchSwitch.CurrentActiveTalentsProfile = SwitchSwitch.defaultProfileName:lower()
        end

        self:PLAYER_TALENT_UPDATE(true)
        return true
    end
    return false
end

function SwitchSwitch:RenameProfile(name, newName, class, spec)
    if(self:DoesProfileExits(name, class, spec)) then
        name = name:lower()
        local newName = newName:lower()

        self:SetProfileData(newName, self:GetProfileData(name, class, spec), class, spec)
        local suggestions = self:GetProfilesSuggestionTable(class, spec)
        for instanceID, instanceSuggestionData in pairs(suggestions) do
            if(type(instanceID) == "string") then
                if(name == instanceSuggestionData["all"]) then
                    instanceSuggestionData["all"] = newName
                end
            else
                for suggestionType, profilesList in pairs(instanceSuggestionData) do
                    for id, suggestedProfileName in pairs(profilesList) do
                        if(name == suggestedProfileName) then
                            profilesList[id] = newName
                        end
                    end
                end
            end
        end

        if(type(self.db.char.gearSets[self:GetCurrentSpec()]) == "table") then
            self.db.char.gearSets[self:GetCurrentSpec()][newName] = self.db.char.gearSets[self:GetCurrentSpec()][name]
        end

        -- Need to delete after as it will delete the suggestion entries
        self:DeleteProfileData(name, class, spec)

        self:PLAYER_TALENT_UPDATE(true)
        return true
    end

    return false
end

-----------------------------------------------------------------------------------------------------------------------------------------

function SwitchSwitch:DoesClassProfilesSuggestionTableExits(class)
    if(class == nil) then
        return false
    end

    if(self.db.global.TalentSuggestions[class] == nil) then
        return false
    end

    return true
end

function SwitchSwitch:DoesSpecProfilesSuggestionTableExits(class, spec)
    if(not self:DoesClassProfilesSuggestionTableExits(class)) then
        return false
    end

    if(spec == nil) then
        return false
    end

    if(self.db.global.TalentSuggestions[class][spec] == nil) then
        return false
    end

    return true
end

function SwitchSwitch:GetProfilesSuggestionTable(class, spec)
    local profileTable = {}
    class = class or self:GetPlayerClass()
    spec = spec or self:GetCurrentSpec()

    if(spec ~= nil and class ~= nil) then
        if(not self:DoesClassProfilesSuggestionTableExits(class)) then
            self.db.global.TalentSuggestions[class] = {}
        end

        if(not self:DoesSpecProfilesSuggestionTableExits(class, spec)) then
            self.db.global.TalentSuggestions[class][spec] = {}
        end

        profileTable = self.db.global.TalentSuggestions[class][spec]
    end

    return profileTable
end

function SwitchSwitch:GetProfilesSuggestionInstanceData(instanceID, class, spec)
    spec = spec or self:GetCurrentSpec()
    class = class or self:GetPlayerClass()
    local t = self:GetProfilesSuggestionTable(class, spec)

    if(t[instanceID] == nil) then
        t[instanceID] = {}
    end

    return t[instanceID]
end

function SwitchSwitch:SetProfilesSuggestionInstanceData(instanceID, newTable, class, spec)
    spec = spec or self:GetCurrentSpec()
    class = class or self:GetPlayerClass()
    local t = self:GetProfilesSuggestionTable(class, spec)
    t[instanceID] = newTable
end

-----------------------------------------------------------------------------------------------------------------------------------------

function SwitchSwitch:GetCurrentWeeksMythicID()
    local ids = {}
    for i, k in ipairs(C_MythicPlus.GetCurrentAffixes() or {}) do
        table.insert(ids, k.id)
    end

    if(next(ids, nil) ~= nil) then
        return self:encodeMythicPlusAffixesIDs(unpack(ids))
    end

    return 0
end

function SwitchSwitch:encodeMythicPlusAffixesIDs(id1, id2, id3)
    assert(id1 < 256, "To long number to compres into 32 bit")
    assert(id2 < 256, "To long number to compres into 32 bit")
    assert(id3 < 256, "To long number to compres into 32 bit")
    return bit.bor(bit.band(id1, 0xFF), bit.lshift(bit.band(id2, 0xFF), 8), bit.lshift(bit.band(id3, 0xFF), 16))
end

function SwitchSwitch:decodeMythicPlusAffixesID(encoded)
    local id1 = bit.band(encoded, 0xFF)
    local id2 = bit.band((bit.rshift(encoded, 8)), 0xFF)
    local id3 = bit.band((bit.rshift(encoded, 16)), 0xFF)
    return id1, id2, id3
end

-----------------------------------------------------------------------------------------------------------------------------------------

-- TODO: Move this later
function SwitchSwitch:GetSelectedLoadoutConfigID()
    local lastSelected = PlayerUtil.GetCurrentSpecID() and C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID())
    local selectionID = ClassTalentFrame and ClassTalentFrame.TalentsTab and ClassTalentFrame.TalentsTab.LoadoutDropDown and ClassTalentFrame.TalentsTab.LoadoutDropDown.GetSelectionID and ClassTalentFrame.TalentsTab.LoadoutDropDown:GetSelectionID()
    return selectionID or lastSelected or C_ClassTalents.GetActiveConfigID() or nil
end

function GetCurrentTalentsInfoList()
    local list = {}

    local configID = C_ClassTalents.GetActiveConfigID()
    if configID == nil then return end

    local configInfo = C_Traits.GetConfigInfo(configID)
    if configInfo == nil then return end

    for _, treeID in ipairs(configInfo.treeIDs) do -- in the context of talent trees, there is only 1 treeID

        local nodes = C_Traits.GetTreeNodes(treeID)
        for i, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            if(SwitchSwitch:tablelength(nodeInfo.entryIDsWithCommittedRanks) == 1) then
                local talentInfo = {
                    ["id"] = nodeID,
                    ["commitedEntryID"] = nodeInfo.entryIDsWithCommittedRanks[1],
                    ["currentRank"] = nodeInfo.currentRank
                }
                table.insert(list, talentInfo);
            end
        end
    end
    return list
end


--Get the talent from the current active spec
function SwitchSwitch:GetCurrentTalents(saveTalentsPVP)
    local talentSet =
    {
        ["pva"] = GetCurrentTalentsInfoList(),
    }

    for Tier = 1, GetMaxTalentTier() do
        --Create default table
        talentSet["pva"][Tier] =
        {
            ["id"] = nil,
            ["tier"] = nil,
            ["column"] = nil
        }
        --Iterate trought the 2 columnds
        for Column = 1, 3 do
            --Get talent info
            local talentID, name, texture, selected, available = GetTalentInfo(Tier, Column, GetActiveSpecGroup())
            --If the talent is selected store the nececary information
            if(selected) then
                talentSet["pva"][Tier]["id"] = talentID
                talentSet["pva"][Tier]["tier"] = Tier
                talentSet["pva"][Tier]["column"] = Column
                break
            end
        end
    end

    --Only save talents if requested
    if(saveTalentsPVP) then
        talentSet["pvp"] = {}
        --Iterate over pvp talents
        for Tier = 1, 3 do
            local pvpTalentInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(Tier)
            talentSet["pvp"][Tier] =
            {
                ["unlocked"] = pvpTalentInfo.enabled,
                ["id"] = pvpTalentInfo.selectedTalentID,
                ["tier"] = Tier
            }
        end
    end

    --Return talents
    return talentSet;
end

--Check if we can switch talents
function SwitchSwitch:CanChangeTalents()
    local canChange = C_ClassTalents.CanEditTalents();
    return canChange;
end

function SwitchSwitch:ActivateTalentProfile(profileName)

    if(UnitAffectingCombat("Player")) then
        SwitchSwitch:DebugPrint("Player is in combat.")
        return false
    end

    --Check if profileName is not null
    if(not profileName or type(profileName) ~= "string") then
        SwitchSwitch:DebugPrint("Given profile name is null")
        return false
    end

    --Check  if table exits
    if(not SwitchSwitch:DoesProfileExits(profileName)) then
        SwitchSwitch:Print(L["Could not change talents to Profile '%s' as it does not exit"]:format(profileName))
        return false
    end

    if(not SwitchSwitch:CanChangeTalents()) then
        --No check for usage so just return
        SwitchSwitch:Print(L["Could not change talents"])
        return false
    end

    --Function to set talents
    SwitchSwitch:LearnTalents(profileName)
    return true
end
--Helper function to avoid needing to copy-caste every time...
function SwitchSwitch:LearnTalents(profileName)
    --Make sure our event talent change does not detect this as custom switch
    SwitchSwitch:Print(L["Changing talents"] .. ": " .. profileName)

    --Check if the talent addon is up
    if(not IsAddOnLoaded("Blizzard_ClassTalentUI")) then
        LoadAddOn("Blizzard_ClassTalentUI")
    end

    if(not SwitchSwitch:DoesProfileExits(profileName)) then
        return;
    end

    local currentTalentProfile = SwitchSwitch:GetProfileData(profileName)

    --Learn talents normal talents
    if(currentTalentProfile.pva ~= nil) then
        for i, talentTbl in ipairs(currentTalentProfile.pva) do
            --Get the current talent info to see if the talent id changed
            local talent = GetTalentInfo(talentTbl.tier, talentTbl.column, 1)
            if talentTbl.tier > 0 and talentTbl.column > 0  then
                LearnTalents(talent)
                --If talent id changed let the user know that the talents might be wrong
                if(select(1, talent) ~= talentTbl.id) then
                    SwitchSwitch:Print(L["It seems like the talent from tier: '%s' and column: '%s' have been moved or changed, check you talents!"]:format(tostring(talentTbl.tier), tostring(talentTbl.column)))
                end
            end
        end
    end

    if(currentTalentProfile.pvp ~= nil) then
        --Leanr pvp talent
        for i, pvpTalentTabl in ipairs(currentTalentProfile.pvp) do
            if(pvpTalentTabl.unlocked and pvpTalentTabl.id ~= nil) then
                --Make sure the talent is not used anywhere else, set to random if used in anothet tier
                for i2 = 0, 3 do
                    local pvpTalentInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(i2)
                    if(pvpTalentInfo ~= nil and pvpTalentTabl.id == pvpTalentInfo.selectedTalentID and pvpTalentTabl.tier ~= i2) then
                        --Get random talent
                        LearnPvpTalent(pvpTalentInfo.availableTalentIDs[math.random(#pvpTalentInfo.availableTalentIDs)], i2)
                    end
                end
                --Lern the talent in the tier
                LearnPvpTalent(pvpTalentTabl.id, pvpTalentTabl.tier)
            end
        end
    end

    -- Gear set
    if(type(self.db.char.gearSets[self:GetCurrentSpec()]) == "table" and self.db.char.gearSets[self:GetCurrentSpec()][profileName] ~= nil) then
        local itemSetID = C_EquipmentSet.GetEquipmentSetID(self.db.char.gearSets[self:GetCurrentSpec()][profileName])
        local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(itemSetID)
        if(name ~= nil and not isEquipped) then
            C_EquipmentSet.UseEquipmentSet(itemSetID)
        end
    end

    --Print and return
    SwitchSwitch:Print(L["Changed talents to '%s'"]:format(profileName))
    return true
end

--Check if a given profile is the current talents
function SwitchSwitch:IsCurrentTalentProfile(profileName, checkGearAndSoulbinds)
    --Check if null or not existing
    if(not SwitchSwitch:DoesProfileExits(profileName)) then
        SwitchSwitch:DebugPrint(string.format("Profile name does not exist [%s]", profileName))
        return false
    end

    local currentActiveTalents = SwitchSwitch:GetCurrentTalents()
    local currentprofile = SwitchSwitch:GetProfileData(profileName)

    --Check pvp talents
    local currentPVPTalentsTable = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
    if(currentprofile.pvp ~= nil) then
        for i, pvpTalentInfo in ipairs(currentprofile.pvp) do
            --Check if we got the talent
            local hasTalent = false
            for k, talentID in ipairs(currentPVPTalentsTable) do
                if(talentID == pvpTalentInfo.id) then
                    hasTalent = true;
                end
            end
            --We dont have the talent so just return false
            if(not hasTalent) then
                SwitchSwitch:DebugPrint("PVP tlanets does not match");
                return false
            end
        end
    end

    if(currentprofile.pva ~= nil) then
        --Check normal talents
        for i, talentInfo in ipairs(currentprofile.pva) do
            local talentID, name, _, selected, available, _, _, row, column, known, _ = GetTalentInfoByID(talentInfo.id, GetActiveSpecGroup())
            if(not known) then
                SwitchSwitch:DebugPrint(string.format("Talent with the name %s is not leanred", name))
                return false
            end
        end
    end

    if(checkGearAndSoulbinds == true) then
        -- Gear set
        if(type(self.db.char.gearSets[self:GetCurrentSpec()]) == "table" and self.db.char.gearSets[self:GetCurrentSpec()][profileName] ~= nil) then
            local itemSetID = C_EquipmentSet.GetEquipmentSetID(self.db.char.gearSets[self:GetCurrentSpec()][profileName])
            local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(itemSetID)
            if(name ~= nil and not isEquipped) then
                return false
            end
        end
    end

    return true
end

function SwitchSwitch:GetCurrentActiveProfile()
    --Iterate trough every talent profile
    for name, TalentArray in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
        if(SwitchSwitch:IsCurrentTalentProfile(name, true)) then
            --Return the currentprofilename
            SwitchSwitch:DebugPrint("Detected: " .. name)
            return name:lower()
        end
    end

    -- Fallback in case we dont find any with the current gear/soulbind so we try to match talents without any of the gear and soulbinds
    for name, TalentArray in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
        if(SwitchSwitch:IsCurrentTalentProfile(name, false)) then
            --Return the currentprofilename
            SwitchSwitch:DebugPrint("Detected: " .. name)
            return name:lower()
        end
    end

    SwitchSwitch:DebugPrint("No profiles match current talnets")
    --Return the custom profile name
    return SwitchSwitch.defaultProfileName
end