local SwitchSwitch, L, AceGUI, LibDBIcon =unpack(select(2, ...))
local LibDeflate = LibStub("LibDeflate")

function SwitchSwitch:ProfilesToString(profilesList, includePVP)
    local encodeTableProfiles = {
        [self:GetPlayerClass()] = {
            [self:GetCurrentSpec()] = {
            }
        }
    }
    local profilesData = encodeTableProfiles[self:GetPlayerClass()][self:GetCurrentSpec()]
    for _, name in ipairs(profilesList) do
        local profileData = self:deepcopy(self:GetProfileData(name))
        if(not includePVP) then
            profileData["pvp"] = nil
        end
        profilesData[name] = profileData
    end
    local serialized = "@SWITCHSWITCH_1@" .. self:Serialize({["TalentData"] = encodeTableProfiles})
    local compressed = LibDeflate:CompressDeflate(serialized, {["level"] = 9})
    local encoded = LibDeflate:EncodeForPrint(compressed)
    return encoded
end

function SwitchSwitch:ImportEncodedProfiles(encoded)
    local compressed = LibDeflate:DecodeForPrint(encoded)
    local uncompressed = LibDeflate:DecompressDeflate(compressed, {["level"] = 9})
    local version, serializedData = string.match( uncompressed or "", "^@SWITCHSWITCH_(%d+)@(.+)$" )
    local infoText = ""
    if(version == nil) then return false end

    if(tonumber(version) == 1) then
        local suceess, unserializedData = self:Deserialize(serializedData)
        if(not suceess) then return false end

        if(unserializedData["TalentData"] ~= nil) then
            for classID, classData in pairs(unserializedData["TalentData"]) do
                local className = select(1, GetClassInfo(classID))
                for specID, profilesData in pairs(classData) do
                    local specName = select(2, GetSpecializationInfoByID(specID))
                    local currentSavedData = self:GetProfilesTable(classID, specID)
                    local profilesCount = 0
                    local namesList = ""
                    for name, data in pairs(profilesData) do
                        local saveName = name
                        local counter = 1
                        while(self:DoesProfileExits(saveName, classID, specID)) do
                            saveName = name .. "_imported_" .. tostring(counter)
                            counter = counter + 1
                        end
                        currentSavedData[saveName] = data
                        namesList = namesList .. "'" ..  saveName .. "'" .. ", "
                        profilesCount = profilesCount + 1
                    end
                    namesList = namesList:sub(1, -3)
                    infoText = infoText .. L["Imported %d profile(s) for class %s-%s: %s"]:format(profilesCount, className, specName, namesList)
                end
                infoText = infoText .. "\n"
            end
        end
    else
        return false
    end

    self:PLAYER_TALENT_UPDATE(true)
    self:Print(infoText)
    return true, infoText
end