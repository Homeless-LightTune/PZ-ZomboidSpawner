
ISZombieEmitterCurrentZonesUI = ISPanel:derive("ISZombieEmitterCurrentZonesUI");
ZombieEmiter = ZombieEmitter or {}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local HEADER_HGT = FONT_HGT_SMALL + 2 * 2

function ISZombieEmitterCurrentZonesUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    -- İptal Butonu
    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, "İptal", self,
        ISZombieEmitterCurrentZonesUI.onClick);
    self.no.internal = "CANCEL";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.no);

    -- Yenile Butonu
    self.refreshBtn = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        "Yenile", self, ISZombieEmitterCurrentZonesUI.onClick);
    self.refreshBtn.internal = "REFRESH";
    self.refreshBtn.anchorTop = false
    self.refreshBtn.anchorBottom = true
    self.refreshBtn:initialise();
    self.refreshBtn:instantiate();
    self.refreshBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.refreshBtn);

    -- Kaldır Butonu
    self.removeBtn = ISButton:new(self.refreshBtn.x - btnWid - 25, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        "Kaldır", self, ISZombieEmitterCurrentZonesUI.onClick);
    self.removeBtn.internal = "REMOVE";
    self.removeBtn.anchorTop = false
    self.removeBtn.anchorBottom = true
    self.removeBtn:initialise();
    self.removeBtn:instantiate();
    self.removeBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.removeBtn);

    -- Işınlan Butonu
    self.teleportBtn = ISButton:new(self.removeBtn.x - btnWid - 25, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        "Işınlan", self, ISZombieEmitterCurrentZonesUI.onClick);
    self.teleportBtn.internal = "TELEPORT";
    self.teleportBtn.anchorTop = false
    self.teleportBtn.anchorBottom = true
    self.teleportBtn:initialise();
    self.teleportBtn:instantiate();
    self.teleportBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.teleportBtn);

    -- Bölgeyi Düzenle Butonu
    self.editBtn = ISButton:new(self.teleportBtn.x - btnWid - 25, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        "Bölgeyi Düzenle", self, ISZombieEmitterCurrentZonesUI.onClick);
    self.editBtn.internal = "EDITZONE";
    self.editBtn.anchorTop = false
    self.editBtn.anchorBottom = true
    self.editBtn:initialise();
    self.editBtn:instantiate();
    self.editBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self:addChild(self.editBtn);

    self:getZones();
end

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

function ISZombieEmitterCurrentZonesUI:render()
    self:drawRectBorder(self.datas.x, self.datas.y - HEADER_HGT, self.datas:getWidth(), HEADER_HGT + 1, 1,
        self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x, 1 + self.datas.y - HEADER_HGT, self.datas.width, HEADER_HGT, self.listHeaderColor.a,
        self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);
    self:drawText("Bölge Adı", self.datas.x + 5, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Yarıçap", self.datas.x + 105, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("İç Yarıçap", self.datas.x + 205, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Doğum Aralığı", self.datas.x + 305, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Sayı", self.datas.x + 405, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Maksimum Zombi", self.datas.x + 505, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Toplam Doğan", self.datas.x + 605, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Sürünen", self.datas.x + 715, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Öne Düşme", self.datas.x + 805, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Sahte Ölü", self.datas.x + 915, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Yere Yıkılmış", self.datas.x + 1015, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Sağlık", self.datas.x + 1135, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Kıyafet", self.datas.x + 1205, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Tür", self.datas.x + 1305, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
    self:drawText("Bölge Kimliği", self.datas.x + 1405, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small);
end

function ISZombieEmitterCurrentZonesUI:onClick(button)
    if button.internal == "CANCEL" then
        self:close();
    end
    if button.internal == "REFRESH" then
        self:RefreshUI()
    end
    if button.internal == "REMOVE" then
        local modal = ISModalDialog:new(0, 0, 250, 150, "Are you sure you want to remove this zone?", true, self,
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

function ISZombieEmitterCurrentZonesUI:onRemoveZone(button)
    if button.internal == "YES" then
        local selectedZoneID = self:getSelectedZoneID()
        if not selectedZoneID then return end

        sendClientCommand(getPlayer(), "ZombieEmitter", "RemoveZone", { selectedZoneID = selectedZoneID })

        self:RefreshUI()
    end
end

function ISZombieEmitterCurrentZonesUI:RefreshUI()
    self.datas:clear();
    ZombieEmitter.selectedZone = nil
    self:getZones();
end

function ISZombieEmitterCurrentZonesUI:close()
    ISZombieEmitterCurrentZonesUI.instance = nil
    self:setVisible(false);
    self:removeFromUIManager();
end

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
