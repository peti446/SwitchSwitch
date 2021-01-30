local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
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
    local version, serializedData = string.match( uncompressed, "^@SWITCHSWITCH_(%d+)@(.+)$" )
    if(version == nil) then return false end

    if(tonumber(version) == 1) then
        local suceess, unserializedData = self:Deserialize(serializedData)
        if(not suceess) then return false end

        if(unserializedData["TalentData"] ~= nil) then
            for classID, classData in pairs(unserializedData["TalentData"]) do
                for specID, profilesData in pairs(classData) do
                    local currentSavedData = self:GetProfilesTable(classID, specID)
                    for name, data in pairs(profilesData) do
                        local saveName = name
                        local counter = 1
                        while(self:DoesProfileExits(saveName, classID, specID)) do
                            saveName = name .. "_imported_" .. tostring(counter)
                            counter = counter + 1
                        end
                        currentSavedData[saveName] = data
                    end
                end
            end
        end
    else
        return false
    end
    self:PLAYER_TALENT_UPDATE(true)
    return true
end