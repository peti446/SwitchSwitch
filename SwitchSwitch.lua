--############################################
-- Namespace
--############################################
local _, addon = ...

addon.G = {}
addon.G.SwitchingTalents = false
addon.version = "1.0"

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

--Checks if the talents porfile database contains the given porfile
function addon:DoesTalentProfileExist(porfile)
    --If talent spec table does not exist create one
    if(addon.sv.Talents.TalentsProfiles[GetSpecialization()] == nil) then
        addon.sv.Talents.TalentsProfiles[GetSpecialization()] = {}
    end
    --Iterate 
    for k,v in pairs(addon.sv.Talents.TalentsProfiles[GetSpecialization()]) do
        if(k:lower() == porfile:lower()) then
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
        local spellID = select(10, UnitBuff("player"), i)
        for index, id in ipairs(buffLookingFor) do
            if(spellID == id) then
                return true
            end
        end
    end
    return false
end

function addon:ActivateTalentPorfile(profileName)
    --If we cannot change talents why even try?
    if(not addon:CanChangeTalents()) then
        addon:Print(addon.L["Could not change talents as you are not in a rested area, or dont have the buff"])
        return false
    end

    --Check if profileName is not null
    if(not profileName or type(profileName) ~= "string") then
        addon:Debug(addon.L["Givine profile name is null"])
        return false
    end

    --Check  if table exits
    if(addon.sv.Talents.TalentsProfiles[GetSpecialization()] == nil or addon.sv.Talents.TalentsProfiles[GetSpecialization()][profileName] == nil or type(addon.sv.Talents.TalentsProfiles[GetSpecialization()][profileName]) ~= "table") then
        addon:Debug(addon.L["Could not change talents to porfile %s as it does not exits in the database"]:format(profileName))
        return false
    end

    --Make sure our event talent change does not detect this as custom switch
    addon.G.SwitchingTalents = true

    --Learn talents
    for i, talentTbl in ipairs(addon.sv.Talents.TalentsProfiles[GetSpecialization()][profileName]) do
        --Get the current talent info to see if the talent id changed
        local talent = GetTalentInfo(talentTbl.tier, talentTbl.column, 1)
        if talentTbl.tier > 0 and talentTbl.column > 0  then
            LearnTalents(talent)
            --If talent id changed let the user know that the talents might be wrong
            if(select(1, talent) ~= talentTbl.id) then
                addon:Print(addon.L["It seems like the talent from tier: %s and column: %s have been moved or changed, check you talents!"]:format(tostring(talentTbl.tier), tostring(talentTbl.column)))
            end
        end
    end
    --Print and return
    addon:Print(addon.L["Changed talents to %s"]:format(profileName))
    --Set the global switching variable to false so we detect custom talents switches (after a time as the evnt might fire late)
    C_Timer.After(0.3,function() addon.G.SwitchingTalents = false end)
    --Set the global value of the current porfile so we can remember it later
    addon.sv.Talents.SelectedTalentsProfile = profileName
    return true
end