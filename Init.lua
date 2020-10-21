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
        ["SelectedTalentsProfile"] = "",
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
                ["Version"] = addon.version,
            }
        end

        -- Global talents progile table
        if(SwitchSwitchProfiles == nil) then
            SwitchSwitchProfiles =
            {
                ["Version"] = addon.version,
                ["Profiles"] = {}
            }
        end

        if(SwitchSwitchConfig == nil) then
            --Default config
            SwitchSwitchConfig = GetDefaultConfig()
        end

        --Add the global variables to the addon global
        addon.sv = {}
        addon.sv.Talents = SwitchSwitchProfiles
        --Deprected just here for the this version so old folks can update, after 1 months of initial release this is removed
        -- TODO: REMOVE
        addon.sv.DEPRECTED = SwitchSwitchTalents
        addon.sv.config = SwitchSwitchConfig
    elseif(event == "PLAYER_LOGIN") then
        --Update the tables in case they are not updated
        addon:Update();
        
        --Load Commands
        addon.Commands:Init()
        --Load global frame
        addon.GlobalFrames:Init()

        --Load the UI if not currently loaded
        if(not IsAddOnLoaded("Blizzard_TalentUI")) then
            LoadAddOn("Blizzard_TalentUI")
        end
        --Check if talents is a Profile
        addon.sv.config.SelectedTalentsProfile = addon:GetCurrentProfileFromSaved()

        --Unregister current event
        self:UnregisterEvent(event)
        self:RegisterEvent("AZERITE_ESSENCE_UPDATE")
        self:RegisterEvent("PLAYER_TALENT_UPDATE")
    elseif(event == "PLAYER_TALENT_UPDATE" or event == "AZERITE_ESSENCE_UPDATE") then
        addon.sv.config.SelectedTalentsProfile = addon:GetCurrentProfileFromSaved()
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
    local oldDEPRECTEDVersion = addon.sv.DEPRECTED.Version or addon.version
    local oldTalentsVersion = addon.sv.Talents.Version or addon.version
    --Convert the string to numbers
    if(type(oldConfigVersion) == "string") then
        oldConfigVersion = tonumber(oldConfigVersion)
    end
    if(type(oldDEPRECTEDVersion) == "string") then
        oldDEPRECTEDVersion = tonumber(oldDEPRECTEDVersion)
    end
    if(type(oldTalentsVersion) == "string") then
        oldTalentsVersion = tonumber(oldTalentsVersion)
    end
    --Get current version in number
    local currentVersion = tonumber(addon.version)

    --Update deprected table
    if(oldDEPRECTEDVersion ~= currentVersion) then
        -- New talents this means all old talents are not usefull anymore
        if(oldDEPRECTEDVersion < 1.6) then
            addon.sv.DEPRECTED.TalentsProfiles = nil
        end
    end

    --Update talents table
    if(oldTalentsVersion ~= currentVersion) then
    end

    --Update config
    if(oldConfigVersion ~= currentVersion) then
        --Current selected talents are not in normal config saved now
        if(oldConfigVersion < 1.6) then
            addon.sv.config.SelectedTalentsProfile = ""
            if(oldDEPRECTEDVersion < 1.6) then
                addon.sv.config.SelectedTalentsProfile =  addon.sv.DEPRECTED.SelectedTalentsProfile
                addon.sv.DEPRECTED.SelectedTalentsProfile = nil
            end
            addon.sv.config.autoSuggest = 
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
        end
    end

    --Update versions
    addon.sv.DEPRECTED.Version = addon.version
    addon.sv.Talents.Version = addon.version
    addon.sv.config.Version = addon.version
end

-- Event handling frame
addon.event_frame = CreateFrame("Frame")
-- Set Scripts
addon.event_frame:SetScript("OnEvent", addon.eventHandler)
-- Register events
addon.event_frame:RegisterEvent("ADDON_LOADED")
addon.event_frame:RegisterEvent("PLAYER_LOGIN")
addon.event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")