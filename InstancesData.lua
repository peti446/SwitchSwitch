local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

SwitchSwitch.InstancesBossData = {}
SwitchSwitch.ContentTypeStrings =
{
    [1] = L["Raids"],
    [2] = L["Dungeons"],
    [3] = L["Scenarios"],
    [20] = L["Arenas"],
    [21] = L["Battleground"]
}

SwitchSwitch.InstanceTypeToContentID =
{
    ["raid"] = 1,
    ["party"] = 2,
    ["scenario"] = 3,
    ["arena"] = 20,
    ["pvp"] = 21,
}

SwitchSwitch.DificultyStrings =
{
    [1] = L["Normal"],
    [2] = L["Heroic"],
    [23] = L["Mythic/Mythic+"],
    [14] = L["Normal"],
    [15] = L["Heroic"],
    [16] = L["Mythic"],
}

SwitchSwitch.PreMythicPlusDificulty = 23

SwitchSwitch.MythicPlusAffixes = {
    -- Sesion got by C_MythicPlus.GetCurrentSeason() then we got a list of bit shifted int based on the 3 affixes active
    -- To retrive then affix info C_ChallengeMode.GetAffixInfo(ID)
    -- Sesason 1 Shadowlands
    [5] = {
        [SwitchSwitch:encodeMythicPlusAffixesIDs(10, 11, 3)]    = L["Week"] .. " 1"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(10)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(11))  .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(3))   ..")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(9, 7, 124)]    = L["Week"] .. " 2"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(9))  .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(7))   .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(124)) ..")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(10, 123, 12)]  = L["Week"] .. " 3"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(10)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(123)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(12))  .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(9, 122, 4)]    = L["Week"] .. " 4"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(9))  .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(122)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(4))   .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(10, 8, 14)]    = L["Week"] .. " 5"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(10)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(8))   .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(14))  .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(9, 6, 13)]     = L["Week"] .. " 6"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(9))  .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(6))   .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(13))  .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(10, 123, 3)]   = L["Week"] .. " 7"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(10)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(123)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(13))  .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(9, 7, 4)]      = L["Week"] .. " 8"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(9))  .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(7))   .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(4))   .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(10, 122, 124)] = L["Week"] .. " 9"  .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(10)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(122)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(124)) .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(9, 11, 13)]    = L["Week"] .. " 10" .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(9))  .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(11))  .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(13))  .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(10, 8, 12)]    = L["Week"] .. " 11" .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(10)) .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(8))   .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(12))  .. ")",
        [SwitchSwitch:encodeMythicPlusAffixesIDs(9, 6, 14)]     = L["Week"] .. " 12" .. " (" .. select(1, C_ChallengeMode.GetAffixInfo(9))  .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(6))   .. "/" .. select(1, C_ChallengeMode.GetAffixInfo(14))  .. ")",
    },
}

-- Shadowlands
SwitchSwitch.InstancesBossData["Shadowlands"] = {
    [1] = {
        [1190] = { -- Castle of nathria (JurnalID)
            ["instanceID"] = 2296, -- Castle of nathria (InstanceID)
            ["difficulties"] = {14,15,16},
            ["bossData"] = {
                [164406] = { -- Shriekwing
                    ["requieres"] = {},
                    ["zoneID"] = 1735,
                    ["position"] = {
                        ["x1"] = 64.0,
                        ["y1"] = 76.0,
                        ["x2"] = 51.0,
                        ["y2"] = 90.0,
                    },
                    ["jurnalIndex"] = 1,
                    ["ecnounterID"] = 2393
                },
                [165066] = { -- Altimor
                    ["requieres"] = {164406},
                    ["zoneID"] = 1735,
                    ["position"] = {
                        ["x1"] = 74.0,
                        ["y1"] = 45.0,
                        ["x2"] = 61.0,
                        ["y2"] = 59.0,
                    },
                    ["jurnalIndex"] = 2,
                    ["ecnounterID"] = 2429
                },
                [164261] = { -- Hungering
                    ["requieres"] = {165066},
                    ["zoneID"] = 1735,
                    ["position"] = {
                        ["x1"] = 40.0,
                        ["y1"] = 32.0,
                        ["x2"] = 28.0,
                        ["y2"] = 45.0,
                    },
                    ["jurnalIndex"] = 4,
                    ["ecnounterID"] = 2428
                },
                [165521] = { -- Inerva
                    ["requieres"] = {164261},
                    ["zoneID"] = 1744,
                    ["jurnalIndex"] = 6,
                    ["ecnounterID"] = 2420
                },
                [165759] = { -- Sun King
                    ["requieres"] = {164406},
                    ["zoneID"] = 1746,
                    ["jurnalIndex"] = 3,
                    ["ecnounterID"] = 2422
                },
                [166644] = { -- Xymos
                    ["requieres"] = {164406},
                    ["zoneID"] = 1745,
                    ["position"] = {
                        ["x1"] = 70.0,
                        ["y1"] = 16.0,
                        ["x2"] = 58.0,
                        ["y2"] = 33.0,
                    },
                    ["jurnalIndex"] = 5,
                    ["ecnounterID"] = 2418
                },
                [166969] = { --Council
                    ["requieres"] = {165759, 166644},
                    ["zoneID"] = 1750,
                    ["jurnalIndex"] = 7,
                    ["ecnounterID"] = 2426
                },
                [164407] = { -- Sludgefist
                    ["requieres"] = {166969, 165521},
                    ["zoneID"] = 1735,
                    ["position"] = {
                        ["x1"] = 64.0,
                        ["y1"] = 76.0,
                        ["x2"] = 51.0,
                        ["y2"] = 90.0,
                    },
                    ["jurnalIndex"] = 8,
                    ["ecnounterID"] = 2394
                },
                [168112] = { -- Stone Legion
                    ["requieres"] = {},
                    ["zoneID"] = 1747,
                    ["jurnalIndex"] = 9,
                    ["ecnounterID"] = 2425
                },
                [167406] = { --Sire Denathrius
                    ["requieres"] = {168112},
                    ["zoneID"] = 1747,
                    ["jurnalIndex"] = 10,
                    ["ecnounterID"] = 2424
                }
            }
        }
    },
    [2] = { -- Dungeons
        [1188] = { -- Da other Side
            ["instanceID"] = 2291,
            ["difficulties"] = {1,2,23},
            ["hasMythic+"] = true,
        },
        [1185] = { -- Halls of atonement
            ["instanceID"] = 2287,
            ["difficulties"] = {1,2,23},
            ["hasMythic+"] = true,
        },
        [1184] = { -- Mists of Tirna Scithe
            ["instanceID"] = 2290,
            ["difficulties"] = {1,2,23},
            ["hasMythic+"] = true,
        },
        [1183] = { -- Plaguefall
            ["instanceID"] = 2289,
            ["difficulties"] = {1,2,23},
            ["hasMythic+"] = true,
        },
        [1189] = { -- Sanguine Depths
            ["instanceID"] = 2284,
            ["difficulties"] = {1,2,23},
            ["hasMythic+"] = true,
        },
        [1186] = { -- Spires of Ascension
            ["instanceID"] = 2285,
            ["difficulties"] = {1,2,23},
            ["hasMythic+"] = true,
        },
        [1182] = { -- Necrotic Wake
            ["instanceID"] = 2286,
            ["difficulties"] = {1,2,23},
            ["hasMythic+"] = true,
        },
        [1187] = { -- Theather of pain
            ["instanceID"] = 2293,
            ["difficulties"] = {1,2,23},
            ["hasMythic+"] = true,
        },
    }
}