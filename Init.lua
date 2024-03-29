--############################################
-- Namespace
--############################################
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

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
        ["autoUseTomes"] = true,
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
        ["preferredSoulbind"] = {}
    }
}

--##########################################################################################################################
--                                  Initialization
--##########################################################################################################################
function SwitchSwitch:OnInitialize()
    self:DebugPrint("Addon Initializing")
    self.db = LibStub("AceDB-3.0"):New("SwitchSwitchDB", dbDefaults)

    -- Register events we will liten to
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterBucketEvent({"AZERITE_ESSENCE_UPDATE", "PLAYER_TALENT_UPDATE"}, 0.75, "PLAYER_TALENT_UPDATE")

    --Update the tables in case they are not updated
    SwitchSwitch:Update();

    -- Set up Settings for profiles settings
    local aceOptionTable = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("SwitchSwitch", aceOptionTable)

    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

function SwitchSwitch:OnEnable()
    self:DebugPrint("Addon Enabling")

    --Load Commands
    SwitchSwitch.Commands:Init()

    --Init the minimap
    SwitchSwitch:InitMinimapIcon()

    --Load the UI if not currently loaded
    if(not IsAddOnLoaded("Blizzard_TalentUI")) then
        LoadAddOn("Blizzard_TalentUI")
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
                -- For mythic plus we are not going to detext each sesson we just detect the mythic+ dificulty (normal mythic dificulty in this case 23)
                if(next(suggestions["mythic+"] or {},nil) ~= nil) then
                    detectionModule:SetDetectionForInstanceEnabled(InstanceData["instanceID"], self.PreMythicPlusDificulty, true)
                end
            end
        end
    end
    -- Enable boss detection for pvp and arenas
    local data = SwitchSwitch:GetProfilesSuggestionInstanceData("pvp")
    SwitchSwitch:GetModule("BossDetection"):SetDetectingInstanceTypeEnabled("pvp", data["all"] ~= nil)
    data = SwitchSwitch:GetProfilesSuggestionInstanceData("arena")
    SwitchSwitch:GetModule("BossDetection"):SetDetectingInstanceTypeEnabled("arena", data["all"] ~= nil)

    -- Lets refresh all the UIS
    self:PLAYER_TALENT_UPDATE(true)
    -- Load the tomes data
    local tomesID = SwitchSwitch:GetValidTomesItemsID()
    for i, id in ipairs(tomesID) do
        C_Item.RequestLoadItemDataByID(id)
    end
end

function SwitchSwitch:OnDisable()
    self:DebugPrint("Addon disabling")
end

--##########################################################################################################################
--                                  Config Update to never version
--##########################################################################################################################

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

    -- Internal version to release version
    -- 2.0 - 2.0,2.01
    -- 20 - 2.02

    --Update Global table
    if(globalConfigVersion ~= -1 and globalConfigVersion ~= self.InternalVersion) then

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