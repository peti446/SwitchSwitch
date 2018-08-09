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
        ["debug"] = false
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
                addon.FrameHelper:CreateTalentFrameUI()
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

        --Unregister current event
        self:UnregisterEvent(event)
    elseif(event == "PLAYER_TALENT_UPDATE") then
        if(IsAddOnLoaded("Blizzard_TalentUI") and not addon.G.SwitchingTalents) then
            UIDropDownMenu_SetSelectedValue(addon.FrameHelper.UpperTalentsUI.DropDownTalents, "Custom")
            addon.sv.Talents.SelectedTalentsProfile = "Custom"
            addon.FrameHelper.UpperTalentsUI.DeleteButton:Disable()
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