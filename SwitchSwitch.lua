--############################################
-- Namespace
--############################################
local _, addon = ...

addon.G = {}
addon.G.SwitchingTalents = false
addon.version = "1.46"
addon.CustomProfileName = "Custom"

--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
-- Function to print a debug message
function addon:Debug(...)
    if(addon.sv.config.debug) then
        addon:Print(string.join(" ", "|cFFFF0000(DEBUG)|r", tostringall(... or "nil")));
    end
end

-- Function to print a message to the chat.
function addon:Print(...)
    local msg = string.join(" ","|cFF029CFC[SwitchSwitch]|r", tostringall(... or "nil"));
    DEFAULT_CHAT_FRAME:AddMessage(msg);
end

--Print a table, if the value of a key is a talbe recursivly call the function again
function addon:PrintTable(tbl, indent)
    if not indent then indent = 0 end
    if type(tbl) == 'table' then
        for k, v in pairs(tbl) do
            formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
              addon:Print(formatting)
              addon:PrintTable(v, indent+1)
            else
                addon:Print(formatting .. tostring(v))
            end
        end
    end
end

--Checks if the talents Profile database contains the given Profile
function addon:DoesTalentProfileExist(Profile)
    --If talent spec table does not exist create one
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] == nil) then
        addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] = {}
    end
    --Iterate to find the profile (could use quick [profile] to see if it exits, but we want to compare allin lower (names are not case sentivies))
    for k,v in pairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) do
        if(k:lower() == Profile:lower()) then
            --Profile exists
            return true
        end
    end
    --Profile does not exist
    return false
end

--Get the talent from the current active spec
function addon:GetCurrentTalents(saveTalentsPVP)
    --If not provided save talents will be true
    if(saveTalentsPVP == nil) then
        saveTalentsPVP = true;
    end

    local talentSet =
    {
        ["pva"] = {},
        ["pvp"] = {},
        ["essences"] = {}
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
            talentID, name, texture, selected, available, _, _, _, _, _, _ = GetTalentInfo(Tier, Column, GetActiveSpecGroup())
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
        --Iterate over pvp talents
        for Tier = 1, 4 do
            pvpTalentInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(Tier)
            talentSet["pvp"][Tier] =
            {
                ["unlocked"] = pvpTalentInfo.enabled,
                ["id"] = pvpTalentInfo.selectedTalentID,
                ["tier"] = Tier
            }
        end
    end
    --Get Essence information
    local MilestoneIDs = {115,116,117}
    for index, id in ipairs(MilestoneIDs) do
        local milestonesInfo = C_AzeriteEssence.GetMilestoneInfo(id)
        if(milestonesInfo.unlocked) then
            talentSet["essences"][milestonesInfo.ID] = C_AzeriteEssence.GetMilestoneEssence(id)
        end
    end
    --local milestonesInfo = C_AzeriteEssence.GetMilestones()
    --for i, slotInfo in ipairs(milestonesInfo) do
    --    if(slotInfo.unlocked) then
    --        talentSet["essences"][slotInfo.ID] = C_AzeriteEssence.GetMilestoneEssence(slotInfo.ID)
    --        addon:Debug("asdasdda", slotInfo.ID)
    --    end
    --end
    --Return talents
    return talentSet;
end

--Check if we can switch talents
function addon:CanChangeTalents()
    --Quick return if resting for better performance
    if(IsResting()) then
        return true
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
        44521
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

function addon:ActivateTalentProfile(profileName)

    if(UnitAffectingCombat("Player")) then
        addon:Debug("Player is in combat.")
        return
    end

    --Check if profileName is not null
    if(not profileName or type(profileName) ~= "string") then
        addon:Debug("Given profile name is null")
        return
    end

    --Check  if table exits
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] == nil or addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName]) ~= "table") then
        addon:Print(addon.L["Could not change talents to Profile '%s' as it does not exit"]:format(profileName))
        return
    end

    --If we cannot change talents why even try?
    if(not addon:CanChangeTalents()) then
        if(addon.sv.config.autoUseItems) then
            local tomesID = 
            {
                153647, -- Quit mind
                141446, -- Tranquil mind crafted
                143785, -- tranquil mind _ dalaran quest
                143780  -- tranquil mind _ random
            }
            --Check for level to add the Clear mind tome
            if (UnitLevel("player") <= 109) then
                table.insert(tomesID, 141640) -- Clear mind
            end

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
                addon:Print(addon.L["Could not find a Tome to use and change talents"])
                return
            end

            -- Set the item attibute
            --Got an item so open the popup to ask to use it!
            local dialog = StaticPopup_Show("SwitchSwitch_ConfirmTomeUsage", nil, nil, bagID .. " " .. slot)
            if(dialog) then
                addon:Debug("Setting data to ask for tome usage to: " .. profileName)
                dialog.data2 = profileName
            end
        else
            --No check for usage so just return
            addon:Print(addon.L["Could not change talents as you are not in a rested area, or dont have the buff"])
        end
        return
    end

    --Function to set talents
    addon:SetTalents(profileName)
end
--Helper function to avoid needing to copy-caste every time...
function addon:SetTalents(profileName)
    --Make sure our event talent change does not detect this as custom switch
    addon.G.SwitchingTalents = true
    addon:Print(addon.L["Changing talents"])

    --Check if the talent addon is up
    if(not IsAddOnLoaded("Blizzard_TalentUI")) then
        LoadAddOn("Blizzard_TalentUI")
    end

    local currentTalentPorfile = addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName]

    --Learn talents normal talents
    for i, talentTbl in ipairs(currentTalentPorfile.pva) do
        --Get the current talent info to see if the talent id changed
        local talent = GetTalentInfo(talentTbl.tier, talentTbl.column, 1)
        if talentTbl.tier > 0 and talentTbl.column > 0  then
            LearnTalents(talent)
            --If talent id changed let the user know that the talents might be wrong
            if(select(1, talent) ~= talentTbl.id) then
                addon:Print(addon.L["It seems like the talent from tier: '%s' and column: '%s' have been moved or changed, check you talents!"]:format(tostring(talentTbl.tier), tostring(talentTbl.column)))
            end
        end
    end
    --Leanr pvp talent
    for i, pvpTalentTabl in ipairs(currentTalentPorfile.pvp) do
        if(pvpTalentTabl.unlocked and pvpTalentTabl.id ~= nil) then
            --Make sure the talent is not used anywhere else, set to random if used in anothet tier
            for i2 = 1, 4 do
                local pvpTalentInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(i2)
                if(pvpTalentTabl.id == pvpTalentInfo.selectedTalentID and pvpTalentTabl.tier ~= i2) then
                    --Get random talent
                    LearnPvpTalent(pvpTalentInfo.availableTalentIDs[math.random(#pvpTalentInfo.availableTalentIDs)], i2)
                end
            end
            --Lern the talent in the tier
            LearnPvpTalent(pvpTalentTabl.id, pvpTalentTabl.tier)
        end
    end 
    --Learn essences
    for milestoneID, essenceID in pairs(currentTalentPorfile.essences) do
        C_AzeriteEssence.ActivateEssence(essenceID, milestoneID)
    end

    --Change gear set if available
    if(currentTalentPorfile.gearSet ~= nil) then
        addon:Debug("ID: ", currentTalentPorfile.gearSet)
        C_EquipmentSet.UseEquipmentSet(currentTalentPorfile.gearSet)
    end


    --Print and return
    addon:Print(addon.L["Changed talents to '%s'"]:format(profileName))
    --Set the global switching variable to false so we detect custom talents switches (after a time as the evnt might fire late)
    C_Timer.After(0.3,function() addon.G.SwitchingTalents = false end)
    --Set the global value of the current Profile so we can remember it later
    addon.sv.Talents.SelectedTalentsProfile = profileName
end

--Check if a given profile is the current talents
function addon:IsCurrentTalentProfile(profileName)
    --Check if null or not existing
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) ~= "table"
        or addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName]) ~= "table") then
        addon:Debug(string.format("Profile name does not exist [%s]", profileName))
        return false
    end

    local currentActiveTalents = addon:GetCurrentTalents()
    --Check essences
    for milestoneID, essenceID in pairs(currentActiveTalents.essences) do
        if( addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName].essences[milestoneID] == nil or essenceID ~=  addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName].essences[milestoneID]) then
            addon:Debug("Essences do not match");
            return false   
        end
    end

    --Check pvp talents
    local currentPVPTalentsTable = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
    for i, pvpTalentInfo in ipairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName].pvp) do
        --Check if we got the talent
        local hasTalent = false
        for k, talentID in ipairs(currentPVPTalentsTable) do
            if(talentID == pvpTalentInfo.id) then
                hasTalent = true;
            end
        end
        --We dont have the talent so just return false
        if(not hasTalent) then
            addon:Debug("PVP tlanets does not match");
            return false
        end
    end
    --Check normal talents
    for i, talentInfo in ipairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName].pva) do
        talentID, name, _, selected, available, _, _, row, column, known, _ = GetTalentInfoByID(talentInfo.id, GetActiveSpecGroup())
        if(not known) then
            addon:Debug(string.format("Talent with the name %s is not leanred", name))
            return false
        end
    end
    return true
end

--Gets the profile that is active from all the saved profiles
function addon:GetCurrentProfileFromSaved()
    --Check if null or not existing
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) ~= "table") then
        addon:Debug("Current specialization has no profiles")
        return addon.CustomProfileName
    end
    --Iterate trough every talent profile
    for name, TalentArray in pairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) do
        if(addon:IsCurrentTalentProfile(name)) then
            --Return the currentprofilename
            return name
        end
    end
    addon:Debug("No profiles match current talnets")
    --Return the custom profile name
    return addon.CustomProfileName
end
--Lua helper functions
--creates a deep copy of the table
function addon:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[addon:deepcopy(orig_key)] = addon:deepcopy(orig_value)
        end
        setmetatable(copy, addon:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function addon:tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end