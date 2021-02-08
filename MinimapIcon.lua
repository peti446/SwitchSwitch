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
    tooltip:AddLine("Switch Switch " .. GetAddOnMetadata("SwitchSwitch", "Version"))
    tooltip:AddLine(" ")
    tooltip:AddLine(("%s%s: %s%s|r"):format(RED_FONT_COLOR_CODE, L["Click"], NORMAL_FONT_COLOR_CODE, L["Show config panel"]))
    tooltip:AddLine(" ")
    if(SwitchSwitch.CurrentActiveTalentsProfile ~= SwitchSwitch.defaultProfileName) then
        tooltip:AddLine(("%s%s: |cffa0522d%s|r"):format(NORMAL_FONT_COLOR_CODE, L["Current Profile"], SwitchSwitch.CurrentActiveTalentsProfile))
    else
        tooltip:AddLine(("%s%s. |r"):format(NORMAL_FONT_COLOR_CODE, L["No profile is active, select or create one"]))
    end
end

function LDBSwitchSwitch:OnClick(button, down)
    SwitchSwitch:TogleMainFrame()
end

function SwitchSwitch:InitMinimapIcon()
    if(AlreadyRegistered == false) then
        mmIcon:Register("SwitchSwitch", LDBSwitchSwitch, self.db.profile.minimap)
        AlreadyRegistered = true
    end
end

function SwitchSwitch:RefreshMinimapIcon()
    if(AlreadyRegistered) then
        mmIcon:Refresh("SwitchSwitch", self.db.profile.minimap)
    end
end

function SwitchSwitch:SetMinimapIconVisible(visible)
    if(visible) then
        if(not AlreadyRegistered) then self:InitMinimapIcon() end
        mmIcon:Show("SwitchSwitch")
    else
        mmIcon:Hide("SwitchSwitch")
    end
end