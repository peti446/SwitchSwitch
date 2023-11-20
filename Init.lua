--############################################
-- Namespace
--############################################
local SwitchSwitch = unpack(select(2, ...))

--##########################################################################################################################
--                                  Default configurations
--##########################################################################################################################

local dbDefaults =
{
    global =
    {
        ["Version"] = -1,
        ["TalentProfiles"] = {},
        ["TalentSuggestions"] = {}
    },
    profile =
    {
        ["Version"] = -1,
        ["debug"] = false,
        ["talentsSuggestionFrame"] =
        {
            ["location"] =
            {
                ["point"] = "CENTER",
                ["relativePoint"] = "CENTER",
                ["frameX"] = 0,
                ["frameY"] = 0
            },
            ["enabled"] = true,
            ["fadeTime"] = 15
        },
        ["minimap"] =
        {
            ["hide"] = false,
        }
    },
    char =
    {
        ["Version"] = -1,
        ["gearSets"] = {},
    }
}

--##########################################################################################################################
--                                  Initialization
--##########################################################################################################################
function SwitchSwitch:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SwitchSwitchDB", dbDefaults)

    -- Register events we will liten to
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("TRAIT_CONFIG_UPDATED")

    -- Set up Settings for profiles settings
    local aceOptionTable = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("SwitchSwitch", aceOptionTable)

    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

    self:DebugPrint("Addon Initializing")

    --Update the tables in case they are not updated
    SwitchSwitch:Update()

    self:DebugPrint("Addon Initialized")
end

function SwitchSwitch:OnEnable()
    self:DebugPrint("Addon Enabling")

    -- Request Mythic+ data from server
    C_MythicPlus.RequestMapInfo()

    --Load Commands
    SwitchSwitch.Commands:Init()

    --Init the minimap
    SwitchSwitch:InitMinimapIcon()

    --Load the UI if not currently loaded
    if(not C_AddOns.IsAddOnLoaded("Blizzard_ClassTalentUI")) then
        C_AddOns.LoadAddOn("Blizzard_ClassTalentUI")
    end

    -- Enable Boss detection and register instances
    self:RegisterMessage("SWITCHSWITCH_BOSS_DETECTED")
    self:RegisterMessage("SWITCHSWITCH_INSTANCE_TYPE_DETECTED")
    self:EnableModule("BossDetection")
    local detectionModule = self:GetModule("BossDetection")
    for expansion, data in pairs(SwitchSwitch.InstancesBossData) do
        for contentType, contentData in pairs(data) do
            for jurnalID, InstanceData in pairs(contentData) do
                -- Register the data with the module
                detectionModule:RegisterInstance(InstanceData["instanceID"], InstanceData["bossData"] or {})
                -- Check aswell for suggestion to automaticly start detecting them avoids us going over them later
                local suggestions = self:GetProfilesSuggestionInstanceData(InstanceData["instanceID"])
                for id, _ in pairs(suggestions["difficulties"] or {}) do
                    detectionModule:SetDetectionForInstanceEnabled(InstanceData["instanceID"], id, true)
                end
                for id,_ in pairs(suggestions["bosses"] or {}) do
                    detectionModule:SetDetectionForBossEnabled(id, InstanceData["instanceID"], true)
                end
            end
        end
    end

    for _journalID, instanceID in pairs(SwitchSwitch.MythicPlusDungeons[self:GetCurrentMythicPlusSeason()]) do
        detectionModule:RegisterInstance(instanceID, {})
        if(self:GetMythicPlusProfileSuggestion(instanceID) ~= nil) then
            detectionModule:SetDetectionForInstanceEnabled(instanceID, self.PreMythicPlusDificulty, true)
        end
    end
    -- Enable boss detection for pvp and arenas
    local data = SwitchSwitch:GetProfilesSuggestionInstanceData("pvp")
    SwitchSwitch:GetModule("BossDetection"):SetDetectingInstanceTypeEnabled("pvp", data["all"] ~= nil)
    data = SwitchSwitch:GetProfilesSuggestionInstanceData("arena")
    SwitchSwitch:GetModule("BossDetection"):SetDetectingInstanceTypeEnabled("arena", data["all"] ~= nil)

    -- Lets refresh all the UIS
    SwitchSwitch:RefreshCurrentConfigID()
end

function SwitchSwitch:OnDisable()
    self:DebugPrint("Addon disabling")
end

--##########################################################################################################################
--                                  Config Update to never version
--##########################################################################################################################

-- IF version has 2 . it concatenates the last dots so 3.1.1 = 3.11 and 3.0.1 = 3.01 ect
local function GetVersionNumber(str)
    if(str == nil) then
        return 0.0
    end

    if(type(str) == "string") then
        if(SwitchSwitch:Repeats(str, "%.") == 2) then
            local index = SwitchSwitch:findLastInString(str, "%.")
            str = string.sub( str, 1, index-1) .. string.sub( str, index+1)
        end

        str = tonumber(str)
    end

    return str
end

function SwitchSwitch:Update()
    --Get old version string
    local globalConfigVersion = GetVersionNumber(self.db.global.Version)
    local profileConfigVerison = GetVersionNumber(self.db.profile.Version)
    local characterConfigVerison = GetVersionNumber(self.db.profile.Version)

    --Update Global table
    if(globalConfigVersion ~= -1 and globalConfigVersion ~= self.InternalVersion) then
        -- Update the tables after 3.0 (dragonflight) as talents changed
        if(globalConfigVersion < 3.00) then
            self.db.global.TalentProfiles = {}
            self.db.global.TalentSuggestions = {}
        end
    end

    -- Update profile table
    if(profileConfigVerison ~= -1 and profileConfigVerison ~= self.InternalVersion) then
    end

    -- Update character table
    if(characterConfigVerison ~= -1 and characterConfigVerison ~= self.InternalVersion) then

    end

    -- Lastly we update the verison of the config
    self.db.global.Version = self.InternalVersion
    self.db.profile.Version = self.InternalVersion
    self.db.char.Version = self.InternalVersion
end