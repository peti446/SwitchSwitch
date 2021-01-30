local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local savePVPCheckbox

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
        --Execute it after a timer so that the the call is not executed when we still don't have the buff as it takes time to activate
        SwitchSwitch:DebugPrint("Changing talents after 1 seconds to " .. data2)
        C_Timer.After(1, function() SwitchSwitch:ActivateTalentProfile(data2) end)
        self.sbutton:Hide()
    end,
}

StaticPopupDialogs["SwitchSwitch_ConfirmDeleteprofile"] =
{
    text = L["You want to delete the profile '%s'?"],
    button1 = L["Delete"],
    button2 = L["Cancel"],
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    exclusive = true,
    enterClicksFirstButton = true,
    showAlert = true,
    OnAccept = function(self, profile)
        if(not SwitchSwitch:DoesProfileExits(profile)) then
            return
        end
        --Delete the Profile
        if(SwitchSwitch:DeleteProfileData(profile)) then
            if(self.OnDeleted ~= nil) then
                self.OnDeleted(profile)
            end
        end
    end,
}

StaticPopupDialogs["SwitchSwitch_NewTalentProfilePopUp"] =
{
    text = L["Create/Overwrite a profile"],
    button1 = L["Save"],
    button2 = L["Cancel"],
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    hasEditBox = true,
    exclusive = true,
    enterClicksFirstButton = true,
    autoCompleteSource = SwitchSwitch.GetAutoCompleatProfiles,
    autoCompleteArgs = {},
    OnShow = function(self) 
        --Add the check box to ignore pvp talent
        if(savePVPCheckbox == nil) then
            savePVPCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
            savePVPCheckbox.text:SetText(L["Save PVP Talents"])
            savePVPCheckbox.text:SetFontObject("GameFontWhite")
            --savePVPCheckbox.text:SetWidth(200)
            savePVPCheckbox.text:SetJustifyH("LEFT")
            SwitchSwitch:DebugPrint("Create Checkbuton for saving pvp talents")
        end
        self.insertedFrame = savePVPCheckbox
        self.insertedFrame:SetChecked(false)
        self.insertedFrame:SetParent(self)
        self.editBox:ClearAllPoints()
        self.editBox:SetPoint("TOP", self.text, "BOTTOM", 0, -5);
        self.insertedFrame:ClearAllPoints()
        self.insertedFrame:SetPoint("TOP", self.editBox, "BOTTOM", -self.insertedFrame.text:GetWidth()*0.5, -5)
        self.insertedFrame:Show()
        end,
    OnAccept = function(self, data)
        if(data == nil) then
            SwitchSwitch:DebugPrint("New talent propuo passed with no data.. using default")
            data = {}
        end
        local profileName = self.editBox:GetText()
        local savePVPTalents = self.insertedFrame:GetChecked();
        --Check if the profile exits if so, change the text
        if(SwitchSwitch:DoesProfileExits(profileName, data.class, data.spec)) then
            SwitchSwitch:DebugPrint("Profile exits, asking confirmation to overwrite")
            self.button1:Disable()
            local dialog = StaticPopup_Show("SwitchSwitch_ConfirmTalemtsSavePopUp", profileName)
            if(dialog) then
                dialog.data = {
                    ["profile"] = profileName,
                    ["savePVP"] = savePVPTalents,
                    ["class"] = data.class,
                    ["spec"] = data.spec,
                }
            end
            return
        end
    
        SwitchSwitch:DebugPrint("Create profile")
        --If talent spec table does not exist create one
        SwitchSwitch:SetProfileData(profileName, SwitchSwitch:GetCurrentTalents(savePVPTalents), data.class, data.spec)
        SwitchSwitch:PLAYER_TALENT_UPDATE(true)
    
        --Let the user know that the profile has been created
        SwitchSwitch:Print(L["Talent profile %s created!"]:format(profileName))
    end,
    EditBoxOnTextChanged = function (self) 
        local data = self:GetParent().editBox:GetText()
        local label = self:GetParent().text
        local button =  self:GetParent().button1
        label:SetText(L["Create/Overwrite a profile"])
        button:Enable()
        --Check if text is not nill or not empty
        if(data ~= nil and data ~= '') then
            if(data:lower() == SwitchSwitch.defaultProfileName:lower()) then
                --Text is "custom" so disable the Create button and give a warning
                label:SetText(label:GetText() .. "\n\n|cFFFF0000" .. L["'Custom' cannot be used as name!"])
                button:Disable()
            elseif(data:len() > 40) then
                --Text is too long, disable create button and give a warning
                label:SetText(label:GetText() .. "\n\n|cFFFF0000" .. L["Name too long!"])
                button:Disable()
            end
        else
            --Empty so disable Create button
            button:Disable()
        end
        --Rezise the frame
        StaticPopup_Resize(self:GetParent(), self:GetParent().which)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide();
    end,
}

StaticPopupDialogs["SwitchSwitch_ConfirmTalemtsSavePopUp"] =
{
    text = L["Saving will override '%s' configuration"],
    button1 = L["Save"],
    button2 = L["Cancel"],
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    exclusive = true,
    enterClicksFirstButton = true,
    showAlert = true,
    OnAccept = function(self, data)
        SwitchSwitch:SetProfileData(data.profile, nil, data.class, data.spec)
        SwitchSwitch:DebugPrint("Create profile")
        --If talent spec table does not exist create one
        SwitchSwitch:SetProfileData(data.profile, SwitchSwitch:GetCurrentTalents(savePVPTalents), data.class, data.spec)
        SwitchSwitch:PLAYER_TALENT_UPDATE(true)
    end,
    OnCancel = function(self, data)
        local dialog = StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp")
        if(dialog) then
            dialog.editBox:SetText(data.profile)
            savePVPCheckbox:SetChecked(data.savePVP)
            dialog.data = {
                ["class"] = data.class,
                ["spec"] = data.spec
            }
        end
    end
}


function SwitchSwitch.GetSuggestedProfileNames(currentString)
    local returnNames = {};
    for name, _ in pairs(SwitchSwitch:GetProfilesTable()) do
        if(name:find(currentString) ~= nil) then
            table.insert(returnNames, {
                ["name"] = name,
                ["priority"] = LE_AUTOCOMPLETE_PRIORITY_OTHER
            })
        end
    end
    return returnNames;
end