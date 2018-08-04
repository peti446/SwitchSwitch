--############################################
-- Namespace
--############################################
local _, addon = ...

--Create the table for localizations
addon.L = {}

local function LocalizationNotFound(L, key)
    -- Return default key
    return key;
end
--Set meta table
setmetatable(addon.L, {__index=LocalizationNotFound})

-- Set default Localization (English)