local Type, Version = "TalentRow", 1
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local function Frame_OnEnter(frame)
    frame.obj:Fire("OnEnter")
end

local function Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function TalentButton_OnEnter(talentButton)
    if(talentButton.talentID ~= nil) then
        GameTooltip:SetOwner(talentButton, "ANCHOR_RIGHT");
        GameTooltip:SetTalent(talentButton.talentID);
        talentButton.UpdateTooltip = TalentButton_OnEnter;
    end
end

local function TalentButton_OnLeave(talentButton)
    GameTooltip_Hide();
end

local function TalentButton_OnClick(talentButton)
    local frame = talentButton:GetParent()
    if(frame ~= nil and frame.obj.currentColumnSelected ~= talentButton.column) then
        frame.obj:SetColumnSelected(talentButton.column)
        frame.obj:Fire("TalentSelected", talentButton.column, frame.obj.currentColumnSelected)
    end
end

local methods =
{
	["OnAcquire"] = function(self)
		self:SetHeight(42)
		self:SetWidth(629)
        self:Show()
        self:SetLevel()
        for i, talentButton in ipairs(self.talents) do
            self:SetColumnSelected(i)
            self:SetTalentName(i)
            self:SetTalentIcon(i)
            self:SetTalentID(i)
        end
    end,
    
    ["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
    end,
    
    ["SetLevel"] = function(self, level) 
        self.levelLabel:SetText(level)
    end,

    ["SetTalentIcon"] = function(self, column, icon)
        self.talents[column].icon:SetTexture(icon)
    end,

    ["SetTalentName"] = function(self, column, name)
        self.talents[column].name:SetText(name)
    end,

    ["SetTalentID"] = function(self, column, id)
        self.talents[column].talentID = id
    end,
    ["GetTalentID"] = function(self, column)
        return self.talents[column].talentID
    end,
 
    ["SetColumnSelected"] = function(self, column)
        if(self.currentColumnSelected ~= nil) then
            self.talents[self.currentColumnSelected].knownSelection:Hide()
            self.currentColumnSelected = nil
        end

        if(column ~= nil) then
            self.talents[column].knownSelection:Show()
            self.currentColumnSelected = column
        end
    end,
	-- ["OnRelease"] = nil,
}



local function Constructor()
    local name = "AceGUI30TalentRow" .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", name, UIParent, "PlayerTalentRowTemplate")
    frame:Hide()
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", Frame_OnEnter)
    frame:SetScript("OnLeave", Frame_OnLeave)

    -- Need to unhook all scripts and hook it to custom ones as we are not goint to want to changes talents in here
    for i, talentButton in ipairs(frame["talents"]) do
        talentButton:SetScript("OnLoad", nil)
        talentButton:SetScript("OnClick", TalentButton_OnClick)
        talentButton:SetScript("OnEvent", nil)
        talentButton:SetScript("OnEnter", TalentButton_OnEnter)
        talentButton:SetScript("OnLeave", TalentButton_OnLeave)
        talentButton:SetScript("OnDragStart", nil)
        talentButton:SetScript("OnReceiveDrag", nil)
        talentButton.column = i
    end

    local widget = {
        frame = frame,
        levelLabel = frame["level"],
        talents = frame["talents"],
		type  = Type
    }
    
	for method, func in pairs(methods) do
		widget[method] = func
    end
    
	return AceGUI:RegisterAsWidget(widget)
end


AceGUI:RegisterWidgetType(Type, Constructor, Version)