--############################################
-- Namespace
--############################################
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local SuggestionFrame
--##########################################################################################################################
--                                  Frames Init
--##########################################################################################################################
local function CreateSuggestionFrame(profileName)
    local frame = AceGUI:Create("Window")
    local frameLocation = SwitchSwitch.db.profile.talentsSuggestionFrame.location
    frame:SetPoint(frameLocation.point, UIParent, frameLocation.relativePoint, frameLocation.frameX, frameLocation.frameY)
    frame:SetLayout("Flow")
    frame:SetWidth(275)
    frame:SetHeight(150)
    frame:SetTitle(L["Talents Suggestion"])
    frame:EnableResize(false)

    local descriptionLabel = AceGUI:Create("Label")
    descriptionLabel:SetFullWidth(true)
    descriptionLabel:SetText(L["Would you like to activate the profile '%s?'"]:format(profileName) .. "\n\n")
    descriptionLabel:SetFontObject(GameFontWhite)
    descriptionLabel:SetJustifyH("CENTER")
    frame:AddChild(descriptionLabel)

    local remainingLabel
    if(SwitchSwitch.db.profile.talentsSuggestionFrame.enabled) then
        remainingLabel = AceGUI:Create("Label")
        remainingLabel:SetFullWidth(true)
        remainingLabel:SetFontObject(GameFontWhite)
        remainingLabel:SetText(L["Closing in %s seconds..."]:format(string.format("%.0f",SwitchSwitch.db.profile.talentsSuggestionFrame.fadeTime)) .. "\n\n")
        remainingLabel:SetJustifyH("CENTER")
        frame:AddChild(remainingLabel)
    else
        frame:SetHeight(125)
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Table")
    buttonGroup:SetFullWidth(true)
    buttonGroup:SetUserData("table", {
          columns = {125, 125},
          space = 2,
          align = "CENTER"
    })

    local acceptButton = AceGUI:Create("Button")
    acceptButton:SetText(L["Change Talents"])
    acceptButton:SetUserData("Parent", frame)
    acceptButton:SetUserData("ProfileName", profileName)
    acceptButton:SetCallback("OnClick", function(self)
        local profileName = self:GetUserData("ProfileName")
        SwitchSwitch:ActivateTalentProfile(profileName)
        self:GetUserData("Parent"):Hide()
    end)
    buttonGroup:AddChild(acceptButton);


    local cancelButton = AceGUI:Create("Button")
    cancelButton:SetText(L["Cancel"])
    cancelButton:SetUserData("Parent", frame)
    cancelButton:SetCallback("OnClick", function(self)
        self:GetUserData("Parent"):Hide()
    end)
    buttonGroup:AddChild(cancelButton)

    frame:AddChild(buttonGroup)

    frame:SetCallback("OnClose", function(frame)
        local point1, _, relativePoint1, xOfs, yOfs = frame:GetPoint(1);
        SwitchSwitch.db.profile.talentsSuggestionFrame.location.point = point1;
        SwitchSwitch.db.profile.talentsSuggestionFrame.location.relativePoint = relativePoint1;
        SwitchSwitch.db.profile.talentsSuggestionFrame.location.frameX = xOfs;
        SwitchSwitch.db.profile.talentsSuggestionFrame.location.frameY = yOfs;
        local timerID = frame:GetUserData("TimerID")
        if(timerID ~= nil) then
            SwitchSwitch:CancelTimer(timerID)
        end
        frame:Release()
        SuggestionFrame = nil
        SwitchSwitch:DebugPrint("Closing Suggestion Frame")
    end)

    if (SwitchSwitch.db.profile.talentsSuggestionFrame.enabled) then
        local fadeTimerId = SwitchSwitch:ScheduleRepeatingTimer(function(frame)
            frame:SetUserData("SecondsPassed", frame:GetUserData("SecondsPassed")+1)
            frame:GetUserData("TextToUpdate"):SetText(L["Closing in %s seconds..."]:format(string.format("%.0f",SwitchSwitch.db.profile.talentsSuggestionFrame.fadeTime - frame:GetUserData("SecondsPassed"))) .. "\n\n")
            if(frame:GetUserData("SecondsPassed") >= SwitchSwitch.db.profile.talentsSuggestionFrame.fadeTime) then
                frame:Hide()
            end
        end, 1.0, frame)
        frame:SetUserData("TimerID", fadeTimerId)
        frame:SetUserData("SecondsPassed", 0)
        frame:SetUserData("TextToUpdate", remainingLabel)
    end
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
    if(SuggestionFrame ~= nil) then
        SuggestionFrame:Hide()
    end
    SuggestionFrame = CreateSuggestionFrame(profileToActivate)
    SuggestionFrame:Show()
end