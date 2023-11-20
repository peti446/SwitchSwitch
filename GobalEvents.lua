local SwitchSwitch = unpack(select(2, ...))

function SwitchSwitch:ADDON_LOADED(event, arg1)
    if(arg1 == "Blizzard_ClassTalentUI") then
        self:PLAYER_SPECIALIZATION_CHANGED()
  --      self:HookScript(ClassTalentFrame, "OnShow", "EmbedUIIntoTalentFrame")
        return
    end
end

function SwitchSwitch:PLAYER_SPECIALIZATION_CHANGED(_event, unitTarget)
    if(unitTarget ~= "player" or (type(unitTarget) == "table" and unitTarget["player"] == nil)) then
        return
    end

    local playerSpec = SwitchSwitch:GetCurrentSpec()
    if(playerSpec == self.lastUpdatePlayerSpec) then
        return
    end
    self.lastUpdatePlayerSpec = playerSpec

    --Update all the UI that is dependend on spec
    SwitchSwitch:RefreshCurrentConfigID()
end

-- When true is passed in we will only update the current active profile,
-- other wise do full update if the player is changing talents or the talbe is null (manually called)
function SwitchSwitch:TRAIT_CONFIG_UPDATED(_eventName, configID)
    if(SwitchSwitch.TalentsUpdate.UpdatePending == true and configID == C_ClassTalents.GetActiveConfigID()) then
        local pendingProfileID = SwitchSwitch.TalentsUpdate.PendingProfileID
        RunNextFrame(function()
            SwitchSwitch.TalentsUpdate.UpdatePending = false
            SwitchSwitch.TalentsUpdate.PendingProfileID = nil

            -- Lests update the UI as Blizzard does not do it by themselves
            C_ClassTalents.UpdateLastSelectedSavedConfigID(SwitchSwitch:GetCurrentSpec(), pendingProfileID);
            local _ = ClassTalentFrame
                and ClassTalentFrame.TalentsTab
                and ClassTalentFrame.TalentsTab.LoadoutDropDown
                and ClassTalentFrame.TalentsTab.LoadoutDropDown.SetSelectionID
                and ClassTalentFrame.TalentsTab.LoadoutDropDown:SetSelectionID(pendingProfileID)

            if(not InCombatLockdown() and ClassTalentFrame and ClassTalentFrame:IsShown()) then
                HideUIPanel(ClassTalentFrame);
                ShowUIPanel(ClassTalentFrame);
                SwitchSwitch:DebugPrint("class frame updated")
            end

            SwitchSwitch:RefreshCurrentConfigID()
        end)
    else
        RunNextFrame(function()
            SwitchSwitch:RefreshCurrentConfigID()
        end)
    end
end


function SwitchSwitch:SWITCHSWITCH_INSTANCE_TYPE_DETECTED(event_name, contentType)
    local allSuggestionsForInstance = self:GetProfilesSuggestionInstanceData(contentType)
    local suggestedProfileId = nil
    if(allSuggestionsForInstance ~= nil) then
        suggestedProfileId = allSuggestionsForInstance["all"]
    end

    if(suggestedProfileId ~= nil and suggestedProfileId ~= self.CurrentActiveTalentsConfigID) then
        self:ToggleSuggestionFrame(suggestedProfileId)
    end
end


function SwitchSwitch:SWITCHSWITCH_BOSS_DETECTED(event_name, instanceID, difficultyID, npcID)
    local allSuggestionsForInstance = self:GetProfilesSuggestionInstanceData(instanceID)
    local suggestedProfileId = nil
    if(npcID ~= nil) then
        -- We are in npc zone or mousovered it
        if(allSuggestionsForInstance["bosses"] ~= nil) then
            suggestedProfileId = allSuggestionsForInstance["bosses"][npcID]
        end
    else
        -- We entered an instance !!
        if(allSuggestionsForInstance["difficulties"] ~= nil) then
            suggestedProfileId = allSuggestionsForInstance["difficulties"][difficultyID]
        end

        -- If we are in mythic/mythic+ we want to see the week specific data
        local mythicPlusProfileId = self:GetMythicPlusProfileSuggestion(instanceID)
        if(difficultyID == self.PreMythicPlusDificulty and mythicPlusProfileId ~= nil) then
            suggestedProfileId = mythicPlusProfileId
        end
    end

    if(suggestedProfileId ~= nil) then
        if(suggestedProfileId ~= self.CurrentActiveTalentsConfigID) then
            self:ToggleSuggestionFrame(suggestedProfileId)
        end
    end
end