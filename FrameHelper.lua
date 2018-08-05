--############################################
-- Namespace
--############################################
local _, addon = ...

--Set up frame helper gobal tables
addon.FrameHelper = {}
local FrameHelper = addon.FrameHelper

--##########################################################################################################################
--                                  Frames Init
--##########################################################################################################################
--Creates the Frame inside the talent frame
function FrameHelper:CreateTalentFrameUI()
    --Check if we already created the frame, as WOW does not delete frames unless you reload, so we dont need to recreate it
    if(FrameHelper.TalentsUI ~= nil) then
        --Update the frame and add/remove porfiles as needed (using garbage collection for memory otimisation)
        --FrameHelper:UpdateTalentFrameUIComponents()
        return
    end
    --Create frame and hide it by default
    FrameHelper.UpperTalentsUI = CreateFrame("Frame", "SwitchSwitch_UpperTalentsUI", PlayerTalentFrameTalents)
    local UpperTalentsUI = FrameHelper.UpperTalentsUI
    UpperTalentsUI:SetPoint("TOPLEFT", PlayerTalentFrameTalents, "TOPLEFT", 60, 30)
    UpperTalentsUI:SetPoint("BOTTOMRIGHT", PlayerTalentFrameTalents, "TOPRIGHT", -110, 2)
    --talentsUI:Hide()
    --Create the new and save buttons
    UpperTalentsUI.SaveButton = FrameHelper:CreateButton("TOPRIGHT", UpperTalentsUI, UpperTalentsUI, "TOPRIGHT", addon.L["Save"], 80, nil, -10, -2)
    UpperTalentsUI.NewButton = FrameHelper:CreateButton("TOPRIGHT", UpperTalentsUI.SaveButton, UpperTalentsUI.SaveButton, "TOPLEFT", addon.L["New"], 80, nil, -5, 0) 
    
    --Create Talent string
    UpperTalentsUI.CurrentPorfie = UpperTalentsUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
    UpperTalentsUI.CurrentPorfie:SetText(addon.L["Talents"] .. ":")
    UpperTalentsUI.CurrentPorfie:SetPoint("LEFT")

    --Create Dropdown menu for talent groups
    UpperTalentsUI.DropDownTalents = CreateFrame("FRAME", "SwitchSwitch_UpperTalentsUI_Dropdown", UpperTalentsUI, "UIDropDownMenuTemplate")
    UpperTalentsUI.DropDownTalents:SetPoint("LEFT", UpperTalentsUI.CurrentPorfie, "RIGHT", 0, -3)
    UIDropDownMenu_SetWidth(UpperTalentsUI.DropDownTalents, 200)
    UIDropDownMenu_Initialize(UpperTalentsUI.DropDownTalents, FrameHelper.Initialize_Talents_List)
end

--Creates the Configuration frame UI
function FrameHelper:CreateConfigFrame()

end

--##########################################################################################################################
--                                  Frames Component handler
--##########################################################################################################################
function FrameHelper.Initialize_Talents_List(dropDownFrame ,level, menuList)
    menuList = 
    {
        { 
            text = "test",
            checked = true,
        },
        { 
            text = "test4",
            checked = false,
        },
        { 
            text = "test5",
            checked = false,
        }
    }
	for index = 1, #menuList do
        local value = menuList[index]
		if (value.text) then
            value.index = index
            value.value = value.text
            value.arg1 = value.text
            value.func = UpperTalentsUI.DropDownTalents.SetDropDownValue
			UIDropDownMenu_AddButton( value, level )
		end
	end
end

function UpperTalentsUI.DropDownTalents:SetDropDownValue(TalentName)
    addon:Print(dropDownFrame)
    addon:Print(TalentName)
end


--##########################################################################################################################
--                                  Helper Functions
--##########################################################################################################################
function FrameHelper:CreateButton(point, parentFrame, relativeFrame, relativePoint, text, width, height, xOffSet, yOffSet, TextHeight)
    --Set defalt values in case not specified
    width = width or 100
    height = height or 20
    xOffSet = xOffSet or 0
    yOffSet = yOffSet or 0
    TextHeight = TextHeight or ""
    text = text or "Not specified"
    --Create the button and set their value
    local button = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
    button:SetPoint(point, relativeFrame, relativePoint, xOffSet, yOffSet)
    button:SetSize(width,height)
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal"..TextHeight)
    button:SetHighlightFontObject("GameFontHighlight"..TextHeight)
    --Return the button
    return button
end