local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local OptionsPage = SwitchSwitch:RegisterMenuEntry(L["Character Options"])


function OptionsPage:OnOpen(parent)
    SwitchSwitch:DebugPrint("Selected Options tab")

    parent:SetLayout("Fill")
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    scroll:SetLayout("Flow")
    parent:AddChild(scroll)
    parent = scroll

    parent:AddChild(self:CreateHeader(L["General"]));

    local cb = self:CreateCheckBox(L["Ask to automatically use tome when trying to change talents"])
    cb:SetValue(SwitchSwitch.db.profile.autoUseTomes)
    cb:SetCallback("OnValueChanged", function(_, _, newVal)
        SwitchSwitch.db.profile.autoUseTomes = newVal
    end)
    parent:AddChild(cb)

    local cbForSlider = self:CreateCheckBox(L["Suggest talent changes based on zone/boss"])
    cbForSlider:SetValue(SwitchSwitch.db.profile.talentsSuggestionFrame.enabled)
    cbForSlider:SetCallback("OnValueChanged", function(self, _, newVal)
        SwitchSwitch.db.profile.talentsSuggestionFrame.enabled = newVal
        self:GetUserData("slider"):SetDisabled(not SwitchSwitch.db.profile.talentsSuggestionFrame.enabled)
    end)
    parent:AddChild(cbForSlider)

    local fadeSlider = AceGUI:Create("Slider")
    fadeSlider:SetSliderValues(10, 60, 1)
    fadeSlider:SetLabel(L["Time for suggestion-frame to fade away (in seconds)"])
    fadeSlider:SetFullWidth(true)
    fadeSlider:SetValue(math.min(60, math.max(10, SwitchSwitch.db.profile.talentsSuggestionFrame.fadeTime)))
    fadeSlider:SetCallback("OnValueChanged", function(_, _, newVal)
        SwitchSwitch.db.profile.talentsSuggestionFrame.fadeTime = newVal
    end)
    fadeSlider:SetDisabled(not SwitchSwitch.db.profile.talentsSuggestionFrame.enabled)
    parent:AddChild(fadeSlider)
    cbForSlider:SetUserData("slider", fadeSlider)

    parent:AddChild(self:CreateHeader(L["Misc"]));

    cb = self:CreateCheckBox(L["Enable minimap button"])
    cb:SetValue(not SwitchSwitch.db.profile.minimap.hide)
    cb:SetCallback("OnValueChanged", function(_, _, newVal)
        SwitchSwitch.db.profile.minimap.hide = not newVal
        SwitchSwitch:SetMinimapIconVisible(newVal)
    end)
    parent:AddChild(cb);

    cb = self:CreateCheckBox(L["Enable debug messages in chat"])
    cb:SetValue(SwitchSwitch.db.profile.debug)
    cb:SetCallback("OnValueChanged", function(_, _, newVal)
        SwitchSwitch.db.profile.debug = newVal
    end)
    parent:AddChild(cb);
end

function OptionsPage:OnClose()
    SwitchSwitch:DebugPrint("Closing Options tab")
end

function OptionsPage:CreateCheckBox(Text)
    local debugCheckBox = AceGUI:Create("CheckBox")
    debugCheckBox:SetLabel(Text)
    debugCheckBox:SetFullWidth(true)
    return debugCheckBox
end

function OptionsPage:CreateHeader(Text)
    local header = AceGUI:Create("Heading")
    header:SetText(Text)
    header:SetFullWidth(true)
    header:SetHeight(35)
    return header
end