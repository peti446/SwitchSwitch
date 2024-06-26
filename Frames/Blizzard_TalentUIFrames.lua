-- TODO: Rename or Update!
--local SwitchSwitch, L, AceGUI, LibDBIcon =unpack(select(2, ...))
--local parent
--local dropDown
--local saveButton
--
--local function OnDropDownSelectionChanged(self, _, profile)
--    if(profile == nil or SwitchSwitch.CurrentActiveTalentsConfigID == profile) then
--        return
--    end
--
--    local talentsAlreadyChanged = SwitchSwitch:ActivateTalentProfile(profile)
--    if(not talentsAlreadyChanged) then
--        SwitchSwitch:RefreshTalentUI()
--    end
--end
--
--local function OnSaveClicked()
--    local dialog = StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp")
--    if(dialog) then
--        dialog.data = {
--            ["class"] = SwitchSwitch:GetPlayerClass(),
--            ["spec"] = SwitchSwitch:GetCurrentSpec()
--        }
--    end
--end
--
--function SwitchSwitch:EmbedUIIntoTalentFrame()
--    parent = AceGUI:Create("SimpleGroup")
--    parent:SetLayout("Table")
--    parent:SetUserData("table", {
--          columns = {0, 0},
--          space = 2,
--          align = "LEFT"
--    })
--    parent.frame:SetParent(ClassTalentFrame)
--    parent:ClearAllPoints()
--    parent:SetPoint("TOPLEFT", ClassTalentFrame.TopTileStreaks, "TOPLEFT", 115, 0)
--    parent:SetPoint("BOTTOMRIGHT", ClassTalentFrame.TopTileStreaks, "BOTTOMRIGHT", -145, 5)
--    parent.frame:Show()
--    dropDown = AceGUI:Create("Dropdown")
--    dropDown:SetLabel(L["Profiles"] .. ":")
--    dropDown.dropdown:SetPoint("TOPLEFT",dropDown.frame,"TOPLEFT", -15,-6)
--    dropDown.label:ClearAllPoints()
--    dropDown.label:SetPoint("RIGHT", dropDown.frame, "LEFT", -5, 0)
--    dropDown.label:SetFontObject("GameFontNormalLeft")
--    dropDown:SetCallback("OnValueChanged", OnDropDownSelectionChanged)
--    parent:AddChild(dropDown)
--
--
--    saveButton = AceGUI:Create("Button")
--    saveButton:SetText(L["New Profile"])
--    saveButton:SetWidth(120)
--    saveButton:SetCallback("OnClick", OnSaveClicked)
--    parent:AddChild(saveButton)
--    self:DebugPrint("Talent Frame has been shown embedded frame")
--    self:HookScript(ClassTalentFrame, "OnHide", "BlizzardTalentUIHidden")
--    SwitchSwitch:RefreshTalentUI()
--end
--
--function SwitchSwitch:BlizzardTalentUIHidden()
--    self:DebugPrint("Talent Frame has been hidding releasing the embeded frame")
--    parent:Release()
--    parent = nil
--    dropDown = nil
--    saveButton = nil
--    self:Unhook(ClassTalentFrame, "OnHide")
--end
--
--function SwitchSwitch:RefreshTalentUI()
--    if(dropDown == nil) then return end
--
--    local talentsProfiles = self:GetAllCurrentSpecProfiles()
--    local dropDownData = {}
--    for name, data in pairs(talentsProfiles) do
--        dropDownData[name] = name
--    end
--    dropDown:SetList(dropDownData)
--
--    if(self.CurrentActiveTalentsConfigID ~= self.CustomProfileName and self:DoesProfileExits(self.CurrentActiveTalentsConfigID)) then
--        dropDown:SetValue(self.CurrentActiveTalentsConfigID)
--        saveButton.frame:Hide()
--    else
--        dropDown:SetValue()
--        dropDown:SetText(self.CustomProfileName)
--        saveButton.frame:Show()
--    end
--end