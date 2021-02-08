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
        },
        [1185] = { -- Halls of atonement
            ["instanceID"] = 2287,
            ["difficulties"] = {1,2,23},
        },
        [1184] = { -- Mists of Tirna Scithe
            ["instanceID"] = 2290,
            ["difficulties"] = {1,2,23},
        },
        [1183] = { -- Plaguefall
            ["instanceID"] = 2289,
            ["difficulties"] = {1,2,23},
        },
        [1189] = { -- Sanguine Depths
            ["instanceID"] = 2284,
            ["difficulties"] = {1,2,23},
        },
        [1186] = { -- Spires of Ascension
            ["instanceID"] = 2285,
            ["difficulties"] = {1,2,23},
        },
        [1182] = { -- Necrotic Wake
            ["instanceID"] = 2286,
            ["difficulties"] = {1,2,23},
        },
        [1187] = { -- Theather of pain
            ["instanceID"] = 2293,
            ["difficulties"] = {1,2,23},
        },
    }
}