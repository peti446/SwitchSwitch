--############################################
-- Namespace
--############################################
local addonName, addon = ...

addon.ConfigFrame = {}
local ConfigFrame = addon.ConfigFrame


function ConfigFrame:Init()
  --  ConfigFrame:ToggleFrame()
end

--##########################################################################################################################
--                                  Config Frame Init
--##########################################################################################################################
local function CreateConfigFrame()
    --Create the main frame and set some its look
    local frame = CreateFrame("FRAME", "SS_MainConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetPoint("CENTER")
    frame:SetSize(400,500)
    frame.TitleText:SetText(addon.L["Switch Switch Options"])

    --General Text seperator
    frame.GeneralText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLargeLeft")
    frame.GeneralText:SetText(addon.L["General"])
    frame.GeneralText:SetPoint("TOPLEFT", frame.InsetBorderTopLeft, "BOTTOMRIGHT", 5, -7)
    frame.GeneralText:SetPoint("TOPRIGHT", frame.InsetBorderTopRight, "BOTTOMLEFT", -5, -7)

    --------- Create subelements to actually change the options
    frame.DebugModeCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.DebugModeCB:SetPoint("TOPLEFT", frame.GeneralText, "BOTTOMLEFT", 2, -5)
    frame.DebugModeCB.text:SetText(addon.L["Debug mode"])
    frame.DebugModeCB.text:SetFontObject("GameFontWhite")

    frame.autoUseItemsCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.autoUseItemsCB:SetPoint("TOPLEFT", frame.DebugModeCB, "BOTTOMLEFT")
    frame.autoUseItemsCB.text:SetText(addon.L["Prompact to use Tome to change talents?"])
    frame.autoUseItemsCB.text:SetFontObject("GameFontWhite")

    frame.autoUseItemsCDText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.autoUseItemsCDText:SetText(addon.L["Autofade timer for auto-change frame"]..":")
    frame.autoUseItemsCDText:SetPoint("TOPLEFT", frame.autoUseItemsCB, "BOTTOMLEFT", 10, -3)

    frame.autoUseItemsCDSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    frame.autoUseItemsCDSlider:SetPoint("TOPRIGHT", frame.autoUseItemsCDText, "BOTTOMLEFT", 150, -10)
    frame.autoUseItemsCDSlider:SetMinMaxValues(0, 30)
    frame.autoUseItemsCDSlider.minValue, frame.autoUseItemsCDSlider.maxValue = frame.autoUseItemsCDSlider:GetMinMaxValues() 
    frame.autoUseItemsCDSlider.Low:SetText(frame.autoUseItemsCDSlider.minValue)
    frame.autoUseItemsCDSlider.High:SetText(frame.autoUseItemsCDSlider.maxValue)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame.autoUseItemsCDSlider.Text:GetPoint()
    frame.autoUseItemsCDSlider.Text:SetPoint("TOP", relativeTo, "BOTTOM", 0, -25)
    frame.autoUseItemsCDSlider.Text:SetText("sdd")
    frame.autoUseItemsCDSlider:SetValue(15)
    frame.autoUseItemsCDSlider:SetValueStep(1)
    frame.autoUseItemsCDSlider.Text2 = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.autoUseItemsCDSlider.Text2:SetPoint("LEFT", frame.autoUseItemsCDSlider, "RIGHT", 15, 0)
    frame.autoUseItemsCDSlider.Text2:SetText(addon.L["(0 to disable auto-fade)"])

    frame.ProfilesConfigText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLargeLeft")
    frame.ProfilesConfigText:SetText(addon.L["Profiles for instance auto-change:"])
    frame.ProfilesConfigText:SetPoint("TOPLEFT", frame.autoUseItemsCDSlider.Low, "BOTTOMLEFT", -13, -10)

    frame.ArenaText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.ArenaText:SetPoint("TOPLEFT", frame.ProfilesConfigText, "BOTTOMLEFT", 0, -20)
    frame.ArenaText:SetText(addon.L["Arenas"] .. ":")
    frame.ArenaText.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.ArenaText.DropDownMenu:SetPoint("LEFT", frame.ArenaText, "RIGHT", 0, -5)
    UIDropDownMenu_SetWidth(frame.ArenaText.DropDownMenu, 200)


    frame.BattlegroundText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.BattlegroundText:SetPoint("TOPLEFT", frame.ArenaText, "BOTTOMLEFT", 0, -20)
    frame.BattlegroundText:SetText(addon.L["Battlegrounds"]..":")
    frame.BattlegroundText.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.BattlegroundText.DropDownMenu:SetPoint("LEFT", frame.BattlegroundText, "RIGHT", 0, -5)
    UIDropDownMenu_SetWidth(frame.BattlegroundText.DropDownMenu, 200)


    frame.RaidText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.RaidText:SetPoint("TOPLEFT", frame.BattlegroundText, "BOTTOMLEFT", 0, -20)
    frame.RaidText:SetText(addon.L["Raid"] .. ":")
    frame.RaidText.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.RaidText.DropDownMenu:SetPoint("LEFT", frame.RaidText, "RIGHT", 0, -5)
    UIDropDownMenu_SetWidth(frame.RaidText.DropDownMenu, 200)


    frame.Party = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.Party:SetPoint("TOPLEFT", frame.RaidText, "BOTTOMLEFT", 0, -20)
    frame.Party:SetText(addon.L["Party"] .. ":")


    frame.Party.HC = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.Party.HC:SetPoint("TOPLEFT", frame.Party, "BOTTOMLEFT", 30, -10)
    frame.Party.HC:SetText(addon.L["Heroic"] .. ":")
    frame.Party.HC.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.Party.HC.DropDownMenu:SetPoint("LEFT", frame.Party.HC, "RIGHT", 0, -5)
    UIDropDownMenu_SetWidth(frame.Party.HC.DropDownMenu, 200)


    frame.Party.MM = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.Party.MM:SetPoint("TOPLEFT", frame.Party.HC, "BOTTOMLEFT", 0, -20)
    frame.Party.MM:SetText(addon.L["Mythic"] .. ":")
    frame.Party.MM.DropDownMenu = CreateFrame("FRAME", nil, frame, "UIDropDownMenuTemplate")
    frame.Party.MM.DropDownMenu:SetPoint("LEFT", frame.Party.MM, "RIGHT", 0, -5)
    UIDropDownMenu_SetWidth(frame.Party.MM.DropDownMenu, 200)


    --Hide the frame by default
    frame:Hide()
    --Return the frame
    return frame
end

function ConfigFrame:ToggleFrame()
    addon.ConfigFrame.Frame = addon.ConfigFrame.Frame or CreateConfigFrame()
    addon.ConfigFrame.Frame:SetShown(not addon.ConfigFrame.Frame:IsShown())
end

--##########################################################################################################################
--                                  Sub-Functions
--##########################################################################################################################



--##########################################################################################################################
--                                  Helper functions
--##########################################################################################################################