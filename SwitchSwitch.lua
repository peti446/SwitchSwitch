--############################################
-- Namespace
--############################################
local namespace = select(2, ...)

--############################################
-- Addon Setup & Lib Setup
--############################################

---@class SwitchSwitch
local SwitchSwitch = LibStub("AceAddon-3.0"):NewAddon("SwitchSwitch", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceBucket-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SwitchSwitch")
local AceGUI = LibStub("AceGUI-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")

-- The namespace table is passed to all files so we add anything we want global to it
namespace[1] = SwitchSwitch
namespace[2] = L
namespace[3] = AceGUI
namespace[4] = LibDBIcon

--@debug@
_G.SwitchSwitch = namespace[1];
--@end-debug@


SwitchSwitch.Constants = {}
SwitchSwitch.Constants.CustomProfilePrefix = "sscustom_"

SwitchSwitch.TalentsUpdate = {
    UpdatePending = false,
    PendingProfileID = nil,
}

SwitchSwitch.InternalVersion = 30
SwitchSwitch.defaultProfileID = "profile_not_set"
SwitchSwitch.CurrentActiveTalentsConfigID = SwitchSwitch.defaultProfileID

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

function SwitchSwitch:TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function SwitchSwitch:ToLower(k)
    if(type(k) == "string") then
        return k:lower()
    end
    return k;
end

-------------------------------------------------------------------- Talent table edition

function SwitchSwitch:GetCustomProfilesTable(class, spec)
    local profileTable = {}
    if(spec ~= nil and class ~= nil) then
        -- Update the data
        self.db.global.TalentProfiles[class] = self.db.global.TalentProfiles[class] or {}
        self.db.global.TalentProfiles[class][spec] = self.db.global.TalentProfiles[class][spec] or {}
        profileTable = self.db.global.TalentProfiles[class][spec]
    end

    return profileTable
end

function SwitchSwitch:GetBlizzardSavedTalentsProfiles()
    local profiles = {}
    for _, configID in pairs(C_ClassTalents.GetConfigIDsBySpecID(self:GetCurrentSpec())) do
        local data = C_Traits.GetConfigInfo(configID);
        local _id, _type, name, treeID, usesSharedActionBars = data.id, data.type, data.name, data.treeId, data.usesSharedActionBars;
        if(name ~= nil) then
            profiles[configID] = {
                type =  'blizzard',
                talentConfigId = configID,
                treeID = treeID,
                name =  CreateAtlasMarkup("gmchat-icon-blizz", 16, 16) .. name,
                usesSharedActionBars = usesSharedActionBars,
            }
        end
   end
   return profiles;
end

function SwitchSwitch:GetProfiles(class, spec)
    class = class or self:GetPlayerClass()
    spec = spec or self:GetCurrentSpec()

    local customProfiles = self:GetCustomProfilesTable(class, spec)
    local blizzardProfiles = self:GetBlizzardSavedTalentsProfiles()
    local combination = {}

    for id, data in pairs(customProfiles) do
        combination[id] = data
    end

    if(class == self:GetPlayerClass() and spec == self:GetCurrentSpec()) then
        for id, data in pairs(blizzardProfiles) do
            combination[id] = data
        end
    end

    return combination
end

function SwitchSwitch:GetAllCurrentSpecProfiles()
    return self:GetProfiles(self:GetPlayerClass(), self:GetCurrentSpec())
end

function SwitchSwitch:DoesProfileExits(id, class, spec)
    -- When iterating we want to also lower both sides this will help with collisions where the user might type it upper or lower case mixed
    if(id == nil) then
        return false
    end

    local profiles = self:GetProfiles(class, spec)
    id = SwitchSwitch:ToLower(id)
    for k,v in pairs(profiles) do
        if(SwitchSwitch:ToLower(k) == id) then
            return true
        end
    end

    return false
end

---Gets a copy of the profile data modifying this talbe will not work, call SetProfileData to change it with the new data
---@param id string|number The id of the profile, a string if custom profile and a number if a blizzard one
---@param class nubmer|nil The class id
---@param spec number|nil The spec id
---@return nil|table if the profile does not exits nil is returned otherwise a copy of the profile data is returned
function SwitchSwitch:GetProfileData(id, class, spec)
    if(id == nil) then
        self:DebugPrint("Test Error!")
        return nil
    end

    spec = spec or self:GetCurrentSpec()
    class = class or self:GetPlayerClass()
    local t = self:GetProfiles(class, spec)
    id = SwitchSwitch:ToLower(id)
    if(not self:DoesProfileExits(id, class, spec)) then
        return nil
    end

    return self:deepcopy(t[id])
end

function SwitchSwitch:SetProfileData(name, newTable, class, spec)
    if(name == nil) then
        return nil
    end

    spec = spec or self:GetCurrentSpec()
    class = class or self:GetPlayerClass()
    local t = self:GetProfiles(class, spec)
    name = SwitchSwitch:ToLower(name)
    t[name] = newTable
end

function SwitchSwitch:DeleteProfileData(name, class, spec)
    if(self:DoesProfileExits(name, class, spec)) then
        name = SwitchSwitch:ToLower(name)

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
        if(name == SwitchSwitch.CurrentActiveTalentsConfigID) then
            SwitchSwitch.CurrentActiveTalentsConfigID = SwitchSwitch:ToLower(SwitchSwitch.defaultProfileID)
        end

        SwitchSwitch:RefreshCurrentConfigID()
        return true
    end
    return false
end

function SwitchSwitch:RenameProfile(name, newName, class, spec)
    if(self:DoesProfileExits(name, class, spec)) then
        name = SwitchSwitch:ToLower(name)
        local newName = SwitchSwitch:ToLower(newName)

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

        SwitchSwitch:RefreshCurrentConfigID()
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

function SwitchSwitch:GetGetProfilesSuggestionMythicPlusInstance(instanceID, season, class, spec)
    spec = spec or self:GetCurrentSpec()
    class = class or self:GetPlayerClass()
    local t = self:GetProfilesSuggestionTable(class, spec)
    if(t["mythic+"] == nil) then
        t["mythic+"] = {}
    end
    if(t["mythic+"][season] == nil) then
        t["mythic+"][season] = {}
    end
    if(t["mythic+"][season][instanceID] == nil) then
        t["mythic+"][season][instanceID] = {}
    end

    return t["mythic+"][season][instanceID];
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

function SwitchSwitch:GetCurrentMythicPlusAfixHash()
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

function SwitchSwitch:GetMythicPlusSeason()
    local currentSeasonID = C_MythicPlus.GetCurrentSeason()
    -- IF we are not max level it will return -1 so manually setting it to current season
    if(currentSeasonID == -1) then
        currentSeasonID = SwitchSwitch.DefaultMythicPlusSeason
    end

    return currentSeasonID
end

function SwitchSwitch:RefreshCurrentConfigID()
    local tempActiveProfile = self.CurrentActiveTalentsConfigID
    self.CurrentActiveTalentsConfigID = self:GetCurrentActiveProfile()
    if(self.CurrentActiveTalentsConfigID ~= tempActiveProfile) then
        self:UpdateLDBText()
    end

    self:RefreshProfilesEditorPage()
    self:RefreshTalentsSuggestionUI()
    self:RefreshExportUI()
end


function SwitchSwitch:GetSelectedLoadoutConfigID()
    local selectionID = C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID())

    if(selectionID == nil) then
        selectionID = ClassTalentFrame.TalentsTab.LoadoutDropDown:GetSelectionID()
    end
    if(C_ClassTalents.GetStarterBuildActive()) then
        selectionID = nil
    end

    return selectionID
--    if(not ClassTalentFrame or not ClassTalentFrame.TalentsTab or not ClassTalentFrame.TalentsTab.LoadoutDropDown or not ClassTalentFrame.TalentsTab.LoadoutDropDown.GetSelectionID) then
--        self:DebugPrint("Class TalentFrame is not valid returning last selected config id")
--        local lastSelected = PlayerUtil.GetCurrentSpecID() and C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID())
--        return lastSelected or nil;
--    end
--
--    local selectionID = ClassTalentFrame.TalentsTab.LoadoutDropDown:GetSelectionID()
--    if(C_ClassTalents.GetStarterBuildActive()) then
--        selectionID = nil
--    end
--
--    return selectionID;
end

local function GetCurrentTalentsInfoList()
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
            local talentID, _name, _texture, selected, _available = GetTalentInfo(Tier, Column, GetActiveSpecGroup())
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
            if(pvpTalentInfo ~= nil) then
                talentSet["pvp"][Tier] =
                {
                    ["unlocked"] = pvpTalentInfo.enabled,
                    ["id"] = pvpTalentInfo.selectedTalentID,
                    ["tier"] = Tier
                }
            end
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

function SwitchSwitch:ActivateTalentProfile(profileID)

    if(UnitAffectingCombat("player")) then
        SwitchSwitch:DebugPrint("Player is in combat.")
        return false
    end

    --Check if profileName is not null
    if(not profileID or (type(profileID) ~= "string" and type(profileID) ~= "number")) then
        SwitchSwitch:DebugPrint("Given profile id is null")
        return false
    end

    --Check  if table exits
    if(not SwitchSwitch:DoesProfileExits(profileID)) then
        SwitchSwitch:Print(L["Could not change talents to Profile with id '%s' as it does not exit"]:format(profileID))
        return false
    end

    if(not SwitchSwitch:CanChangeTalents()) then
        --No check for usage so just return
        SwitchSwitch:Print(L["Could not change talents"])
        return false
    end

    -- Function to set talents
    SwitchSwitch:LearnTalents(profileID)
    return true
end

--Helper function to avoid needing to copy-caste every time...
function SwitchSwitch:LearnTalents(profileID)
    local profileData = SwitchSwitch:GetProfileData(profileID)
    if(not profileData) then
        return
    end

    SwitchSwitch:Print(L["Changing talents"] .. ": " .. profileData.name)

    --Check if the talent addon is up
    if(not C_AddOns.IsAddOnLoaded("Blizzard_ClassTalentUI")) then
        C_AddOns.LoadAddOn("Blizzard_ClassTalentUI")
    end

    if(not SwitchSwitch:DoesProfileExits(profileID)) then
        return
    end

    -- TODO: Move this to after the talents are changed using a globla variable to set the callback
    -- Gear set
    if(type(self.db.char.gearSets[self:GetCurrentSpec()]) == "table" and self.db.char.gearSets[self:GetCurrentSpec()][profileID] ~= nil) then
        local itemSetID = self.db.char.gearSets[self:GetCurrentSpec()][profileID]
        local _name, _iconFileID, _setID, isEquipped, _numItems, _numEquipped, _numInInventory, _numLost, _numIgnored = C_EquipmentSet.GetEquipmentSetInfo(itemSetID)
        if(itemSetID ~= nil  and not isEquipped) then
            C_EquipmentSet.UseEquipmentSet(itemSetID)
        end
    end

    if(profileData.type == "blizzard") then
        -- Result can be 0 - Error, 1 - NoChangeNecesary, 2 - LoadInProgress, 3 - Finished
        -- When result is 2 any other requried change need to happen after TRAIT_CONFIG_UPDATED or CONFIG_COMMIT_FAILED
        local result, changeError, _ = C_ClassTalents.LoadConfig(profileID, true)
        SwitchSwitch:DebugPrint("Result: " .. tostring(result) .. " Error: " .. tostring(changeError))
        if(result == 0) then
            return
        elseif(result == 1) then
            SwitchSwitch:DebugPrint("No change necessary")
            return
        elseif(result == 2) then
            SwitchSwitch.TalentsUpdate.UpdatePending = true
            SwitchSwitch.TalentsUpdate.PendingProfileID = profileID
        end
    else
        self:DebugPrint("Chromie is that you? AGAIN!?!?!?!")
        --Learn talents normal talents
        --if(profileData.pva ~= nil) then
        --    for i, talentTbl in ipairs(profileData.pva) do
        --        --Get the current talent info to see if the talent id changed
        --        local talent = GetTalentInfo(talentTbl.tier, talentTbl.column, 1)
        --        if talentTbl.tier > 0 and talentTbl.column > 0  then
        --            LearnTalents(talent)
        --            --If talent id changed let the user know that the talents might be wrong
        --            if(select(1, talent) ~= talentTbl.id) then
        --                SwitchSwitch:Print(L["It seems like the talent from tier: '%s' and column: '%s' have been moved or changed, check you talents!"]:format(tostring(talentTbl.tier), tostring(talentTbl.column)))
        --            end
        --        end
        --    end
        --end
    end

    -- SoonTM
    if(profileData.pvp ~= nil) then
        self:DebugPrint("PvP Talents Not Supported Yet. How did you save them?")
        --Leanr pvp talent
        --for i, pvpTalentTabl in ipairs(profileData.pvp) do
        --    if(pvpTalentTabl.unlocked and pvpTalentTabl.id ~= nil) then
        --        --Make sure the talent is not used anywhere else, set to random if used in anothet tier
        --        for i2 = 0, 3 do
        --            local pvpTalentInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(i2)
        --            if(pvpTalentInfo ~= nil and pvpTalentTabl.id == pvpTalentInfo.selectedTalentID and pvpTalentTabl.tier ~= i2) then
        --                --Get random talent
        --                LearnPvpTalent(pvpTalentInfo.availableTalentIDs[math.random(#pvpTalentInfo.availableTalentIDs)], i2)
        --            end
        --        end
        --        --Lern the talent in the tier
        --        LearnPvpTalent(pvpTalentTabl.id, pvpTalentTabl.tier)
        --    end
        --end
    end

    --Print and return
    SwitchSwitch:Print(L["Changed talents to '%s'"]:format(profileData.name))
    return true
end

-- TODO: Maybe use the profile data in one go ?
--- Check if a talent profileID is currently equiped
--- @param profileID number|string The Profile ID
--- @param checkGear boolean If we should check if the right gear set is equiped to mark the talent set as used
--- @return boolean If the profile is currently equiped
function SwitchSwitch:IsCurrentTalentProfile(profileID, checkGear)
    --Check if null or not existing
    if(not SwitchSwitch:DoesProfileExits(profileID)) then
        SwitchSwitch:DebugPrint(string.format("Profile name does not exist [%s]", profileID))
        return false
    end

    local currentprofile = SwitchSwitch:GetProfileData(profileID)
    if(currentprofile == nil) then
        return false
    end

    if(currentprofile.type == "blizzard") then
        local currentBlizzardConfigID = SwitchSwitch:GetSelectedLoadoutConfigID()
        if(currentBlizzardConfigID == nil) then
            return false
        end

        if(currentBlizzardConfigID ~= currentprofile.talentConfigId) then
            return false
        end
    elseif(currentprofile.type == "custom") then
        -- TODO: Add for custom Talents
        self:DebugPrint("How did we manage to get here? Custom talents are not available yet, Chromie is that you??")
        --if(currentprofile.pva ~= nil) then
        --    --Check normal talents
        --    for i, talentInfo in ipairs(currentprofile.pva) do
        --        local talentID, name, _, selected, available, _, _, row, column, known, _ = GetTalentInfoByID(talentInfo.id, GetActiveSpecGroup())
        --        if(not known) then
        --            SwitchSwitch:DebugPrint(string.format("Talent with the name %s is not leanred", name))
        --            return false
        --        end
        --    end
        --end
    end

    -- TODO: Add for custom Talents
    --Check pvp talents
    --local currentPVPTalentsTable = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
    --if(currentprofile.pvp ~= nil) then
    --    for i, pvpTalentInfo in ipairs(currentprofile.pvp) do
    --        --Check if we got the talent
    --        local hasTalent = false
    --        for k, talentID in ipairs(currentPVPTalentsTable) do
    --            if(talentID == pvpTalentInfo.id) then
    --                hasTalent = true;
    --            end
    --        end
    --        --We dont have the talent so just return false
    --        if(not hasTalent) then
    --            SwitchSwitch:DebugPrint("PVP tlanets does not match");
    --            return false
    --        end
    --    end
    --end

    if(checkGear) then
        -- Gear set
        if(type(self.db.char.gearSets[self:GetCurrentSpec()]) == "table" and self.db.char.gearSets[self:GetCurrentSpec()][profileID] ~= nil) then
            local name, _iconFileID, _setID, isEquipped, _numItems, _numEquipped, _numInInventory, _numLost, _numIgnored = C_EquipmentSet.GetEquipmentSetInfo(self.db.char.gearSets[self:GetCurrentSpec()][profileID])
            if(name ~= nil and not isEquipped) then
                return false
            end
        end
    end

    return true
end

function SwitchSwitch:GetCurrentActiveProfile()
    --Iterate trough every talent profile
    local lowPrioDetectedID = nil
    for id, talentData in pairs(SwitchSwitch:GetAllCurrentSpecProfiles()) do
        if(SwitchSwitch:IsCurrentTalentProfile(id, true)) then
            --Return the currentprofilename
            SwitchSwitch:DebugPrint("Detected Profile With ID: " .. id)
            return SwitchSwitch:ToLower(id)
        elseif(not lowPrioDetectedID and SwitchSwitch:IsCurrentTalentProfile(id, false)) then
            lowPrioDetectedID = id
        end
    end

    if(not lowPrioDetectedID) then
        SwitchSwitch:DebugPrint("No profiles match current talnets")
        lowPrioDetectedID = SwitchSwitch.defaultProfileID
    end
    return lowPrioDetectedID
end