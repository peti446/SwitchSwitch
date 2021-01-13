local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

StaticPopupDialogs["SwitchSwitch_ConfirmTomeUsage"] =
{
    text = L["Do you want to use a tome to change talents?"],
    button1 = L["Yes"],
    button2 = L["No"],
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    exclusive = true,
    enterClicksFirstButton = true,
    OnShow = function(self, data) 
        --Wellll as there is no build-in way to have secure button as part of a static popuop we need to replace the buttons shig
        -- so we do
        if(self.sbutton == nil) then
            self.sbutton = CreateFrame("Button", "SS_ButtonUseTomePopup", self, "UIPanelButtonTemplate, SecureActionButtonTemplate");
            self.sbutton:SetAttribute("type", "item");
            self.sbutton:SetAttribute("item", data)
            self.sbutton:SetParent(self)
            self.sbutton:ClearAllPoints()
            self.sbutton:SetPoint(self.button1:GetPoint())
            self.sbutton:SetWidth(self.button1:GetWidth())
            self.sbutton:SetHeight(self.button1:GetHeight())
            self.sbutton:SetText(self.button1:GetText())
            self.sbutton:SetScript("PostClick", function() self.button1:Click() end)
        end
        self.sbutton:Show()
        self.button1:Hide()
        end,
        OnAccept = function(self, data, data2)
        --Execute it after a timer so that the the call is not executed when we still dont have the buff as it takes time to activate
        SwitchSwitch:DebugPrint("Changing talents after 1 seconds to " .. data2)
        C_Timer.After(1, function() SwitchSwitch:ActivateTalentProfile(data2) end)
        self.sbutton:Hide()
    end,
}