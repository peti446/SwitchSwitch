--############################################
-- Namespace
--############################################
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local SuggestionFrame

--##########################################################################################################################
--                                  Frames Init
--##########################################################################################################################
local function CreateSuggestionFrame()
    --Frame for auto profile sugestor in instance
    local frame = CreateFrame("FRAME", "SS_SuggestionFrame", UIParent, "InsetFrameTemplate3")
    frame:SetPoint(SwitchSwitch.dbpc.char.talentsSuggestionFrame.location.point, UIParent, SwitchSwitch.dbpc.char.talentsSuggestionFrame.location.relativePoint, SwitchSwitch.dbpc.char.talentsSuggestionFrame.location.frameX, SwitchSwitch.dbpc.char.talentsSuggestionFrame.location.frameY)
    frame:SetSize(300, 100)
    --Add the first text tp notify the user what talent we ar about to change
    frame.InfoText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite") 
    frame.InfoText:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    frame.InfoText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    frame.InfoText:SetText("PLACEHOLDER")
    --Add the text to let the user know how long until auto closo of the frame
    frame.RemainingText = frame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    frame.RemainingText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    frame.RemainingText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    frame.RemainingText:SetText("PLACEHOLDER")
    --Add Buttons for the frame
    --Change button
    frame.ChangeProfileButton = CreateFrame("BUTTON", "SS_SuggestionFrameChangeButton", frame, "UIPanelButtonTemplate")
    frame.ChangeProfileButton:SetPoint("LEFT", frame, "LEFT", 10, -5)
    frame.ChangeProfileButton:SetSize(125, 40)
    frame.ChangeProfileButton:SetText(L["Change!"])
    --Cancel button to close the frame up
    frame.CancelButton = CreateFrame("BUTTON", "SS_SuggestionCancelButton", frame, "UIPanelButtonTemplate")
    frame.CancelButton:SetPoint("RIGHT", frame, "RIGHT", -10, -5)
    frame.CancelButton:SetSize(125, 40)
    frame.CancelButton:SetText(L["Cancel"])

    --Set the buttons functions
    --Cancel button
    frame.CancelButton:SetScript("OnClick", function(self)  self:GetParent():Hide() end)
    --Change button
    frame.ChangeProfileButton:SetScript("OnClick", function(self)
        SwitchSwitch:DebugPrint("Clicked change talents to recomended: " .. self.Profile)
        SwitchSwitch:ActivateTalentProfile(self.Profile)
        self:GetParent():Hide()
    end)

    --Make the frame moveable
    frame:SetMovable(true);
    frame:EnableMouse(true);
    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", frame.StartMoving);
    frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing();
            point1, _, relativePoint1, xOfs, yOfs = self:GetPoint(1);
            SwitchSwitch.dbpc.char.talentsSuggestionFrame.location.point = point1;
            SwitchSwitch.dbpc.char.talentsSuggestionFrame.location.relativePoint = relativePoint1;
            SwitchSwitch.dbpc.char.talentsSuggestionFrame.location.frameX = xOfs;
            SwitchSwitch.dbpc.char.talentsSuggestionFrame.location.frameY = yOfs;
    end);

    -- Add update to the frame so it can dissaper after a certain time
    frame:SetScript("OnShow", function(self)
        self.ElapsedTime = 0
        self.InfoText:SetText(L["Would you like to change you talents to %s?"]:format(self.ChangeProfileButton.Profile))
        --If no time is given then hide the text
        if(SwitchSwitch.dbpc.char.talentsSuggestionFrame.fadeTime == 0) then
            self.RemainingText:Hide()
        else 
            self.RemainingText:Show()
        end
    end)
    frame:SetScript("OnUpdate", function(self, elapsed)
        --If the max time is 0 then not update anything
        if(SwitchSwitch.dbpc.char.talentsSuggestionFrame.fadeTime == 0) then
            return
        end
        --Update elapsed time and string
        self.ElapsedTime = self.ElapsedTime + elapsed
        self.RemainingText:SetText(L["Frame will close after %s seconds..."]:format(string.format("%.0f",SwitchSwitch.dbpc.char.talentsSuggestionFrame.fadeTime - self.ElapsedTime)))
        --If the time given passed hide
        if(self.ElapsedTime >= SwitchSwitch.dbpc.char.talentsSuggestionFrame.fadeTime) then
            self:Hide()
        end
    end)
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event =="PLAYER_REGEN_DISABLED" then
            self:Hide()
        end
        self:UnregisterEvent(event)
    end)

    --Debuging text
    SwitchSwitch:DebugPrint("Created Suggestion frame!")

    --Hide the frame by default
    frame:Hide()

    return frame
end


function SwitchSwitch:ToggleSuggestionFrame(profileToActivate)
    --First check if the profile is valid and exists
    if(not profileToActivate or profileToActivate == "" or not self:DoesProfileExits(profileToActivate)) then
        self:DebugPrint("Could not open 'Sugestion frame' as either the profile is null or does not exist")
        return
    end
    self:DebugPrint("Showing Toggle suggestion frame with profile: " .. profileToActivate)
    --Set the frame or create it, set data and show the frame.
    SuggestionFrame = SuggestionFrame or CreateSuggestionFrame()
    SuggestionFrame.ChangeProfileButton.Profile = profileToActivate
    SuggestionFrame:Show()
end