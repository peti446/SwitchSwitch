local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

-- Private variables
local LastInstanceID = -1

function SwitchSwitch:ADDON_LOADED(event, arg1)
    if(arg1 == "Blizzard_TalentUI") then
        self:PLAYER_SPECIALIZATION_CHANGED()
        self:HookScript(PlayerTalentFrame, "OnShow", "EmbedUIIntoTalentFrame")
        return
    end
end

function SwitchSwitch:PLAYER_SPECIALIZATION_CHANGED(units)
    if(not IsAddOnLoaded("Blizzard_TalentUI")) then
        LoadAddOn("Blizzard_TalentUI")
        return
    end

    if(type(units) == "table" and units["player"] == nil) then
        return
    end

    local playerSpec = SwitchSwitch:GetCurrentSpec()
    if(playerSpec ==  self.lastUpdatePlayerSpec) then
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
    self.CurrentActiveTalentsProfile = self:GetCurrentActiveProfile()
    self:RefreshTalentUI()
    if(type(units) ~= "boolean" or not units) then
        return
    end

    -- If we reach here its means
    self:RefreshProfilesEditorPage()
    self:RefreshTalentsSuggestionUI()
    self:RefreshExportUI()
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
    end

    if(suggestedProfileName ~= nil) then
        if(suggestedProfileName ~= self.CurrentActiveTalentsProfile) then
            self:ToggleSuggestionFrame(suggestedProfileName)
        end
    end
end