--############################################
-- Namespace
--############################################
local addonName, addon = ...

--##########################################################################################################################
--                                  Default configurations
--##########################################################################################################################
local function GetDefaultConfig()
    return {
        ["Version"] = addon.version,
        ["debug"] = false,
        ["autoUseItems"] = false,
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
                SelectedTalentsProfile = "",
                Version = addon.version,
                TalentsProfiles = {}
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
    elseif(event == "PLAYER_LOGIN") then
        --Load Commands
        addon.Commands:Init()
        --Load global frame
        addon.GlobalFrames:Init()

        --Check if talents is a Profile
        addon.sv.Talents.SelectedTalentsProfile = addon:GetCurrentProfileFromSaved()

        --Unregister current event
        self:UnregisterEvent(event)
    elseif(event == "PLAYER_TALENT_UPDATE") then
        if(IsAddOnLoaded("Blizzard_TalentUI") and not addon.G.SwitchingTalents) then
            addon.sv.Talents.SelectedTalentsProfile = addon:GetCurrentProfileFromSaved()
            UIDropDownMenu_SetSelectedValue(addon.TalentUIFrame.UpperTalentsUI.DropDownTalents, addon.sv.Talents.SelectedTalentsProfile)
            if(addon.sv.Talents.SelectedTalentsProfile == addon.CustomProfileName) then
                addon.TalentUIFrame.UpperTalentsUI.DeleteButton:Disable()
            end
        end
    elseif(event == "PLAYER_ENTERING_WORLD") then
        local inInstance, instanceType = IsInInstance()
        if(inInstance) then
            local porfileNameToUse = addon.sv.config.autoSuggest[instanceType]
            if(instanceType == "party") then
                local difficulty = GetDungeonDifficultyID()
                local difficultyByID = 
                {
                    [1] = "HM", -- Normal mode but we truncate it up to hc profile mode
                    [2] = "HM",
                    [23] = "MM"
                }
                porfileNameToUse = addon.sv.config.autoSuggest[instanceType][difficultyByID[difficulty]])
                return
            end
            addon.GlobalFrames:ToggleSuggestionFrame(porfileNameToUse)
        end
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