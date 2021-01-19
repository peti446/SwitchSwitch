--############################################
-- Namespace
--############################################
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

--Set up frame helper gobal tables
SwitchSwitch.TalentUIFrame = {}
local TalentUIFrame = SwitchSwitch.TalentUIFrame

--##########################################################################################################################
--                                  Init
--##########################################################################################################################
--Creates the edit frame
function TalentUIFrame:CreateEditUI()
    SwitchSwitch.TalentUIFrame.ProfileEditorFrame = CreateFrame("Frame", "SwitchSwitch_TalentFrameEditor", PlayerTalentFrame, "UIPanelDialogTemplate")
    local editorFrame =  SwitchSwitch.TalentUIFrame.ProfileEditorFrame
    
    --Editor frame config
    editorFrame:SetWidth(250)
    editorFrame:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT")
    editorFrame:SetPoint("BOTTOMLEFT", PlayerTalentFrame, "BOTTOMRIGHT")
    editorFrame.Title:SetText(L["Talent Profile Editor"])
    editorFrame:HookScript("OnHide", function(self) 
        --Save all the data modified
        SwitchSwitch:DebugPrint("Closed editor, saving data...")
        if(not self.GearSet:GetChecked() and SwitchSwitch:DoesProfileExits(self.CurrentProfileEditing)) then
            local tbl = SwitchSwitch:GetProfileData(self.CurrentProfileEditing) 
            tbl.gearSet = nil
            SwitchSwitch:SetProfileData(self.CurrentProfileEditing, tbl)
        end
    end)
    editorFrame:Hide()
    editorFrame:HookScript("OnShow", function(self) 
        --Update the data
        SwitchSwitch:DebugPrint("Updating Edit frame data...")
        self.InsideTitle:SetText(string.format(L["Editing '%s'"], self.CurrentProfileEditing or "ERROR"))
        local tbl = SwitchSwitch:GetProfileData(self.CurrentProfileEditing)
        if(SwitchSwitch:DoesProfileExits(self.CurrentProfileEditing) and tbl.gearSet ~= nil) then
            self.GearSet:SetChecked(true)
            self.GearSet.SelectionFrame:Show()
            UIDropDownMenu_SetSelectedValue(self.GearSet.SelectionFrame.DropDown, tbl.gearSet)
            local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(tbl.gearSet)
            UIDropDownMenu_SetText(self.GearSet.SelectionFrame.DropDown, name)
        else 
            self.GearSet:SetChecked(false)
            self.GearSet.SelectionFrame:Hide()
            UIDropDownMenu_SetSelectedValue(self.GearSet.SelectionFrame.DropDown, "")
            UIDropDownMenu_SetText(self.GearSet.SelectionFrame.DropDown, "None")
        end
    end)

    --Title
    editorFrame.InsideTitle = editorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLargeLeft")
    editorFrame.InsideTitle:SetPoint("TOPLEFT", editorFrame, "TOPLEFT", 35, -35)

    --Selection of gear set
    editorFrame.GearSet = CreateFrame("CheckButton", nil, editorFrame, "UICheckButtonTemplate")
    editorFrame.GearSet:SetPoint("TOPLEFT", editorFrame.InsideTitle, "BOTTOMLEFT", -20, -10)
    editorFrame.GearSet.text:SetText(L["Auto equip gear set with this talent profile?"])
    editorFrame.GearSet.text:SetFontObject("GameFontWhite")
    editorFrame.GearSet.text:SetWidth(190)
    editorFrame.GearSet:SetScript("OnClick", function(self)
        if(self:GetChecked()) then
           self.SelectionFrame:Show()
        else
            self.SelectionFrame:Hide()
        end
        end)

    --Frame for the gear selection
    editorFrame.GearSet.SelectionFrame = CreateFrame("Frame", nil, editorFrame.GearSet)
    editorFrame.GearSet.SelectionFrame:SetPoint("TOPLEFT", editorFrame.GearSet, "BOTTOMLEFT", 5, -5)
    editorFrame.GearSet.SelectionFrame:SetPoint("TOPRIGHT", editorFrame.GearSet, "BOTTOMRIGHT", 0, 0)
    editorFrame.GearSet.SelectionFrame:SetPoint("BOTTOMRIGHT", editorFrame.GearSet, "BOTTOMRIGHT", 0, -25)
    if(not editorFrame.GearSet:GetChecked()) then
        editorFrame.GearSet.SelectionFrame:Hide()
    end

    --Text information
    editorFrame.GearSet.SelectionFrame.Text = editorFrame.GearSet.SelectionFrame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    editorFrame.GearSet.SelectionFrame.Text:SetText(L["Gear set to auto-equip:"])
    editorFrame.GearSet.SelectionFrame.Text:SetPoint("TOPLEFT", editorFrame.GearSet.SelectionFrame, "TOPLEFT")
    editorFrame.GearSet.SelectionFrame.Text:SetWidth(210)
    editorFrame.GearSet.SelectionFrame.Text:SetJustifyH("LEFT")

    --DropDown
    editorFrame.GearSet.SelectionFrame.DropDown = CreateFrame("FRAME", nil, editorFrame.GearSet.SelectionFrame, "UIDropDownMenuTemplate")
    editorFrame.GearSet.SelectionFrame.DropDown:SetPoint("TOPLEFT", editorFrame.GearSet.SelectionFrame.Text, "BOTTOMLEFT", -15, -5)
    editorFrame.GearSet.SelectionFrame.DropDown.funcName = "equipedGear"
    UIDropDownMenu_SetWidth(editorFrame.GearSet.SelectionFrame.DropDown, 190)
    UIDropDownMenu_Initialize(editorFrame.GearSet.SelectionFrame.DropDown, function(self)
        local info = UIDropDownMenu_CreateInfo()
        info.text = "None"
        info.value = ""
        info.index = 1
        info.arg1 = self
        info.func = TalentUIFrame.SetSelectedValueForDropDowns
        info.justifyH = "LEFT"
        UIDropDownMenu_AddButton(info, 1)

        for i, setID in ipairs(C_EquipmentSet.GetEquipmentSetIDs()) do
            local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(setID)
            info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.value = setID
            info.index = i +1
            info.arg1 = self
            info.func = TalentUIFrame.SetSelectedValueForDropDowns
            info.justifyH = "LEFT"
            UIDropDownMenu_AddButton(info,1)
        end
    end)
    UIDropDownMenu_SetSelectedValue( editorFrame.GearSet.SelectionFrame.DropDown, "")

    --Delete button
    editorFrame.DeleteButton = TalentUIFrame:CreateButton("BOTTOMLEFT", editorFrame, editorFrame, "BOTTOMLEFT", L["Delete"], 160, 25, 45, 20)
    editorFrame.DeleteButton:SetScript("OnClick", function()
        local dialog = StaticPopup_Show("SwitchSwitch_ConfirmDeleteprofile", SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing)
        if(dialog) then
            dialog.data = SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing
        end 
    end)

    --Rename button
    editorFrame.Rename = TalentUIFrame:CreateButton("BOTTOMLEFT", editorFrame, editorFrame, "BOTTOMLEFT", L["Rename"], 160, 25, 45, 45)
    editorFrame.Rename:SetScript("OnClick", function()
        local dialog = StaticPopup_Show("SwitchSwitch_RenameProfile", SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing)
        if(dialog) then
            dialog.data = SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing
        end 
    end)


    --Popup generation
    StaticPopupDialogs["SwitchSwitch_RenameProfile"] =
    {
        text = L["Rename profile"],
        button1 = L["Ok"],
        button2 = L["Cancel"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        exclusive = true,
        enterClicksFirstButton = true,
        OnAccept = function(self)
            TalentUIFrame:OnRenameAccepted(self)
        end,
        EditBoxOnTextChanged = function (self) 
            TalentUIFrame:OnRenameTextChanged(self)
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide();
        end,
    }
end 

function TalentUIFrame.SetSelectedValueForDropDowns(self, arg1, arg2, checked)
    if(not checked) then
        UIDropDownMenu_SetSelectedValue(arg1, self.value)
        if(arg1.funcName == "equipedGear") then
            local tbl = SwitchSwitch:GetProfileData(SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing)
            tbl["gearSet"] = self.value
            if (self.value == "") then
                tbl["gearSet"] = nil
            end
            SwitchSwitch:SetProfileData(SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing, tbl)
        end
    end
end

--##########################################################################################################################
--                                  Edit Frame Component handler
--##########################################################################################################################
function TalentUIFrame:OnRenameTextChanged(frame)
    local data = frame:GetParent().editBox:GetText()

    --Check if text is not nill or not empty
    if(data ~= nil and data ~= '') then

        if(data:lower() == SwitchSwitch.CustomProfileName:lower()) then
            --Text is "custom" so disable the Create button and give a warning
            frame:GetParent().text:SetText(L["Rename profile"] .. "\n\n|cFFFF0000" .. L["'Custom' cannot be used as name!"])
            frame:GetParent().button1:Disable()
        elseif(data:len() > 20) then
            --Text is too long, disable create button and give a warning
            frame:GetParent().text:SetText(L["Rename profile"].. "\n\n|cFFFF0000" .. L["Name too long!"])
            frame:GetParent().button1:Disable()
        elseif(SwitchSwitch:DoesProfileExits(data)) then
            --Text is fine so enable everything
            frame:GetParent().button1:Enable()
            frame:GetParent().text:SetText(L["Rename profile"] .. "\n\n|cFFFF0000" .. L["Name already taken!"])
        else
            --Text is fine so enable everything
            frame:GetParent().button1:Enable()
            frame:GetParent().text:SetText(L["Rename profile"])
        end
    else
        --Empty so disable Create button
        frame:GetParent().button1:Disable()
        frame:GetParent().text:SetText(L["Rename profile"])
    end

    --Rezise the frame
    StaticPopup_Resize(frame:GetParent(), frame:GetParent().which)
end

function TalentUIFrame:OnRenameAccepted(frame)
    local newName = frame.editBox:GetText()
    SwitchSwitch:SetProfileData(newName, SwitchSwitch:GetProfileData(SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing))
    SwitchSwitch:DeleteProfileData(SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing)
    SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing = newName
    SwitchSwitch.TalentUIFrame.ProfileEditorFrame:Hide();
    SwitchSwitch.TalentUIFrame.ProfileEditorFrame:Show();
    SwitchSwitch:Print(L["Profile renamed correctly!"]);
end

--Creates the Frame inside the talent frame
function TalentUIFrame:CreateTalentFrameUI()
    self.CreateEditUI();
    --Create frame and hide it by default
    TalentUIFrame.UpperTalentsUI = CreateFrame("Frame", "SwitchSwitch_UpperTalentsUI", PlayerTalentFrameTalents)
    local UpperTalentsUI = TalentUIFrame.UpperTalentsUI
    UpperTalentsUI:SetPoint("TOPLEFT", PlayerTalentFrameTalents, "TOPLEFT", 60, 30)
    UpperTalentsUI:SetPoint("BOTTOMRIGHT", PlayerTalentFrameTalents, "TOPRIGHT", -110, 2)

    --Set variable for update
    UpperTalentsUI.LastProfileUpdateName = "Custom"

    --Set scripts for the fram
    UpperTalentsUI:SetScript("OnUpdate", TalentUIFrame.UpdateUpperFrame)

    --Create the edit button
    UpperTalentsUI.EditButton = TalentUIFrame:CreateButton("TOPRIGHT", UpperTalentsUI, UpperTalentsUI, "TOPRIGHT", L["Edit"], 80, nil, -10, -2, "SS_EditButton_TF") 
    UpperTalentsUI.EditButton:SetScript("OnClick", function()
        ToggleDropDownMenu(1, nil, TalentUIFrame.UpperTalentsUI.EditButtonContext)
    end)
    

    --New botton
    UpperTalentsUI.NewButton = TalentUIFrame:CreateButton("TOPRIGHT", UpperTalentsUI, UpperTalentsUI, "TOPRIGHT", L["Save"], 80, nil, -95, -2) 
    UpperTalentsUI.NewButton:SetScript("OnClick", function() StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp" , nil, nil, nil, SwitchSwitch.GlobalFrames.SavePVPTalents)end)

    --Edit context menu
    UpperTalentsUI.EditButtonContext = CreateFrame("FRAME", nil, UpperTalentsUI.EditButton, "UIDropDownMenuTemplate")
    UpperTalentsUI.EditButtonContext:SetPoint("TOPLEFT", UpperTalentsUI.EditButton, "BOTTOMLEFT")
    UpperTalentsUI.EditButtonContext.funcName = "editProfileSelection"
    UIDropDownMenu_Initialize(UpperTalentsUI.EditButtonContext, function(self, level)
        local i = 2
        for pname, info in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = pname
            info.index = i
            if(SwitchSwitch.dbpc.char.SelectedTalentsProfile == pname:lower()) then
                info.index = 1
            else
                i = i + 1
            end
            info.func = function(self) 
                SwitchSwitch.TalentUIFrame.ProfileEditorFrame.CurrentProfileEditing = self.value
                SwitchSwitch.TalentUIFrame.ProfileEditorFrame:Hide()
                SwitchSwitch.TalentUIFrame.ProfileEditorFrame:Show()
            end
            UIDropDownMenu_AddButton(info,1)
        end
    end, "MENU")
    
    --Create Talent string
    UpperTalentsUI.CurrentProfie = UpperTalentsUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
    UpperTalentsUI.CurrentProfie:SetText(L["Talents"] .. ":")
    UpperTalentsUI.CurrentProfie:SetPoint("LEFT")

    --Create Dropdown menu for talent groups
    UpperTalentsUI.DropDownTalents = CreateFrame("FRAME", "SwitchSwitch_UpperTalentsUI_Dropdown", UpperTalentsUI, "UIDropDownMenuTemplate")
    UpperTalentsUI.DropDownTalents:SetPoint("LEFT", UpperTalentsUI.CurrentProfie, "RIGHT", 0, -3)
    --Setup the UIDropDownMenu and set the SelectedProgile vatiable
    UIDropDownMenu_SetWidth(UpperTalentsUI.DropDownTalents, 200)
    UIDropDownMenu_Initialize(UpperTalentsUI.DropDownTalents, TalentUIFrame.Initialize_Talents_List)

    --Create new Static popup dialog
    
end

--##########################################################################################################################
--                                  Frames Component handler
--##########################################################################################################################
function TalentUIFrame.Initialize_Talents_List(self, level, menuLists)
    local menuList = {}
    --Get all profile names and create the list for the dropdown menu
    if(SwitchSwitch:GetCurrentSpecProfilesTable()) then
        for TalentProfileName, data in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
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
    UIDropDownMenu_Refresh(self)
end

function TalentUIFrame.SetDropDownValue(self, arg1, arg2, checked)
    if (not checked) then
        --Change Talents!
        SwitchSwitch:ActivateTalentProfile(self.value)
    end
end


function TalentUIFrame:OnAcceptDeleteprofile(frame, profile)
    --Check if the Profile exists
    if(not SwitchSwitch:DoesProfileExits(profile)) then
        return
    end

    --Delete the Profile
    SwitchSwitch:DeleteProfileData(profile)
    if(profile:lower() == SwitchSwitch.dbpc.char.SelectedTalentsProfile) then
        SwitchSwitch.dbpc.char.SelectedTalentsProfile = SwitchSwitch.CustomProfileName
    end
    SwitchSwitch.TalentUIFrame.ProfileEditorFrame:Hide()
end

function TalentUIFrame:OnAcceptOverwrrite(frame, profile, savePVP)
    SwitchSwitch:SetProfileData(profile, SwitchSwitch:GetCurrentTalents(savePVP))
    SwitchSwitch.dbpc.char.SelectedTalentsProfile = profile:lower()
    SwitchSwitch:Print(L["Profile '%s' overwritten!"]:format(profile))
end

function TalentUIFrame.UpdateUpperFrame(self, elapsed)
    --Just to make sure we dont update all every frame, as 90% of the time it will not change
    self.LastUpdateTimerPassed = (self.LastUpdateTimerPassed or 1) + elapsed
    if(self.LastProfileUpdateName ~= SwitchSwitch.dbpc.char.SelectedTalentsProfile or self.LastUpdateTimerPassed >= 1) then
        --Update the local variable to avoud updating every frame
        self.LastProfileUpdateName = SwitchSwitch.dbpc.char.SelectedTalentsProfile
        self.LastUpdateTimerPassed = 0
        --Update the UI elements
        UIDropDownMenu_SetSelectedValue(self.DropDownTalents, SwitchSwitch.dbpc.char.SelectedTalentsProfile)

        if(SwitchSwitch.dbpc.char.SelectedTalentsProfile ~= "") then
            UIDropDownMenu_SetText(self.DropDownTalents, SwitchSwitch.dbpc.char.SelectedTalentsProfile)
        end
        -- Save button 
        if(SwitchSwitch.dbpc.char.SelectedTalentsProfile == SwitchSwitch.CustomProfileName) then
            self.NewButton:Show()
            self.NewButton:Enable()
        else
            self.NewButton:Disable()
            self.NewButton:Hide()
        end

        -- Edit button
        if(--[[SwitchSwitch:CountCurrentTalentsProfile() == 0]] false) then
            self.EditButton:Disable()
            self.EditButton:Hide()
        else
            self.EditButton:Show()
            self.EditButton:Enable()
        end
    end
end

--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
function TalentUIFrame:CreateButton(point, parentFrame, relativeFrame, relativePoint, text, width, height, xOffSet, yOffSet, ButtonName, TextHeight)
    --Set defalt values in case not specified
    width = width or 100
    height = height or 20
    xOffSet = xOffSet or 0
    yOffSet = yOffSet or 0
    TextHeight = TextHeight or ""
    text = text or "Not specified"
    --Create the button and set their value
    local button = CreateFrame("Button", ButtonName, parentFrame, "UIPanelButtonTemplate")
    button:SetPoint(point, relativeFrame, relativePoint, xOffSet, yOffSet)
    button:SetSize(width,height)
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal"..TextHeight)
    button:SetHighlightFontObject("GameFontHighlight"..TextHeight)
    --Return the button
    return button
end

function TalentUIFrame.GetAutoCompleatProfiles(currentString, ...)
    local returnNames = {};
    for name, _ in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
        if(name:find(currentString) ~= nil) then
            table.insert(returnNames, {
                ["name"] = name,
                ["priority"] = LE_AUTOCOMPLETE_PRIORITY_OTHER
            })
        end
    end
    return returnNames;
end