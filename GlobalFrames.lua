--############################################
-- Namespace
--############################################
local _, addon = ...

--Set up frame helper gobal tables
addon.GlobalFrames = {}
local GlobalFrames = addon.GlobalFrames


--##########################################################################################################################
--                                  Frames Init
--##########################################################################################################################
function GlobalFrames:Init()
    --Secure Action button to use item
    GlobalFrames.UseTome = CreateFrame("Button", "SS_ButtonUseTomePopup", UIParent, "UIPanelButtonTemplate, SecureActionButtonTemplate")
    GlobalFrames.UseTome:SetAttribute("type", "item")
    GlobalFrames.UseTome:Hide()

    --Popup to notify the user if they want the addon to automaticly use a tome
    StaticPopupDialogs["SwitchSwitch_ConfirmTomeUsage"] =
    {
        text = addon.L["Do you want to use a tome to change talents?"],
        button1 = addon.L["Yes"],
        button2 = addon.L["No"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        exclusive = true,
        enterClicksFirstButton = true,
        OnShow = function(self) 
            --Wellll as there is no build-in way to have secure button as part of a static popuop we need to replace the buttons shig
            -- so we do
            self.insertedFrame:SetParent(self)
            self.insertedFrame:ClearAllPoints()
            self.insertedFrame:SetPoint(self.button1:GetPoint())
            self.insertedFrame:SetWidth(self.button1:GetWidth())
            self.insertedFrame:SetHeight(self.button1:GetHeight())
            self.insertedFrame:SetText(self.button1:GetText())
            self.insertedFrame:SetScript("PostClick", function() self.button1:Click() end)
            self.insertedFrame:Show()
            self.button1:Hide()
         end,
        OnAccept = function(self, data)
            --Execute it after a timer so that the the call is not executed when we still dont have the buff as it takes time to activate
            C_Timer.After(1, function() data.callback(addon:ActivateTalentProfile(data.name)) end)
            self.insertedFrame:Hide()
        end,
        OnCancel = function(self, data)
            --Make sure everything works fine and gets disabled properly
            data.callback(false)
            self.insertedFrame:Hide()
        end

        --
    }
end