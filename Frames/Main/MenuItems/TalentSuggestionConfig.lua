local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local TalentsSuggestionPage = SwitchSwitch:RegisterMenuEntry(L["Talents Suggestion"])
local treeGroup, CurrentSelectedPath

local function OnDropDownGroupSelectedForType(frame, _, group)
    local DifficultyID = frame:GetUserData("DifficultyID")
    local Expansion = frame:GetUserData("Expansion")
    local ContentType = frame:GetUserData("ContentType")
    
    if(group == "None") then
        group = nil
    end

    for JurnalInstanceID, instanceData in pairs(SwitchSwitch.InstancesBossData[Expansion][ContentType]) do
        if(SwitchSwitch:table_has_value(SwitchSwitch.InstancesBossData[Expansion][ContentType][JurnalInstanceID]["difficulties"], DifficultyID)) then
            local savedSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData.instanceID)
            savedSuggestions["difficulties"] = savedSuggestions["difficulties"] or {}
            savedSuggestions["difficulties"][DifficultyID] = group

            -- This might register the isntance but this data is static and should not change anyways so its not necesary
            SwitchSwitch:GetModule("BossDetection"):RegisterInstance(instanceData.instanceID, SwitchSwitch.InstancesBossData[Expansion][ContentType][JurnalInstanceID]["bossData"])
        end
    end
end

local function OnDropDownGroupSelected(frame, _, group)
    local InstanceID = frame:GetUserData("InstanceID")
    local DifficultyID = frame:GetUserData("DifficultyID")
    local npcID = frame:GetUserData("npcID")
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
    else
        savedSuggestions["difficulties"] = savedSuggestions["difficulties"] or {}
        savedSuggestions["difficulties"][DifficultyID] = group
    end

    -- This might register the isntance but this data is static and should not change anyways so its not necesary
    SwitchSwitch:GetModule("BossDetection"):RegisterInstance(InstanceID, bossRegisterData)
end

local function OnGroupSelected(frame, _, group)
    local Expansion, ContentType, JurnalInstanceID = ("\001"):split(group)
    CurrentSelectedPath = group
    if(not IsAddOnLoaded("Blizzard_EncounterJournal")) then
        LoadAddOn("Blizzard_EncounterJournal")
    end

    -- Reset the frame as we are now in a new instance
    frame:ReleaseChildren()
    frame:SetLayout("Flow")
    if(JurnalInstanceID ~= nil) then
        
        -- Get the data
        ContentType = tonumber(ContentType)
        JurnalInstanceID = tonumber(JurnalInstanceID)
        local instanceData = SwitchSwitch.InstancesBossData[Expansion][ContentType][JurnalInstanceID]
        local savedProfileSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData["instanceID"])
        local dropDownData = {}
        dropDownData["None"] = L["None"]
        for profileName, _ in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
            dropDownData[profileName] = profileName
        end

        -- Set up per dificulty dropdowns
        frame:AddChild(TalentsSuggestionPage:CreateHeader(L["On Enter Instance"]))
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        label:SetText(L["Will suggest a talent build when entering the instance in a specific dificulty."])
        frame:AddChild(label)
        for _, id in ipairs(instanceData["difficulties"]) do
            local dropDown = AceGUI:Create("Dropdown")
            dropDown:SetLabel(SwitchSwitch.DificultyStrings[id])
            dropDown:SetUserData("InstanceID", instanceData["instanceID"])
            dropDown:SetUserData("DifficultyID", id)
            dropDown:SetUserData("Expansion", Expansion)
            dropDown:SetUserData("ContentType", ContentType)
            dropDown:SetUserData("JurnalInstanceID", JurnalInstanceID)
            dropDown.alignoffset = 15
            dropDown:SetList(dropDownData)
            local setValue = "None"
            if(savedProfileSuggestions ~= nil and savedProfileSuggestions["difficulties"] ~= nil and savedProfileSuggestions["difficulties"][id] ~= nil) then
                setValue = savedProfileSuggestions["difficulties"][id]
            end
            dropDown:SetValue(setValue)
            dropDown:SetCallback("OnValueChanged", OnDropDownGroupSelected)
            frame:AddChild(dropDown)
        end

        -- Lets list all bosses if there are any
        if (instanceData["bossData"] ~= nil) then
            frame:AddChild(TalentsSuggestionPage:CreateHeader(L["Profiles per boss"]))
            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            label:SetText(L["Allows you to set specific talents build when mouse hovering a boss in the instance, set to none to disable for specific boss."])
            frame:AddChild(label)
            for npcID, bossData in pairs(instanceData["bossData"]) do
                local name, _, _, _, _, _, _, instanceID = EJ_GetEncounterInfo(bossData.ecnounterID)
                local dropDown = AceGUI:Create("Dropdown")
                dropDown:SetLabel(name)
                dropDown:SetUserData("InstanceID", instanceData["instanceID"])
                dropDown:SetUserData("npcID", npcID)
                dropDown:SetUserData("Expansion", Expansion)
                dropDown:SetUserData("ContentType", ContentType)
                dropDown:SetUserData("JurnalInstanceID", JurnalInstanceID)
                dropDown.alignoffset = 15
                dropDown:SetList(dropDownData)
                local setValue = "None"
                if(savedProfileSuggestions ~= nil and savedProfileSuggestions["bosses"] ~= nil and savedProfileSuggestions["bosses"][npcID] ~= nil) then
                    setValue = savedProfileSuggestions["bosses"][npcID]
                end
                dropDown:SetValue(setValue)
                dropDown:SetCallback("OnValueChanged", OnDropDownGroupSelected)
                frame:AddChild(dropDown)
            end
        end
    elseif(ContentType ~= nil) then
        
        -- Get the data
        ContentType = tonumber(ContentType)
        local contentData = SwitchSwitch.InstancesBossData[Expansion][ContentType]
        local dropDownData = {
            ["None"] = L["None"]
        }
        local difficulties = {} 

        for profileName, _ in pairs(SwitchSwitch:GetCurrentSpecProfilesTable()) do
            dropDownData[profileName] = profileName
        end

        for jurnalID, instanceData in pairs(contentData) do
            for i, difficultyID in ipairs(instanceData["difficulties"]) do
                if(not SwitchSwitch:table_has_value(difficulties, difficultyID)) then
                    table.insert( difficulties,  difficultyID)
                end
            end
        end

        -- Set up per dificulty dropdowns
        frame:AddChild(TalentsSuggestionPage:CreateHeader(L["On Enter Instance"]))
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        label:SetText(L["Will suggest a talent build when entering the instance in a specific dificulty."] .. "\n\n|cffff0000" .. L["Changes here will affect all %s of %s"]:format(SwitchSwitch.ContentTypeStrings[ContentType], Expansion) .. "|r")
        frame:AddChild(label)

        for _, id in ipairs(difficulties) do
            local dropDown = AceGUI:Create("Dropdown")
            dropDown:SetLabel(SwitchSwitch.DificultyStrings[id])
            dropDown:SetUserData("DifficultyID", id)
            dropDown:SetUserData("Expansion", Expansion)
            dropDown:SetUserData("ContentType", ContentType)
            dropDown.alignoffset = 15
            dropDown:SetList(dropDownData)

            local setValue = "None"
            local suggestionNotSet = true
            for jurnalID, instanceData in pairs(contentData) do
                if(SwitchSwitch:table_has_value(instanceData["difficulties"], id)) then
                    local savedProfileSuggestions = SwitchSwitch:GetProfilesSuggestionInstanceData(instanceData["instanceID"])
                    local suggestedProfileName = (savedProfileSuggestions["difficulties"] or {})[id]
                    if(suggestionNotSet) then
                        if(suggestedProfileName ~= nil) then
                            setValue = suggestedProfileName
                            suggestionNotSet = false
                        end
                    elseif(setValue ~= suggestedProfileName) then
                        setValue = "Multiple"
                    end
                end
            end

            if(setValue == "Multiple") then
                dropDown:SetValue("None")
                dropDown:SetText(L["Multiple values"])
            else 
                dropDown:SetValue(setValue)
            end
            dropDown:SetCallback("OnValueChanged", OnDropDownGroupSelectedForType)
            frame:AddChild(dropDown)
        end
    end
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
    treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetFullWidth(true)
    treeGroup:SetFullHeight(true)
    parent:AddChild(treeGroup)
    self:SetTreeData()
end

function TalentsSuggestionPage:OnClose()
    treeData = nil
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

    treeGroup:SetTree(treeData)
    treeGroup:SetCallback("OnGroupSelected", OnGroupSelected)
    treeGroup:SetLayout("Flow")
    CurrentSelectedPath = CurrentSelectedPath or "Shadowlands\0011\0011190"
    treeGroup:SelectByPath(CurrentSelectedPath)
    local treeStatus = {
        groups= {
            ["Shadowlands"] = true,
            ["Shadowlands\0011"] = true,
            ["Shadowlands\0012"] = true
        },
        selected = CurrentSelectedPath
    }
    treeGroup:SetStatusTable(treeStatus)
    treeGroup:RefreshTree()

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