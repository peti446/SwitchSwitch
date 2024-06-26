local SwitchSwitch, L = unpack(select(2, ...))

local LDBSwitchSwitch = LibStub("LibDataBroker-1.1"):NewDataObject("SwitchSwitchIcon", {
    type = "data source",
    label = "Switch Switch",
    icon = "Interface\\Icons\\INV_Artifact_Tome02",
    text = ("%s%s. |r"):format(NORMAL_FONT_COLOR_CODE, L["No profile is active, select or create one"]) .. "|r",
});
local mmIcon = LibStub("LibDBIcon-1.0")
local AlreadyRegistered = false
local MenuFrame = nil

function LDBSwitchSwitch:OnTooltipShow()
    local tooltip = self
    local projectVersion = C_AddOns.GetAddOnMetadata("SwitchSwitch", "Version")
    if (projectVersion == '@project-version@') then
        projectVersion = SwitchSwitch.InternalVersion
    end

    tooltip:AddLine("Switch Switch " .. projectVersion)
    tooltip:AddLine(" ")
    tooltip:AddLine(("%s%s: %s%s|r"):format(RED_FONT_COLOR_CODE, L["Left Click"], NORMAL_FONT_COLOR_CODE, L["Show config panel"]))
    tooltip:AddLine(("%s%s: %s%s|r"):format(RED_FONT_COLOR_CODE, L["Right Click"], NORMAL_FONT_COLOR_CODE, L["Quick talents profile change"]))
    tooltip:AddLine(" ")
    if(SwitchSwitch.CurrentActiveTalentsConfigID ~= SwitchSwitch.defaultProfileID) then
        local profileData = SwitchSwitch:GetProfileData(SwitchSwitch.CurrentActiveTalentsConfigID)
        tooltip:AddLine(("%s%s: |cffa0522d%s|r"):format(NORMAL_FONT_COLOR_CODE, L["Current Profile"], profileData.name) .. "|r")
    else
        tooltip:AddLine(("%s%s. |r"):format(NORMAL_FONT_COLOR_CODE, L["No profile is active, select or create one"]) .. "|r")
    end
end

function LDBSwitchSwitch:OnClick(button, down)
    if(button == "RightButton") then
        if(not MenuFrame) then
            MenuFrame = CreateFrame("Frame", "Test_DropDown", UIParent, "UIDropDownMenuTemplate")
        end
        UIDropDownMenu_SetWidth(MenuFrame, 200)
        UIDropDownMenu_Initialize(MenuFrame, function(self, level, menuList)
            local talentsProfiles = SwitchSwitch:GetAllCurrentSpecProfiles()
            local titleIcon = UIDropDownMenu_CreateInfo()
            titleIcon.text = "Switch Switch - " .. L["Change Talents"]
            titleIcon.isTitle = true
            titleIcon.notClickable = true
            titleIcon.notCheckable = true
            UIDropDownMenu_AddButton(titleIcon, level)
            for id, data in pairs(talentsProfiles) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = data.name
                info.arg1 = id
                info.checked = id == SwitchSwitch.CurrentActiveTalentsConfigID
                info.func = function(self, id) SwitchSwitch:ActivateTalentProfile(id) end
                UIDropDownMenu_AddButton(info, level)
            end
        end, "MENU")
        MenuFrame:Show()
        ToggleDropDownMenu(1, nil, MenuFrame, "cursor", 3, -3)
    else
        SwitchSwitch:TogleMainFrame()
    end
end

function SwitchSwitch:UpdateLDBText()
    local profileData = SwitchSwitch:GetProfileData(SwitchSwitch.CurrentActiveTalentsConfigID)
    LDBSwitchSwitch.text = (profileData and profileData.name) or L["None"]
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