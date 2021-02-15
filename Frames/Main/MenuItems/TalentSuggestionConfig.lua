local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local TalentsSuggestionPage = SwitchSwitch:RegisterMenuEntry(L["Talents Suggestion"])
local treeGroup, CurrentSelectedPath

local function OnPVPDownGroupSelected(frame, _, group)
    local pvpType = frame:GetUserData("PVP")

    if(group == "None") then
        group = nil
    end

    local data = SwitchSwitch:GetProfilesSuggestionInstanceData("arena")
    data["all"] = group
    SwitchSwitch:GetModule("BossDetection"):SetDetectingInstanceTypeEnabled(pvpType, group ~= nil)
end

local function OnDropDownGroupSelectedForType(frame, _, group)
    local DifficultyID = frame:GetUserData("DifficultyID")
    local Expansion = frame:GetUserData("Expansion")
    local ContentType = frame:GetUserData("ContentType")
    local mythicID = frame:GetUserData("mythicID")

    if(group == "None") then
        group = nil
    end

    if(mythicID ~= nil) then
        for JurnalInstanceID, instanceData in pairs(SwitchSwitch.InstancesBossData[Expansion][ContentType]) do
            if(instanceData["hasMythic+"] == true) then
                local savedSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData.instanceID)
                savedSuggestions["mythic+"] = savedSuggestions["mythic+"] or {}
                savedSuggestions["mythic+"][mythicID] = group
                local difficultyData = savedSuggestions["difficulties"] or {}
                -- Register or unregister
                SwitchSwitch:GetModule("BossDetection"):SetDetectionForInstanceEnabled(instanceData.instanceID, DifficultyID, group ~= nil or difficultyData[SwitchSwitch.PreMythicPlusDificulty] ~= nil)
            end
        end
    else
        for JurnalInstanceID, instanceData in pairs(SwitchSwitch.InstancesBossData[Expansion][ContentType]) do
            if(SwitchSwitch:table_has_value(SwitchSwitch.InstancesBossData[Expansion][ContentType][JurnalInstanceID]["difficulties"], DifficultyID)) then
                local savedSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData.instanceID)
                savedSuggestions["difficulties"] = savedSuggestions["difficulties"] or {}
                savedSuggestions["difficulties"][DifficultyID] = group
                local mythicPlusData  = savedSuggestions["mythic+"] or {}
                -- Register or unregister
                SwitchSwitch:GetModule("BossDetection"):SetDetectionForInstanceEnabled(instanceData.instanceID, DifficultyID, group ~= nil or next(mythicPlusData, nil) ~= nil)
            end
        end
    end
end

local function OnDropDownGroupSelected(frame, _, group)
    local InstanceID = frame:GetUserData("InstanceID")
    local DifficultyID = frame:GetUserData("DifficultyID")
    local npcID = frame:GetUserData("npcID")
    local mythicplusID = frame:GetUserData("mythicID")
    local Expansion = frame:GetUserData("Expansion")
    local ContentType = frame:GetUserData("ContentType")
    local JurnalInstanceID = frame:GetUserData("JurnalInstanceID")
    local savedSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(InstanceID)
    local bossRegisterData = SwitchSwitch.InstancesBossData[Expansion][ContentType][JurnalInstanceID]["bossData"]

    -- If group is settet to none we consider it as nill
    if(group == "None") then
        group = nil
    end

    -- If the NPCID is set it means we are setting a boss value other wise its the whole instance data
    if(npcID ~= nil) then
        savedSuggestions["bosses"] = savedSuggestions["bosses"] or {}
        savedSuggestions["bosses"][npcID] = group
        SwitchSwitch:GetModule("BossDetection"):SetDetectionForBossEnabled(npcID, InstanceID, group ~= nil)
    elseif(mythicplusID ~= nil) then
        savedSuggestions["mythic+"]  = savedSuggestions["mythic+"] or {}
        savedSuggestions["mythic+"][mythicplusID] = group
        local difficultyData = savedSuggestions["difficulties"] or {}
        SwitchSwitch:GetModule("BossDetection"):SetDetectionForInstanceEnabled(InstanceID, SwitchSwitch.PreMythicPlusDificulty, group ~= nil or difficultyData[SwitchSwitch.PreMythicPlusDificulty] ~= nil)
    else
        savedSuggestions["difficulties"] = savedSuggestions["difficulties"] or {}
        savedSuggestions["difficulties"][DifficultyID] = group
        local mythicPlusData = savedSuggestions["mythic+"] or {}
        SwitchSwitch:GetModule("BossDetection"):SetDetectionForInstanceEnabled(InstanceID, DifficultyID, group ~= nil or next(mythicPlusData, nil) ~= nil)
    end
end

local function DrawDificultiesSection(frame, expansion, contentType, jurnalInstanceID, validProfilesList)
    if(SwitchSwitch.InstancesBossData[expansion] == nil
        or SwitchSwitch.InstancesBossData[expansion][contentType] == nil
        or SwitchSwitch.InstancesBossData[expansion][contentType][jurnalInstanceID] == nil) then
        return
    end

    local instanceData = SwitchSwitch.InstancesBossData[expansion][contentType][jurnalInstanceID]
    local savedProfileSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData["instanceID"])
    if(type(instanceData["difficulties"]) ~= "table" or next(instanceData["difficulties"], nil) == nil) then
        return
    end

    -- Renader header
    frame:AddChild(TalentsSuggestionPage:CreateHeader(L["On Enter Instance"]))
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetText(L["Will suggest a talent build when entering the instance in a specific difficulty."])
    frame:AddChild(label)

    -- Render all bosse dropbox
    for _, id in ipairs(instanceData["difficulties"]) do
        local dropDown = AceGUI:Create("Dropdown")
        dropDown:SetLabel(SwitchSwitch.DificultyStrings[id])
        dropDown:SetUserData("InstanceID", instanceData["instanceID"])
        dropDown:SetUserData("DifficultyID", id)
        dropDown:SetUserData("Expansion", expansion)
        dropDown:SetUserData("ContentType", contentType)
        dropDown:SetUserData("JurnalInstanceID", jurnalInstanceID)
        dropDown.alignoffset = 15
        dropDown:SetList(validProfilesList)
        local setValue = "None"
        if(savedProfileSuggestions ~= nil and savedProfileSuggestions["difficulties"] ~= nil and savedProfileSuggestions["difficulties"][id] ~= nil) then
            setValue = savedProfileSuggestions["difficulties"][id]
        end
        dropDown:SetValue(setValue)
        dropDown:SetCallback("OnValueChanged", OnDropDownGroupSelected)
        frame:AddChild(dropDown)
    end
end

local function DrawBossesSection(frame, expansion, contentType, jurnalInstanceID, validProfilesList)
    if(SwitchSwitch.InstancesBossData[expansion] == nil
        or SwitchSwitch.InstancesBossData[expansion][contentType] == nil
        or SwitchSwitch.InstancesBossData[expansion][contentType][jurnalInstanceID] == nil) then
        return
    end

    local instanceData = SwitchSwitch.InstancesBossData[expansion][contentType][jurnalInstanceID]
    local savedProfileSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData["instanceID"])
    if(type(instanceData["bossData"]) ~= "table" or next(instanceData["bossData"], nil) == nil) then
        return
    end

    -- Render header
    frame:AddChild(TalentsSuggestionPage:CreateHeader(L["Profiles per boss"]))
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetText(L["Allows you to set specific talents build when mouse hovering a boss in the instance, set to none to disable for specific boss."])
    frame:AddChild(label)

    -- Render boss data
    for npcID, bossData in pairs(instanceData["bossData"]) do
        local name = EJ_GetEncounterInfo(bossData.ecnounterID)
        local dropDown = AceGUI:Create("Dropdown")
        dropDown:SetLabel(name)
        dropDown:SetUserData("InstanceID", instanceData["instanceID"])
        dropDown:SetUserData("Expansion", expansion)
        dropDown:SetUserData("ContentType", contentType)
        dropDown:SetUserData("JurnalInstanceID", jurnalInstanceID)
        dropDown:SetUserData("npcID", npcID)
        dropDown.alignoffset = 15
        dropDown:SetList(validProfilesList)
        local setValue = "None"
        if(savedProfileSuggestions ~= nil and savedProfileSuggestions["bosses"] ~= nil and savedProfileSuggestions["bosses"][npcID] ~= nil) then
            setValue = savedProfileSuggestions["bosses"][npcID]
        end
        dropDown:SetValue(setValue)
        dropDown:SetCallback("OnValueChanged", OnDropDownGroupSelected)
        frame:AddChild(dropDown)
    end
end

local function DrawMythicPlusSection(frame, expansion, contentType, jurnalInstanceID, validProfilesList)
    if(SwitchSwitch.InstancesBossData[expansion] == nil
        or SwitchSwitch.InstancesBossData[expansion][contentType] == nil
        or SwitchSwitch.InstancesBossData[expansion][contentType][jurnalInstanceID] == nil) then
        return
    end

    local instanceData = SwitchSwitch.InstancesBossData[expansion][contentType][jurnalInstanceID]
    local savedProfileSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData["instanceID"])
    if(instanceData["hasMythic+"] == true) then
        -- Render header
        frame:AddChild(TalentsSuggestionPage:CreateHeader(L["Profiles per Mythic+ Week"]))
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        label:SetText(L["Allows to suggest a talent profile based on the current weeks affixes when entering a instance in mythic difficulty (before starting the key)"].. ".\n" .. L["If any value below is set to none the fallback `%s` will be used for that week"]:format(SwitchSwitch.DificultyStrings[SwitchSwitch.PreMythicPlusDificulty]) .. ".")
        frame:AddChild(label)

        -- Sort the week data so that it always appers in same order as ID are all over the palce
        local currentSeasonData = {}
        for compressedID, label in pairs(SwitchSwitch.MythicPlusAffixes[C_MythicPlus.GetCurrentSeason()] or {}) do
            currentSeasonData[tonumber(select(1,string.match( label,L["Week"] .. " (%d+) %(.+")))] = {compressedID,label}
        end

        --Render dropboxes
        local currentWeekID = SwitchSwitch:GetCurrentWeeksMythicID()
        for i, packedData in ipairs(currentSeasonData) do
            local compressedID, label = unpack(packedData)
            local dropDown = AceGUI:Create("Dropdown")
            local labelText = label;
            if(compressedID == currentWeekID) then
                labelText = "|cFF00FF00" .. label .. "|r"
            end
            dropDown:SetLabel(labelText)
            dropDown:SetUserData("InstanceID", instanceData["instanceID"])
            dropDown:SetUserData("Expansion", expansion)
            dropDown:SetUserData("ContentType", contentType)
            dropDown:SetUserData("JurnalInstanceID", jurnalInstanceID)
            dropDown:SetUserData("mythicID", compressedID)
            dropDown.alignoffset = 25
            dropDown:SetList(validProfilesList)
            local setValue = "None"
            if(savedProfileSuggestions ~= nil and savedProfileSuggestions["mythic+"] ~= nil and savedProfileSuggestions["mythic+"][compressedID] ~= nil) then
                setValue = savedProfileSuggestions["mythic+"][compressedID]
            end
            dropDown:SetValue(setValue)
            dropDown:SetCallback("OnValueChanged", OnDropDownGroupSelected)
            frame:AddChild(dropDown)
        end
    end
end

local function OnGroupSelected(frame, _, group)
    local Expansion, ContentType, JurnalInstanceID = ("\001"):split(group)
    CurrentSelectedPath = group
    if(not IsAddOnLoaded("Blizzard_EncounterJournal")) then
        LoadAddOn("Blizzard_EncounterJournal")
    end

    -- Reset the frame as we are now in a new instance
    frame:ReleaseChildren()
    frame:SetLayout("Fill")
    -- Create scroll frame as the data might be bigger then the current frame
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    scroll:SetLayout("Flow")
    frame:AddChild(scroll)

    -- Prepare and sanitize data
    local validProfilesList = {}
    validProfilesList["None"] = L["None"]
    for profileName, _ in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
        validProfilesList[profileName] = profileName
    end

    if(ContentType) then
        ContentType = tonumber(ContentType)
    end
    if(JurnalInstanceID) then
        JurnalInstanceID = tonumber(JurnalInstanceID)
    end

    if(type(JurnalInstanceID) == "number") then
        -- We are rendering instance specific data so lets draw all posibilities that it might contian
        DrawDificultiesSection(scroll, Expansion, ContentType, JurnalInstanceID, validProfilesList)
        DrawBossesSection(scroll, Expansion, ContentType, JurnalInstanceID, validProfilesList)
        DrawMythicPlusSection(scroll, Expansion, ContentType, JurnalInstanceID, validProfilesList)
    elseif(type(ContentType) == "number") then

        -- Get the data
        local difficulties = {}
        local contentData = SwitchSwitch.InstancesBossData[Expansion][ContentType]
        local hasMythicplus = false
        for jurnalID, instanceData in pairs(contentData) do
            for i, difficultyID in ipairs(instanceData["difficulties"] or {}) do
                if(not SwitchSwitch:table_has_value(difficulties, difficultyID)) then
                    table.insert( difficulties,  difficultyID)
                end
            end

            hasMythicplus = hasMythicplus or instanceData["hasMythic+"] == true
        end

        if(next(difficulties, nil) ~= nil) then
            -- Set up per dificulty dropdowns
            scroll:AddChild(TalentsSuggestionPage:CreateHeader(L["On Enter Instance"]))
            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            label:SetText(L["Will suggest a talent build when entering the instance in a specific difficulty."] .. "\n\n|cffff0000" .. L["Changes here will affect all %s of %s"]:format(SwitchSwitch.ContentTypeStrings[ContentType], Expansion) .. "|r")
            scroll:AddChild(label)

            for _, id in ipairs(difficulties) do
                local dropDown = AceGUI:Create("Dropdown")
                dropDown:SetLabel(SwitchSwitch.DificultyStrings[id])
                dropDown:SetUserData("DifficultyID", id)
                dropDown:SetUserData("Expansion", Expansion)
                dropDown:SetUserData("ContentType", ContentType)
                dropDown.alignoffset = 15
                dropDown:SetList(validProfilesList)

                local setValue = nil
                local firstSuggestion = true
                for jurnalID, instanceData in pairs(contentData) do
                    if(SwitchSwitch:table_has_value(instanceData["difficulties"], id)) then
                        local savedProfileSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData["instanceID"])
                        local suggestedProfileName = (savedProfileSuggestions["difficulties"] or {})[id]
                        if(firstSuggestion) then
                            setValue = suggestedProfileName
                            firstSuggestion = false
                        else
                            if(setValue ~= suggestedProfileName) then
                                setValue = "Multiple"
                                break;
                            end
                        end
                    end
                end
                if(setValue == nil) then
                    setValue = "None"
                end

                if(setValue == "Multiple") then
                    dropDown:SetText(L["Multiple values"])
                else
                    dropDown:SetValue(setValue)
                end
                dropDown:SetCallback("OnValueChanged", OnDropDownGroupSelectedForType)
                scroll:AddChild(dropDown)
            end
        end


        if(hasMythicplus) then
            -- Render header
            scroll:AddChild(TalentsSuggestionPage:CreateHeader(L["Profiles per Mythic+ Week"]))
            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            label:SetText(L["Allows to suggest a talent profile based on the current weeks affixes when entering a instance in mythic difficulty (before starting the key)"].. ".\n" .. L["If any value below is set to none the fallback `%s` for the specific dungeon will be used for that week"]:format(SwitchSwitch.DificultyStrings[SwitchSwitch.PreMythicPlusDificulty]) .. "." ..  "\n\n|cffff0000" .. L["Changes here will affect all %s of %s"]:format(SwitchSwitch.ContentTypeStrings[ContentType], Expansion) .. "|r")
            scroll:AddChild(label)

            local currentSeasonData = {}
            for compressedID, label in pairs(SwitchSwitch.MythicPlusAffixes[C_MythicPlus.GetCurrentSeason()] or {}) do
                currentSeasonData[tonumber(select(1,string.match( label,L["Week"] .. " (%d+) %(.+")))] = {compressedID,label}
            end

            --Render dropboxes
            local currentWeekID = SwitchSwitch:GetCurrentWeeksMythicID()
            for i, packedData in ipairs(currentSeasonData) do
                local compressedID, label = unpack(packedData)
                local dropDown = AceGUI:Create("Dropdown")
                local labelText = label;
                if(compressedID == currentWeekID) then
                    labelText = "|cFF00FF00" .. label .. "|r"
                end
                dropDown:SetLabel(labelText)
                dropDown:SetUserData("Expansion", Expansion)
                dropDown:SetUserData("ContentType", ContentType)
                dropDown:SetUserData("mythicID", compressedID)
                dropDown:SetUserData("DifficultyID", SwitchSwitch.PreMythicPlusDificulty)
                dropDown.alignoffset = 25
                dropDown:SetList(validProfilesList)
                local setValue = nil
                local firstSuggestion = true
                for jurnalID, instanceData in pairs(contentData) do
                    if(instanceData["hasMythic+"]) then
                        local savedProfileSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData["instanceID"])
                        local suggestedProfileName = (savedProfileSuggestions["mythic+"] or {})[compressedID]
                        if(firstSuggestion) then
                            setValue = suggestedProfileName
                            firstSuggestion = false
                        else
                            if(setValue ~= suggestedProfileName) then
                                setValue = "Multiple"
                                break;
                            end
                        end
                    end
                end
                if(setValue == nil) then
                    setValue = "None"
                end

                if(setValue == "Multiple") then
                    dropDown:SetText(L["Multiple values"])
                else
                    dropDown:SetValue(setValue)
                end
                dropDown:SetCallback("OnValueChanged", OnDropDownGroupSelectedForType)
                scroll:AddChild(dropDown)
            end
        end
    else
        scroll:AddChild(TalentsSuggestionPage:CreateHeader(L["On enter PVP Instance"]))
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        label:SetText(L["Will suggest a talent build when entering a PVP instance of the specific type"] .. ".")
        scroll:AddChild(label)

        local arenasSuggestion  = SwitchSwitch:GetProfilesSuggestionInstanceData("arena");
        local battlegroundsSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData("pvp")

        local battlegroundsDropDown = AceGUI:Create("Dropdown")
        battlegroundsDropDown:SetLabel(L["Battlegrounds"])
        battlegroundsDropDown:SetUserData("PVP", "pvp")
        battlegroundsDropDown.alignoffset = 15
        battlegroundsDropDown:SetList(validProfilesList)
        local battlegroundSetValue = "None"
        if(battlegroundsSuggestions["all"] ~= nil) then
            battlegroundSetValue = battlegroundsSuggestions["all"]
        end
        battlegroundsDropDown:SetValue(battlegroundSetValue)
        battlegroundsDropDown:SetCallback("OnValueChanged", OnPVPDownGroupSelected)
        scroll:AddChild(battlegroundsDropDown)

        local arenasDropDown = AceGUI:Create("Dropdown")
        arenasDropDown:SetLabel(L["Arenas"])
        arenasDropDown:SetUserData("PVP", "arena")
        arenasDropDown.alignoffset = 15
        arenasDropDown:SetList(validProfilesList)
        local arenasSetValue = "None"
        if(arenasSuggestion["all"] ~= nil) then
            arenasSetValue = arenasSuggestion["all"]
        end
        arenasDropDown:SetValue(arenasSetValue)
        arenasDropDown:SetCallback("OnValueChanged", OnPVPDownGroupSelected)
        scroll:AddChild(arenasDropDown)
    end

    scroll:DoLayout()
end

local function GetInstanceNameByID(ID, isRaid)
    if(not IsAddOnLoaded("Blizzard_EncounterJournal")) then
        LoadAddOn("Blizzard_EncounterJournal")
    end

    for tier = 1, EJ_GetNumTiers() do
        EJ_SelectTier(tier)
        local index = 1
        local instanceID, name = EJ_GetInstanceByIndex(index, isRaid)

        while instanceID do
            if(instanceID == ID) then
                return name
            end
            index = index + 1
            instanceID, name = EJ_GetInstanceByIndex(index, isRaid)
        end
    end
    return "WTF"
end

function TalentsSuggestionPage:OnOpen(parent)
    SwitchSwitch:DebugPrint("Opening Talent Suggestion config")
    treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetFullWidth(true)
    treeGroup:SetFullHeight(true)
    treeGroup:SetLayout("Flow")
    treeGroup:SetCallback("OnGroupSelected", OnGroupSelected)
    parent:AddChild(treeGroup)
    self:SetTreeData()
end

function TalentsSuggestionPage:OnClose()
    SwitchSwitch:DebugPrint("Closing Talent Suggestion config")
    treeGroup = nil
    CurrentSelectedPath = nil
end

function TalentsSuggestionPage:SetTreeData()
    if(treeGroup == nil) then
        return
    end

    local treeData = {}
    for expansion, expansionData in pairs(SwitchSwitch.InstancesBossData) do
        local expansionTree = {
            text = expansion,
            value = expansion,
            children = {}
        }
        for contentType, contentData in pairs(expansionData) do
            local contentTypeTable = {
                text = SwitchSwitch.ContentTypeStrings[contentType],
                value = tostring(contentType),
                children = {}
            }
            for instanceID, instanceData in pairs(contentData) do
                local instanceTable = {
                    text = GetInstanceNameByID(instanceID, contentType == 1),
                    value = tostring(instanceID)
                }
                table.insert( contentTypeTable.children, instanceTable )
            end
            table.insert( expansionTree.children, contentTypeTable )
        end

        table.insert( treeData, expansionTree )
    end

    -- We handle PVP separate as it is not per expansion but global
    table.insert( treeData, {
        text = L["PVP"],
        value = "PVP",
    })

    treeGroup:SetTree(treeData)
    CurrentSelectedPath = CurrentSelectedPath or "Shadowlands\0011\0011190"
    local treeStatus = {
        groups= {
            ["Shadowlands"] = true,
            ["Shadowlands\0011"] = true,
            ["Shadowlands\0012"] = true,
            ["PVP"] = true
        },
        selected = CurrentSelectedPath
    }
    treeGroup:SetStatusTable(treeStatus)
    treeGroup:RefreshTree()
    treeGroup:SelectByPath(CurrentSelectedPath)
    treeGroup:DoLayout()
end

function TalentsSuggestionPage:CreateHeader(Text)
    local header = AceGUI:Create("Heading")
    header:SetText(Text)
    header:SetFullWidth(true)
    header:SetHeight(35)
    return header
end

-- Called on talent changes/spec changes
function SwitchSwitch:RefreshTalentsSuggestionUI()
    TalentsSuggestionPage:SetTreeData()
end