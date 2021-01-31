local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local MenuEntry = SwitchSwitch:RegisterMenuEntry(L["Export"])
local ProfilesDropDown

local function ExportButtonClicked(button)
    local editBox = button:GetUserData("EditBox")
    local dropdown = button:GetUserData("DropDown")
    local exportPVPTalents = button:GetUserData("PVPCheckBox"):GetValue()

    local profileList = {}
    for i, widget in dropdown.pullout:IterateItems() do
        if widget.type == "Dropdown-Item-Toggle" then
            if widget:GetValue() then
                table.insert( profileList, widget.userdata.value )
            end
        end
    end
    editBox:SetText(SwitchSwitch:ProfilesToString(profileList, exportPVPTalents))
    editBox:HighlightText()
    editBox:SetFocus()
    editBox:SetDisabled(false)
end

function MenuEntry:OnOpen(parent)
    SwitchSwitch:DebugPrint("Selected Export/Import tab")

    parent:SetLayout("Fill")
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    scroll:SetLayout("Flow")
    parent:AddChild(scroll)
    parent = scroll

    parent:AddChild(self:CreateHeader(L["Export"]))
    parent:AddChild(self:CreateLabel(L["Select one or more profiles from you current sepc to export"] ..  ".\n\n"))

    ProfilesDropDown = AceGUI:Create("Dropdown")
    ProfilesDropDown:SetLabel(L["Select profiles to export"])
    ProfilesDropDown:SetMultiselect(true)
    ProfilesDropDown:SetFullWidth(true)
    self:SetDropDownProfileList()
    ProfilesDropDown:SetCallback("OnValueChanged", function(self)
        local hasSelected = false
		for i, widget in self.pullout:IterateItems() do
			if widget.type == "Dropdown-Item-Toggle" then
                if widget:GetValue() then
                    hasSelected = true
                    break;
				end
			end
		end

        self:GetUserData("ButtonToEnable"):SetDisabled(not hasSelected)
    end)
    parent:AddChild(ProfilesDropDown)

    local cb = self:CreateCheckBox(L["Should export PVP Talents?"])
    cb:SetDescription(L["Will only export pvp talents if the specific profile was created with pvp talents enabled, this will not add pvp talents to any profile"])
    parent:AddChild(cb)

    local exportButton = self:CreateButton(L["Export"])
    exportButton:SetDisabled(true)
    exportButton:SetUserData("DropDown", ProfilesDropDown)
    exportButton:SetUserData("PVPCheckBox", cb)
    exportButton:SetCallback("OnClick", ExportButtonClicked)
    ProfilesDropDown:SetUserData("ButtonToEnable", exportButton)
    parent:AddChild(exportButton)

    local editBox = self:CreateEditBox(L["Export String"])
    editBox:SetCallback("OnTextChanged", function(self, _, text)
        self:SetDisabled(text == nil or text == "")
    end)
    editBox:SetDisabled(true)
    exportButton:SetUserData("EditBox", editBox)
    parent:AddChild(editBox)
end

function MenuEntry:OnClose()
    SwitchSwitch:DebugPrint("Closing Export tab")
    ProfilesDropDown = nil
end


function MenuEntry:CreateHeader(Text)
    local header = AceGUI:Create("Heading")
    header:SetText(Text)
    header:SetFullWidth(true)
    header:SetHeight(35)
    return header
end

function MenuEntry:CreateEditBox(Label)
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetFullWidth(true)
    editBox:DisableButton(true)
    editBox:SetLabel(Label)
    editBox:SetNumLines(14)
    return editBox;
end

function MenuEntry:CreateCheckBox(Text)
    local debugCheckBox = AceGUI:Create("CheckBox")
    debugCheckBox:SetLabel(Text)
    debugCheckBox:SetFullWidth(true)
    return debugCheckBox
end


function MenuEntry:CreateButton(Text)
    local button = AceGUI:Create("Button")
    button:SetText(Text)
    button:SetWidth(200)
    return button
end

function MenuEntry:CreateLabel(Text)
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetText(Text)
    return label
end

function MenuEntry:SetDropDownProfileList()
    if(ProfilesDropDown == nil) then
        return
    end
    local talentsProfiles = SwitchSwitch:GetCurrentSpecProfilesTable()
    local ProfilesDropDownData = {}
    for name, data in pairs(talentsProfiles) do
        ProfilesDropDownData[name] = name
    end
    ProfilesDropDown:SetList(ProfilesDropDownData)
    ProfilesDropDown:Fire("OnValueChanged", next(ProfilesDropDownData), false)
end

function SwitchSwitch:RefreshExportUI()
    if(ProfilesDropDown == nil) then
        return
    end
    MenuEntry:SetDropDownProfileList()
end