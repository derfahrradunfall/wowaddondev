local addonName = "AutoJunkDelete_vDnD"
local f = CreateFrame("Frame")
local db

-- Vorwärtsdeklarationen und Zustandsvariablen
local AutoCleanPass
local mainFrame, mainBtn, moverOverlay
local isMerchantOpen = false

-- Eingebettete dauerhafte Whitelist (wird niemals gelöscht/verkauft)
local BUILT_IN_WHITELIST = {
    [6948] = true,      -- Ruhestein
}

-- ----------------------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------------------

local function IsWhitelisted(id)
    if not id then return false end
    if BUILT_IN_WHITELIST[id] then return true end
    return db.whitelist and db.whitelist[id] == true
end

local function IsBlacklisted(id)
    if not id then return false end
    return db.blacklist and db.blacklist[id] == true
end

local function MigrateListToKeyValue(list)
    if not list then return {} end
    local isOldArrayFormat = false
    for k, v in pairs(list) do
        if type(k) == "number" and type(v) == "number" then
            isOldArrayFormat = true
            break
        end
    end
    if not isOldArrayFormat then return list end
    local migrated = {}
    for _, v in pairs(list) do
        if type(v) == "number" then migrated[v] = true end
    end
    return migrated
end

-- Zählt die Gesamtzahl aller freien Plätze in allen normalen Haupttaschen (0-4)
local function GetTotalFreeSlots()
    local free = 0
    for bag = 0, 4 do
        local slots, bagType = GetContainerNumFreeSlots(bag)
        if bagType == 0 then
            free = free + slots
        end
    end
    return free
end

-- Prüft, ob ein Gegenstand basierend auf Qualität und Typ gelöscht/verkauft werden darf
local function IsItemDeletableOrSellable(id, quality, link)
    if not id then return false end
    
    -- Absolute Priorität 1: Wenn es gewhitelistet ist, NIEMALS anfassen!
    if IsWhitelisted(id) then return false end
    
    -- Absolute Priorität 2: Grundregel – Keine Questgegenstände berühren
    local _, _, _, _, _, itemType = GetItemInfo(link)
    if itemType == "Quest" then return false end
    
    -- Explizit auf der Blacklist? Dann immer freigegeben (da Whitelist oben schon ausgeschlossen wurde)
    if IsBlacklisted(id) then return true end
    
    -- GEÄNDERT: Automatisch (ohne Blacklist-Eintrag) ist ab jetzt NUR NOCH
    -- Grau (0) erlaubt. Weiß (1) und alles darüber wird NUR noch gelöscht/
    -- verkauft, wenn es oben bereits über IsBlacklisted(id) explizit
    -- freigegeben wurde.
    if quality and quality == 0 then
        return true
    end
    
    return false
end

-- Verkauf-Logik für den Händler (Verkauft zulässige Items restlos)
local function SellJunkToMerchant()
    local soldCount = 0
    local earnedGold = 0
    
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local id = tonumber(link:match("item:(%d+)"))
                local name, _, quality, _, _, _, _, _, _, _, sellPrice = GetItemInfo(link)
                local _, count, locked = GetContainerItemInfo(bag, slot)
                
                if id and not name then
                    GetItemInfo(id)
                elseif id and not locked and not IsWhitelisted(id) and IsItemDeletableOrSellable(id, quality, link) then
                    if sellPrice and sellPrice > 0 then
                        UseContainerItem(bag, slot)
                        soldCount = soldCount + 1
                        earnedGold = earnedGold + (sellPrice * (count or 1))
                    end
                end
            end
        end
    end
    
    if soldCount > 0 then
        local gold = math.floor(earnedGold / 10000)
        local silver = math.floor((earnedGold % 10000) / 100)
        local copper = earnedGold % 100
        print(string.format("|cFF40FF40[AJD Merchant]|r Gegenstände verkauft für: %dg %ds %dc", gold, silver, copper))
    end
end

-- Optimierte Bereinigung: Hält beim Auto-Check Plätze frei, löscht bei manuellem Klick immer 1 Item
local function ProcessSpaceProtection(isManualClick)
    if isMerchantOpen then return end

    local currentFree = GetTotalFreeSlots()
    -- Wenn manuell geklickt, erzwingen wir, dass mindestens 1 Item gesucht wird
    local neededSlots = isManualClick and 1 or (2 - currentFree)

    -- Nur aktiv werden, wenn Plätze gebraucht werden ODER manuell geklickt wurde
    if neededSlots > 0 then
        local deletableItems = {}
        
        -- Gesamtes Inventar nach löschbaren Items scannen
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local link = GetContainerItemLink(bag, slot)
                if link then
                    local id = tonumber(link:match("item:(%d+)"))
                    if id then
                        local name, _, quality, _, _, _, _, _, _, _, sellPrice = GetItemInfo(link)
                        local _, count, locked = GetContainerItemInfo(bag, slot)

                        if id and not name then
                            GetItemInfo(id)
                        elseif not locked and count and count > 0 and not IsWhitelisted(id) and IsItemDeletableOrSellable(id, quality, link) then
                            local itemPrice = sellPrice or 0

                            table.insert(deletableItems, {
                                bag = bag,
                                slot = slot,
                                id = id,
                                link = link,
                                name = name or "Unbekannt",
                                count = count,
                                value = itemPrice * count -- Stack-Gesamtwert (Berücksichtigt vorhandene Anzahl)
                            })
                        end
                    end
                end
            end
        end

        -- Keine zulässigen Items zum Löschen gefunden? Abbrechen.
        if #deletableItems == 0 then 
            if isManualClick then
                print("|cFFFF5555[AJD]|r Keine löschbaren Gegenstände (Grau/Blacklist) gefunden.")
            end
            return 
        end

        -- Sortierung: Wertlose Items (0c) ans Ende, wertvolle Items aufsteigend nach Stack-Wert (Günstigste zuerst)
        table.sort(deletableItems, function(a, b)
            if (a.value > 0) ~= (b.value > 0) then
                return a.value > 0
            end
            return a.value < b.value
        end)

        -- Löscht exakt die benötigte Anzahl (beim Klick = 1, beim Autoschutz = was fehlt)
        local loops = math.min(neededSlots, #deletableItems)

        for i = 1, loops do
            local item = deletableItems[i]
            if item and item.id and not IsWhitelisted(item.id) then
                PickupContainerItem(item.bag, item.slot)
                DeleteCursorItem()
                print(string.format("|cFF40FF40[AJD]|r Gegenstand manuell gelöscht: %s ×%d (Wert: %dc)", item.link or item.name, item.count, item.value))
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- Periodischer Check bei geöffneten Taschen
-- ----------------------------------------------------------------------------

local bagCheckElapsed = 0
f:SetScript("OnUpdate", function(self, elapsed)
    if isMerchantOpen then return end

    bagCheckElapsed = bagCheckElapsed + elapsed
    if bagCheckElapsed >= 0.8 then
        bagCheckElapsed = 0

        local anyBagOpen = false
        for i = 1, NUM_CONTAINER_FRAMES do
            local frame = _G["ContainerFrame" .. i]
            if frame and frame:IsShown() then
                anyBagOpen = true
                break
            end
        end

        if anyBagOpen and db and db.cleanAuto then
            AutoCleanPass()
        end
    end
end)

-- ----------------------------------------------------------------------------
-- Whitelist/Blacklist umschalten (Shift + Rechtsklick)
-- ----------------------------------------------------------------------------
local function CycleList(id, link)
    db.blacklist = db.blacklist or {}
    db.whitelist = db.whitelist or {}
    local itemLabel = link or ("item " .. id)

    if db.blacklist[id] then
        db.blacklist[id] = nil
        db.whitelist[id] = true
        print("|cFF40FF40[AJD]|r Verschoben zur Whitelist: " .. itemLabel)
    elseif db.whitelist[id] then
        db.whitelist[id] = nil
        db.blacklist[id] = true
        print("|cFF40FF40[AJD]|r Verschoben zur Blacklist: " .. itemLabel)
    else
        db.blacklist[id] = true
        print("|cFF40FF40[AJD]|r Hinzugefügt zur Blacklist: " .. itemLabel)
    end
end

local function HookBagItemClick()
    if ContainerFrameItemButton_OnModifiedClick then
        local old = ContainerFrameItemButton_OnModifiedClick
        ContainerFrameItemButton_OnModifiedClick = function(self, button)
            if IsShiftKeyDown() and button == "RightButton" then
                local bag = self:GetParent():GetID()
                local slot = self:GetID()
                local link = GetContainerItemLink(bag, slot)
                local id = link and tonumber(link:match("item:(%d+)"))
                if id then
                    CycleList(id, link)
                    return
                end
            end
            old(self, button)
        end
    end
end

AutoCleanPass = function()
    ProcessSpaceProtection()
end

-- ----------------------------------------------------------------------------
-- Positions-Verwaltung für das UI
-- ----------------------------------------------------------------------------

local function SavePosition()
    local p, _, rp, x, y = mainFrame:GetPoint()
    db.point, db.relativePoint, db.xOfs, db.yOfs = p, rp, x, y
    print("|cFF40FF40[AJD]|r Position gespeichert.")
end

local function CreateMoverOverlay()
    if moverOverlay then return end
    moverOverlay = CreateFrame("Frame", nil, mainFrame)
    moverOverlay:SetAllPoints(true)
    moverOverlay:SetFrameStrata("HIGH")
    moverOverlay:EnableMouse(true)
    moverOverlay:SetMovable(true)
    moverOverlay:RegisterForDrag("LeftButton")

    moverOverlay:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left=4,right=4,top=4,bottom=4}
    })
    moverOverlay:SetBackdropColor(0.1, 0.9, 0.1, 0.35)
    moverOverlay:SetBackdropBorderColor(0.1, 1, 0.1, 0.9)

    local txt = moverOverlay:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    txt:SetPoint("CENTER")
    txt:SetText("Ziehen → danach /ajd lock")

    moverOverlay:SetScript("OnDragStart", function() mainFrame:StartMoving() end)
    moverOverlay:SetScript("OnDragStop", function() mainFrame:StopMovingOrSizing(); SavePosition() end)
    moverOverlay:Hide()
end

local function UnlockPosition()
    CreateMoverOverlay()
    moverOverlay:Show()
    print("|cFF40FF40[AJD]|r Bewegungsmodus aktiv. Button verschieben, danach /ajd lock")
end

local function LockPosition()
    if moverOverlay then moverOverlay:Hide() end
    SavePosition()
    print("|cFF40FF40[AJD]|r Position gesperrt.")
end

-- ----------------------------------------------------------------------------
-- Gemeinsame Einstellungsübersicht (Button-Rechtsklick & /ajd)
-- ----------------------------------------------------------------------------

local function ShowSettings()
    print(" ")
    print("|cFF40FF40=== AutoJunkDelete Einstellungen ===|r")
    print(" ")
    print("  /ajd clean_auto_toggle   Automatischer Schutz (Tasche leeren):  " .. (db.cleanAuto and "|cFF00FF00AN|r" or "|cFFFF5555AUS|r"))
    print("  /ajd wl <id>      Von Whitelist hinzufügen/entfernen (niemals löschen/verkaufen)")
    print("  /ajd bl <id>      Von Blacklist hinzufügen/entfernen (Auto-Verkauf / Löschen bei vollen Taschen)")
    print("  /ajd clean_man    Intelligente Bereinigung jetzt manuell erzwingen")
    print("  /ajd unlock       Button verschiebbar machen")
    print("  /ajd lock         Position speichern & Bewegungsmodus beenden")
    print(" ")
    print("|cFFAAAAAAHinweis:|r Ruhestein (ID 6948) und Quest-Items sind dauerhaft geschützt.")
    print("Regel: Verarbeitet automatisch nur Graue Items, sowie zusätzlich alles, was du per /ajd bl auf die Blacklist gesetzt hast.")
    print("Beim Händler: Verkauft alle zulässigen Items restlos.")
    print("Beim Farmen / Klick / Behälter öffnen: Löscht die wertlosesten Stapel, sobald die Tasche komplett voll ist.")
    print("Shift + Rechtsklick auf ein Item schaltet es direkt zwischen Black- und Whitelist um.")
    print(" ")
end

-- ----------------------------------------------------------------------------
-- Interface-Optionsmenü
-- ----------------------------------------------------------------------------

local function CreateOptionsPanel()
    local panel = CreateFrame("Frame", "AutoJunkDeleteOptionsPanel")
    panel.name = "AutoJunkDelete_vDnD"
    InterfaceOptions_AddCategory(panel)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("AutoJunkDelete Einstellungen")

    local toggleCleanAuto = CreateFrame("CheckButton", "AJD_CleanAutoCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    toggleCleanAuto:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
    toggleCleanAuto.label = toggleCleanAuto:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    toggleCleanAuto.label:SetPoint("LEFT", toggleCleanAuto, "RIGHT", 5, 0)
    toggleCleanAuto.label:SetText("Intelligenten Schutz aktivieren (reagiert sofort aggressiv bei vollen Taschen)")
    toggleCleanAuto:SetScript("OnClick", function(self) db.cleanAuto = self:GetChecked() end)
    toggleCleanAuto:SetChecked(db.cleanAuto)

    local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    hint:SetPoint("TOPLEFT", toggleCleanAuto, "BOTTOMLEFT", 0, -20)
    hint:SetText("Schnelles Umschalten: Shift + Rechtsklick auf Gegenstand in der Tasche (automatisch nur Grau, alles andere nur wenn geblacklisted)")

    panel:SetScript("OnShow", function() toggleCleanAuto:SetChecked(db.cleanAuto) end)
end

-- ----------------------------------------------------------------------------
-- UI-Erstellung (Hauptbutton)
-- ----------------------------------------------------------------------------

local function CreateMainButton()
    mainFrame = CreateFrame("Frame", "AJDMainFrame", UIParent)
    mainFrame:SetSize(88, 28)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetFrameStrata("LOW")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)

    if db.point then
        mainFrame:SetPoint(db.point, UIParent, db.relativePoint or "CENTER", db.xOfs or 0, db.yOfs or 0)
    else
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -160)
    end

    mainBtn = CreateFrame("Button", nil, mainFrame, "GameMenuButtonTemplate")
    mainBtn:SetAllPoints(true)
    mainBtn:SetText("AJD")
    mainBtn:RegisterForClicks("AnyUp")

	mainBtn:SetScript("OnClick", function(_, button)
        if button == "LeftButton" then
            if isMerchantOpen then
                SellJunkToMerchant()
            else
                ProcessSpaceProtection(true) -- HIER: true übergeben für erzwungenes Löschen
            end
        else
            ShowSettings()
        end
    end)

    mainBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("|cFF40FF40AutoJunkDelete|r")
        GameTooltip:AddLine("Links-Klick → Müll verkaufen (Händler) / Platz freimachen (Farmen)")
        GameTooltip:AddLine("Rechts-Klick → Einstellungen anzeigen")
        GameTooltip:Show()
    end)
    mainBtn:SetScript("OnLeave", GameTooltip_Hide)
end

-- ----------------------------------------------------------------------------
-- Tooltip-Hook für IDs
-- ----------------------------------------------------------------------------

local function HookTooltip()
    GameTooltip:HookScript("OnTooltipSetItem", function(tt)
        local _, link = tt:GetItem()
        if link then
            -- WICHTIG: tonumber() ist hier nötig, da IsBlacklisted()/
            -- IsWhitelisted() ihre Tabellen mit numerischen Keys führen
            -- (siehe CycleList). Ein String-Key ("6948") würde nie treffen.
            local id = tonumber(link:match("item:(%d+)"))
            if id then
                -- GEÄNDERT: Zeigt jetzt nur noch den reinen Status dynamisch an,
                -- statt einer festen Anleitungszeile. Rot = Blacklist,
                -- Grün = Whitelist. Ist das Item auf keiner der beiden Listen,
                -- wird nur die ID neutral angezeigt (keine falsche Aussage).
                if IsBlacklisted(id) then
                    tt:AddLine("ID: " .. id .. "; Blacklist", 1, 0.2, 0.2) -- Rot
                elseif IsWhitelisted(id) then
                    tt:AddLine("ID: " .. id .. "; Whitelist", 0.2, 1, 0.2) -- Grün
                else
                    tt:AddLine("ID: " .. id, 0.8, 0.8, 0.8) -- Neutral, keine Liste
                end
            end
        end
    end)
end

-- ----------------------------------------------------------------------------
-- Slash-Befehle (/ajd)
-- ----------------------------------------------------------------------------

local function SlashHandler(msg)
    local cmd, arg = (msg or ""):trim():lower():match("^(%S+)%s*(.*)")
    
    if cmd == "wl" then
        local id = tonumber(arg)
        if id then
            db.whitelist = db.whitelist or {}
            db.blacklist = db.blacklist or {}
            if db.whitelist[id] then
                db.whitelist[id] = nil
                print("|cFF40FF40[AJD Whitelist]|r Entfernt: " .. id)
            else
                db.whitelist[id] = true
                db.blacklist[id] = nil
                print("|cFF40FF40[AJD Whitelist]|r Hinzugefügt: " .. id)
            end
        else
            print("|cFFFF5555[AJD]|r Nutzung: /ajd wl <itemID>")
        end
    elseif cmd == "bl" or cmd == "blacklist" then
        local id = tonumber(arg)
        if id then
            db.blacklist = db.blacklist or {}
            db.whitelist = db.whitelist or {}
            if db.blacklist[id] then
                db.blacklist[id] = nil
                print("|cFF40FF40[AJD Blacklist]|r Entfernt: " .. id)
            else
                db.blacklist[id] = true
                db.whitelist[id] = nil
                print("|cFF40FF40[AJD Blacklist]|r Hinzugefügt: " .. id)
            end
        else
            print("|cFFFF5555[AJD]|r Nutzung: /ajd bl <itemID>")
        end
    elseif cmd == "list_clear" then
        db.whitelist = {}
        db.blacklist = {}
        print("|cFF40FF40[AJD]|r Alle Listen wurden vollständig geleert!")
    elseif cmd == "clean_man" then
        if isMerchantOpen then
            SellJunkToMerchant()
        else
            ProcessSpaceProtection()
        end
    elseif cmd == "clean_auto_toggle" then
        db.cleanAuto = not db.cleanAuto
        print("|cFF40FF40[AJD]|r Automatischer Taschenschutz: " .. (db.cleanAuto and "|cFF00FF00AN|r" or "|cFFFF5555AUS|r"))
    elseif cmd == "unlock" then
        UnlockPosition()
    elseif cmd == "lock" then
        LockPosition()
    else
        ShowSettings()
    end
end

SLASH_AJD1 = "/ajd"
SlashCmdList["AJD"] = SlashHandler

-- ----------------------------------------------------------------------------
-- Event-Registrierung & Handling
-- ----------------------------------------------------------------------------

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Name muss exakt mit "## SavedVariables:" in der .Toc uebereinstimmen,
        -- sonst wird die Tabelle nie gespeichert/geladen (siehe Toc-Kommentar).
        AutoJunkDeleteDB_vDnD = AutoJunkDeleteDB_vDnD or {}
        db = AutoJunkDeleteDB_vDnD

        db.whitelist    = MigrateListToKeyValue(db.whitelist)
        db.blacklist    = MigrateListToKeyValue(db.blacklist)

        if db.cleanAuto == nil then db.cleanAuto = true end

        CreateMainButton()
        HookTooltip()
        HookBagItemClick()
        CreateOptionsPanel()

        print("|cFF40FF40[AJD] geladen|r  –  /ajd für Einstellungen")
        print("|cFFFFFF00Shift + Rechtsklick:|r Schaltet Items zwischen Blacklist/Whitelist um")
        print("Schutzregel: Hält beim Farmen genau 1 Taschenplatz frei (automatisch nur Grau + Blacklist).")
        
    elseif event == "MERCHANT_SHOW" then
        isMerchantOpen = true
        SellJunkToMerchant()
        
    elseif event == "MERCHANT_CLOSED" then
        isMerchantOpen = false
        
    elseif event == "LOOT_CLOSED" or event == "BAG_UPDATE" then
        if db.cleanAuto and not isMerchantOpen then
            AutoCleanPass()
        end
        
    elseif event == "PLAYER_LOGIN" then
        local removed = 0
        for id in pairs(db.blacklist) do
            if db.whitelist[id] then
                db.blacklist[id] = nil
                removed = removed + 1
            end
        end
        if removed > 0 then
            print("|cFF40FF40[AJD]|r " .. removed .. " doppelte Blacklist/Whitelist-Einträge bereinigt (Whitelist gewinnt).")
        end
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("MERCHANT_SHOW")
f:RegisterEvent("MERCHANT_CLOSED")
f:RegisterEvent("LOOT_CLOSED")
f:RegisterEvent("BAG_UPDATE")
f:RegisterEvent("PLAYER_LOGIN")