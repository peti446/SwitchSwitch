--############################################
-- Namespace
--############################################
local _, addon = ...

--Set up frame helper gobal tables
addon.FrameHelper = {}
local FrameHelper = addon.FrameHelper

--##########################################################################################################################
--                                  Frames Init
--##########################################################################################################################
--Creates the Frame inside the talent frame
function FrameHelper:CreateTalentFrameUI()
    --Check if we already created the frame, as WOW does not delete frames unless you reload, so we dont need to recreate it
    if(FrameHelper.FrameTalentsUI ~= nil) then
        --Update the frame and add/remove porfiles as needed (using garbage collection for memory otimisation)
        --FrameHelper:UpdateTalentFrameUIComponents()
        return
    end
    --Create frame and hide it by default
    FrameHelper.FrameTalentsUI = CreateFrame("Frame", "SwitchSwitch_FrameTalents", PlayerTalentFrameTalents)
    FrameHelper.FrameTalentsUI:Hide()
    
end

--Creates the Configuration frame UI
function FrameHelper:CreateConfigFrame()

end

--##########################################################################################################################
--                                  Frames Component handler
--##########################################################################################################################
