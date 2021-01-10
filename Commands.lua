--############################################
-- Namespace
--############################################
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

SwitchSwitch.Commands = {}

local Commands = SwitchSwitch.Commands

--##########################################################################################################################
--                                  Commands Fnctions
--##########################################################################################################################
function Commands:Help()
    SwitchSwitch:Print("--------- |cff00F3FF"..L["List of commands"]..":|r ---------");
    SwitchSwitch:Print("|cff188E01/ss help|r - " .. L["Shows all commands"] .. ".");
    SwitchSwitch:Print("|cff188E01/ss config|r - " .. L["Shows the config frame"] .. ".");
	SwitchSwitch:Print("|cff188E01/ss load <profileName>|r - " .. L["Loads a talent profile"] .. ".");
	SwitchSwitch:Print("|cff188E01/ss resetFrame suggestion|r - " .. L["Resets the suggestion frame location"] .. ".");
	SwitchSwitch:Print("-------------------------------------");
end

function Commands:LoadProfileCMD(...)
	SwitchSwitch:DebugPrint("Changing talents to: " .. ...)
	SwitchSwitch:ActivateTalentProfile(string.join(" ", tostringall(...)))
end


function Commands:ResetFrameLocation(frame)
	if(frame == "suggestion") then
		SwitchSwitch.sv.config.SuggestionFramePoint =
		{
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["frameX"] = 0,
			["frameY"] = 0
		}
	end
end

--##########################################################################################################################
--                                  Commands handling
--##########################################################################################################################
local CommandList =
{
	["config"] = SwitchSwitch.ConfigFrame.ToggleFrame,
	["help"] = Commands.Help,
	["load"] = Commands.LoadProfileCMD,
	["resetFrame"] = Commands.ResetFrameLocation
}

local function HandleSlashCommands(str)
	if (#str == 0) then
		Commands:Help()
		-- User entered command without any args
		return
	end	
	
	local args = {}
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg)
		end
	end
	
	local path = CommandList -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower()		
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function
					path[arg](addon, select(id + 1, unpack(args)))
					return
				elseif (type(path[arg]) == "table") then				
					path = path[arg] -- another sub-table found!
				end
			else
				-- does not exist!
				Commands:Help()
				return
			end
		end
	end
end

--##########################################################################################################################
--                                  Commands Init
--##########################################################################################################################
function Commands:Init()
    SLASH_SwitchSwitch1 = "/ss"
    SLASH_SwitchSwitch2 = "/sstalent"
    SLASH_SwitchSwitch3 = "/switchswitch"
    SlashCmdList.SwitchSwitch = HandleSlashCommands
end