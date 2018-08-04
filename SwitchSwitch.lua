--############################################
-- Namespace
--############################################
local _, addon = ...

--https://wow.gamepedia.com/Patch_5.0.4/API_changes

--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
-- Function to print a debug message
function addon:Debug(...)
    if(addon.DataToSave.options.debug) then
        addon:Print(string.join(" ", "|cFFFF0000(DEBUG)|r", tostringall(... or "nil")));
    end
end

-- Function to print a message to the chat.
function addon:Print(...)
    local msg = string.join(" ","|cFF029CFC[SwitchSwitch]|r", tostringall(... or "nil"));
    DEFAULT_CHAT_FRAME:AddMessage(msg);
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
            ChosenTalents[Tier]["id"] = talentID
            ChosenTalents[Tier]["tier"] = Tier
            ChosenTalents[Tier]["column"] = Column
        end
    end
    return ChosenTalents;
end