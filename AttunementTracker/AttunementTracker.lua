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
displayFrame:SetSize(300, 400)
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

-- Add a title to the display frame
local title = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -15)
title:SetText("Raid & Dungeon Attunements")

-- Create close button
local closeButton = CreateFrame("Button", nil, displayFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -5, -5)

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
        ["Molten Core"] = true,
        ["Blackwing Lair"] = IsQuestComplete(7761), -- Example quest ID
        
        -- The Burning Crusade
        ["Karazhan"] = true,
        ["Karazhan Crypts"] = CheckBags(254076), -- Check for the keystone in bags
        ["Gruul's Lair"] = true,
        ["Magtheridon's Lair"] = true,
        ["Serpentshrine Cavern"] = IsQuestComplete(10901), -- Example quest ID
        ["Tempest Keep"] = true,
        ["Mount Hyjal"] = IsQuestComplete(10445), -- Example quest ID
        ["Black Temple"] = IsQuestComplete(10985), -- Example quest ID
        
        -- Wrath of the Lich King
        ["Icecrown Citadel"] = true
    }
    
    return attunements
end

-- Create the content frame for attunements
local contentFrame = CreateFrame("Frame", nil, displayFrame)
contentFrame:SetSize(280, 360)
contentFrame:SetPoint("TOP", 0, -40)

-- Function to create category headers
local function CreateCategoryHeader(text, yOffset)
    local header = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 10, -yOffset)
    header:SetText(text)
    return yOffset + 25
end

-- Function to update the display
local function UpdateDisplay()
    -- Clear existing content
    for _, child in pairs({contentFrame:GetChildren()}) do
        child:Hide()
    end
    
    local attunements = CheckAttunements()
    local yOffset = 0
    
    -- Classic raids
    yOffset = CreateCategoryHeader("Classic Raids", yOffset)
    for raid in pairs({["Molten Core"] = true, ["Blackwing Lair"] = true}) do
        local raidText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        raidText:SetPoint("TOPLEFT", 20, -yOffset)
        raidText:SetText(raid)
        
        local status = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        status:SetPoint("TOPRIGHT", -20, -yOffset)
        status:SetText(attunements[raid] and "|cFF00FF00Attuned|r" or "|cFFFF0000Not Attuned|r")
        
        yOffset = yOffset + 20
    end
    
    -- TBC raids and dungeons
    yOffset = yOffset + 10
    yOffset = CreateCategoryHeader("The Burning Crusade", yOffset)
    for raid in pairs({
        ["Karazhan"] = true,
        ["Karazhan Crypts"] = true,
        ["Gruul's Lair"] = true,
        ["Magtheridon's Lair"] = true,
        ["Serpentshrine Cavern"] = true,
        ["Tempest Keep"] = true,
        ["Mount Hyjal"] = true,
        ["Black Temple"] = true
    }) do
        local raidText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        raidText:SetPoint("TOPLEFT", 20, -yOffset)
        raidText:SetText(raid)
        
        local status = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        status:SetPoint("TOPRIGHT", -20, -yOffset)
        if raid == "Karazhan Crypts" then
            local hasItem = attunements[raid]
            status:SetText(hasItem and "|cFF00FF00Has Keystone|r" or "|cFFFF0000No Keystone|r")
        else
            status:SetText(attunements[raid] and "|cFF00FF00Attuned|r" or "|cFFFF0000Not Attuned|r")
        end
        
        yOffset = yOffset + 20
    end
    
    -- WotLK raids
    yOffset = yOffset + 10
    yOffset = CreateCategoryHeader("Wrath of the Lich King", yOffset)
    for raid in pairs({["Icecrown Citadel"] = true}) do
        local raidText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        raidText:SetPoint("TOPLEFT", 20, -yOffset)
        raidText:SetText(raid)
        
        local status = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        status:SetPoint("TOPRIGHT", -20, -yOffset)
        status:SetText(attunements[raid] and "|cFF00FF00Attuned|r" or "|cFFFF0000Not Attuned|r")
        
        yOffset = yOffset + 20
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
        -- Initialize any necessary data
        print("Attunement Tracker loaded. Click the minimap button to check your raid attunements.")
    end
end)

frame:RegisterEvent("PLAYER_LOGIN")