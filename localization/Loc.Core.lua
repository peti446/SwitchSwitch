--############################################
-- Namespace
--############################################
local _, addon = ...

--Create the table for localizations
addon.L = {}

local function LocalizationNotFound(L, key)
    -- Print message to chat
    addon:Print("|cFFff0000(Localization Error) ->|r|cFFf4aa42Localization key:|cFF00FF00"..key.."|r does not exist|r");
    -- Return default key
    return key;
end
--Set meta table
setmetatable(addon.L, {__index=LocalizationNotFound})

-- Set default Localization (English)