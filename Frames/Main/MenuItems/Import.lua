local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local MenuEntry = SwitchSwitch:RegisterMenuEntry(L["Import"])

function MenuEntry:OnOpen(parent)
    SwitchSwitch:DebugPrint("Selected Import tab")

    parent:SetLayout("Fill")
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    scroll:SetLayout("Flow")
    parent:AddChild(scroll)
    parent = scroll

    parent:AddChild(self:CreateHeader(L["Import"]))
    parent:AddChild(self:CreateLabel(L["Imported profiles will be added with the names they had at time of export, if the name is already taken '_imported_X' will be appended to the name"] .. ".\n\n"))
    local editBox = self:CreateEditBox(L["Import String"])
    editBox:SetCallback("OnTextChanged", function(self, _, text)
        self:GetUserData("ButtonToEnable"):SetDisabled(text == nil or text == "")
    end)
    parent:AddChild(editBox)

    local importButton = self:CreateButton(L["Import"])
    importButton:SetDisabled(true)
    importButton:SetUserData("EditBox", editBox)
    importButton:SetCallback("OnClick", function(self)
        local text = self:GetUserData("EditBox"):GetText()
        local statusLabel = self:GetUserData("StatusLabel")
        local sucess, statusText = SwitchSwitch:ImportEncodedProfiles(text)
        self:GetUserData("EditBox"):SetText("")
        self:SetDisabled(true)
        if(sucess) then
            statusLabel:SetText("|cff00ff00" .. statusText .. "|r")
        else
            statusLabel:SetText("|cffff0000" .. L["The string you tried to import is not valid"] .. "|r")
        end
    end)
    editBox:SetUserData("ButtonToEnable", importButton)
    parent:AddChild(importButton)

    local statusLabel = self:CreateLabel("");
    statusLabel:SetFontObject(GameFontNormalLarge)
    statusLabel.alignoffset = 45
    importButton:SetUserData("StatusLabel", statusLabel)
    parent:AddChild(statusLabel)
end

function MenuEntry:OnClose()
    SwitchSwitch:DebugPrint("Closing Import tab")
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
