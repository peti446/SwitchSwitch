--############################################
-- Namespace
--############################################
local addonName, addon = ...

addon.LastInstanceID = -1

--##########################################################################################################################
--                                  Default configurations
--##########################################################################################################################
local function GetDefaultConfig()
    return {
        ["Version"] = addon.version,
        ["debug"] = false,
        ["autoUseItems"] = true,
        ["SuggestionFramePoint"] =
        {
            ["point"] = "CENTER",
            ["relativePoint"] = "CENTER",
            ["frameX"] = 0,
            ["frameY"] = 0
        },
        ["maxTimeSuggestionFrame"] = 15,
        ["autoSuggest"] = 
        {
            ["pvp"] = "",
            ["arena"] = "",
            ["raid"] = "",
            ["party"] = 
            {
                ["HM"] = "",
                ["MM"] = ""                
            }
        }
    }
end

--##########################################################################################################################
--                                  Event handling
--##########################################################################################################################
function addon:eventHandler(event, arg1)
    if (event == "ADDON_LOADED") then
        if(arg1 ~= addonName) then
            --Check if talents have been loaded to create our frame in top of it.
            if(arg1 == "Blizzard_TalentUI") then
                addon.TalentUIFrame:CreateTalentFrameUI()
            end
            return 
        end

        --Talents table
        if(SwitchSwitchTalents == nil) then
            --Default talents table
            SwitchSwitchTalents =
            {
                ["SelectedTalentsProfile"] = "",
                ["Version"] = addon.version,
                ["TalentsProfiles"] = {}
            }
        end

        if(SwitchSwitchConfig == nil) then
            --Default config
            SwitchSwitchConfig = GetDefaultConfig()
        end

        --Add the global variables to the addon global
        addon.sv = {}
        addon.sv.Talents = SwitchSwitchTalents
        addon.sv.config = SwitchSwitchConfig
        --Update the tables in case they are not updated
        addon:Update();
    elseif(event == "PLAYER_LOGIN") then
        --Load Commands
        addon.Commands:Init()
        --Load global frame
        addon.GlobalFrames:Init()

        --Load the UI if not currently loaded
        if(not IsAddOnLoaded("Blizzard_TalentUI")) then
            LoadAddOn("Blizzard_TalentUI")
        end
        --Check if talents is a Profile
        addon.sv.Talents.SelectedTalentsProfile = addon:GetCurrentProfileFromSaved()

        --Unregister current event
        self:UnregisterEvent(event)
    elseif(event == "PLAYER_TALENT_UPDATE" or event == "AZERITE_ESSENCE_UPDATE") then
        if( not addon.G.SwitchingTalents) then
            addon.sv.Talents.SelectedTalentsProfile = addon:GetCurrentProfileFromSaved()
            addon:Debug("Selected profile before equiping: " .. addon.sv.Talents.SelectedTalentsProfile)
            if(addon.sv.Talents.SelectedTalentsProfile ~= addon.CustomProfileName and addon:DoesTalentProfileExist(addon.sv.Talents.SelectedTalentsProfile)) then
                --Check if equiped the set if not equip
                local tbl = addon:GetTalentTable(addon.sv.Talents.SelectedTalentsProfile)
                if(tbl.gearSet ~= nil) then
                    addon:Debug("Gear set:" .. tbl.gearSet)
                    local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(tbl.gearSet)
                    addon:Debug("Gear set " .. name .. " is ", isEquipped)
                    if(not isEquipped) then
                        C_EquipmentSet.UseEquipmentSet(tbl.gearSet)
                    end
                else
                    addon:Debug("Gear set is nil")
                end
            end
        end
    elseif(event == "PLAYER_ENTERING_WORLD") then
        --Check if we actually switched map from last time
        local instanceID = select(8,GetInstanceInfo())
        --Debuging
        addon:Debug("Entering instance:" .. string.join(" - ", tostringall(GetInstanceInfo())))
        if(addon.LastInstanceID == instanceID) then
            return
        end
        addon.LastInstanceID = instanceID
        --Check if we are in an instance
        local inInstance, instanceType = IsInInstance()
        if(inInstance) then
            local porfileNameToUse = addon.sv.config.autoSuggest[instanceType]

            addon:Debug("Instance type: " .. instanceType)

            --Party is a table so we need to ge the profile out via dificullty
            if(instanceType == "party") then
                local difficulty = GetDungeonDifficultyID()
                local difficultyByID = 
                {
                    [1] = "HM", -- Normal mode but we truncate it up to hc profile mode
                    [2] = "HM",
                    [23] = "MM"
                }
                porfileNameToUse = addon.sv.config.autoSuggest[instanceType][difficultyByID[difficulty]]
            end
            --Check if we are already in the current porfile
            if(porfileNameToUse ~= nil and porfileNameToUse ~= "") then
                if(not addon:IsCurrentTalentProfile(porfileNameToUse)) then 
                    addon:Debug("Atuo suggest changing to profile: " .. porfileNameToUse)
                    addon.GlobalFrames:ToggleSuggestionFrame(porfileNameToUse)
                else
                    addon:Debug("Profile " .. porfileNameToUse .. " is already in use.")
                end
            else
                addon:Debug("No profile set for this type of instance.")
            end
        end
    end
end

function addon:Update()
    --Get the old version
    local oldConfigVersion = addon.sv.config.Version or addon.version
    local oldTalentsVersion = addon.sv.Talents.Version or addon.version
    --Convert the string to numbers
    if(type(oldConfigVersion) == "string") then
        oldConfigVersion = tonumber(oldConfigVersion)
    end
    if(type(oldTalentsVersion) == "string") then
        oldTalentsVersion = tonumber(oldTalentsVersion)
    end
    --Get current version in number
    local currentVersion = tonumber(addon.version)


    --Update talent table
    if(oldTalentsVersion ~= currentVersion) then
        --If the version is lower then the 1.1 (the version will be 1.0), the data will be in the wrong fformat so update it
        if(oldTalentsVersion < 1.1) then
            --No pvp talents are present so lets just get the current table and set it to pva and leave pvp empty
            --Iterate over each spec and then talents set
            for specID, talentSets in pairs(addon.sv.Talents.TalentsProfiles) do
                for talentSetName, normalTalentInfoTbl in pairs(talentSets) do
                    --By default the format of the normal talbe info will be the information of normal talents so just copy these to the pva fuield
                    local newFormat = 
                    {
                        ["pva"] = addon:deepcopy(normalTalentInfoTbl),
                        ["pvp"] = {}
                    }
                    --Updathe the table
                    addon.sv.Talents.TalentsProfiles[specID][talentSetName] = newFormat
                end
            end
        end

        --If the version is lower then 1.4 the essence table is not included so add it
        if(oldTalentsVersion < 1.4) then
            for specID, talentSets in pairs(addon.sv.Talents.TalentsProfiles) do
                for talentSetName, talentTable in pairs(talentSets) do
                    --By default the format of the normal talbe info will be the information of normal talents so just copy these to the pva fuield
                    local newFormat = addon:deepcopy(talentTable)
                    newFormat["essences"] = {}
                    --Updathe the table
                    addon.sv.Talents.TalentsProfiles[specID][talentSetName] = newFormat
                end
            end
        end

        --Update the version
        addon.sv.Talents.Version = addon.version
    end

    --Update config
    if(oldConfigVersion ~= currentVersion) then

        addon.sv.config.Version = addon.version
    end
end

-- Event handling frame
addon.event_frame = CreateFrame("Frame")
-- Set Scripts
addon.event_frame:SetScript("OnEvent", addon.eventHandler)
-- Register events
addon.event_frame:RegisterEvent("ADDON_LOADED")
addon.event_frame:RegisterEvent("PLAYER_LOGIN")
addon.event_frame:RegisterEvent("PLAYER_TALENT_UPDATE")
addon.event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
addon.event_frame:RegisterEvent("AZERITE_ESSENCE_UPDATE")