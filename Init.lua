--############################################
-- Namespace
--############################################
local _, addon = ...

--##########################################################################################################################
--                                  Event handling
--##########################################################################################################################
function addon:eventHandling(event, arg1)
    if (event == "ADDON_LOADED") then

    elseif(event == "PLAYER_LOGIN") then

        --Load Commands
        addon.Commands:Init();
    end
end

-- Event handling frame
addon.event_frame = CreateFrame("Frame")
-- Set Scripts
addon.main_frame:SetScript("OnEvent", addon.eventHandling)
-- Register events
addon.main_frame:RegisterEvent("ADDON_LOADED")
addon.main_frame:RegisterEvent("PLAYER_LOGIN")