local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

local LDBSwitchSwitch = LibStub("LibDataBroker-1.1"):NewDataObject("SwitchSwitchIcon", {
    type = "data source", 
    text = "Switch Switch",
    icon = "Interface\\Icons\\INV_Artifact_Tome02",
});
local mmIcon = LibStub("LibDBIcon-1.0")
local AlreadyRegistered = false

function LDBSwitchSwitch:OnTooltipShow()
    local tooltip = self
    tooltip:AddLine("Switch Switch V" .. SwitchSwitch.version)
    tooltip:AddLine(" ")
    tooltip:AddLine(("%s%s: %s%s|r"):format(RED_FONT_COLOR_CODE, L["Click"], NORMAL_FONT_COLOR_CODE, L["Show config panel"]))
    tooltip:AddLine(" ")
    if(SwitchSwitch.sv.config.SelectedTalentsProfile ~= SwitchSwitch.CustomProfileName) then
        tooltip:AddLine(("%s%s: |cffa0522d%s|r"):format(NORMAL_FONT_COLOR_CODE, L["Current Profile"], SwitchSwitch.sv.config.SelectedTalentsProfile))
    else
        tooltip:AddLine(("%s%s. |r"):format(NORMAL_FONT_COLOR_CODE, L["No profile is active, select or create one"]))
    end
end

function LDBSwitchSwitch:OnClick(button, down)
    SwitchSwitch.ConfigFrame:ToggleFrame()
end

function SwitchSwitch:InitMinimapIcon()
    if(AlreadyRegistered == false) then
        mmIcon:Register("SwitchSwitch", LDBSwitchSwitch, SwitchSwitch.sv.config)
        AlreadyRegistered = true
    end
end