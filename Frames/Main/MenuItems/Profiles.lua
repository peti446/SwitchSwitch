local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local MenuEntry = SwitchSwitch:RegisterMenuEntry(L["Profiles"])


function MenuEntry:OnOpen(parent)
    SwitchSwitch:DebugPrint("Selected Profiles tab")
end

function MenuEntry:OnClose()
    SwitchSwitch:DebugPrint("Closing Profiles tab")
end