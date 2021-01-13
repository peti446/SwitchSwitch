local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local MenuEntry = SwitchSwitch:RegisterMenuEntry(L["Export/Import"])

function MenuEntry:OnOpen(parent)
    SwitchSwitch:DebugPrint("Selected Export/Import tab")
end

function MenuEntry:OnClose()
    SwitchSwitch:DebugPrint("Closing Export/Import tab")
end