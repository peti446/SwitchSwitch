--############################################
-- Namespace
--############################################
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

SwitchSwitch.ConfigFrame = {}
local ConfigFrame = SwitchSwitch.ConfigFrame

--##########################################################################################################################
--                                  Config Frame Init
--##########################################################################################################################
local function CreateConfigFrame()
    --Create the main frame and set some its look
    local frame = CreateFrame("FRAME", "SS_MainConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetPoint("CENTER")
    frame:SetSize(400,500)
    frame.TitleText:SetText(L["Switch Switch Options"])

    --General Text seperator
    frame.GeneralText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLargeLeft")
    frame.GeneralText:SetText(L["General"])
    frame.GeneralText:SetPoint("TOPLEFT", frame.InsetBorderTopLeft, "BOTTOMRIGHT", 5, -7)
    frame.GeneralText:SetPoint("TOPRIGHT", frame.InsetBorderTopRight, "BOTTOMLEFT", -5, -7)

    --------- Create subelements to actually change the options
    frame.DebugModeCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.DebugModeCB:SetPoint("TOPLEFT", frame.GeneralText, "BOTTOMLEFT", 2, -5)
    frame.DebugModeCB.text:SetText(L["Debug mode"])
    frame.DebugModeCB.text:SetFontObject("GameFontWhite")
    frame.DebugModeCB:SetScript("OnClick", function(self) SwitchSwitch.dbpc.char.debug = self:GetChecked()  end)

    frame.autoUseItemsCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.autoUseItemsCB:SetPoint("TOPLEFT", frame.DebugModeCB, "BOTTOMLEFT")
    frame.autoUseItemsCB.text:SetText(L["Prompact to use Tome to change talents?"])
    frame.autoUseItemsCB.text:SetFontObject("GameFontWhite")
    frame.autoUseItemsCB:SetScript("OnClick", function(self) SwitchSwitch.dbpc.char.autoUseItems = self:GetChecked()  end)

    frame.autoUseItemsCDText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.autoUseItemsCDText:SetText(L["Autofade timer for auto-change frame"]..":")
    frame.autoUseItemsCDText:SetPoint("TOPLEFT", frame.autoUseItemsCB, "BOTTOMLEFT", 10, -3)

    frame.autoUseItemsCDSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    frame.autoUseItemsCDSlider:SetPoint("TOPRIGHT", frame.autoUseItemsCDText, "BOTTOMLEFT", 150, -10)
    frame.autoUseItemsCDSlider:SetMinMaxValues(0, 30)
    frame.autoUseItemsCDSlider.minValue, frame.autoUseItemsCDSlider.maxValue = frame.autoUseItemsCDSlider:GetMinMaxValues() 
    frame.autoUseItemsCDSlider.Low:SetText(frame.autoUseItemsCDSlider.minValue)
    frame.autoUseItemsCDSlider.High:SetText(frame.autoUseItemsCDSlider.maxValue)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame.autoUseItemsCDSlider.Text:GetPoint()
    frame.autoUseItemsCDSlider.Text:SetPoint("TOP", relativeTo, "BOTTOM", 0, -25)
    frame.autoUseItemsCDSlider.Text:SetText("15")
    frame.autoUseItemsCDSlider:SetValueStep(1)
    frame.autoUseItemsCDSlider.Text2 = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.autoUseItemsCDSlider.Text2:SetPoint("LEFT", frame.autoUseItemsCDSlider, "RIGHT", 15, 0)
    frame.autoUseItemsCDSlider.Text2:SetText(L["(0 to disable auto-fade)"])
    frame.autoUseItemsCDSlider:SetScript("OnValueChanged", function(self,value, userInput)
        frame.autoUseItemsCDSlider.Text:SetText(string.format("%.f", value))
        SwitchSwitch.dbpc.char.maxTimeSuggestionFrame = tonumber(string.format("%.f", value))
    end)
    frame.autoUseItemsCDSlider:SetValue(SwitchSwitch.dbpc.char.maxTimeSuggestionFrame)

    frame.ProfilesConfigText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLargeLeft")
    frame.ProfilesConfigText:SetText(L["Profiles for instance auto-change:"])
    frame.ProfilesConfigText:SetPoint("TOPLEFT", frame.autoUseItemsCDSlider.Low, "BOTTOMLEFT", -13, -10)

    frame.ProfilesConfigText.Description = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.ProfilesConfigText.Description:SetText(L["If you select a profile from any of the dropdown boxes, when etering the specific instance, you will be greeted with a popup that will ask you if you want to change to that profile."])
    frame.ProfilesConfigText.Description:SetPoint("TOPLEFT", frame.ProfilesConfigText, "BOTTOMLEFT", 5, -5)
    frame.ProfilesConfigText.Description:SetWidth(350)
    frame.ProfilesConfigText.Description:SetJustifyH("LEFT")

    frame.ArenaText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.ArenaText:SetPoint("TOPLEFT", frame.ProfilesConfigText.Description, "BOTTOMLEFT", 0, -20)
    frame.ArenaText:SetText(L["Arenas"] .. ":")
    frame.ArenaText.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.ArenaText.DropDownMenu:SetPoint("LEFT", frame.ArenaText, "RIGHT", 0, -5)
    frame.ArenaText.DropDownMenu.funcName = "arena"
    UIDropDownMenu_SetWidth(frame.ArenaText.DropDownMenu, 200)
    UIDropDownMenu_Initialize(frame.ArenaText.DropDownMenu, ConfigFrame.SetUpButtons)


    frame.BattlegroundText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.BattlegroundText:SetPoint("TOPLEFT", frame.ArenaText, "BOTTOMLEFT", 0, -20)
    frame.BattlegroundText:SetText(L["Battlegrounds"]..":")
    frame.BattlegroundText.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.BattlegroundText.DropDownMenu:SetPoint("LEFT", frame.BattlegroundText, "RIGHT", 0, -5)
    frame.BattlegroundText.DropDownMenu.funcName = "bg"
    UIDropDownMenu_SetWidth(frame.BattlegroundText.DropDownMenu, 200)
    UIDropDownMenu_Initialize(frame.BattlegroundText.DropDownMenu, ConfigFrame.SetUpButtons)


    frame.RaidText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.RaidText:SetPoint("TOPLEFT", frame.BattlegroundText, "BOTTOMLEFT", 0, -20)
    frame.RaidText:SetText(L["Raid"] .. ":")
    frame.RaidText.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.RaidText.DropDownMenu:SetPoint("LEFT", frame.RaidText, "RIGHT", 0, -5)
    frame.RaidText.DropDownMenu.funcName = "raid"
    UIDropDownMenu_SetWidth(frame.RaidText.DropDownMenu, 200)
    UIDropDownMenu_Initialize(frame.RaidText.DropDownMenu, ConfigFrame.SetUpButtons)


    frame.Party = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.Party:SetPoint("TOPLEFT", frame.RaidText, "BOTTOMLEFT", 0, -20)
    frame.Party:SetText(L["Party"] .. ":")


    frame.Party.HC = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.Party.HC:SetPoint("TOPLEFT", frame.Party, "BOTTOMLEFT", 30, -10)
    frame.Party.HC:SetText(L["Heroic"] .. ":")
    frame.Party.HC.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.Party.HC.DropDownMenu:SetPoint("LEFT", frame.Party.HC, "RIGHT", 0, -5)
    frame.Party.HC.DropDownMenu.funcName = "partyhc"
    UIDropDownMenu_SetWidth(frame.Party.HC.DropDownMenu, 200)
    UIDropDownMenu_Initialize(frame.Party.HC.DropDownMenu, ConfigFrame.SetUpButtons)


    frame.Party.MM = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.Party.MM:SetPoint("TOPLEFT", frame.Party.HC, "BOTTOMLEFT", 0, -20)
    frame.Party.MM:SetText(L["Mythic"] .. ":")
    frame.Party.MM.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.Party.MM.DropDownMenu:SetPoint("LEFT", frame.Party.MM, "RIGHT", 0, -5)
    frame.Party.MM.DropDownMenu.funcName = "partymm"
    UIDropDownMenu_SetWidth(frame.Party.MM.DropDownMenu, 200)
    UIDropDownMenu_Initialize(frame.Party.MM.DropDownMenu, ConfigFrame.SetUpButtons)


    --Make the frame moveable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end);

    --Set on shown script
    frame:SetScript("OnShow", function(self)
        self.autoUseItemsCDSlider:SetValue(SwitchSwitch.dbpc.char.maxTimeSuggestionFrame)
        self.autoUseItemsCB:SetChecked(SwitchSwitch.dbpc.char.autoUseItems)
        self.DebugModeCB:SetChecked(SwitchSwitch.dbpc.char.debug)
        UIDropDownMenu_SetSelectedValue(self.ArenaText.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.arena)
        UIDropDownMenu_SetSelectedValue(self.BattlegroundText.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.pvp)
        UIDropDownMenu_SetSelectedValue(self.RaidText.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.raid)
        UIDropDownMenu_SetSelectedValue(self.Party.HC.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.party.HM)
        UIDropDownMenu_SetSelectedValue(self.Party.MM.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.party.MM)
        UIDropDownMenu_SetText(self.ArenaText.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.arena ~= "" and SwitchSwitch.dbpc.char.autoSuggest.arena or "None")
        UIDropDownMenu_SetText(self.BattlegroundText.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.pvp ~= "" and SwitchSwitch.dbpc.char.autoSuggest.pvp or "None")
        UIDropDownMenu_SetText(self.RaidText.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.raid ~= "" and SwitchSwitch.dbpc.char.autoSuggest.raid or "None")
        UIDropDownMenu_SetText(self.Party.HC.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.party.HM ~= "" and SwitchSwitch.dbpc.char.autoSuggest.party.HM or "None")
        UIDropDownMenu_SetText(self.Party.MM.DropDownMenu, SwitchSwitch.dbpc.char.autoSuggest.party.MM ~= "" and SwitchSwitch.dbpc.char.autoSuggest.party.MM or "None")
        
    end)

    --Hide the frame by default
    frame:Hide()
    --Return the frame
    return frame
end

function ConfigFrame:ToggleFrame()
    SwitchSwitch.ConfigFrame.Frame = SwitchSwitch.ConfigFrame.Frame or CreateConfigFrame()
    SwitchSwitch.ConfigFrame.Frame:SetShown(not SwitchSwitch.ConfigFrame.Frame:IsShown())
end

--##########################################################################################################################
--                                  Dropdown functions
--##########################################################################################################################
function ConfigFrame.SetUpButtons(self, level, menuList)
    local menuList = {
        {
            text = "None",
            value = ""
        }
    }
    --Get all profile names and create the list for the dropdown menu
    for TalentProfileName, data in pairs(SwitchSwitch:GetCurrentProfilesTable()) do
        table.insert(menuList, {
            text = TalentProfileName
        })
    end
    
    --Make sure level is always set
    if(not level) then
        level = 1
    end

    --Create all buttons and attach the nececarry information
	for index = 1, #menuList do
        local info = menuList[index]
		if (info.text) then
            info.index = index
            info.arg1 = self
            info.func = ConfigFrame.SetSelectedValueAutoChange
			UIDropDownMenu_AddButton( info, level )
		end
	end
end

function ConfigFrame.SetSelectedValueAutoChange(self, arg1, arg2, checked)
    if(not checked) then
        UIDropDownMenu_SetSelectedValue(arg1, self.value)
        if(arg1.funcName == "arena") then
            SwitchSwitch.dbpc.char.autoSuggest.arena = self.value
        elseif(arg1.funcName == "bg") then
            SwitchSwitch.dbpc.char.autoSuggest.pvp = self.value
        elseif(arg1.funcName == "raid") then
            SwitchSwitch.dbpc.char.autoSuggest.raid = self.value
        elseif(arg1.funcName == "partyhc") then
            SwitchSwitch.dbpc.char.autoSuggest.party.HM = self.value
        elseif(arg1.funcName == "partymm") then
            SwitchSwitch.dbpc.char.autoSuggest.party.MM = self.value
        end
    end
end