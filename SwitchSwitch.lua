--############################################
-- Namespace
--############################################
local _, addon = ...

addon.G = {}
addon.G.SwitchingTalents = false
addon.version = "1.0"
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
    --Iterate 
    for k,v in pairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) do
        if(k:lower() == Profile:lower()) then
            return true
        end
    end
    return false
end

--Get the talent from the current active spec
function addon:GetCurrentTalents()
    local ChosenTalents = {};
    for Tier = 1, GetMaxTalentTier() do
        ChosenTalents[Tier] =
        {
            ["id"] = nil,
            ["tier"] = nil,
            ["column"] = nil
        }
        for Column = 1, 3 do
            talentID, name, texture, selected, available, _, _, _, _, _, _ = GetTalentInfo(Tier, Column, GetActiveSpecGroup())
            if(selected) then
                ChosenTalents[Tier]["id"] = talentID
                ChosenTalents[Tier]["tier"] = Tier
                ChosenTalents[Tier]["column"] = Column
                break
            end
        end
    end
    return ChosenTalents;
end

--Check if we can switch talents
function addon:CanChangeTalents()
    --Quick return if resting for better performance
    if(IsResting()) then
        return true
    end
    local buffLookingFor = 
    {
        226234,
        227041,
        227563,
        227565,
        227569,
        256231,
        256229
    }
    for i = 1, 40 do
        local spellID = select(10, UnitBuff("player", i))
        for index, id in ipairs(buffLookingFor) do
            if(spellID == id) then
                return true
            end
        end
    end
    return false
end

function addon:ActivateTalentProfile(profileName)
    --Check if profileName is not null
    if(not profileName or type(profileName) ~= "string") then
        addon:Debug(addon.L["Givine profile name is null"])
        return false
    end

    --Check  if table exits
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] == nil or addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName]) ~= "table") then
        addon:Debug(addon.L["Could not change talents to Profile '%s' as it does not exits in the database"]:format(profileName))
        return false
    end

    --If we cannot change talents why even try?
    if(not addon:CanChangeTalents()) then
        addon:Print(addon.L["Could not change talents as you are not in a rested area, or dont have the buff"])
        return false
    end

    --Function to set talents
    addon:SetTalents(profileName)

    return true
end

function addon:ActivateTalentProfileCallback(profileName, callback)
    --Check if callbar is valid if not assign it a simple funciton
    if(not callback) then
        callback = function(suceeded) end
    end

    --Check if profileName is not null
    if(not profileName or type(profileName) ~= "string") then
        addon:Debug(addon.L["Givine profile name is null"])
        callback(true)
        return
    end

    --Check  if table exits
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] == nil or addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName]) ~= "table") then
        addon:Debug(addon.L["Could not change talents to Profile '%s' as it does not exits in the database"]:format(profileName))
        callback(true)
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
                callback(false)
                return
            end

            -- Set the item attibute
            addon.GlobalFrames.UseTome:SetAttribute("item", bagID .. " " .. slot);
            --Got an item so open the popup to ask to use it!
            local dialog = StaticPopup_Show("SwitchSwitch_ConfirmTomeUsage", nil, nil, nil, addon.GlobalFrames.UseTome)
            if(dialog) then
                dialog.data = {["name"] = profileName, ["callback"] = callback}
            end
        else
            --No check for usage so just return
            addon:Print(addon.L["Could not change talents as you are not in a rested area, or dont have the buff"])
            callback(false)
        end
        return
    end
    
    --Function to set talents
    addon:SetTalents(profileName)
    callback(true)
end

--Helper function to avoid needing to copy-caste every time...
function addon:SetTalents(profileName)
    --Make sure our event talent change does not detect this as custom switch
    addon.G.SwitchingTalents = true

    --Learn talents
    for i, talentTbl in ipairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName]) do
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
    --Print and return
    addon:Print(addon.L["Changed talents to '%s'"]:format(profileName))
    --Set the global switching variable to false so we detect custom talents switches (after a time as the evnt might fire late)
    C_Timer.After(0.3,function() addon.G.SwitchingTalents = false end)
    --Set the global value of the current Profile so we can remember it later
    addon.sv.Talents.SelectedTalentsProfile = profileName
end

--Check if a given porfile is the current talents
function addon:IsCurrentTalentProfile(profileName)
    --Check if null or not existing
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) ~= "table"
        or addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName]) ~= "table") then
        return false
    end
    --Get current tier
    local currentTalents = addon:GetCurrentTalents()
    for i, talentInfo in ipairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName]) do
        if(currentTalents[talentInfo.tier].tier ~= talentInfo.tier) then
            --Not in current tier iterate to find tier
            for i2, currentTalentInfo in ipairs(currentTalentInfo) do
                if(currentTalentInfo.tier == talentInfo.tier) then
                    --In correct tier, check columns to see if equals, if not retun false
                    if(currentTalents[talentInfo.tier].column ~= talentInfo.column) then
                        return false
                    end
                end
            end
        else
            --In correct tier, check columns to see if equals, if not retun false
            if(currentTalents[talentInfo.tier].column ~= talentInfo.column) then
                return false
            end
        end
    end
    return true
end

--Gets the porfile that is active from all the saved porfiles
function addon:GetCurrentProfileFromSaved()
    --Check if null or not existing
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] == nil or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) ~= "table") then
        return addon.CustomProfileName
    end
    --Iterate trough every talent profile
    for name, TalentArray in pairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) do
        if(addon:IsCurrentTalentProfile(name)) then
            return name
        end
    end
    return addon.CustomProfileName
end

--Helper function to execute a command in chat
function addon:RunSlashCmd(cmd)
    local slash, rest = cmd:match("^(%S+)%s*(.-)$")
    addon:Print(cmd)
    for name, func in pairs(SlashCmdList) do
       local i, slashCmd = 1
       repeat
          slashCmd, i = _G["SLASH_"..name..i], i + 1
          if slashCmd == slash then
             return true, func(rest)
          end
       until not slashCmd
    end
    -- Okay, so it's not a slash command. It may also be an emote.
    local i = 1
    while _G["EMOTE" .. i .. "_TOKEN"] do
       local j, cn = 2, _G["EMOTE" .. i .. "_CMD1"]
       while cn do
          if cn == slash then
             return true, DoEmote(_G["EMOTE" .. i .. "_TOKEN"], rest);
          end
          j, cn = j+1, _G["EMOTE" .. i .. "_CMD" .. j]
       end
       i = i + 1
    end
  end