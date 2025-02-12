-- Addon name and initialization
local addonName, addon = ...
local frame = CreateFrame("Frame")

-- Create the minimap button
local minimapButton = CreateFrame("Button", "AttunementTrackerMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

-- Set the button texture
minimapButton:SetNormalTexture("Interface\\Icons\\Achievement_Dungeon_HEROIC_GloryoftheRaider")
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Create the main display frame
local displayFrame = CreateFrame("Frame", "AttunementTrackerFrame", UIParent)
displayFrame:SetSize(700, 500)  -- Increased width and height
displayFrame:SetPoint("CENTER")
displayFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
displayFrame:Hide()

-- Create scroll frame
local scrollFrame = CreateFrame("ScrollFrame", nil, displayFrame)
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -10, 10)

-- Create scroll child frame
local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetSize(680, 460)

-- Add a title to the display frame
local title = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -15)
title:SetText("Raid & Dungeon Attunements")

-- Create close button
local closeButton = CreateFrame("Button", nil, displayFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -5, -5)

-- Raid requirements table
local raidRequirements = {
    -- Classic
    ["Onyxia's Lair (Classic)"] = "Quest required: Drakefire Amulet questline",
    ["Blackwing Lair"] = "Quest required: Blackhand's Command",
    ["Molten Core"] = "Level 55+ and requires Molten Core Medallion or Honored with Hydraxian Waterlords",
    ["Naxxramas (Classic)"] = "Level 60 and Honored with Argent Dawn",
    
    -- The Burning Crusade
    ["Karazhan"] = "Quest required: Master's Key questline",
    ["Black Temple"] = "Quest required: Black Temple attunement chain",
    ["Mount Hyjal"] = "Quest required: Battle of Mount Hyjal attunement",
    ["Serpentshrine Cavern"] = "Quest required: The Cudgel of Kar'desh",
    ["Tempest Keep"] = "Quest required: Trial of the Naaru",
    ["Karazhan Crypts"] = "Requires Attuned Crypt Keystone"
}

-- Function to check if player has an item in bags
local function CheckBags(itemID)
    local count = GetItemCount(itemID)
    if count and count > 0 then
        return true
    end
    return false
end

-- Function to check attunements
local function CheckAttunements()
    local attunements = {
        -- Classic
        ["Molten Core"] = CheckBags(666000) or true, -- Check for Molten Core Medallion
        ["Onyxia's Lair (Classic)"] = true,
        ["Blackwing Lair"] = IsQuestComplete(7761),
        ["Zul'Gurub"] = true,
        ["Ruins of Ahn'Qiraj"] = true,
        ["Temple of Ahn'Qiraj"] = true,
        ["Naxxramas (Classic)"] = true,
        
        -- The Burning Crusade
        ["Karazhan"] = true,
        ["Karazhan Crypts"] = CheckBags(254076),
        ["Gruul's Lair"] = true,
        ["Magtheridon's Lair"] = true,
        ["Serpentshrine Cavern"] = IsQuestComplete(10901),
        ["Tempest Keep"] = true,
        ["Mount Hyjal"] = IsQuestComplete(10445),
        ["Black Temple"] = IsQuestComplete(10985),
        ["Zul'Aman"] = true,
        ["Sunwell Plateau"] = true
    }
    
    return attunements
end

-- Function to create category headers
local function CreateCategoryHeader(text, xOffset, yOffset)
    local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", xOffset, -yOffset)
    header:SetText(text)
    return header
end

-- Function to create a raid entry with tooltip
local function CreateRaidEntry(raid, xOffset, yOffset)
    -- Create text frame for the raid name
    local raidFrame = CreateFrame("Frame", nil, scrollChild)
    raidFrame:SetSize(200, 20)
    raidFrame:SetPoint("TOPLEFT", xOffset, -yOffset)
    
    -- Add raid name text
    local raidText = raidFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raidText:SetPoint("LEFT", 0, 0)
    raidText:SetText(raid)
    
    -- Enable mouse events for the frame
    raidFrame:EnableMouse(true)
    
    -- Add tooltip functionality if this raid has requirements
    if raidRequirements[raid] then
        raidFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(raid, 1, 1, 1)
            GameTooltip:AddLine(raidRequirements[raid], 1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        
        raidFrame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end
    
    return raidFrame
end

-- Function to update the display
local function UpdateDisplay()
    -- Clear existing content
    for _, child in pairs({scrollChild:GetChildren()}) do
        child:Hide()
    end
    
    local attunements = CheckAttunements()
    local yOffset = 20  -- Increased initial offset
    
    -- Classic raids (Left column)
    local leftXOffset = 40  -- Increased left margin
    CreateCategoryHeader("Classic", leftXOffset, yOffset)
    yOffset = yOffset + 30  -- Increased spacing after header
    
    local classicRaids = {
        ["Molten Core"] = true,
        ["Onyxia's Lair (Classic)"] = true,
        ["Blackwing Lair"] = true,
        ["Zul'Gurub"] = true,
        ["Ruins of Ahn'Qiraj"] = true,
        ["Temple of Ahn'Qiraj"] = true,
        ["Naxxramas (Classic)"] = true
    }
    
    for raid in pairs(classicRaids) do
        local raidFrame = CreateRaidEntry(raid, leftXOffset, yOffset)
        
        local status = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        status:SetPoint("RIGHT", raidFrame, "RIGHT", 30, 0)
        status:SetText(attunements[raid] and "|cFF00FF00Attuned|r" or "|cFFFF0000Not Attuned|r")
        
        yOffset = yOffset + 30  -- Increased spacing between raids
    end
    
    -- TBC raids (Right column)
    local rightXOffset = 380  -- Increased spacing between columns
    yOffset = 20  -- Reset yOffset for the right column
    CreateCategoryHeader("The Burning Crusade", rightXOffset, yOffset)
    yOffset = yOffset + 30  -- Increased spacing after header
    
    local tbcRaids = {
        ["Karazhan"] = true,
        ["Karazhan Crypts"] = true,
        ["Gruul's Lair"] = true,
        ["Magtheridon's Lair"] = true,
        ["Serpentshrine Cavern"] = true,
        ["Tempest Keep"] = true,
        ["Mount Hyjal"] = true,
        ["Black Temple"] = true,
        ["Zul'Aman"] = true,
        ["Sunwell Plateau"] = true
    }
    
    for raid in pairs(tbcRaids) do
        local raidFrame = CreateRaidEntry(raid, rightXOffset, yOffset)
        
        local status = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        status:SetPoint("RIGHT", raidFrame, "RIGHT", 30, 0)
        if raid == "Karazhan Crypts" then
            local hasItem = attunements[raid]
            status:SetText(hasItem and "|cFF00FF00Has Keystone|r" or "|cFFFF0000No Keystone|r")
        else
            status:SetText(attunements[raid] and "|cFF00FF00Attuned|r" or "|cFFFF0000Not Attuned|r")
        end
        
        yOffset = yOffset + 30  -- Increased spacing between raids
    end
end

-- Minimap button click handler
minimapButton:SetScript("OnClick", function()
    if displayFrame:IsShown() then
        displayFrame:Hide()
    else
        UpdateDisplay()
        displayFrame:Show()
    end
end)

-- Make the frame movable
displayFrame:SetMovable(true)
displayFrame:EnableMouse(true)
displayFrame:RegisterForDrag("LeftButton")
displayFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
displayFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Initialize the addon
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print("Attunement Tracker loaded. Click the minimap button to check your raid attunements.")
    end
end)

frame:RegisterEvent("PLAYER_LOGIN")