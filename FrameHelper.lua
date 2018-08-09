--############################################
-- Namespace
--############################################
local _, addon = ...

--Set up frame helper gobal tables
addon.FrameHelper = {}
local FrameHelper = addon.FrameHelper

--##########################################################################################################################
--                                  Frames Init
--##########################################################################################################################
--Creates the Frame inside the talent frame
function FrameHelper:CreateTalentFrameUI()
    --Create frame and hide it by default
    FrameHelper.UpperTalentsUI = CreateFrame("Frame", "SwitchSwitch_UpperTalentsUI", PlayerTalentFrameTalents)
    local UpperTalentsUI = FrameHelper.UpperTalentsUI
    UpperTalentsUI:SetPoint("TOPLEFT", PlayerTalentFrameTalents, "TOPLEFT", 60, 30)
    UpperTalentsUI:SetPoint("BOTTOMRIGHT", PlayerTalentFrameTalents, "TOPRIGHT", -110, 2)

    --Create the new and save buttons
    UpperTalentsUI.DeleteButton = FrameHelper:CreateButton("TOPRIGHT", UpperTalentsUI, UpperTalentsUI, "TOPRIGHT", addon.L["Delete"], 80, nil, -10, -2)
    UpperTalentsUI.DeleteButton:SetScript("OnClick", function()
        local dialog = StaticPopup_Show("SwitchSwitch_ConfirmDeleteprofile", addon.sv.Talents.SelectedTalentsProfile)
        if(dialog) then
            dialog.data = addon.sv.Talents.SelectedTalentsProfile
        end 
    end)
    UpperTalentsUI.NewButton = FrameHelper:CreateButton("TOPRIGHT", UpperTalentsUI.DeleteButton, UpperTalentsUI.DeleteButton, "TOPLEFT", addon.L["New"], 80, nil, -5, 0) 
    UpperTalentsUI.NewButton:SetScript("OnClick", function() StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp")end)
    --Create Talent string
    UpperTalentsUI.CurrentPorfie = UpperTalentsUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
    UpperTalentsUI.CurrentPorfie:SetText(addon.L["Talents"] .. ":")
    UpperTalentsUI.CurrentPorfie:SetPoint("LEFT")

    --Create Dropdown menu for talent groups
    UpperTalentsUI.DropDownTalents = CreateFrame("FRAME", "SwitchSwitch_UpperTalentsUI_Dropdown", UpperTalentsUI, "UIDropDownMenuTemplate")
    UpperTalentsUI.DropDownTalents:SetPoint("LEFT", UpperTalentsUI.CurrentPorfie, "RIGHT", 0, -3)
    UIDropDownMenu_SetWidth(UpperTalentsUI.DropDownTalents, 200)
    UIDropDownMenu_Initialize(UpperTalentsUI.DropDownTalents, FrameHelper.Initialize_Talents_List)
    UIDropDownMenu_SetSelectedID(UpperTalentsUI.DropDownTalents, 1, true)
    addon.sv.Talents.SelectedTalentsProfile = UIDropDownMenu_GetText(UpperTalentsUI.DropDownTalents)

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
        OnAccept = function(self)
            FrameHelper:OnAceptNewprofile(self)
        end,
        EditBoxOnTextChanged = function (self) 
            local data = self:GetParent().editBox:GetText()
            if(data ~= nil and data ~= '') then
                if(data:lower() == "custom") then
                    self:GetParent().button1:Disable()
                    return
                end
                self:GetParent().button1:Enable()
            else
                self:GetParent().button1:Disable()
            end
        end,
        OnShow = function(self)
            self.button1:Disable()
        end
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
        OnAccept = function(self, profileName)
            addon.sv.Talents.TalentsProfiles[profileName].talents = addon:GetCurrentTalents()
            addon:Print(addon.L["Profile %s overwritten!"]:format(profileName))
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
         OnAccept = function(self, data)
            FrameHelper:OnAcceptDeleteprofile(self, data)
         end,
    }
end

--Creates the Configuration frame UI
function FrameHelper:CreateConfigFrame()

end

--##########################################################################################################################
--                                  Frames Component handler
--##########################################################################################################################
function FrameHelper.Initialize_Talents_List(self, level, menuList)
    local menuList = {}
    --Get all profile names and create the list for the dropdown menu
    for TalentProfileName, data in pairs(addon.sv.Talents.TalentsProfiles) do
        table.insert(menuList, {
            text = TalentProfileName
        })
    end
    if(not level) then
        level = 1
    end
    --Create all buttons and attach the nececarry information
	for index = 1, #menuList do
        local info = menuList[index]
		if (info.text) then
            info.index = index
            info.arg1 = self
            info.func = FrameHelper.SetDropDownValue
			UIDropDownMenu_AddButton( info, level )
		end
	end
end

function FrameHelper.SetDropDownValue(self, arg1, arg2, checked)
    if (not checked) then
        --Temp profile to check in case we cannot change talents
        local tempOldSelected = addon.sv.Talents.SelectedTalentsProfile
		-- set selected value as selected
        UIDropDownMenu_SetSelectedValue(arg1, self.value)
        --Set the global value so we remember when we log back in
        addon.sv.Talents.SelectedTalentsProfile = self.value
        --Enable the delete button
        addon.FrameHelper.UpperTalentsUI.DeleteButton:Enable()
        --Try to change talents
        if(not addon:ActivateTalentPorfile(self.value)) then
            if(tempOldSelected == "") then
                tempOldSelected = "Custom"
                addon.FrameHelper.UpperTalentsUI.DeleteButton:Disable()
            end
            --Set to custom as we could not active the porfile
            UIDropDownMenu_SetSelectedValue(arg1, tempOldSelected)
            addon.sv.Talents.SelectedTalentsProfile = tempOldSelected
        end
    end
end

function FrameHelper:OnAceptNewprofile(frame)
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

    --profile name does not exist so create it
    addon.sv.Talents.TalentsProfiles[profileName] =
    {
        options = {},
        talents = addon:GetCurrentTalents()
    }
    addon.sv.Talents.SelectedTalentsProfile = profileName
    --Select the new porfile
    UIDropDownMenu_SetSelectedValue(FrameHelper.UpperTalentsUI.DropDownTalents, profileName)
    UIDropDownMenu_SetText(FrameHelper.UpperTalentsUI.DropDownTalents, profileName)
    --Let the user know that the profile has been created
    addon:Print(addon.L["Talent profile %s created!"]:format(profileName))
end

function FrameHelper:OnAcceptDeleteprofile(frame, profile)
    --Check if the porfile exists
    if(addon.sv.Talents.TalentsProfiles[profile] == nil or type(addon.sv.Talents.TalentsProfiles[profile]) ~= "table") then
        return
    end

    --Delete the porfile
    addon.sv.Talents.TalentsProfiles[profile] = nil

    --If it is the current selected porfile change the selected vlaue to custom
    if(profile == addon.sv.Talents.SelectedTalentsProfile) then
        UIDropDownMenu_SetSelectedValue(FrameHelper.UpperTalentsUI.DropDownTalents, "Custom")
        addon.sv.Talents.SelectedTalentsProfile = "Custom"
        addon.FrameHelper.UpperTalentsUI.DeleteButton:Disable()
    end
end

--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
function FrameHelper:CreateButton(point, parentFrame, relativeFrame, relativePoint, text, width, height, xOffSet, yOffSet, TextHeight)
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