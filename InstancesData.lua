local SwitchSwitch, L = unpack(select(2, ...))

SwitchSwitch.InstancesBossData = {}
SwitchSwitch.ContentTypeStrings =
{
    [1] = L["Raids"],
    [2] = L["Dungeons"],
    [3] = L["Scenarios"],
    [20] = L["Arenas"],
    [21] = L["Battlegrounds"]
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
    -- Dungeons
    [1] = L["Normal"],
    [2] = L["Heroic"],
    [23] = L["Mythic"],
    -- Raid
    [14] = L["Normal"],
    [15] = L["Heroic"],
    [16] = L["Mythic"],
}

SwitchSwitch.PreMythicPlusDificulty = 23
SwitchSwitch.DefaultMythicPlusSeason = 12

-- Format is: JournalID -> InstancID
SwitchSwitch.MythicPlusDungeons = {
    -- Season 1 TWW
    [13] = {
        [1271] = 2660, -- Ara-Jara
        [1274] = 2669, -- City of Threads
        [1270] = 2662, -- The Dawnbreaker
        [1269] = 2652, -- The Stonevault
        [1184] = 2290, -- Mist of tirna Scithe
        [1182] = 2286, -- The Necrotic Wake
        [1023] = 1822, -- Siege of Boralus
        [71] = 670, -- Grim Batol
    },
    -- Season 4 Dragonflight
    [12] = {
        [1201] = 2526, --Academy
        [1196] = 2520, -- Brackenhide hallow
        [1204] = 2527, -- Hakks if Infusion
        [1199] = 2519, -- Neltarhius
        [1202] = 2521, -- Ruby Life Pools
        [1203] = 2515, -- Azure Vaults
        [1198] = 2516, -- Nokhud Offensive
        [1197] = 2451, -- Uldaman
    },
    -- Season 3 Dragonflight
    [11] = {
        [1209] = 2579,
        [968] = 1763,
        [1021] = 1862,
        [740] = 1501,
        [762] = 1466,
        [556] = 1279,
        [65] = 643
    }
}
--  \[(SwitchSwitch:encodeMythicPlusAffixesIDs\(\d+, \d+, \d+\))]  = BuildMythicPlusTitle\("(\d+)", \d+, \d+, \d+\),
-- Sesion got by /dump C_MythicPlus.GetCurrentSeason() then we got a list of bit shifted int based on the 3 affixes active
-- To retrive then affix info C_ChallengeMode.GetAffixInfo(ID)
-- Also normaly good to check is wowhead they tend to have a table of affixes that gets updated. For Season 3 https://www.wowhead.com/guides/season-3-shadowlands-mythic-plus-updates-item-levels
SwitchSwitch.MythicPlusAffixes = {
    -- Season 1 TWW
    [13] = {

    },
    -- Season 4 Dragonflight
    [12] = {
        [1] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 124, 6),
        [2] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 134, 7),
        [3] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 136, 123),
        [4] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 135, 6),
        [5] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 3, 8),
        [6] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 124, 11),
        [7] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 135, 7),
        [8] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 136, 8),
        [9] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 134, 11),
        [10] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 3, 123),
    },
    -- Season 3 Dragonflight
    [11] = {
        [1] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 136, 8),
        [2] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 134, 11),
        [3] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 3, 123),
        [4] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 124, 6),
        [5] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 134, 7),
        [6] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 136, 123),
        [7] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 135, 6),
        [8] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 3, 8),
        [9] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 124, 11),
        [10] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 135, 7),
    },
    -- Missed all the other seasons as I stopped updating the addon Feel free to add them
    -- Sesason 3 Shadowlands
    [7] = {
        [1] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 7, 13),
        [2] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 11, 124),
        [3] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 6, 3),
        [4] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 122, 12),
        [5] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 123, 4),
        [6] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 7, 14),
        [7] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 8, 124),
        [8] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 6, 13),
        [9] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 11, 3),
        [10] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 123, 4),
        [11] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 122, 14),
        [12] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 8, 12),
    },
    -- Sesason 2 Shadowlands
    [6] = {
        [1] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 11, 124),
        [2] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 6, 3),
        [3] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 122, 12),
        [4] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 123, 4),
        [5] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 7, 14),
        [6] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 8, 124),
        [7] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 6, 13),
        [8] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 11, 3),
        [9] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 123, 12),
        [10] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 122, 14),
        [11] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 8, 4),
        [12] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 7, 13),
    },
    -- Sesason 1 Shadowlands
    [5] = {
        [1] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 11, 3),
        [2] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 7, 124),
        [3] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 123, 12),
        [4] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 122, 4),
        [5] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 8, 14),
        [6] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 6, 13),
        [7] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 123, 3),
        [8] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 7, 4),
        [9] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 122, 124),
        [10] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 11, 13),
        [11] = SwitchSwitch:encodeMythicPlusAffixesIDs(10, 8, 12),
        [12] = SwitchSwitch:encodeMythicPlusAffixesIDs(9, 6, 14),
    },
}

-- To obtain the bossData key look at wowhead and searh for the npc the ID is the key
-- To obtain the JurnalID look at https://wago.tools/db2/JournalInstance?sort[ID]=desc&page=1 and look at the id for the raid and the instance ID is the MapID
-- To obtain bosses data look at https://wago.tools/db2/JournalEncounter?page=1, the UiMapID is the zone, ID is encounterid, jurnalIndex is OrderIndex
-- To obtain duneons data look at https://wago.tools/db2/Map?filter[ExpansionID]=10&filter[InstanceType]=1&page=1&sort[Directory]=asc ID is the instanceID
-- The boss entry ID is the boss npc ID wich is what we search for in the tooltip
SwitchSwitch.InstancesBossData["The War Within"] = {
    -- Raids
    [1] = {
        [1273] = {
            ["instanceID"] = 2657,
            ["difficulties"] = {14,15,16},
            ["bossData"] = {
                [215657] = { -- Ulgrax
                    ["requieres"] = {},
                    ["zoneID"] = 2292,
                    ["jurnalIndex"] = 1,
                    ["encounterID"] = 2607,
                    ["otherBossID"] = {},
                },
                [214502] = { -- The bloodbound horror
                    ["requieres"] = {215657},
                    ["zoneID"] = 2291,
                    ["jurnalIndex"] = 2,
                    ["encounterID"] = 2611,
                    ["otherBossID"] = {},
                },
                [214503] = { -- Sikran
                    ["requieres"] = {214502},
                    ["zoneID"] = 2293,
                    ["jurnalIndex"] = 3,
                    ["encounterID"] = 2599,
                    ["otherBossID"] = {},
                },
                [224552] = { -- Rasha'nan
                    ["requieres"] = {214503},
                    ["zoneID"] = 2292,
                    ["jurnalIndex"] = 4,
                    ["encounterID"] = 2609,
                    ["otherBossID"] = {},
                },
                [214506] = { -- Broodtwister Ovi'nax
                    ["requieres"] = {224552},
                    ["zoneID"] = 2294,
                    ["jurnalIndex"] = 5,
                    ["encounterID"] = 2612,
                    ["otherBossID"] = {},
                },
                [218425] = { -- Nexus-Princess Ky'veza
                    ["requieres"] = {224552},
                    ["zoneID"] = 2294,
                    ["jurnalIndex"] = 6,
                    ["encounterID"] = 2601,
                    ["otherBossID"] = {},
                },
                [223779] = { -- The sIlken Court
                    ["requieres"] = {218425, 214506},
                    ["zoneID"] = 2294,
                    ["jurnalIndex"] = 7,
                    ["encounterID"] = 2608,
                    ["otherBossID"] = {219878},
                },
                [219778] = { -- Queen Ansurek
                    ["requieres"] = {223779},
                    ["zoneID"] = 2295,
                    ["jurnalIndex"] = 8,
                    ["encounterID"] = 2602,
                    ["otherBossID"] = {},
                },
            }
        },
    },
    [2] = {
        [1271] = {
            ["instanceID"] = 2660,
            ["difficulties"] = {1,2,23},
        }, -- Ara-Kara
        [1274] = {
            ["instanceID"] = 2669,
            ["difficulties"] = {1,2,23},
        }, -- City of Threads
        [1270] = {
            ["instanceID"] = 2662,
            ["difficulties"] = {1,2,23},
        }, -- The Dawnbreaker
        [1268] = {
            ["instanceID"] = 2648,
            ["difficulties"] = {1,2,23},
        }, -- The Rookery
        [1267] = {
            ["instanceID"] = 2649,
            ["difficulties"] = {1,2,23},
        }, -- Priory of the Sacred Flame
        [1210] = {
            ["instanceID"] = 2651,
            ["difficulties"] = {1,2,23},
        }, -- Darkflame Cleft
        [1269] = {
            ["instanceID"] = 2652,
            ["difficulties"] = {1,2,23},
        }, -- The Stonevault
        [1272] = {
            ["instanceID"] = 2661,
            ["difficulties"] = {1,2,23},
        }, -- Cinderbrew Meadery
    },
}
SwitchSwitch.InstancesBossData["Dragonflight"] = {
    -- Raids
    [1] = {
        [1200] = { -- Vault of the Incarnates
            ["instanceID"] = 2522,
            ["difficulties"] = {14,15,16},
            ["bossData"] = {
                [184972] = { -- Eranog
                    ["requieres"] = {},
                    ["zoneID"] = 2119,
                    ["jurnalIndex"] = 1,
                    ["encounterID"] = 2480,
                    ["otherBossID"] = {},
                },
                [190496] = { -- Terros
                    ["requieres"] = {184972},
                    ["zoneID"] = 2122,
                    ["jurnalIndex"] = 2,
                    ["encounterID"] = 2500,
                    ["otherBossID"] = {},
                },
                [187771] = { -- Primal Council
                    ["requieres"] = {184972},
                    ["zoneID"] = 2120,
                    ["jurnalIndex"] = 3,
                    ["encounterID"] = 2486,
                    ["otherBossID"] = {},
                },
                [187967] = { -- Sennarth
                    ["requieres"] = {190496},
                    ["zoneID"] = 2122,
                    ["jurnalIndex"] = 4,
                    ["encounterID"] = 2482,
                    ["otherBossID"] = {},
                },
                [189813] = { -- Dathea
                    ["requieres"] = {187771},
                    ["zoneID"] = 2121,
                    ["jurnalIndex"] = 5,
                    ["encounterID"] = 2502,
                    ["otherBossID"] = {},
                },
                [181378] = { -- Kurog
                    ["requieres"] = {187967},
                    ["zoneID"] = 2124,
                    ["jurnalIndex"] = 6,
                    ["encounterID"] = 2491,
                    ["otherBossID"] = {},
                },
                [190245] = { -- Bloodkeeper
                    ["requieres"] = {181378, 189813},
                    ["zoneID"] = 2126,
                    ["jurnalIndex"] = 7,
                    ["encounterID"] = 2493,
                    ["otherBossID"] = {},
                },
                [189492] = { -- Raszageth
                    ["requieres"] = {190245},
                    ["zoneID"] = 2125,
                    ["jurnalIndex"] = 8,
                    ["encounterID"] = 2499,
                    ["otherBossID"] = {},
                }
            },
        },
        [1208] = { -- Aberrus, the Shadowed Crucible
            ["instanceID"] = 2569,
            ["difficulties"] = {14,15,16},
            ["bossData"] = {
                [201261] = { -- Kazzara
                    ["requieres"] = {},
                    ["zoneID"] = 2166,
                    ["jurnalIndex"] = 1,
                    ["encounterID"] = 2522,
                    ["otherBossID"] = {}
                },
                [201774] = { -- Amalgamation Chamber
                    ["requieres"] = {201261},
                    ["zoneID"] = 2167,
                    ["jurnalIndex"] = 2,
                    ["encounterID"] = 2529,
                    ["otherBossID"] = {},
                },
                [200912] = { -- Forgotten Experiments
                    ["requieres"] = {201774},
                    ["zoneID"] = 2166,
                    ["jurnalIndex"] = 3,
                    ["encounterID"] = 2530,
                    ["otherBossID"] = {}
                },
                [199659] = { -- Zaqali Assault
                    ["requieres"] = {201261},
                    ["zoneID"] =  2168,
                    ["jurnalIndex"] = 4,
                    ["encounterID"] = 2524,
                    ["otherBossID"] = {}
                },
                [201320] = { -- Rashok
                    ["requieres"] = {199659},
                    ["zoneID"] = 2166,
                    ["jurnalIndex"] = 5,
                    ["encounterID"] = 2525,
                    ["otherBossID"] =  {}
                },
                [202637] = { -- Zskarn
                    ["requieres"] = {201320, 200912},
                    ["zoneID"] = 2166,
                    ["jurnalIndex"] = 6,
                    ["encounterID"] = 2532,
                    ["otherBossID"] = {}
                },
                [201579] = { -- Magmorax
                    ["requieres"] = {202637},
                    ["zoneID"] = 2166,
                    ["jurnalIndex"] = 7,
                    ["encounterID"] = 2527,
                    ["otherBossID"] =  {}
                },
                [201668] = { -- Echo of Neltharion
                    ["requieres"] = {201579},
                    ["zoneID"] = 2169,
                    ["jurnalIndex"] = 8,
                    ["encounterID"] = 2523,
                    ["otherBossID"] = {},
                },
                [201754] = { -- Sarkareth
                    ["requieres"] = {201668},
                    ["zoneID"] = 2170,
                    ["jurnalIndex"] = 9,
                    ["encounterID"] = 2520,
                    ["otherBossID"] = {}
                },
            },
        },
        [1207] = { -- Amirdrassil
            ["instanceID"] = 2549,
            ["difficulties"] = {14,15,16},
            ["bossData"] = {
                [209333] = { -- Gnarlroot
                    ["requieres"] = {},
                    ["zoneID"] = 2232,
                    ["jurnalIndex"] = 1,
                    ["encounterID"] = 2564,
                    ["otherBossID"] = {}
                },
                [200926] = { -- Igira
                    ["requieres"] = {},
                    ["zoneID"] = 2232,
                    ["jurnalIndex"] = 2,
                    ["encounterID"] = 2554,
                    ["otherBossID"] = {}
                },
                [208478] = { -- Volcoross
                    ["requieres"] = {},
                    ["zoneID"] = 2244,
                    ["jurnalIndex"] = 3,
                    ["encounterID"] = 2557,
                    ["otherBossID"] = {}
                },
                [208363] = { -- Council of Dreams
                    ["requieres"] = {},
                    ["zoneID"] = 2240,
                    ["jurnalIndex"] = 4,
                    ["encounterID"] = 2555,
                    ["otherBossID"] = {208365, 208367}
                },
                [208445] = { -- Larodar
                    ["requieres"] = {},
                    ["zoneID"] = 2244,
                    ["jurnalIndex"] = 5,
                    ["encounterID"] = 2553,
                    ["otherBossID"] = {}
                },
                [206172] = { -- Nymue
                    ["requieres"] = {},
                    ["zoneID"] = 2240,
                    ["jurnalIndex"] = 6,
                    ["encounterID"] = 2556,
                    ["otherBossID"] = {}
                },
                [200927] = { -- Smolderon
                    ["requieres"] = {},
                    ["zoneID"] = 2233,
                    ["jurnalIndex"] = 7,
                    ["encounterID"] = 2563,
                    ["otherBossID"] = {}
                },
                [209090] = { -- Tindral Sageswift
                    ["requieres"] = {},
                    ["zoneID"] = 2234,
                    ["jurnalIndex"] = 8,
                    ["encounterID"] = 2565,
                    ["otherBossID"] = {}
                },
                [204931] = { -- Fyrakk The Blazing
                    ["requieres"] = {},
                    ["zoneID"] = 2238,
                    ["jurnalIndex"] = 9,
                    ["encounterID"] = 2519,
                    ["otherBossID"] = {}
                },
            },
        }
    },
    -- Dungeons
    [2] = {
        [1209] = {
            ["instanceID"] = 2579,
            ["difficulties"] = {23},
        },
        [1204] = { -- Halls of Infusion
            ["instanceID"] = 2527,
            ["difficulties"] = {1,2,23},
        },
        [1203] = { -- The Azure Vault
            ["instanceID"] = 2515,
            ["difficulties"] = {1,2,23},
        },
        [1202] = { -- Ruby Life Pools
            ["instanceID"] = 2521,
            ["difficulties"] = {1,2,23},
        },
        [1201] = { -- Algeth'ar Academy
            ["instanceID"] = 2526,
            ["difficulties"] = {1,2,23},
        },
        [1199] = { -- Neltharus
            ["instanceID"] = 2519,
            ["difficulties"] = {1,2,23},
        },
        [1198] = { -- The Nokhud Offensive
            ["instanceID"] = 2516,
            ["difficulties"] = {1,2,23},
        },
        [1197] = { -- Uldaman: Legacy of Tyr
            ["instanceID"] = 2451,
            ["difficulties"] = {1,2,23},
        },
        [1196] = { -- Brackenhide Hollow
            ["instanceID"] = 2520,
            ["difficulties"] = {1,2,23},
        },
    },

    -- Senarios
    --[3] = nil,
}


SwitchSwitch.InstancesBossData["Shadowlands"] = {
    [1] = {
        [1195] = {
            ["instanceID"] = 2481, -- Sepulcher of the First Ones (InstanceID)
            ["difficulties"] = {14,15,16},
            ["bossData"] = {
                [180773] = {  -- Vigilant Guardian
                    ["requieres"] = {},
                    ["zoneID"] = 2047,
                    ["jurnalIndex"] = 1,
                    ["encounterID"] = 2458,
                    ["otherBossID"] = {184522},
                },
                [181395] = { -- Skolex
                    ["requieres"] = {180773},
                    ["zoneID"] = 2061,
                    ["jurnalIndex"] = 2,
                    ["encounterID"] = 2465,
                },
                [183501] = { -- Artificer Xy'mox
                    ["requieres"] = {180773},
                    ["zoneID"] = 2061,
                    ["jurnalIndex"] = 3,
                    ["encounterID"] = 2470,
                },
                [181224] = { -- Dausegne
                    ["requieres"] = {180773},
                    ["zoneID"] = 2048,
                    ["jurnalIndex"] = 4,
                    ["encounterID"] = 2459,
                },
                [181549] = { -- Prototype Pantheon
                    ["requieres"] = {181224},
                    ["zoneID"] = 2049,
                    ["jurnalIndex"] = 5,
                    ["encounterID"] = 2460,
                    ["otherBossID"] = {181548, 181546, 181551},
                },
                [182169] = { -- Lihuvim
                    ["requieres"] = {181549},
                    ["zoneID"] = 2049,
                    ["jurnalIndex"] = 6,
                    ["encounterID"] = 2461,
                },
                [180906] = { -- Halondrus
                    ["requieres"] = {181395, 183501},
                    ["zoneID"] = 2061,
                    ["jurnalIndex"] = 7,
                    ["encounterID"] = 2463,
                },
                [181954] = { -- Anduin
                    ["requieres"] = {182169, 180906},
                    ["zoneID"] = 2050,
                    ["jurnalIndex"] = 8,
                    ["encounterID"] = 2469,
                },
                [181398] = { -- Lords of Dread
                    ["requieres"] = {181954},
                    ["zoneID"] = 2052,
                    ["jurnalIndex"] = 9,
                    ["encounterID"] = 2457,
                    ["otherBossID"] = {181399},
                },
                [182777] = { -- Rygelon
                    ["requieres"] = {181954},
                    ["zoneID"] = 2052,
                    ["jurnalIndex"] = 10,
                    ["encounterID"] = 2467,
                },
                [180990] = { -- Jailer
                    ["requieres"] = {181398, 182777},
                    ["zoneID"] = 2051,
                    ["jurnalIndex"] = 11,
                    ["encounterID"] = 2464,
                },
            }
        },
        [1193] = {
            ["instanceID"] = 2450, -- Castle of nathria (InstanceID)
            ["difficulties"] = {14,15,16},
            ["bossData"] = {
                [175611] = {  -- The Tarragrue
                    ["requieres"] = {},
                    ["zoneID"] = 1998,
                    ["jurnalIndex"] = 1,
                    ["encounterID"] = 2435
                },
                [175725] = { -- Eye of the jailer
                    ["requieres"] = {175611},
                    ["zoneID"] = 1999,
                    ["jurnalIndex"] = 2,
                    ["encounterID"] = 2442
                },
                [177095] = { -- The Nine
                    ["requieres"] = {175611},
                    ["zoneID"] = 1999,
                    ["jurnalIndex"] = 3,
                    ["encounterID"] = 2439,
                    ["otherBossID"] = {177094, 175726}
                },
                [175729] = { -- Remnant of Ner'zul
                    ["requieres"] = {177095, 175725},
                    ["zoneID"] = 2000,
                    ["jurnalIndex"] = 5,
                    ["encounterID"] = 2444
                },
                [175727] = { -- Soulrender Dormazain
                    ["requieres"] = {177095, 175725},
                    ["zoneID"] = 2000,
                    ["jurnalIndex"] = 4,
                    ["encounterID"] = 2445
                },
                [176523] = { -- Painsmith Raznal
                    ["requieres"] = {177095, 175725},
                    ["zoneID"] = 2000,
                    ["jurnalIndex"] = 6,
                    ["encounterID"] = 2443
                },
                [175731] = { -- Guardian of the First Ones
                    ["requieres"] = {176523, 175729, 175727},
                    ["zoneID"] = 2001,
                    ["jurnalIndex"] = 7,
                    ["encounterID"] = 2446
                },
                [179390] = { -- Fatescribe Roh-Kalo
                    ["requieres"] = {176523, 175729, 175727},
                    ["zoneID"] = 2001,
                    ["jurnalIndex"] = 8,
                    ["encounterID"] = 2447
                },
                [15990] = { -- Kel'Thuzad
                    ["requieres"] = {176523, 175729, 175727},
                    ["zoneID"] = 2001,
                    ["jurnalIndex"] = 9,
                    ["encounterID"] = 2440
                },
                [180828] = { -- Sylvanas Windrunner
                    ["requieres"] = {175731, 179390, 15990},
                    ["zoneID"] = 2002,
                    ["jurnalIndex"] = 10,
                    ["encounterID"] = 2441
                },

            }
        },
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
                    ["encounterID"] = 2393
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
                    ["encounterID"] = 2429
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
                    ["encounterID"] = 2428
                },
                [165521] = { -- Inerva
                    ["requieres"] = {164261},
                    ["zoneID"] = 1744,
                    ["jurnalIndex"] = 6,
                    ["encounterID"] = 2420
                },
                [165759] = { -- Sun King
                    ["requieres"] = {164406},
                    ["zoneID"] = 1746,
                    ["jurnalIndex"] = 3,
                    ["encounterID"] = 2422
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
                    ["encounterID"] = 2418
                },
                [166969] = { --Council
                    ["requieres"] = {165759, 166644},
                    ["zoneID"] = 1750,
                    ["jurnalIndex"] = 7,
                    ["encounterID"] = 2426
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
                    ["encounterID"] = 2394
                },
                [168112] = { -- Stone Legion
                    ["requieres"] = {},
                    ["zoneID"] = 1747,
                    ["jurnalIndex"] = 9,
                    ["encounterID"] = 2425
                },
                [167406] = { --Sire Denathrius
                    ["requieres"] = {168112},
                    ["zoneID"] = 1747,
                    ["jurnalIndex"] = 10,
                    ["encounterID"] = 2424
                }
            }
        }
    },
    [2] = { -- Dungeons
        [1194] = { -- Tazavesh the Veiled Market
            ["instanceID"] = 2441,
            ["difficulties"] = {23},
        },
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
            ["difficulties"] = {1,2,23}
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