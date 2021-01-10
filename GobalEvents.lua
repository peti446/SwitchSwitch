local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

-- Private variables
local LastInstanceID = -1

function SwitchSwitch:ADDON_LOADED(event, arg1)
    if(arg1 == "Blizzard_TalentUI") then
        SwitchSwitch.TalentUIFrame:CreateTalentFrameUI()
        return
    end
end

function SwitchSwitch:PLAYER_ENTERING_WORLD()
    --Check if we actually switched map from last time
    local instanceID = select(8,GetInstanceInfo())
    --Debuging
    SwitchSwitch:DebugPrint("Entering instance: " .. string.join(" - ", tostringall(GetInstanceInfo())))
    if(LastInstanceID == instanceID) then
        return
    end
    LastInstanceID = instanceID
    --Check if we are in an instance
    local inInstance, instanceType = IsInInstance()
    if(inInstance) then
        local profileNameToUse = self.dbpc.char.autoSuggest[instanceType]

        SwitchSwitch:DebugPrint("Instance type: " .. instanceType)

        --Party is a table so we need to ge the profile out via dificullty
        if(instanceType == "party") then
            local difficulty = GetDungeonDifficultyID()
            local difficultyByID = 
            {
                [1] = "HM", -- Normal mode but we truncate it up to hc profile mode
                [2] = "HM",
                [23] = "MM"
            }
            profileNameToUse = self.dbpc.char.autoSuggest[instanceType][difficultyByID[difficulty]]
        end
        --Check if we are already in the current profile
        if(profileNameToUse ~= nil and profileNameToUse ~= "") then
            if(not SwitchSwitch:IsCurrentTalentProfile(profileNameToUse)) then 
                SwitchSwitch:DebugPrint("Atuo suggest changing to profile: " .. profileNameToUse)
                SwitchSwitch.GlobalFrames:ToggleSuggestionFrame(profileNameToUse)
            else
                SwitchSwitch:DebugPrint("Profile " .. profileNameToUse .. " is already in use.")
            end
        else
            SwitchSwitch:DebugPrint("No profile set for this type of instance.")
        end
    end
end

function SwitchSwitch:PLAYER_TALENT_UPDATE()
    self.dbpc.char.SelectedTalentsProfile = SwitchSwitch:GetCurrentProfileFromSaved()
end