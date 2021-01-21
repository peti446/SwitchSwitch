local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))
local AuthorList = "|cffff7d0aGeloch-Sanguino(EU)|r"
local FrameName = "SwitchSwitchFrame"
local frame, menuContainer, tabContainer, UISpecialFramesCurrentID, LastFramePosition
local SelectedMenuItemID = 1
local MenuEntries = {}


function SwitchSwitch:RegisterMenuEntry(menuName)
    local newIndex= #MenuEntries + 1
    -- This is the tale that will be send to all
    local entry = {
        ["name"] = menuName,
        ["id"] = newIndex,
        ["enabled"] = false,
        ["label"] = nil, -- Label table
        --OnOpen(parent) -- Function
        --OnClose()      -- Function
        -- *             -- Custom functions and variables for that specific page, we dont put them into the global one as we dont really want it there most of the time
    }

    MenuEntries[newIndex] = entry
    return entry
end

local function OnMainFrameClosed(frame)
    if UISpecialFrames[UISpecialFramesCurrentID] == FrameName then
        tremove(UISpecialFrames, UISpecialFramesCurrentID)
    end

    SwitchSwitch:HideMainFrame()
end


local function SetMenuEntryEnabled(newID)
    local oldMenuEntry = MenuEntries[SelectedMenuItemID]
    local newMenuEntry = MenuEntries[newID]
    SelectedMenuItemID = newID

    if(oldMenuEntry ~= nil) then
        oldMenuEntry.label:SetColor(0.8941, 0.73725, 0.01961)
        oldMenuEntry.label:SetHighlight("Interface\\QuestFrame\\UI-QuestTitleHighlight")

        -- Initialisation calls
        if(oldMenuEntry.enabled and oldMenuEntry.OnClose ~= nil) then
            oldMenuEntry:OnClose()
            oldMenuEntry.enabled = false
            
        end
    end

    -- We want to clear all the contents before we start drawing again
    tabContainer:ReleaseChildren()
    tabContainer:SetLayout("Flow")
    if(newMenuEntry ~= nil) then
        newMenuEntry.label:SetColor(1, 1, 1)
        newMenuEntry.label:SetHighlight("")
        if(not newMenuEntry.enabled and newMenuEntry.OnOpen ~= nil) then
            newMenuEntry:OnOpen(tabContainer)
            newMenuEntry.enabled = true
        end
    end
end

local function OnMenuLabelClicked(newLabel)
    local newMenuEntryID = newLabel:GetUserData("id")
    if(newMenuEntryID ~= nil and newMenuEntryID <= #MenuEntries) then
        SetMenuEntryEnabled(newMenuEntryID)
    end
end

function SwitchSwitch:GetMainFrame()
    if(frame) then return frame end
    frame = AceGUI:Create("Frame")
    frame.frame:SetFrameStrata("HIGH")

    --make closable with escape
    _G[FrameName] = frame.frame
    tinsert(UISpecialFrames, FrameName)
    UISpecialFramesCurrentID = #UISpecialFrames
    
    --Start setup
    frame:SetTitle("SwitchSwitch")
    frame:SetStatusText("Created by: " .. AuthorList .. " Version: " .. GetAddOnMetadata("SwitchSwitch", "Version"))
    frame:SetLayout("Flow")
    frame:SetCallback("OnClose", OnMainFrameClosed)
    frame:SetHeight(600)
    frame:SetWidth(870)
    frame.frame:SetMinResize(870, 600)
    frame:PauseLayout()

    --Set up menu  side
    menuContainer = AceGUI:Create("SimpleGroup")
    menuContainer:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, 0)
    menuContainer:SetPoint("BOTTOMRIGHT", frame.content, "BOTTOMLEFT", 160, 0)
    menuContainer:SetWidth(150)
    menuContainer:PauseLayout()
    local previousLabel
    for i=1, #MenuEntries do
        local menuLabel = AceGUI:Create("InteractiveLabel")
        local currentMenuEntry = MenuEntries[i]
        menuLabel:SetText(currentMenuEntry.name);
        menuLabel:SetWidth(130)
        menuLabel:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
        menuLabel:SetColor(0.8941, 0.73725, 0.01961)
        menuLabel:SetHighlight("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        menuLabel:SetCallback("OnClick", OnMenuLabelClicked)
        menuLabel:SetUserData("id", currentMenuEntry.id)

        if not previousLabel then
            menuLabel:SetPoint("TOPLEFT", menuContainer.content, "TOPLEFT", 10, -10)
            menuLabel:SetPoint("TOPRIGHT", menuContainer.content, "TOPRIGHT", -10, -10)
        else
            menuLabel:SetPoint("TOPLEFT", previousLabel.frame, "BOTTOMLEFT", 0, -10)
            menuLabel:SetPoint("TOPRIGHT", previousLabel.frame, "BOTTOMRIGHT", 0, -10)
        end
        previousLabel = menuLabel
        currentMenuEntry.label = menuLabel
        menuContainer:AddChild(menuLabel)
    end
    frame:AddChild(menuContainer)
    frame:SetUserData("menu", menuContainer)

    -- The tab container is where the components for each sub file in MenuItems will be displayed in
    tabContainer = AceGUI:Create("SimpleGroup")
    tabContainer:SetLayout("Flow")
    tabContainer:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, 0)
    tabContainer:SetPoint("BOTTOMLEFT", menuContainer.frame, "BOTTOMRIGHT", 5, 0)
    frame:AddChild(tabContainer)
    frame:SetUserData("content", tabContainer)
    -- If we do not pause layout we will need this to resize correctly
    --tabContainer:SetWidth(frame.frame:GetWidth() - 160 - 20 - 5)
    --[[ frame.OnWidthSet = function(self)
        local tabContainer = self:GetUserData("content")
        tabContainer:SetWidth(self.frame:GetWidth() - 160 - 20 - 5)
        SwitchSwitch:DebugPrint("Width:" ..  self.frame:GetHeight())
    end
    frame.OnHeightSet = function(self)
        local tabContainer = self:GetUserData("content")
        local menuContainer = self:GetUserData("menu")
        tabContainer:SetHeight(self.frame:GetHeight() - 20)
        menuContainer:SetHeight(self.frame:GetHeight() - 20)
        SwitchSwitch:DebugPrint("Height:" .. self.frame:GetHeight())
    end--]]

    -- We dont want it to appear in the middle all time, just after reloads, otherwise close where the user closed
    if(LastFramePosition) then
        frame:ClearAllPoints()
        frame:SetPoint(unpack(LastFramePosition))
    end

    -- Lets start up with selecting the first labe as this is the default one
    SetMenuEntryEnabled(SelectedMenuItemID)

    return frame
end


function SwitchSwitch:ShowMainFrame()
    if(not frame) then
        self:GetMainFrame():Show()
    end
end

function SwitchSwitch:ShowMainFrame_Config()
    self:ShowMainFrame()
    SetMenuEntryEnabled(3)
end

function SwitchSwitch:HideMainFrame()
    if(not frame) then return end
    -- Frame extis and is valid from here on
    LastFramePosition = {frame.frame:GetPoint(1)}
    LastFramePosition[2] = type(LastFramePosition[2]) == "table" and LastFramePosition[2]:GetName() or LastFramePosition[2]
    frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")
    -- We want to make sure the with and height is always right
    frame.OnWidthSet = nil
    frame.OnHeightSet = nil
    local oldMenuEntry = MenuEntries[SelectedMenuItemID]
    if(oldMenuEntry ~= nil) then
        -- Initialisation calls
        if(oldMenuEntry.enabled and oldMenuEntry.OnClose ~= nil) then
            oldMenuEntry:OnClose()
            oldMenuEntry.enabled = false
            
        end
    end
    frame:Release()
    frame = nil
end

function SwitchSwitch:TogleMainFrame()
    if(not frame) then
        self:ShowMainFrame()
    else
        self:HideMainFrame()
    end
end