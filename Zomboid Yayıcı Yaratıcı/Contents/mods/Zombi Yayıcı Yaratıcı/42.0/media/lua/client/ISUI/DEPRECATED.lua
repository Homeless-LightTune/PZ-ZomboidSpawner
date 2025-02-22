ISZombieEmitterCurrentZonesUI = ISPanel:derive("ISZombieEmitterCurrentZonesUI");
ZombieEmiter = ZombieEmitter or {}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local HEADER_HGT = FONT_HGT_SMALL + 2 * 2

---Paneli başlatır ve bileşenleri oluşturur
function ISZombieEmitterCurrentZonesUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    -- İptal butonu
    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self,
        ISZombieEmitterCurrentZonesUI.onClick);
    self.no.internal = "CANCEL";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.no);

    -- Bölge listesi
    local y = 20 + FONT_HGT_MEDIUM + HEADER_HGT
    self.datas = ISScrollingListBox:new(10, y, self.width - 20, self.height - padBottom - btnHgt - padBottom - y)
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
    self:addChild(self.datas);

    -- Yenile butonu
    self.refreshBtn = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        getText("IGUI_DbViewer_Refresh"), self, ISZombieEmitterCurrentZonesUI.onClick);
    self.refreshBtn.internal = "REFRESH";
    self.refreshBtn.anchorTop = false
    self.refreshBtn.anchorBottom = true
    self.refreshBtn:initialise();
    self.refreshBtn:instantiate();
    self.refreshBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.refreshBtn);

    -- Kaldır butonu
    self.removeBtn = ISButton:new(self.refreshBtn.x - btnWid - 25, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        "Kaldır", self, ISZombieEmitterCurrentZonesUI.onClick);
    self.removeBtn.internal = "REMOVE";
    self.removeBtn.anchorTop = false
    self.removeBtn.anchorBottom = true
    self.removeBtn:initialise();
    self.removeBtn:instantiate();
    self.removeBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.removeBtn);

    -- Işınlanma butonu
    self.teleportBtn = ISButton:new(self.removeBtn.x - btnWid - 25, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        "Işınlan", self, ISZombieEmitterCurrentZonesUI.onClick);
    self.teleportBtn.internal = "TELEPORT";
    self.teleportBtn.anchorTop = false
    self.teleportBtn.anchorBottom = true
    self.teleportBtn:initialise();
    self.teleportBtn:instantiate();
    self.teleportBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.teleportBtn);

    -- Düzenle butonu
    self.editBtn = ISButton:new(self.teleportBtn.x - btnWid - 25, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        "Bölgeyi Düzenle", self, ISZombieEmitterCurrentZonesUI.onClick);
    self.editBtn.internal = "EDITZONE";
    self.editBtn.anchorTop = false
    self.editBtn.anchorBottom = true
    self.editBtn:initialise();
    self.editBtn:instantiate();
    self.editBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.editBtn);

    -- Bölgeleri yükle
    self:getZones();
end

---Bölgeleri alır ve listeyi doldurur
function ISZombieEmitterCurrentZonesUI:getZones()
    local zonesData = ModData.get("ZOMBIE_EMITTER_DATA")
    if zonesData and zonesData.zones then
        self.zones = zonesData.zones
        self:populateList()
    end
end

---Seçili bölgenin ID'sini döndürür
---@return string
function ISZombieEmitterCurrentZonesUI:getSelectedZoneID()
    return ZombieEmitter.selectedZone.zoneID
end

---Listeyi bölgelerle doldurur
function ISZombieEmitterCurrentZonesUI:populateList()
    self.datas:clear()
    ZombieEmitter.selectedZone = nil;

    for i, zone in ipairs(self.zones) do
        local item = {}
        item.zone = zone

        self.datas:addItem(zone.name, item)
        if i == 1 then
            ZombieEmitter.selectedZone = zone
        end
    end
end

---Paneli günceller
function ISZombieEmitterCurrentZonesUI:update()
    local selectedItem = self.datas.items[self.datas.selected]
    if selectedItem then
        local selectedZoneData = selectedItem.item.zone
        ZombieEmitter.selectedZone = selectedZoneData
    end
end

---Liste öğelerini çizer
---@param y number Y koordinatı
---@param item table Liste öğesi
---@param alt boolean Alternatif renk kullanılsın mı?
---@return number
function ISZombieEmitterCurrentZonesUI:drawDatas(y, item, alt)
    local a = 0.9

    self:drawRectBorder(0, y, self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local zone = item.item.zone

    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15)
        ZombieEmitter.selectedZone = zone
    end

    self:drawText(zone.zoneName, 10, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.radius), 105, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.innerRadius), 205, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.spawnInterval) .. " (" .. zone.timeType .. ")", 305, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.count), 405, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.maxZombies), 505, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.totalSpawnedZombies), 605, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.crawler), 715, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.isFallOnFront), 805, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.isFakeDead), 915, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.knockedDown), 1015, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.health), 1135, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.outfit), 1205, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.type), 1305, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(zone.zoneID), 1405, y + 2, 1, 1, 1, a, self.font)

    return y + self.itemheight
end

---Panelin ön render işlemlerini gerçekleştirir
function ISZombieEmitterCurrentZonesUI:prerender()
    local z = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);
    self:drawText("Mevcut Bölgeleri Görüntüle",
        self.width / 2 - (getTextManager():MeasureStringX(UIFont.Medium, "Mevcut Bölgeleri Görüntüle") / 2), z,
        1, 1, 1, 1, UIFont.Medium);
    self.datas.doDrawItem = self.drawDatas
    self.currentZoneX, self.currentZoneY, self.currentZoneZ =
        ZombieEmitter.selectedZone and (ZombieEmitter.selectedZone.x or ZombieEmitter.selectedZone.Ax) or nil,
        ZombieEmitter.selectedZone and (ZombieEmitter.selectedZone.y or ZombieEmitter.selectedZone.Ay) or nil,
        ZombieEmitter.selectedZone and (ZombieEmitter.selectedZone.z or ZombieEmitter.selectedZone.Az) or nil
end

---Panelin render işlemlerini gerçekleştirir
function ISZombieEmitterCurrentZonesUI:render()
    self:drawRectBorder(self.datas.x, self.datas.y - HEADER_HGT, self.datas:getWidth(), HEADER_HGT + 1, 1,
        self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x, 1 + self.datas.y - HEADER_HGT, self.datas.width, HEADER_HGT, self.listHeaderColor.a,
        self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);
    self:drawRect(self.datas.x + 100, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 200, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 300, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 400, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 500, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 600, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 710, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 800, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 910, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 1010, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 1130, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 1200, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 1300, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x + 1400, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r,
        self.borderColor.g, self.borderColor.b);

    self:drawText("Bölge Adı", self.datas.x + 5, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Yarıçap", self.datas.x + 105, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("İç Yarıçap", self.datas.x + 205, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Spawn Aralığı", self.datas.x + 305, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Sayı", self.datas.x + 405, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Maks. Zombi", self.datas.x + 505, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Top. Spawn", self.datas.x + 605, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Crawler", self.datas.x + 715, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Öne Düşme", self.datas.x + 805, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Sahte Ölü", self.datas.x + 915, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Yere Ser", self.datas.x + 1015, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Sağlık", self.datas.x + 1135, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Kıyafet", self.datas.x + 1205, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Tip", self.datas.x + 1305, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Bölge ID", self.datas.x + 1405, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
end

---Buton tıklama olaylarını işler
---@param button ISButton Tıklanan buton
function ISZombieEmitterCurrentZonesUI:onClick(button)
    if button.internal == "CANCEL" then
        self:close();
    end
    if button.internal == "REFRESH" then
        self:RefreshUI()
    end
    if button.internal == "REMOVE" then
        local modal = ISModalDialog:new(0, 0, 250, 150, "Bu bölgeyi kaldırmak istediğinizden emin misiniz?", true, self,
            ISZombieEmitterCurrentZonesUI.onRemoveZone, nil);
        modal:initialise()
        modal:addToUIManager()
    end
    if button.internal == "TELEPORT" then
        getPlayer():setX(self.currentZoneX);
        getPlayer():setY(self.currentZoneY);
        getPlayer():setZ(self.currentZoneZ);
        getPlayer():setLx(self.currentZoneX)
        getPlayer():setLy(self.currentZoneY)
    end
    if button.internal == "EDITZONE" then
        local zone = ZombieEmitter.selectedZone
        local zoneType = zone.type

        if zoneType == "circular" then
            local square = getSquare(zone.x, zone.y, zone.z)
            local ui = ISZombieEmitterCircularZoneUI:new(0, 0, getPlayer(), square, true, zone);
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

---Bölge kaldırma işlemini onaylar
---@param button ISButton Tıklanan buton
function ISZombieEmitterCurrentZonesUI:onRemoveZone(button)
    if button.internal == "YES" then
        local selectedZoneID = self:getSelectedZoneID()
        if not selectedZoneID then return end

        sendClientCommand(getPlayer(), "ZombieEmitter", "RemoveZone", { selectedZoneID = selectedZoneID })

        self:RefreshUI()
    end
end

---Paneli yeniler
function ISZombieEmitterCurrentZonesUI:RefreshUI()
    self.datas:clear();
    ZombieEmitter.selectedZone = nil
    self:getZones();
end

---Paneli kapatır
function ISZombieEmitterCurrentZonesUI:close()
    ISZombieEmitterCurrentZonesUI.instance = nil
    self:setVisible(false);
    self:removeFromUIManager();
end

---Yeni bir ISZombieEmitterCurrentZonesUI örneği oluşturur
---@return ISZombieEmitterCurrentZonesUI
function ISZombieEmitterCurrentZonesUI:new()
    local o = {}
    local width = 1500;
    local height = 1000;
    local x = getCore():getScreenWidth() / 2 - width / 2
    local y = getCore():getScreenHeight() / 2 - height / 2
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 };
    o.listHeaderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.3 };
    o.moveWithMouse = true;
    ISZombieEmitterCurrentZonesUI.instance = o;
    return o;
end