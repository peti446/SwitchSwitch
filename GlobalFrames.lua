--############################################
-- Namespace
--############################################
local _, addon = ...

--Set up frame helper gobal tables
addon.GlobalFrames = {}
local GlobalFrames = addon.GlobalFrames


--##########################################################################################################################
--                                  Frames Init
--##########################################################################################################################
function GlobalFrames:Init()
    --Secure Action button to use item
    GlobalFrames.UseTome = CreateFrame("Button", "SS_ButtonUseTomePopup", UIParent, "UIPanelButtonTemplate, SecureActionButtonTemplate")
    GlobalFrames.UseTome:SetAttribute("type", "item")
    GlobalFrames.UseTome:Hide()

    --Popup to notify the user if they want the addon to automaticly use a tome
    StaticPopupDialogs["SwitchSwitch_ConfirmTomeUsage"] =
    {
        text = addon.L["Do you want to use a tome to change talents?"],
        button1 = addon.L["Yes"],
        button2 = addon.L["No"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        exclusive = true,
        enterClicksFirstButton = true,
        OnShow = function(self) 
            --Wellll as there is no build-in way to have secure button as part of a static popuop we need to replace the buttons shig
            -- so we do
            self.insertedFrame:SetParent(self)
            self.insertedFrame:ClearAllPoints()
            self.insertedFrame:SetPoint(self.button1:GetPoint())
            self.insertedFrame:SetWidth(self.button1:GetWidth())
            self.insertedFrame:SetHeight(self.button1:GetHeight())
            self.insertedFrame:SetText(self.button1:GetText())
            self.insertedFrame:SetScript("PostClick", function() self.button1:Click() end)
            self.insertedFrame:Show()
            self.button1:Hide()
         end,
        OnAccept = function(self, data)
            --Execute it after a timer so that the the call is not executed when we still dont have the buff as it takes time to activate
            C_Timer.After(1, function() data.callback(addon:ActivateTalentProfile(data.name)) end)
            self.insertedFrame:Hide()
        end,
        OnCancel = function(self, data)
            --Make sure everything works fine and gets disabled properly
            data.callback(false)
            self.insertedFrame:Hide()
        end
    }
end


function GlobalFrames:ToggleSuggestionFrame(profileToActivate)
    if(not profileToActivate or not addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))] or not addon.sv.Talents.TalentsProfiles[select(1,GetSpecializationInfo(GetSpecialization()))][profileToActivate]) then
        addon:Debug("Could not open 'Sugestion frame' as either the profile is null or does not exist")
        return
    end
    GlobalFrames.ProfileSuggestion = GlobalFrames.ProfileSuggestion or CreateSuggestionFrame()
    GlobalFrames.ProfileSuggestion.ChangePorfileButton.Porfile = profileToActivate
    GlobalFrames.ProfileSuggestion:Show()
end

local function CreateSuggestionFrame()
    --Frame for auto porfile sugestor in instance
    GlobalFrames.ProfileSuggestion = CreateFrame("FRAME", "SS_SuggestionFrame", UIParent, "InsetFrameTemplate3")
    GlobalFrames.ProfileSuggestion:SetPoint(addon.sv.config.SuggestionFramePoint.point, UIParent, addon.sv.config.SuggestionFramePoint.relativePoint, addon.sv.config.SuggestionFramePoint.frameX, addon.sv.config.SuggestionFramePoint.frameY)
    GlobalFrames.ProfileSuggestion:SetSize(300, 100)
    --Add the first text tp notify the user what talent we ar about to change
    GlobalFrames.ProfileSuggestion.InfoText = GlobalFrames.ProfileSuggestion:CreateFontString(nil, "ARTWORK", "GameFontWhite") 
    GlobalFrames.ProfileSuggestion.InfoText:SetPoint("TOPLEFT", GlobalFrames.ProfileSuggestion, "TOPLEFT", 10, -10)
    GlobalFrames.ProfileSuggestion.InfoText:SetPoint("TOPRIGHT", GlobalFrames.ProfileSuggestion, "TOPRIGHT", -10, -10)
    GlobalFrames.ProfileSuggestion.InfoText:SetText(addon.L["Would you like to change you talents to %s?"])
    --Add the text to let the user know how long until auto closo of the frame
    GlobalFrames.ProfileSuggestion.RemainingText = GlobalFrames.ProfileSuggestion:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    GlobalFrames.ProfileSuggestion.RemainingText:SetPoint("BOTTOMLEFT", GlobalFrames.ProfileSuggestion, "BOTTOMLEFT", 10, 10)
    GlobalFrames.ProfileSuggestion.RemainingText:SetPoint("BOTTOMRIGHT", GlobalFrames.ProfileSuggestion, "BOTTOMRIGHT", -10, 10)
    GlobalFrames.ProfileSuggestion.RemainingText:SetText(addon.L["Frame will close after %d seconds..."])
    --Add Buttons for the frame
    --Change button
    GlobalFrames.ProfileSuggestion.ChangePorfileButton = CreateFrame("BUTTON", "SS_SuggestionFrameChangeButton", GlobalFrames.ProfileSuggestion, "UIPanelButtonTemplate")
    GlobalFrames.ProfileSuggestion.ChangePorfileButton:SetPoint("LEFT", GlobalFrames.ProfileSuggestion, "LEFT", 10, -5)
    GlobalFrames.ProfileSuggestion.ChangePorfileButton:SetSize(125, 40)
    GlobalFrames.ProfileSuggestion.ChangePorfileButton:SetText(addon.L["Change!"])
    --Cancel button to close the frame up
    GlobalFrames.ProfileSuggestion.CancelButton = CreateFrame("BUTTON", "SS_SuggestionCancelButton", GlobalFrames.ProfileSuggestion, "UIPanelButtonTemplate")
    GlobalFrames.ProfileSuggestion.CancelButton:SetPoint("RIGHT", GlobalFrames.ProfileSuggestion, "RIGHT", -10, -5)
    GlobalFrames.ProfileSuggestion.CancelButton:SetSize(125, 40)
    GlobalFrames.ProfileSuggestion.CancelButton:SetText(addon.L["Cancel"])

    --Set the buttons functions
    --Cancel button
    GlobalFrames.ProfileSuggestion.CancelButton:SetScript("OnClick", function(self)  self:GetParent():Hide() end)
    --Change button
    GlobalFrames.ProfileSuggestion.ChangePorfileButton:SetScript("OnClick", function(self)
        addon:ActivateTalentProfileCallback(self.Porfile, function(changed)
            if(changed) then
                addon.sv.Talents.SelectedTalentsProfile = self.Profile
                if(addon.TalentUIFrame.UpperTalentsUI and type(addon.TalentUIFrame.UpperTalentsUI) == "table") then
                    addon.TalentUIFrame.UpperTalentsUI.DeleteButton:Enable()
                    UIDropDownMenu_SetSelectedValue(addon.TalentUIFrame.UpperTalentsUI.DropDownTalents, self.Profile)
                end
            end
        end)
    end)

    --Make the frame moveable
    GlobalFrames.ProfileSuggestion:SetMovable(true);
    GlobalFrames.ProfileSuggestion:EnableMouse(true);
    GlobalFrames.ProfileSuggestion:RegisterForDrag("LeftButton");
    GlobalFrames.ProfileSuggestion:SetScript("OnDragStart", GlobalFrames.ProfileSuggestion.StartMoving);
    GlobalFrames.ProfileSuggestion:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing();
            point1, _, relativePoint1, xOfs, yOfs = self:GetPoint(1);
            addon.sv.config.SuggestionFramePoint.point = point1;
            addon.sv.config.SuggestionFramePoint.relativePoint = relativePoint1;
            addon.sv.config.SuggestionFramePoint.frameX = xOfs;
            addon.sv.config.SuggestionFramePoint.frameY = yOfs;
    end);

    -- Add update to the frame so it can dissaper after a certain time
    GlobalFrames.ProfileSuggestion:Setscript("OnShow", function(self)
        self.ElapsedTime = 0
    end)
    GlobalFrames.ProfileSuggestion:SetScript("OnUpdate", function(self, elapsed)
        self.ElapsedTime = self.ElapsedTime + elapsed
        self.RemainingText:SetText(addon.L["Frame will close after %s seconds..."]:format(string.format("%.0f",ElapsedTime)))
        if(self.ElapsedTime >= addon.sv.config.maxTimeSuggestionFrame) then
            self:Hide()
        end
    end)

    --Hide the frame by default
    GlobalFrames.ProfileSuggestion:Hide()
end