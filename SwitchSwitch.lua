--############################################
-- Namespace
--############################################
local namespace = select(2, ...)

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

SwitchSwitch.InternalVersion = 20
SwitchSwitch.defaultProfileName = "custom"
SwitchSwitch.CurrentActiveTalentsProfile = SwitchSwitch.defaultProfileName

--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
-- Function to print a debug message
function SwitchSwitch:DebugPrint(...)
    if(type(self.db) ~= "table" or self.db.profile.debug) then
        self:Print(string.join(" ", "|cFFFF0000(DEBUG)|r", tostringall(... or "nil")));
    end
end

function SwitchSwitch:DebugPrintTable(tbl, indent)
    if not indent then indent = 0 end
    if type(tbl) == 'table' then
        for k, v in pairs(tbl) do
            local formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                self:Print(formatting)
                self:PrintTableDebug(v, indent+1)
            else
                self:DebugPrint(formatting .. tostring(v))
            end
        end
    end
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
    return select(1, GetSpecializationInfo(GetSpecialization()))
end

function SwitchSwitch:GetPlayerClass()
    return select(3, UnitClass("player"))
end

function SwitchSwitch:HasHeartOfAzerothEquipped()
    return GetInventoryItemID("player", INVSLOT_NECK) == 158075
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
            for suggestionType, profilesList in pairs(instanceSuggestionData) do
                for id, suggestedProfileName in pairs(profilesList) do
                    if(name == suggestedProfileName) then
                        profilesList[id] = nil
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
            for suggestionType, profilesList in pairs(instanceSuggestionData) do
                for id, suggestedProfileName in pairs(profilesList) do
                    if(name == suggestedProfileName) then
                        profilesList[id] = newName
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
    for i, k in ipairs(C_MythicPlus.GetCurrentAffixes()) do
        table.insert(ids, k.id)
    end

    return self:encodeMythicPlusAffixesIDs(unpack(ids))
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

--Get the talent from the current active spec
function SwitchSwitch:GetCurrentTalents(saveTalentsPVP)
    local talentSet =
    {
        ["pva"] = {}
    }

    --Iterate over all tiers of talents normal
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

    --Get Essence information
    if(SwitchSwitch:HasHeartOfAzerothEquipped()) then
        talentSet["heart_of_azeroth_essences"] = {}
        local MilestoneIDs = {115,116,117,119}
        for index, id in ipairs(MilestoneIDs) do
            local milestonesInfo = C_AzeriteEssence.GetMilestoneInfo(id)
            if(milestonesInfo.unlocked) then
                talentSet["heart_of_azeroth_essences"][milestonesInfo.ID] = C_AzeriteEssence.GetMilestoneEssence(id)
            end
        end
    end

    --Return talents
    return talentSet;
end

--Check if we can switch talents
function SwitchSwitch:CanChangeTalents()
    --Quick return if resting for better performance
    if(IsResting()) then
        return true
    end
    -- If in combat we cannot change so lets exit early
   if(InCombatLockdown()) then
        return false
   end

    --All buffs ids for the tomes
    local buffLookingFor =
    {
        226234,
        227041,
        227563,
        227565,
        227569,
        256231,
        256229,
        --Arena preparation wow
        32727,
        32728,
        -- Dungeon preparation
        228128,
        -- Battleground Insight
        248473,
        44521,
        -- SL LVL 60
        -- Refuge of the dammed
        338907,
        -- Still mind tomes
        324029,
        324028,
        321923,
        -- Time to reflect
        325012,
    }
    local debuffsLookingFor =
    {
        --PRepare for battle
        290165,
        279737
    };
    --There is no quick way to get if a player has a specific buff so we need to go tought all players buff and check if its one of the one we need
    for i = 1, 40 do
        local spellID = select(10, UnitBuff("player", i))
        for index, id in ipairs(buffLookingFor) do
            if(spellID == id) then
                return true
            end
        end
    end
    --Check debufs aswell
    for i = 1, 40 do
        local spellID = select(10, UnitDebuff("player", i))
        for index, id in ipairs(debuffsLookingFor) do
            if(spellID == id) then
                return true
            end
        end
    end
    --Buff not found
    return false
end

function SwitchSwitch:GetValidTomesItemsID()
    local tomesID = {}
    --Check for level to add the Clear mind tome
    if (UnitLevel("player") <= 50) then
        table.insert(tomesID, 141640) -- Clear mind
        table.insert(tomesID, 141446) -- Tranquil mind crafted
        table.insert(tomesID, 143785) -- tranquil mind _ dalaran quest
        table.insert(tomesID, 143780)  -- tranquil mind _ random
    end

    if (UnitLevel("player") <= 59) then
        table.insert(tomesID, 153647) -- Quit mind
    end

    if (UnitLevel("player") <= 60) then
        table.insert(tomesID, 173049) -- Still mind
    end

    return tomesID
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

    --If we cannot change talents why even try?
    if(not SwitchSwitch:CanChangeTalents()) then
        if(SwitchSwitch.db.profile.autoUseTomes) then
            -- Now all tomes have level so lets add them based on character level
            local tomesID = self:GetValidTomesItemsID()

            --Tomes that can be used
            local itemIDToUse = nil
            local bagID = 0
            local slot = 0
            --Find any tome usable in the bags
            for bag = 0, NUM_BAG_SLOTS + 1 do
                for bagSlot = 1, GetContainerNumSlots(bag) do
                    local currentItemInSlotID = GetContainerItemID(bag, bagSlot)
                    for index, id in ipairs(tomesID) do
                        if(id == currentItemInSlotID) then
                            itemIDToUse = currentItemInSlotID
                            bagID = bag
                            slot = bagSlot
                            break
                        end
                    end
                end
            end


            --Check if we found an item if not return false
            if(not itemIDToUse) then
                --No item found so return
                SwitchSwitch:Print(L["Could not find a Tome to use and change talents"])
                return false
            end

            -- Set the item attibute
            --Got an item so open the popup to ask to use it!
            local dialog = StaticPopup_Show("SwitchSwitch_ConfirmTomeUsage", nil, nil, bagID .. " " .. slot)
            if(dialog) then
                SwitchSwitch:DebugPrint("Setting data to ask for tome usage to: " .. profileName)
                dialog.data2 = profileName
            end
        else
            --No check for usage so just return
            SwitchSwitch:Print(L["Could not change talents as you are not in a rested area, or don’t have the buff"])
        end
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
    if(not IsAddOnLoaded("Blizzard_TalentUI")) then
        LoadAddOn("Blizzard_TalentUI")
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


    if(currentTalentProfile.heart_of_azeroth_essences ~= nil and SwitchSwitch:HasHeartOfAzerothEquipped()) then
        --Learn essences
        for milestoneID, essenceID in pairs(currentTalentProfile.heart_of_azeroth_essences) do
            C_AzeriteEssence.ActivateEssence(essenceID, milestoneID)
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
end

--Check if a given profile is the current talents
function SwitchSwitch:IsCurrentTalentProfile(profileName)
    --Check if null or not existing
    if(not SwitchSwitch:DoesProfileExits(profileName)) then
        SwitchSwitch:DebugPrint(string.format("Profile name does not exist [%s]", profileName))
        return false
    end

    local currentActiveTalents = SwitchSwitch:GetCurrentTalents()
    local currentprofile = SwitchSwitch:GetProfileData(profileName)

    if(currentprofile.heart_of_azeroth_essences ~= nil and SwitchSwitch:HasHeartOfAzerothEquipped()) then
        --Check essences
        for milestoneID, essenceID in pairs(currentActiveTalents.heart_of_azeroth_essences) do
            if(currentprofile.heart_of_azeroth_essences[milestoneID] == nil or essenceID ~= currentprofile.heart_of_azeroth_essences[milestoneID]) then
                SwitchSwitch:DebugPrint("Essences do not match");
                return false
            end
        end
    end

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
    return true
end

function SwitchSwitch:GetCurrentActiveProfile()
    --Iterate trough every talent profile
    for name, TalentArray in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
        if(SwitchSwitch:IsCurrentTalentProfile(name)) then
            --Return the currentprofilename
            SwitchSwitch:DebugPrint("Detected: " .. name)
            return name:lower()
        end
    end
    SwitchSwitch:DebugPrint("No profiles match current talnets")
    --Return the custom profile name
    return SwitchSwitch.defaultProfileName
end