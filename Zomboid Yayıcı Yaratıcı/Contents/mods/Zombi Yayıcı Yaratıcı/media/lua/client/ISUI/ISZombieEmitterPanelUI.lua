ISZombieEmitterPanelUI = ISCollapsableWindow:derive("ISZombieEmitterPanelUI")
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local HEADER_HGT = FONT_HGT_SMALL + 2 * 2

function ISZombieEmitterPanelUI.onDeleteZone(this, button, name)
    if button.internal == "EVET" then
        ZombieEmitterUtils.deleteZone(name)
    end
end

function ISZombieEmitterPanelUI:toggleCreateZoneVisibility(isVisible)
    for _, zoneButton in ipairs(self.zoneTypeButtons) do
        zoneButton:setVisible(isVisible)
    end
end

function ISZombieEmitterPanelUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    local y = FONT_HGT_MEDIUM + HEADER_HGT + 30

    -- İptal Butonu
    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self,
        ISZombieEmitterPanelUI.onClick);
    self.no.internal = "CANCEL";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.no);

    -- Bölge Oluştur Butonu
    self.createZoneBtn = ISButton:new(self.no:getRight() + 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        "Bölge Oluştur", self, ISZombieEmitterPanelUI.onClick);
    self.createZoneBtn.internal = "CREATE_ZONE";
    self.createZoneBtn.anchorTop = false
    self.createZoneBtn.anchorBottom = true
    self.createZoneBtn:initialise();
    self.createZoneBtn:instantiate();
    self.createZoneBtn.borderColor = { r = 0, g = 1, b = 0, a = 1 };
    self.createZoneBtn.backgroundColor = { r = 0, g = 0.75, b = 0, a = 1 };
    self.createZoneBtn.backgroundColorMouseOver = { r = 0, g = 0.5, b = 0, a = 1 };
    self.createZoneBtn.textColor = { r = 0, g = 0, b = 0, a = 1 };
    self:addChild(self.createZoneBtn);

    -- Bölge Sil Butonu
    self.removeZoneBtn = ISButton:new(self.createZoneBtn:getRight() + 10, self:getHeight() - padBottom - btnHgt, btnWid,
        btnHgt,
        "Bölge Sil", self, ISZombieEmitterPanelUI.onClick);
    self.removeZoneBtn.internal = "DELETE_ZONE";
    self.removeZoneBtn.anchorTop = false
    self.removeZoneBtn.anchorBottom = true
    self.removeZoneBtn:initialise();
    self.removeZoneBtn:instantiate();
    self.removeZoneBtn.borderColor = { r = 1, g = 0, b = 0, a = 1 };
    self.removeZoneBtn.backgroundColor = { r = 0.75, g = 0, b = 0, a = 1 };
    self.removeZoneBtn.backgroundColorMouseOver = { r = 0.5, g = 0, b = 0, a = 1 };
    self.removeZoneBtn.textColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.removeZoneBtn);

    -- Yenile Butonu
    self.refreshBtn = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        getText("IGUI_DbViewer_Refresh"), self, ISZombieEmitterPanelUI.onClick);
    self.refreshBtn.internal = "REFRESH";
    self.refreshBtn.anchorTop = false
    self.refreshBtn.anchorBottom = true
    self.refreshBtn:initialise();
    self.refreshBtn:instantiate();
    self.refreshBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.refreshBtn);

    local labelX = 150 - (getTextManager():MeasureStringX(UIFont.Large, "Zombi Çıkış Bölgeleri") / 2)
    self.zombieEmitterLbl = ISLabel:new(labelX, y, 20, "Zombi Çıkış Bölgeleri", 1, 1, 1, 1, UIFont.Large, true)
    self:addChild(self.zombieEmitterLbl)

    self.allZonesList = ISScrollingListBox:new(10, self.zombieEmitterLbl:getBottom() + 20, 300,
        300)
    self.allZonesList:initialise();
    self.allZonesList:instantiate();
    self.allZonesList.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.allZonesList.selected = 0;
    self.allZonesList.joypadParent = self;
    self.allZonesList.font = UIFont.NewSmall;
    self.allZonesList.doDrawItem = self.drawZonesDatas;
    self.allZonesList.drawBorder = true;
    self.allZonesList.borderColor = { r = 1, g = 1, b = 1, a = 1 }
    self.allZonesList:addColumn("Bölge Adı", 0)
    self:addChild(self.allZonesList);
    self:getZones();

    -- Işınlanma Butonu
    self.teleportBtn = ISButton:new(self.allZonesList:getX(), self.allZonesList:getBottom() + 10, btnWid, btnHgt,
        "Işınlan", self, ISZombieEmitterPanelUI.onClick);
    self.teleportBtn.internal = "TELEPORT";
    self.teleportBtn.anchorTop = false
    self.teleportBtn.anchorBottom = false
    self.teleportBtn:initialise();
    self.teleportBtn:instantiate();
    self.teleportBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.teleportBtn);

    -- Bölge Düzenle Butonu
    self.editZoneBtn = ISButton:new(self.allZonesList:getRight() - btnWid, self.teleportBtn:getY(), btnWid, btnHgt,
        "Bölge Düzenle", self, ISZombieEmitterPanelUI.onClick);
    self.editZoneBtn.internal = "EDIT_ZONE";
    self.editZoneBtn.anchorTop = false
    self.editZoneBtn.anchorBottom = false
    self.editZoneBtn:initialise();
    self.editZoneBtn:instantiate();
    self.editZoneBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.editZoneBtn);

    -- Bölge Türü Seçim Popup Butonları (Varsayılan olarak gizli)
    self.zoneTypeButtons = {}
    local popupX = self.no:getX()
    local popupY = self.createZoneBtn:getY() - btnHgt - 10
    local zoneTypes = {
        { name = "Dairesel Bölge", internal = "CREATE_CIRCULAR_ZONE" },
        { name = "Halka Bölge",    internal = "CREATE_DONUT_ZONE" },
        { name = "Çizgi Bölge",     internal = "CREATE_LINE_ZONE" },
        {
            name = "İptal",
            internal = "CANCEL_ZONE_CREATION",
            borderColor = { r = 1, g = 0, b = 0, a = 1 },
            backgroundColor = { r = 0.75, g = 0, b = 0, a = 1 },
            backgroundColorMouseOver = { r = 0.5, g = 0, b = 0, a = 1 },
            textColor = { r = 1, g = 1, b = 1, a = 1 }
        }
    }

    for i, zoneType in ipairs(zoneTypes) do
        local button = ISButton:new(popupX + (i - 1) * (btnWid + 10), popupY, btnWid, btnHgt,
            zoneType.name, self, ISZombieEmitterPanelUI.onClick);
        button.internal = zoneType.internal;
        button.anchorTop = false
        button.anchorBottom = false
        button:initialise();
        button:instantiate();
        button.borderColor = zoneType.borderColor or { r = 0.5, g = 0.5, b = 1, a = 1 };                             -- Kenarlık rengi yumuşak mavi
        button.backgroundColor = zoneType.backgroundColor or { r = 0.3, g = 0.3, b = 0.8, a = 1 };                   -- Arka plan rengi yumuşak mavi
        button.backgroundColorMouseOver = zoneType.backgroundColorMouseOver or { r = 0.2, g = 0.2, b = 0.6, a = 1 }; -- Fare üzerine gelindiğinde daha koyu mavi
        button.textColor = zoneType.textColor or { r = 1, g = 1, b = 1, a = 1 };                                     -- Metin rengi beyaz
        button:setVisible(false)
        self:addChild(button);
        table.insert(self.zoneTypeButtons, button)
    end
end

function ISZombieEmitterPanelUI:onClick(button)
    local player = self.chr
    local square = player:getSquare()

    if button.internal == "CANCEL" then
        self:close();
    elseif button.internal == "REFRESH" then
        self:RefreshUI()
    elseif button.internal == "CREATE_ZONE" then
        local isVisible = self.zoneTypeButtons[1]:getIsVisible()
        self:toggleCreateZoneVisibility(not isVisible)
    elseif button.internal == "DELETE_ZONE" then
        if not self.selectedZone then return end
        if not ZombieEmitterUtils.doesZoneExist(self.selectedZone.zoneName) then return end

        if ZombieEmitterUtils.deleteZoneModal then
            ZombieEmitterUtils.deleteZoneModal:setVisible(false)
            ZombieEmitterUtils.deleteZoneModal:removeFromUIManager()
            ZombieEmitterUtils.deleteZoneModal = nil
        end

        local text = "\"" .. self.selectedZone.zoneName .. "\" bölgesini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz!"

        ZombieEmitterUtils.deleteZoneModal = ZombieEmitterUtils.createModalDialog(text, true, nil,
            ISZombieEmitterPanelUI.onDeleteZone, self.selectedZone.zoneName)
        ZombieEmitterUtils.deleteZoneModal:initialise()
        ZombieEmitterUtils.deleteZoneModal:addToUIManager()
    elseif button.internal == "CREATE_CIRCULAR_ZONE" then
        self:toggleCreateZoneVisibility(false)

        if ISZombieEmitterCircularZoneUI.instance then
            ISZombieEmitterCircularZoneUI.instance:close()
        end

        local ui = ISZombieEmitterCircularZoneUI:new(0, 0, player, square, false, nil);
        ui:initialise();
        ui:addToUIManager();
    elseif button.internal == "CREATE_DONUT_ZONE" then
        self:toggleCreateZoneVisibility(false)

        if ISZombieEmitterDonutZoneUI.instance then
            ISZombieEmitterDonutZoneUI.instance:close()
        end

        local ui = ISZombieEmitterDonutZoneUI:new(0, 0, player, square, false, nil);
        ui:initialise();
        ui:addToUIManager();
    elseif button.internal == "CREATE_LINE_ZONE" then
        self:toggleCreateZoneVisibility(false)

        if ISZombieEmitterLineZoneUI.instance then
            ISZombieEmitterLineZoneUI.instance:close()
        end

        local ui = ISZombieEmitterLineZoneUI:new(0, 0, player, square, false, nil);
        ui:initialise();
        ui:addToUIManager();
    elseif button.internal == "CANCEL_ZONE_CREATION" then
        self:toggleCreateZoneVisibility(false)
    elseif button.internal == "TELEPORT" then
        local zoneCoords = ZombieEmitterUtils.getZonesCoords(self.selectedZone.zoneName)
        local x, y, z = zoneCoords.x, zoneCoords.y, zoneCoords.z
        if x and y and z then
            player:setX(x);
            player:setY(y);
            player:setZ(z);
            player:setLx(x)
            player:setLy(y)
            player:setLz(z)
        end
    elseif button.internal == "EDIT_ZONE" then
        local zone = self.selectedZone
        local zoneType = zone.type

        if zoneType == "circular" then
            local square = getSquare(zone.x, zone.y, zone.z)
            local ui = ISZombieEmitterCircularZoneUI:new(0, 0, self.chr, square, true, zone);
            ui:initialise();
            ui:addToUIManager();
        elseif zoneType == "donut" then
            local square = getSquare(zone.x, zone.y, zone.z)
            local ui = ISZombieEmitterDonutZoneUI:new(0, 0, getPlayer(), square, true, zone);
            ui:initialise();
            ui:addToUIManager();
        elseif zoneType == "line" then
            local square = getSquare(zone.Ax, zone.Ay, zone.Az)
            local ui = ISZombieEmitterLineZoneUI:new(0, 0, getPlayer(), square, true, zone);
            ui:initialise();
            ui:addToUIManager();
        end
    end
end

function ISZombieEmitterPanelUI:update()
    ISCollapsableWindow.update(self)

    local selectedZone = self.allZonesList.items[self.allZonesList.selected]

    if selectedZone and (self.selectedZone ~= selectedZone.item.data) then
        local selectedZoneData = selectedZone.item.data
        self.selectedZone = selectedZoneData
    end
end

function ISZombieEmitterPanelUI:prerender()
    ISCollapsableWindow.prerender(self);

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawText("Zombi Çıkış Paneli",
        self.width / 2 - (getTextManager():MeasureStringX(UIFont.Title, "Zombi Çıkış Paneli") / 2), 20, 1, 1, 1, 1,
        UIFont.Title)

    local width = 250
    local height = self.allZonesList:getHeight() + 20
    local x = self:getWidth() - width - 10
    local y = self.allZonesList.y - 20
    self:drawRect(x, y, width, height, 1, 0, 0, 0);
    self:drawRectBorder(x, y, width, height, 1, 1, 1, 1);

    self:drawTextCentre("Bölge Detayları", x + (width / 2), y + (height * 0.01), 1, 1, 1, 1, UIFont.Large)
    if not self.selectedZone then
        local message = "Seçili bölge yok."
        self:drawTextCentre(message, x + (width / 2), y + (height / 2), 1, 1, 1, 1, UIFont.Medium)
    else
        local zoneDetails = {
            radius = tostring(self.selectedZone.radius),
            innerRadius = tostring(self.selectedZone.innerRadius),
            spawnInterval = tonumber(self.selectedZone.spawnInterval),
            timeType = self.selectedZone.timeType,
            totalSpawnedZombies = tostring(self.selectedZone.totalSpawnedZombies),
            type = self.selectedZone.type,
            lastTimestamp = tonumber(self.selectedZone.lastTimestamp)
        }

        local detailsY = y + 30

        if zoneDetails.type == "circular" or zoneDetails.type == "donut" then
            self:drawText("Yarıçap", x + 10, detailsY, 1, 1, 1, 1, UIFont.Medium)
            detailsY = detailsY + 17
            self:drawText(zoneDetails.radius, x + 10, detailsY, 0.5, 0.5, 0.5, 1, UIFont.Small)
            detailsY = detailsY + 25
        end

        if zoneDetails.type == "donut" then
            self:drawText("İç Yarıçap", x + 10, detailsY, 1, 1, 1, 1, UIFont.Medium)
            detailsY = detailsY + 17
            self:drawText(zoneDetails.innerRadius, x + 10, detailsY, 0.5, 0.5, 0.5, 1, UIFont.Small)
            detailsY = detailsY + 25
        end

        -- Çıkış aralığı ve zaman türünü birleştir
        local spawnIntervalStr = string.format("%d %s",
            zoneDetails.spawnInterval,
            zoneDetails.timeType == "ms" and "Milisaniye" or
            (zoneDetails.timeType == "s" and "Saniye" or
                (zoneDetails.timeType == "m" and "Dakika" or
                    (zoneDetails.timeType == "h" and "Saat" or "Gün"))))

        self:drawText("Çıkış Aralığı", x + 10, detailsY, 1, 1, 1, 1, UIFont.Medium)
        detailsY = detailsY + 17
        self:drawText(spawnIntervalStr, x + 10, detailsY, 0.5, 0.5, 0.5, 1, UIFont.Small)
        detailsY = detailsY + 25

        self:drawText("Toplam Çıkan Zombiler", x + 10, detailsY, 1, 1, 1, 1, UIFont.Medium)
        detailsY = detailsY + 17
        self:drawText(zoneDetails.totalSpawnedZombies, x + 10, detailsY, 0.5, 0.5, 0.5, 1, UIFont.Small)
        detailsY = detailsY + 25

        self:drawText("Tür", x + 10, detailsY, 1, 1, 1, 1, UIFont.Medium)
        detailsY = detailsY + 17
        self:drawText(zoneDetails.type, x + 10, detailsY, 0.5, 0.5, 0.5, 1, UIFont.Small)
        detailsY = detailsY + 25

        -- Bir sonraki çıkışa kadar geçen süreyi hesapla, farklı zaman türlerini dikkate al
        local currentTimestamp = getTimestamp()
        local timeElapsed = currentTimestamp - zoneDetails.lastTimestamp
        local timeTypeFactor = {
            ms = 1 / 1000, -- Milisaniyeyi saniyeye çevir
            s = 1,         -- Saniye olduğu gibi kalır
            m = 60,        -- Dakikayı saniyeye çevir
            h = 3600,      -- Saati saniyeye çevir
            d = 86400      -- Günü saniyeye çevir
        }
        local spawnIntervalInSeconds = zoneDetails.spawnInterval * (timeTypeFactor[zoneDetails.timeType] or 1)
        local timeUntilNextSpawn = spawnIntervalInSeconds - timeElapsed
        local timeLeft = timeUntilNextSpawn

        local timeLeftStr = ""
        if timeLeft > 0 then
            if zoneDetails.timeType == "d" then
                timeLeftStr = string.format("%.0f gün", timeLeft / 86400)
            elseif zoneDetails.timeType == "h" then
                local hours = math.floor(timeLeft / 3600)
                local minutes = math.floor((timeLeft % 3600) / 60)
                local seconds = math.floor(timeLeft % 60)
                timeLeftStr = string.format("%d saat, %d dakika, %d saniye", hours, minutes, seconds)
            elseif zoneDetails.timeType == "m" then
                local minutes = math.floor(timeLeft / 60)
                local seconds = math.floor(timeLeft % 60)
                timeLeftStr = string.format("%d dakika, %d saniye", minutes, seconds)
            else
                timeLeftStr = string.format("%.0f saniye", timeLeft)
            end
        else
            timeLeftStr = "Çıkışa hazır"
        end

        self:drawText("Bir Sonraki Çıkışa Kalan Süre", x + 10, detailsY, 1, 1, 1, 1, UIFont.Medium)
        detailsY = detailsY + 17
        self:drawText(timeLeftStr, x + 10, detailsY, 0.5, 0.5, 0.5, 1, UIFont.Small)
    end

    if not self.selectedZone then
        self.teleportBtn:setEnable(false)
        self.teleportBtn.tooltip = "<RGB:255,0,0> Işınlanmak için bir bölge seçmelisiniz"

        self.editZoneBtn:setEnable(false)
        self.editZoneBtn.tooltip = "<RGB:255,0,0> Düzenlemek için bir bölge seçmelisiniz"

        self.removeZoneBtn:setEnable(false)
        self.removeZoneBtn.tooltip = "<RGB:255,0,0> Silmek için bir bölge seçmelisiniz"
    else
        self.teleportBtn:setEnable(true)
        self.teleportBtn.tooltip = "Seçili bölgeye ışınlan"

        self.editZoneBtn:setEnable(true)
        self.editZoneBtn.tooltip = "Seçili bölgeyi düzenle"

        self.removeZoneBtn:setEnable(true)
        self.removeZoneBtn.tooltip = "Seçili bölgeyi sil"
    end
end

function ISZombieEmitterPanelUI:render()
    ISCollapsableWindow.render(self);
end

function ISZombieEmitterPanelUI:close()
    ISZombieEmitterPanelUI.instance = nil
    self:setVisible(false)
    self:removeFromUIManager()
end

function ISZombieEmitterPanelUI:getZones()
    local allZones = ZombieEmitterUtils.getAllZones()
    if allZones then
        self.allZones = allZones
        self:populateZonesList()
    end
end

function ISZombieEmitterPanelUI:populateZonesList()
    self.allZonesList:clear()
    self.selectedZone = nil

    if not self.allZones then
        return
    end

    local zoneNames = {}

    for zoneName, _ in pairs(self.allZones) do
        table.insert(zoneNames, zoneName)
    end

    table.sort(zoneNames, function(a, b)
        return a:lower() < b:lower()
    end)

    for i, zoneName in ipairs(zoneNames) do
        local zoneData = self.allZones[zoneName]
        zoneData.zoneName = zoneName

        local item = { data = zoneData }
        self.allZonesList:addItem(zoneName, item)

        if i == 1 then
            self.selectedZone = zoneData
        end
    end
end

function ISZombieEmitterPanelUI:drawZonesDatas(y, item, alt)
    local alpha = 0.9
    local itemHeightWithPadding = self.itemheight + 4
    local zone = item.item.data
    local isSelected = self.selected == item.index

    self:drawRectBorder(0, y, self:getWidth(), itemHeightWithPadding, alpha, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    if isSelected then
        self:drawRect(0, y, self:getWidth(), itemHeightWithPadding, 0.3, 0.7, 0.35, 0.15)
        self.selectedZone = zone
    end

    local zoneName = zone.zoneName

    self:drawText(zoneName, 10, y + 2, 1, 1, 1, alpha, UIFont.Medium)

    item.item.yPosition = y

    return y + itemHeightWithPadding
end

function ISZombieEmitterPanelUI:RefreshUI()
    self.allZonesList:clear()
    self.selectedZones = nil

    self:getZones()
end

function ISZombieEmitterPanelUI:new(character)
    local o = {}
    local width = 700;
    local height = 520
    local x = getCore():getScreenWidth() / 2 - width / 2
    local y = getCore():getScreenHeight() / 2 - height / 2
    o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 };
    o.listHeaderColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.75 };
    o.moveWithMouse = true;
    o.chr = character
    o:setResizable(false)
    ISZombieEmitterPanelUI.instance = o;
    return o;
end