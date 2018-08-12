--############################################
-- Namespace
--############################################
local _, addon = ...

--Set up frame helper gobal tables
addon.TalentUIFrame = {}
local TalentUIFrame = addon.TalentUIFrame

--##########################################################################################################################
--                                  Init
--##########################################################################################################################
--Creates the Frame inside the talent frame
function TalentUIFrame:CreateTalentFrameUI()
    --Create frame and hide it by default
    TalentUIFrame.UpperTalentsUI = CreateFrame("Frame", "SwitchSwitch_UpperTalentsUI", PlayerTalentFrameTalents)
    local UpperTalentsUI = TalentUIFrame.UpperTalentsUI
    UpperTalentsUI:SetPoint("TOPLEFT", PlayerTalentFrameTalents, "TOPLEFT", 60, 30)
    UpperTalentsUI:SetPoint("BOTTOMRIGHT", PlayerTalentFrameTalents, "TOPRIGHT", -110, 2)

    --Set variable for update
    UpperTalentsUI.LastPorfileUpdateName = ""

    --Set scripts for the fram
    UpperTalentsUI:SetScript("OnUpdate", TalentUIFrame.UpdateUpperFrame)

    --Create the new and save buttons
    UpperTalentsUI.DeleteButton = TalentUIFrame:CreateButton("TOPRIGHT", UpperTalentsUI, UpperTalentsUI, "TOPRIGHT", addon.L["Delete"], 80, nil, -10, -2)
    UpperTalentsUI.DeleteButton:SetScript("OnClick", function()
        local dialog = StaticPopup_Show("SwitchSwitch_ConfirmDeleteprofile", addon.sv.Talents.SelectedTalentsProfile)
        if(dialog) then
            dialog.data = addon.sv.Talents.SelectedTalentsProfile
        end 
    end)
    UpperTalentsUI.NewButton = TalentUIFrame:CreateButton("TOPRIGHT", UpperTalentsUI.DeleteButton, UpperTalentsUI.DeleteButton, "TOPLEFT", addon.L["New"], 80, nil, -5, 0) 
    UpperTalentsUI.NewButton:SetScript("OnClick", function() StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp")end)
    --Create Talent string
    UpperTalentsUI.CurrentPorfie = UpperTalentsUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
    UpperTalentsUI.CurrentPorfie:SetText(addon.L["Talents"] .. ":")
    UpperTalentsUI.CurrentPorfie:SetPoint("LEFT")

    --Create Dropdown menu for talent groups
    UpperTalentsUI.DropDownTalents = CreateFrame("FRAME", "SwitchSwitch_UpperTalentsUI_Dropdown", UpperTalentsUI, "UIDropDownMenuTemplate")
    UpperTalentsUI.DropDownTalents:SetPoint("LEFT", UpperTalentsUI.CurrentPorfie, "RIGHT", 0, -3)
    --Setup the UIDropDownMenu and set the SelectedProgile vatiable
    UIDropDownMenu_SetWidth(UpperTalentsUI.DropDownTalents, 200)
    UIDropDownMenu_Initialize(UpperTalentsUI.DropDownTalents, TalentUIFrame.Initialize_Talents_List)

    --Create new Static popup dialog
    StaticPopupDialogs["SwitchSwitch_NewTalentProfilePopUp"] =
    {
        text = addon.L["Create/Ovewrite a profile"],
        button1 = addon.L["Save"],
        button2 = addon.L["Cancel"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        exclusive = true,
        enterClicksFirstButton = true,
        OnAccept = function(self)
            TalentUIFrame:OnAceptNewprofile(self)
        end,
        EditBoxOnTextChanged = function (self) 
            TalentUIFrame:NewProfileOnTextChange(self)
        end,
        OnShow = function(self)
            self.button1:Disable()
        end,
    }
    --Create the confirim save popup
    StaticPopupDialogs["SwitchSwitch_ConfirmTalemtsSavePopUp"] =
    {
        text = addon.L["Saving will override '%s' configuration"],
        button1 = addon.L["Save"],
        button2 = addon.L["Cancel"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        exclusive = true,
        enterClicksFirstButton = true,
        showAlert = true,
        OnAccept = function(self, profileName)
            TalentUIFrame:OnAcceptOverwrrite(self, profileName)
        end,
        OnCancel = function(self, profileName)
            local dialog = StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp")
            if(dialog) then
                dialog.editBox:SetText(profileName)
            end
        end
    }

     --Create the confirim save popup
    StaticPopupDialogs["SwitchSwitch_ConfirmDeleteprofile"] =
    {
         text = addon.L["You want to delete the profile '%s'?"],
         button1 = addon.L["Delete"],
         button2 = addon.L["Cancel"],
         timeout = 0,
         whileDead = true,
         hideOnEscape = true,
         preferredIndex = 3,
         exclusive = true,
         enterClicksFirstButton = true,
         showAlert = true,
         OnAccept = function(self, data)
            TalentUIFrame:OnAcceptDeleteprofile(self, data)
         end,
    }
end

--##########################################################################################################################
--                                  Frames Component handler
--##########################################################################################################################
function TalentUIFrame.Initialize_Talents_List(self, level, menuList)
    local menuList = {}
    --Get all profile names and create the list for the dropdown menu
    if(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] ~= nil) then
        for TalentProfileName, data in pairs(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) do
            table.insert(menuList, {
                text = TalentProfileName
            })
        end
    end

    --Make sure level is always set
    if(not level) then
        level = 1
    end

    --Create all buttons and attach the nececarry information
	for index = 1, #menuList do
        local info = menuList[index]
		if (info.text) then
            info.index = index
            info.arg1 = self
            info.func = TalentUIFrame.SetDropDownValue
			UIDropDownMenu_AddButton( info, level )
		end
	end
end

function TalentUIFrame.SetDropDownValue(self, arg1, arg2, checked)
    if (not checked) then
        --Change Talents!
        addon:ActivateTalentProfile(self.value)
    end
end

function TalentUIFrame:NewProfileOnTextChange(frame) 
    local data = frame:GetParent().editBox:GetText()
    if(data ~= nil and data ~= '') then
        if(data:lower() == addon.CustomProfileName:lower()) then
            frame:GetParent().text:SetText(addon.L["Create/Ovewrite a profile"] .. "\n\n|cFFFF0000" .. addon.L["'Custom' cannot be used as name!"])
            frame:GetParent().button1:Disable()
        elseif(data:len() > 20) then
            frame:GetParent().text:SetText(addon.L["Create/Ovewrite a profile"] .. "\n\n|cFFFF0000" .. addon.L["Name too long!"])
            frame:GetParent().button1:Disable()
        else
            frame:GetParent().button1:Enable()
            frame:GetParent().text:SetText(addon.L["Create/Ovewrite a profile"])
        end
    else
        frame:GetParent().button1:Disable()
        frame:GetParent().text:SetText(addon.L["Create/Ovewrite a profile"])
    end
    StaticPopup_Resize(frame:GetParent(), frame:GetParent().which)
end

function TalentUIFrame:OnAceptNewprofile(frame)
    local profileName = frame.editBox:GetText()
    --Check if the profile exits if so, change the text
    if(addon:DoesTalentProfileExist(profileName)) then
        frame.button1:Disable()
        local dialog = StaticPopup_Show("SwitchSwitch_ConfirmTalemtsSavePopUp", profileName)
        if(dialog) then
            dialog.data = profileName
        end
        return
    end

    --If talent spec table does not exist create one
    if(not addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))]) then
        addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] = {}
    end

    --profile name does not exist so create it
    addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileName] = addon:GetCurrentTalents()
    addon.sv.Talents.SelectedTalentsProfile = profileName

    --Let the user know that the profile has been created
    addon:Print(addon.L["Talent profile %s created!"]:format(profileName))
end

function TalentUIFrame:OnAcceptDeleteprofile(frame, profile)
    --Check if the Profile exists
    if(not addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] or not addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profile] or type(addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profile]) ~= "table") then
        return
    end

    --Delete the Profile
    addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profile] = nil
    addon.sv.Talents.SelectedTalentsProfile = addon.CustomProfileName
end

function TalentUIFrame:OnAcceptOverwrrite(frame, profile)
    addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profile] = addon:GetCurrentTalents()
    addon.sv.Talents.SelectedTalentsProfile = profile
    addon:Print(addon.L["Profile '%s' overwritten!"]:format(profile))
end

function TalentUIFrame.UpdateUpperFrame(self, elapsed)
    --Just to make sure we dont update all every frame, as 90% of the time it will not change
    if(self.LastPorfileUpdateName ~= addon.sv.Talents.SelectedTalentsProfile) then
        self.LastPorfileUpdateName = addon.sv.Talents.SelectedTalentsProfile
        UIDropDownMenu_SetSelectedValue(self.DropDownTalents, addon.sv.Talents.SelectedTalentsProfile)

        if(addon.sv.Talents.SelectedTalentsProfile == addon.CustomProfileName) then
            self.DeleteButton:Disable()
        else
            self.DeleteButton:Enable()
        end
    end
end

--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
function TalentUIFrame:CreateButton(point, parentFrame, relativeFrame, relativePoint, text, width, height, xOffSet, yOffSet, TextHeight)
    --Set defalt values in case not specified
    width = width or 100
    height = height or 20
    xOffSet = xOffSet or 0
    yOffSet = yOffSet or 0
    TextHeight = TextHeight or ""
    text = text or "Not specified"
    --Create the button and set their value
    local button = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
    button:SetPoint(point, relativeFrame, relativePoint, xOffSet, yOffSet)
    button:SetSize(width,height)
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal"..TextHeight)
    button:SetHighlightFontObject("GameFontHighlight"..TextHeight)
    --Return the button
    return button
end