--############################################
-- Namespace
--############################################
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local addonName = select(1, ...)

LastInstanceID = -1

--##########################################################################################################################
--                                  Default configurations
--##########################################################################################################################
local function GetDefaultConfig()
    return {
        ["Version"] = SwitchSwitch.version,
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
        },
        ["minimap"] = 
        { 
            ["hide"] = false,
        }

    }
end

--##########################################################################################################################
--                                  Event handling
--##########################################################################################################################
function SwitchSwitch:eventHandler(event, arg1)
    if (event == "ADDON_LOADED") then
        if(arg1 ~= addonName) then
            --Check if talents have been loaded to create our frame in top of it.
            if(arg1 == "Blizzard_TalentUI") then
                SwitchSwitch.TalentUIFrame:CreateTalentFrameUI()
            end
            return 
        end

        --Talents table
        if(SwitchSwitchTalents == nil) then
            --Default talents table
            SwitchSwitchTalents =
            {
                ["Version"] = SwitchSwitch.version,
            }
        end

        -- Global talents progile table
        if(SwitchSwitchProfiles == nil) then
            SwitchSwitchProfiles =
            {
                ["Version"] = SwitchSwitch.version,
                ["Profiles"] = {}
            }
        end

        if(SwitchSwitchConfig == nil) then
            --Default config
            SwitchSwitchConfig = GetDefaultConfig()
        end

        --Add the global variables to the addon global
        SwitchSwitch.sv = {}
        SwitchSwitch.sv.Talents = SwitchSwitchProfiles
        SwitchSwitch.sv.config = SwitchSwitchConfig
    elseif(event == "PLAYER_LOGIN") then
        --Update the tables in case they are not updated
        SwitchSwitch:Update();
        
        --Load Commands
        SwitchSwitch.Commands:Init()
        --Load global frame
        SwitchSwitch.GlobalFrames:Init()
        
        --Init the minimap
        SwitchSwitch:InitMinimapIcon()

        --Load the UI if not currently loaded
        if(not IsAddOnLoaded("Blizzard_TalentUI")) then
            LoadAddOn("Blizzard_TalentUI")
        end

        --Unregister current event
        self:UnregisterEvent(event)
        self:RegisterEvent("AZERITE_ESSENCE_UPDATE")
        self:RegisterEvent("PLAYER_TALENT_UPDATE")
    elseif(event == "PLAYER_TALENT_UPDATE" or event == "AZERITE_ESSENCE_UPDATE") then
        SwitchSwitch.sv.config.SelectedTalentsProfile = SwitchSwitch:GetCurrentProfileFromSaved()
    elseif(event == "PLAYER_ENTERING_WORLD") then
        --Check if we actually switched map from last time
        local instanceID = select(8,GetInstanceInfo())
        --Debuging
        SwitchSwitch:DebugPrint("Entering instance:" .. string.join(" - ", tostringall(GetInstanceInfo())))
        if(LastInstanceID == instanceID) then
            return
        end
        LastInstanceID = instanceID
        --Check if we are in an instance
        local inInstance, instanceType = IsInInstance()
        if(inInstance) then
            local profileNameToUse = SwitchSwitch.sv.config.autoSuggest[instanceType]

            SwitchSwitch:DebugPrint("Instance type: " .. instanceType)

            --Party is a table so we need to ge the profile out via dificullty
            if(instanceType == "party") then
                local difficulty = GetDungeonDifficultyID()
                local difficultyByID = 
                {
                    [1] = "HM", -- Normal mode but we truncate it up to hc profile mode
                    [2] = "HM",
                    [23] = "MM"
                }
                profileNameToUse = SwitchSwitch.sv.config.autoSuggest[instanceType][difficultyByID[difficulty]]
            end
            --Check if we are already in the current profile
            if(profileNameToUse ~= nil and profileNameToUse ~= "") then
                if(not SwitchSwitch:IsCurrentTalentProfile(profileNameToUse)) then 
                    SwitchSwitch:DebugPrint("Atuo suggest changing to profile: " .. profileNameToUse)
                    SwitchSwitch.GlobalFrames:ToggleSuggestionFrame(profileNameToUse)
                else
                    SwitchSwitch:DebugPrint("Profile " .. profileNameToUse .. " is already in use.")
                end
            else
                SwitchSwitch:DebugPrint("No profile set for this type of instance.")
            end
        end
    end
end

function SwitchSwitch:Update()
    --Get the old version
    local oldConfigVersion = SwitchSwitch.version
    if(SwitchSwitch.sv.config ~= nil and type(SwitchSwitch.sv.config.Version) == "string") then
        oldConfigVersion = SwitchSwitch.sv.config.Version
    end

    local oldTalentsVersion = SwitchSwitch.version
    if(SwitchSwitch.sv.Talents ~= nil and type(SwitchSwitch.sv.Talents.Version) == "string") then
        oldConfigVersion = SwitchSwitch.sv.config.Version
    end

    --Check special format
    if(SwitchSwitch:Repeats(oldConfigVersion, "%.") == 2) then
        local index = SwitchSwitch:findLastInString(oldConfigVersion, "%.")
        oldConfigVersion = string.sub( oldConfigVersion, 1, index-1) .. string.sub( oldConfigVersion, index+1)
    end

    if(SwitchSwitch:Repeats(oldTalentsVersion, "%.") == 2) then
        local index = SwitchSwitch:findLastInString(oldTalentsVersion, "%.")
        oldTalentsVersion = string.sub( oldTalentsVersion, 1, index-1) .. string.sub( oldTalentsVersion, index+1)
    end

    --Convert the string to numbers
    oldConfigVersion = tonumber(oldConfigVersion)
    oldTalentsVersion = tonumber(oldTalentsVersion)
    --Get current version in number
    local currentVersion = tonumber(SwitchSwitch.version)

    --Update talents table
    if(oldTalentsVersion ~= currentVersion) then
    end

    --Update config
    if(oldConfigVersion ~= currentVersion) then
        --Current selected talents are not in normal config saved now
        if(oldConfigVersion < 1.6) then
            SwitchSwitch.sv.config.SelectedTalentsProfile = ""
            SwitchSwitch.sv.config.autoSuggest = 
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

    SwitchSwitch.sv.Talents.Version = SwitchSwitch.version
    SwitchSwitch.sv.config.Version = SwitchSwitch.version
end

-- Event handling frame
SwitchSwitch.event_frame = CreateFrame("Frame")
-- Set Scripts
SwitchSwitch.event_frame:SetScript("OnEvent", SwitchSwitch.eventHandler)
-- Register events
SwitchSwitch.event_frame:RegisterEvent("ADDON_LOADED")
SwitchSwitch.event_frame:RegisterEvent("PLAYER_LOGIN")
SwitchSwitch.event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")