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

function SwitchSwitch:PLAYER_SPECIALIZATION_CHANGED()
    if(not IsAddOnLoaded("Blizzard_TalentUI")) then
        LoadAddOn("Blizzard_TalentUI")
        return
    end
    
    if(type(SwitchSwitch.TalentsData) ~= "table") then
        SwitchSwitch.TalentsData = {}
    end

    local playerSpec = SwitchSwitch:GetCurrentSpec()
    SwitchSwitch.TalentsData[playerSpec] = {}
    local spec = GetActiveSpecGroup()
    for row=1,MAX_TALENT_TIERS do
        SwitchSwitch.TalentsData[playerSpec][row] = {}
        local tierAvailable, selectedTalent, tierUnlockLevel = GetTalentTierInfo(row, spec)

        SwitchSwitch.TalentsData[playerSpec][row]["requiredLevel"] = tierUnlockLevel
        SwitchSwitch.TalentsData[playerSpec][row]["data"] = {}
        for column=1,NUM_TALENT_COLUMNS do
            local talentID, name, texture, selected, available, spellID, unknown, row, column, known, grantedByAura = GetTalentInfo(row, column, spec)
            SwitchSwitch.TalentsData[playerSpec][row]["data"][column] = 
            {
                ["talentID"] = talentID,
                ["textureID"] = texture,
                ["spellID"] = spellID,
                ["name"] = name
            }
        end
    end
end

function SwitchSwitch:PLAYER_TALENT_UPDATE(onlyActiveUpdate)
    self.CurrentActiveTalentsProfile = self:GetCurrentActiveProfile()
    if(type(onlyActiveUpdate) == "boolean" and onlyActiveUpdate == true) then
        return
    end
    self:RefreshTalentUI()
    self:RefreshProfilesEditorPage()
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