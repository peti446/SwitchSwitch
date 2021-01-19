local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local MenuEntry = SwitchSwitch:RegisterMenuEntry(L["Export/Import"])

function MenuEntry:OnOpen(parent)
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetFullWidth(true)
    editBox:SetHeight(100)
    editBox:DisableButton(true)
    editBox:SetLabel("Export String Output")
    parent:AddChild(editBox)
    SwitchSwitch:DebugPrint("Selected Export/Import tab")
end

function MenuEntry:OnClose()
    SwitchSwitch:DebugPrint("Closing Export/Import tab")
end