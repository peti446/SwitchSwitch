--############################################
-- Namespace
--############################################
local _, addon = ...

addon.Commands = {}

local Commands = addon.Commands

--##########################################################################################################################
--                                  Commands Fnctions
--##########################################################################################################################




--##########################################################################################################################
--                                  Commands handling
--##########################################################################################################################
local CommandList =
{
}

local function HandleSlashCommands(str)
    if (#str == 0) then	
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