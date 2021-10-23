local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local ProfilesEditorPage = SwitchSwitch:RegisterMenuEntry(L["Current Profiles"])
local DropDownGroup
local CurrentEditSpec

function ProfilesEditorPage:OnOpen(parent)
    SwitchSwitch:DebugPrint("Selected Profiles tab")
    CurrentEditSpec = SwitchSwitch:GetCurrentSpec()

    local newButton = AceGUI:Create("Button")
    newButton:SetText(L["New Profile"])
    newButton:SetCallback("OnClick", function(self)
        local dialog = StaticPopup_Show("SwitchSwitch_NewTalentProfilePopUp")
        if(dialog) then
            dialog.data = {
                ["class"] = SwitchSwitch:GetPlayerClass(),
                ["spec"] = CurrentEditSpec
            }
        end
    end)
    parent:AddChild(newButton)

    DropDownGroup = AceGUI:Create("DropdownGroup")
    DropDownGroup:SetFullWidth(true)
    DropDownGroup:SetFullHeight(true)
    DropDownGroup:SetTitle(L["Profiles Editor"])
    DropDownGroup:SetCallback("OnGroupSelected", function(self, _, group) ProfilesEditorPage:OnGroupSelected(self, group) end)
    parent:AddChild(DropDownGroup)

    self:SetDropDownGroupList()
end

function ProfilesEditorPage:OnClose()
    SwitchSwitch:DebugPrint("Closing Profiles tab")
    DropDownGroup = nil
end

function ProfilesEditorPage:SetDropDownGroupList()
    local talentsProfiles = SwitchSwitch:GetCurrentSpecProfilesTable()
    local dropDownData = {}
    local count = 0
    local oldGroup = DropDownGroup.status or DropDownGroup.localstatus

    if(type(oldGroup) ~= "table" or oldGroup.selected == nil) then
        oldGroup = nil
    else
        oldGroup = oldGroup.selected
    end

    local oldGroupExitsInNew = false
    for name, data in pairs(talentsProfiles) do
        dropDownData[name] = name
        count = count + 1
        if(oldGroup == name) then
            oldGroupExitsInNew = true
        end
    end

    if(not oldGroupExitsInNew) then
        oldGroup = nil
    end


    DropDownGroup:SetGroupList(dropDownData)
    if(count > 0) then
        if(oldGroup ~= nil) then
            DropDownGroup:SetGroup(oldGroup)
        elseif(SwitchSwitch.CurrentActiveTalentsProfile ~= SwitchSwitch.defaultProfileName and SwitchSwitch:DoesProfileExits(SwitchSwitch.CurrentActiveTalentsProfile, SwitchSwitch:GetPlayerClass(), CurrentEditSpec)) then
            DropDownGroup:SetGroup(SwitchSwitch.CurrentActiveTalentsProfile)
        else
            DropDownGroup:SetGroup(select(1, next(dropDownData, nil)))
        end
    else
        DropDownGroup:ReleaseChildren()
        DropDownGroup.dropdown:SetText("")
    end
end

local function OnRenameTextChanged(self, _, newText)
    local button = self:GetUserData("AcceptButton")
    local originalText = self:GetUserData("OriginalText")
    button:SetDisabled(newText == originalText)
end

local function OnRenameProfile(self, _)
    local editBox = self:GetUserData("EditBox")
    local originalName = editBox:GetUserData("OriginalText")
    local newName = editBox:GetText()
    if(SwitchSwitch:RenameProfile(originalName, newName, nil, CurrentEditSpec)) then
        DropDownGroup.status = DropDownGroup.status or {}
        DropDownGroup.status["selected"] = newName:lower()
        ProfilesEditorPage:SetDropDownGroupList()
    end
end

local function OnDeleteProfile(self)
    local dialog = StaticPopup_Show("SwitchSwitch_ConfirmDeleteprofile", self:GetUserData("profile"))
    if(dialog) then
        dialog.data = self:GetUserData("profile")
        dialog.OnDeleted = function(deletedProfile) ProfilesEditorPage:SetDropDownGroupList() end
    end
end

local function OnTalentSelected(self, _, newColumn, oldColumn)
    local t = SwitchSwitch:GetProfileData(self:GetUserData("ProfileName"), nil, CurrentEditSpec)
    local row = self:GetUserData("Row")
    t["pva"][row]["column"] = newColumn
    t["pva"][row]["id"] = self:GetTalentID(newColumn)
    SwitchSwitch:PLAYER_TALENT_UPDATE()
end

function ProfilesEditorPage:OnGroupSelected(frame, group)
    SwitchSwitch:DebugPrint("Displaying profile to edit: " .. group)

    frame:ReleaseChildren()
    frame:SetLayout("Fill")

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    scroll:SetLayout("Flow")
    frame:AddChild(scroll)

    scroll:AddChild(self:CreateHeader(L["General"]))

    local renameBox = AceGUI:Create("EditBox")
    renameBox:SetFullWidth(true)
    renameBox:SetHeight(30)
    renameBox:SetLabel(L["Profile Name"])
    renameBox:DisableButton(true)
    renameBox:SetText(group)
    renameBox:SetUserData("OriginalText", group)
    renameBox:SetCallback("OnTextChanged", OnRenameTextChanged)
    scroll:AddChild(renameBox)

    local renameButton = AceGUI:Create("Button")
    renameButton:SetText(L["Rename"])
    renameButton:SetCallback("OnClick", OnRenameProfile)
    renameButton:SetUserData("EditBox", renameBox)
    renameBox:SetUserData("AcceptButton",renameButton)
    renameButton:SetDisabled(true)
    scroll:AddChild(renameButton)

    local deleteButton = AceGUI:Create("Button")
    deleteButton:SetText(L["Delete Profile"])
    deleteButton:SetUserData("profile", group)
    deleteButton:SetCallback("OnClick",OnDeleteProfile)
    scroll:AddChild(deleteButton)

    scroll:AddChild(self:CreateHeader(L["Gear Set"]))
    scroll:AddChild(self:CreateLabel(L["Gear set to equip automaticly when activating this profile set (Blizzard gear set, needs to be created beforehand)"] .. ".\n" .. "|cFFFF0000".. L["Warning: This setting is per character, renaming this profile means you will need to re-set this on each character for this profile"] .. ".|r"))
    local gearSetDropDown = AceGUI:Create("Dropdown")
    gearSetDropDown:SetLabel(L["Gear Set"])
    gearSetDropDown:SetText(L["None"])
    local gearSets = {
    }
    gearSets["none"] = L["None"]
    for _, id in ipairs(C_EquipmentSet.GetEquipmentSetIDs()) do
        local name = C_EquipmentSet.GetEquipmentSetInfo(id)
        gearSets[name] = name
    end
    gearSetDropDown:SetList(gearSets)
    gearSetDropDown:SetUserData("ProfileName", group)
    gearSetDropDown:SetValue("none")
    if(type(SwitchSwitch.db.char.gearSets[SwitchSwitch:GetCurrentSpec()]) == "table" and SwitchSwitch.db.char.gearSets[SwitchSwitch:GetCurrentSpec()][group] ~= nil) then
        gearSetDropDown:SetValue(SwitchSwitch.db.char.gearSets[SwitchSwitch:GetCurrentSpec()][group])
    end
    gearSetDropDown:SetCallback("OnValueChanged", function(self, _, name)
        if(name == "none") then
            name = nil
        end
        if(type(SwitchSwitch.db.char.gearSets[SwitchSwitch:GetCurrentSpec()]) ~= "table") then
            SwitchSwitch.db.char.gearSets[SwitchSwitch:GetCurrentSpec()] = {}
        end
        SwitchSwitch.db.char.gearSets[SwitchSwitch:GetCurrentSpec()][self:GetUserData("ProfileName")] = name
    end)
    scroll:AddChild(gearSetDropDown)

    -- Shadowlands change active soulbind
    scroll:AddChild(self:CreateHeader(L["Preferred Soulbind"]))
    scroll:AddChild(self:CreateLabel(L["Change preferred soulbind when changing talents."] .. ".\n" .. "|cFFFF0000".. L["Warning: This setting is per character, renaming this profile means you will need to re-set this on each character for this profile"] .. ".|r"))
    local preferredSoulbindDropDown = AceGUI:Create("Dropdown")
    preferredSoulbindDropDown:SetLabel(L["Soulbind"])
    preferredSoulbindDropDown:SetText(L["None"])

    local covenantDataID = C_Covenants.GetActiveCovenantID();
    if(covenantDataID == 0) then
        scroll:AddChild(self:CreateLabel("|cFFFF0000" .. L["You do not have a covenant"] .. ".|r"))
    else
        local covenantData = C_Covenants.GetCovenantData(covenantDataID);

        local possibleSoulbinds = {}
        possibleSoulbinds["none"] = L["None"]
        for _, id in ipairs(covenantData.soulbindIDs) do
            local name = C_Soulbinds.GetSoulbindData(id).name
            possibleSoulbinds[id] = name
        end

        preferredSoulbindDropDown:SetList(possibleSoulbinds)
        preferredSoulbindDropDown:SetUserData("ProfileName", group)
        preferredSoulbindDropDown:SetValue("none")
        if(type(SwitchSwitch.db.char.preferredSoulbind[SwitchSwitch:GetCurrentSpec()]) == "table" and SwitchSwitch.db.char.preferredSoulbind[SwitchSwitch:GetCurrentSpec()][group] ~= nil) then
            preferredSoulbindDropDown:SetValue(SwitchSwitch.db.char.preferredSoulbind[SwitchSwitch:GetCurrentSpec()][group])
        end

        preferredSoulbindDropDown:SetCallback("OnValueChanged", function(self, _, id)
            if(id == "none") then
                id = nil
            end
            if(type(SwitchSwitch.db.char.preferredSoulbind[SwitchSwitch:GetCurrentSpec()]) ~= "table") then
                SwitchSwitch.db.char.preferredSoulbind[SwitchSwitch:GetCurrentSpec()] = {}
            end
            SwitchSwitch.db.char.preferredSoulbind[SwitchSwitch:GetCurrentSpec()][self:GetUserData("ProfileName")] = id
        end)
        scroll:AddChild(preferredSoulbindDropDown)
    end


    scroll:AddChild(self:CreateHeader(L["Talents"]))

    local talentFrameGroup = AceGUI:Create("SimpleGroup")
    talentFrameGroup:SetLayout("Flow")
    talentFrameGroup:SetFullWidth(true)
    local selectedProfileTalents = SwitchSwitch:GetProfileData(group, nil, CurrentEditSpec)
    for tier, rowData in pairs(SwitchSwitch.TalentsData[CurrentEditSpec]) do
        local uiRow = AceGUI:Create("TalentRow")
        uiRow:SetLevel(rowData["requiredLevel"])
        uiRow:SetColumnSelected(selectedProfileTalents["pva"][tier]["column"])
        uiRow:SetUserData("Row", tier)
        uiRow:SetUserData("ProfileName", group)

        for column, talentData  in pairs(SwitchSwitch.TalentsData[CurrentEditSpec][tier]["data"]) do
            uiRow:SetTalentIcon(column, talentData.textureID)
            uiRow:SetTalentName(column, talentData.name)
            uiRow:SetTalentID(column, talentData.talentID)
        end

        uiRow:SetCallback("TalentSelected", OnTalentSelected)
        talentFrameGroup:AddChild(uiRow)
    end

    scroll:AddChild(talentFrameGroup)
end

function ProfilesEditorPage:CreateHeader(Text)
    local header = AceGUI:Create("Heading")
    header:SetText(Text)
    header:SetFullWidth(true)
    header:SetHeight(35)
    return header
end

function ProfilesEditorPage:CreateLabel(Text)
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetText(Text)
    return label
end

function SwitchSwitch:RefreshProfilesEditorPage()
    if(DropDownGroup == nil) then
        return
    end
    CurrentEditSpec = SwitchSwitch:GetCurrentSpec()
    ProfilesEditorPage:SetDropDownGroupList()
end