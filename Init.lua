--############################################
-- Namespace
--############################################
local addonName, addon = ...

--##########################################################################################################################
--                                  Event handling
--##########################################################################################################################
function addon:eventHandling(event, arg1)
    if (event == "ADDON_LOADED") then
        if(arg1 ~= addonName) then
            return 
        end

        if(SwitchSwitchTalents == nil) then
            --Default talents table
            SwitchSwitchTalents = {};
        end
        --Unregister current event
        self:UnregisterEvent(event);
    elseif(event == "PLAYER_LOGIN") then

        --Load Commands
        addon.Commands:Init();

        --Unregister current event
        self:UnregisterEvent(event);
    end
end

-- Event handling frame
addon.event_frame = CreateFrame("Frame")
-- Set Scripts
addon.event_frame:SetScript("OnEvent", addon.eventHandling)
-- Register events
addon.event_frame:RegisterEvent("ADDON_LOADED")
addon.event_frame:RegisterEvent("PLAYER_LOGIN")