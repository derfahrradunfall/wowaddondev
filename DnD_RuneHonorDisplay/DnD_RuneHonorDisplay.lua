local addonName = "DnD_RuneHonorDisplay"
local f = CreateFrame("Frame")
local db

-- ----------------------------------------------------------------------------
-- Konfiguration
-- ----------------------------------------------------------------------------
local RUNE_ITEM_NAME = "Rune of Ascension"
local ARENA_CONQUEST_CURRENCY_ID = 390 -- WotLK-ID für Arena/Conquest Points

-- Kompakte Basisgröße für genau 3 Zeilen
local BASE_WIDTH, BASE_HEIGHT = 160, 74
local MIN_SCALE, MAX_SCALE = 0.5, 3.0

local mainFrame, resizeGrip
local runeIcon, runeLabel, runeCount
local honorIcon, honorLabel, honorCount
local conquestIcon, conquestLabel, conquestCount

-- ----------------------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------------------
local function GetItemIconSafe(itemName)
    local icon = GetItemIcon(itemName)
    if not icon then
        GetItemInfo(itemName)
        icon = "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    return icon
end

local function UpdateValues()
    -- 1. Rune of Ascension (RoA)
    local runeAmount = GetItemCount(RUNE_ITEM_NAME, true) or 0
    runeCount:SetText(runeAmount)
    runeIcon:SetTexture(GetItemIconSafe(RUNE_ITEM_NAME))

    -- 2. Honor Points (Methode 2: GetHonorCurrency)
    local honorAmount = 0
    if GetHonorCurrency then
        honorAmount = GetHonorCurrency()
    end
    honorCount:SetText(honorAmount or 0)

    -- 3. Conquest / Arena Points
    local conquestAmount = 0
    -- Versuche zuerst GetArenaCurrency (Standard WotLK für PvP-Währung)
    if GetArenaCurrency then
        conquestAmount = GetArenaCurrency()
    else
        -- Fallback auf das Currency-System (ID 390)
        local _, amt = GetCurrencyInfo(ARENA_CONQUEST_CURRENCY_ID)
        conquestAmount = amt or 0
    end
    conquestCount:SetText(conquestAmount or 0)
end

-- ----------------------------------------------------------------------------
-- UI-Aufbau
-- ----------------------------------------------------------------------------
local function CreateUI()
    mainFrame = CreateFrame("Frame", "RuneHonorDisplayFrame", UIParent)
    mainFrame:SetSize(BASE_WIDTH, BASE_HEIGHT)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetFrameStrata("MEDIUM")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")

    if db.point then
        mainFrame:SetPoint(db.point, UIParent, db.relativePoint or "CENTER", db.xOfs or 0, db.yOfs or 0)
    else
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    end
    mainFrame:SetScale(db.scale or 1.0)

    mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint()
        db.point, db.relativePoint, db.xOfs, db.yOfs = p, rp, x, y
    end)

    -- Rahmen & Hintergrund initial komplett unsichtbar
    mainFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 12, edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3}
    })
    mainFrame:SetBackdropColor(0, 0, 0, 0)
    mainFrame:SetBackdropBorderColor(1, 1, 1, 0)

    -- Hover-Effekt: Sichtbar nur bei Maus-Over
    mainFrame:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0, 0, 0, 0.65)
        self:SetBackdropBorderColor(1, 1, 1, 0.8)
    end)
    mainFrame:SetScript("OnLeave", function(self)
        if not MouseIsOver(self) then
            self:SetBackdropColor(0, 0, 0, 0)
            self:SetBackdropBorderColor(1, 1, 1, 0)
        end
    end)

    -- Zeile 1: RoA
    runeIcon = mainFrame:CreateTexture(nil, "ARTWORK")
    runeIcon:SetSize(14, 14)
    runeIcon:SetPoint("TOPLEFT", 10, -8)

    runeLabel = mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    runeLabel:SetPoint("LEFT", runeIcon, "RIGHT", 5, 0)
    runeLabel:SetText("RoA:")

    runeCount = mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    runeCount:SetPoint("LEFT", runeLabel, "RIGHT", 5, 0)
    runeCount:SetTextColor(1, 0.82, 0)

    -- Zeile 2: Honor
    honorIcon = mainFrame:CreateTexture(nil, "ARTWORK")
    honorIcon:SetSize(14, 14)
    honorIcon:SetPoint("TOPLEFT", runeIcon, "BOTTOMLEFT", 0, -6)
    honorIcon:SetTexture("Interface\\Icons\\PVPCurrency-Honor-Alliance")

    honorLabel = mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    honorLabel:SetPoint("LEFT", honorIcon, "RIGHT", 5, 0)
    honorLabel:SetText("Honor:")

    honorCount = mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    honorCount:SetPoint("LEFT", honorLabel, "RIGHT", 5, 0)
    honorCount:SetTextColor(1, 0.82, 0)

    -- Zeile 3: Conquest Points
    conquestIcon = mainFrame:CreateTexture(nil, "ARTWORK")
    conquestIcon:SetSize(14, 14)
    conquestIcon:SetPoint("TOPLEFT", honorIcon, "BOTTOMLEFT", 0, -6)
    conquestIcon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-Alliance")

    conquestLabel = mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    conquestLabel:SetPoint("LEFT", conquestIcon, "RIGHT", 5, 0)
    conquestLabel:SetText("Conquest:")

    conquestCount = mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    conquestCount:SetPoint("LEFT", conquestLabel, "RIGHT", 5, 0)
    conquestCount:SetTextColor(1, 0.82, 0)

    -- Resize-Griff unten rechts
    resizeGrip = CreateFrame("Frame", nil, mainFrame)
    resizeGrip:SetSize(14, 14)
    resizeGrip:SetPoint("BOTTOMRIGHT", -1, 1)
    resizeGrip:EnableMouse(true)
    resizeGrip:SetFrameLevel(mainFrame:GetFrameLevel() + 10)

    local gripTex = resizeGrip:CreateTexture(nil, "OVERLAY")
    gripTex:SetAllPoints(true)
    gripTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

    resizeGrip:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        self.isSizing = true
        self.startX, self.startY = GetCursorPosition()
        self.startScale = mainFrame:GetScale()
    end)

    resizeGrip:SetScript("OnMouseUp", function(self, button)
        if button ~= "LeftButton" then return end
        self.isSizing = false
        db.scale = mainFrame:GetScale()
    end)

    resizeGrip:SetScript("OnUpdate", function(self)
        if not self.isSizing then return end
        local x, y = GetCursorPosition()
        local delta = ((x - self.startX) + (self.startY - y)) / (2 * BASE_WIDTH)
        local newScale = self.startScale + delta
        if newScale < MIN_SCALE then newScale = MIN_SCALE end
        if newScale > MAX_SCALE then newScale = MAX_SCALE end
        mainFrame:SetScale(newScale)
    end)

    resizeGrip:SetScript("OnEnter", function(self)
        mainFrame:SetBackdropColor(0, 0, 0, 0.65)
        mainFrame:SetBackdropBorderColor(1, 1, 1, 0.8)
    end)
    
    resizeGrip:SetScript("OnLeave", function(self)
        if not MouseIsOver(mainFrame) then
            mainFrame:SetBackdropColor(0, 0, 0, 0)
            mainFrame:SetBackdropBorderColor(1, 1, 1, 0)
        end
    end)
end

-- ----------------------------------------------------------------------------
-- Event-Handling & Ticker
-- ----------------------------------------------------------------------------
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        RuneHonorDisplayDB = RuneHonorDisplayDB or {}
        db = RuneHonorDisplayDB

        CreateUI()
        UpdateValues()
        
        -- Periodischer Refresh als Sicherheitsnetz gegen Server-Verzögerungen
        if C_Timer and C_Timer.NewTicker then
            C_Timer.NewTicker(2, function() UpdateValues() end)
        else
            local total = 0
            mainFrame:SetScript("OnUpdate", function(self, elapsed)
                total = total + elapsed
                if total >= 2 then
                    UpdateValues()
                    total = 0
                end
            end)
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "BAG_UPDATE" or event == "CURRENCY_DISPLAY_UPDATE" then
        if db then UpdateValues() end
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("BAG_UPDATE")
f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")