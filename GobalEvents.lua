local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

-- Private variables
local LastInstanceID = -1

function SwitchSwitch:ADDON_LOADED(event, arg1)
    if(arg1 == "Blizzard_ClassTalentUI") then
        self:PLAYER_SPECIALIZATION_CHANGED()
        self:HookScript(ClassTalentFrame, "OnShow", "EmbedUIIntoTalentFrame")
        return
    end
end

function SwitchSwitch:PLAYER_SPECIALIZATION_CHANGED(units)
    if(not IsAddOnLoaded("Blizzard_ClassTalentUI")) then
        LoadAddOn("Blizzard_ClassTalentUI")
        return
    end

    if(type(units) == "table" and units["player"] == nil) then
        return
    end

    local playerSpec = SwitchSwitch:GetCurrentSpec()
    if(playerSpec == self.lastUpdatePlayerSpec) then
        return
    end
    self.lastUpdatePlayerSpec = playerSpec

    if(type(SwitchSwitch.TalentsData) ~= "table") then
        SwitchSwitch.TalentsData = {}
    end
    SwitchSwitch.TalentsData[playerSpec] = {}
    local spec = GetActiveSpecGroup()
    for row=1,MAX_TALENT_TIERS do
        SwitchSwitch.TalentsData[playerSpec][row] = {}
        local tierAvailable, selectedTalent, tierUnlockLevel = GetTalentTierInfo(row, spec)

        SwitchSwitch.TalentsData[playerSpec][row]["requiredLevel"] = tierUnlockLevel
        SwitchSwitch.TalentsData[playerSpec][row]["data"] = {}
        for column=1,NUM_TALENT_COLUMNS do
            local talentID, name, texture, _, _, spellID = GetTalentInfo(row, column, spec)
            SwitchSwitch.TalentsData[playerSpec][row]["data"][column] =
            {
                ["talentID"] = talentID,
                ["textureID"] = texture,
                ["spellID"] = spellID,
                ["name"] = name
            }
        end
    end

    --Update all the UI that is dependend on spec
    self:PLAYER_TALENT_UPDATE(true)
end

-- When true is passed in we will only update the current active profile,
-- other wise do full update if the player is changing talents or the talbe is null (manually called)
function SwitchSwitch:PLAYER_TALENT_UPDATE(units)
    local tempActiveProfile = self.CurrentActiveTalentsProfile
    self.CurrentActiveTalentsProfile = self:GetCurrentActiveProfile()
    if(self.CurrentActiveTalentsProfile ~= tempActiveProfile) then
        self:SendMessage("SWITCHSWITCH_CURRENT_TALENT_PROFILE_UPDATED")
        self:UpdateLDBText()
        self:RefreshTalentUI()
    end
    if(type(units) ~= "boolean" or not units) then
        return
    end

    -- If we reach here its means
    self:RefreshProfilesEditorPage()
    self:RefreshTalentsSuggestionUI()
    self:RefreshExportUI()
end


function SwitchSwitch:SWITCHSWITCH_INSTANCE_TYPE_DETECTED(event_name, contentType)
    if(SwitchSwitch:GetProfilesSuggestionInstanceData(contentType)["all"] ~= nil) then
        if(SwitchSwitch:GetProfilesSuggestionInstanceData(contentType)["all"] ~= self.CurrentActiveTalentsProfile) then
            self:ToggleSuggestionFrame(SwitchSwitch:GetProfilesSuggestionInstanceData(contentType)["all"])
        end
    end
end


function SwitchSwitch:SWITCHSWITCH_BOSS_DETECTED(event_name, instanceID, difficultyID, npcID)
    local allSuggestionsForInstance = self:GetProfilesSuggestionInstanceData(instanceID)
    local suggestedProfileName = nil
    if(npcID ~= nil) then
        -- We are in npc zone or mousovered it
        if(allSuggestionsForInstance["bosses"] ~= nil) then
            suggestedProfileName = allSuggestionsForInstance["bosses"][npcID]
        end
    else
        -- We entered an instance !!
        if(allSuggestionsForInstance["difficulties"] ~= nil) then
            suggestedProfileName = allSuggestionsForInstance["difficulties"][difficultyID]
        end
        -- If we are in mythic/mythic+ we want to see the week specific data
        if(difficultyID == self.PreMythicPlusDificulty and allSuggestionsForInstance["mythic+"] ~= nil and allSuggestionsForInstance["mythic+"][self:GetCurrentWeeksMythicID()] ~= nil) then
            suggestedProfileName = allSuggestionsForInstance["mythic+"][self:GetCurrentWeeksMythicID()]
        end
    end

    if(suggestedProfileName ~= nil) then
        if(suggestedProfileName ~= self.CurrentActiveTalentsProfile) then
            self:ToggleSuggestionFrame(suggestedProfileName)
        end
    end
end