ISZombieCullerUI = ISCollapsableWindow:derive("ISZombieCullerUI")
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local HEADER_HGT = FONT_HGT_SMALL + 2 * 2

function ISZombieCullerUI.onDeleteZone(this, button, name)
    if button.internal == "YES" then
        ZombieEmitterUtils.deleteCullerZone(name)
    end
end

function ISZombieCullerUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    local y = FONT_HGT_MEDIUM + HEADER_HGT + 30

    -- Tüm temizleyici bölgeleri göstermek için liste
    local x = (self:getWidth() / 2) - (320 / 2)

    self.allZonesList = ISScrollingListBox:new(x, y + 20, 320, 300)
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

    -- İptal Butonu
    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self,
        ISZombieCullerUI.onClick);
    self.no.internal = "CANCEL";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.no);

    -- Yenile Butonu
    self.refreshBtn = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        getText("IGUI_DbViewer_Refresh"), self, ISZombieCullerUI.onClick);
    self.refreshBtn.internal = "REFRESH";
    self.refreshBtn.anchorTop = false
    self.refreshBtn.anchorBottom = true
    self.refreshBtn:initialise();
    self.refreshBtn:instantiate();
    self.refreshBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.refreshBtn);

    -- Bölge Oluştur Butonu
    local x = self.refreshBtn.x - btnWid - 10
    self.createZoneBtn = ISButton:new(x, self.refreshBtn.y, btnWid, btnHgt, "Bölge Oluştur", self,
        ISZombieCullerUI.onClick);
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

    -- Işınlan Butonu
    self.teleportBtn = ISButton:new(self.allZonesList.x, self.allZonesList:getBottom() + 10, btnWid, btnHgt,
        "Işınlan", self, ISZombieCullerUI.onClick);
    self.teleportBtn.internal = "TELEPORT";
    self.teleportBtn.anchorTop = false
    self.teleportBtn.anchorBottom = false
    self.teleportBtn:initialise();
    self.teleportBtn:instantiate();
    self.teleportBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self.teleportBtn.tooltip = "<YEŞİL> Seçili bölgeye ışınlan"
    self:addChild(self.teleportBtn);

    -- Düzenle Butonu
    self.editBtn = ISButton:new(self.teleportBtn:getRight() + 10, self.teleportBtn.y, btnWid, btnHgt,
        "Düzenle", self, ISZombieCullerUI.onClick);
    self.editBtn.internal = "EDIT";
    self.editBtn.anchorTop = false
    self.editBtn.anchorBottom = false
    self.editBtn:initialise();
    self.editBtn:instantiate();
    self.editBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.editBtn);

    -- Bölge Sil Butonu
    self.deleteBtn = ISButton:new(self.editBtn:getRight() + 10, self.editBtn.y, btnWid,
        btnHgt, "Bölge Sil", self, ISZombieCullerUI.onClick);
    self.deleteBtn.internal = "DELETE_ZONE";
    self.deleteBtn.anchorTop = false
    self.deleteBtn.anchorBottom = true
    self.deleteBtn:initialise();
    self.deleteBtn:instantiate();
    self.deleteBtn.borderColor = { r = 1, g = 0, b = 0, a = 1 };
    self.deleteBtn.backgroundColor = { r = 0.75, g = 0, b = 0, a = 1 };
    self.deleteBtn.backgroundColorMouseOver = { r = 0.5, g = 0, b = 0, a = 1 };
    self.deleteBtn.textColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.deleteBtn);
end

function ISZombieCullerUI:onClick(button)
    local player = self.chr

    if button.internal == "CANCEL" then
        self:close();
    elseif button.internal == "CREATE_ZONE" then
        if ISZombieCullerCreateZoneUI.instance then
            ISZombieCullerCreateZoneUI.instance:close()
        end

        local ui = ISZombieCullerCreateZoneUI:new(0, 0, self.chr);
        ui:initialise();
        ui:addToUIManager();
    elseif button.internal == "REFRESH" then
        self:RefreshUI()
    elseif button.internal == "TELEPORT" then
        local x, y, z = self.selectedZone.x1, self.selectedZone.y1, self.selectedZone.z
        if x and y and z then
            player:setX(x);
            player:setY(y);
            player:setZ(z);
            player:setLx(x)
            player:setLy(y)
            player:setLz(z)
        end
    elseif button.internal == "DELETE_ZONE" then
        if not self.selectedZone then return end
        if not ZombieEmitterUtils.doesCullerZoneExist(self.selectedZone.zoneName) then return end

        if ZombieEmitterUtils.deleteCullerZoneModal then
            ZombieEmitterUtils.deleteCullerZoneModal:setVisible(false)
            ZombieEmitterUtils.deleteCullerZoneModal:removeFromUIManager()
            ZombieEmitterUtils.deleteCullerZoneModal = nil
        end

        local text = "\"" .. self.selectedZone.zoneName .. "\" bölgesini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz!"

        ZombieEmitterUtils.deleteCullerZoneModal = ZombieEmitterUtils.createModalDialog(text, true, nil,
            ISZombieCullerUI.onDeleteZone, self.selectedZone.zoneName)
        ZombieEmitterUtils.deleteCullerZoneModal:initialise()
        ZombieEmitterUtils.deleteCullerZoneModal:addToUIManager()
    elseif button.internal == "EDIT" then
        if not self.selectedZone then return end
        if not ZombieEmitterUtils.doesCullerZoneExist(self.selectedZone.zoneName) then return end

        if ISZombieCullerCreateZoneUI.instance then
            ISZombieCullerCreateZoneUI.instance:close()
        end

        local zoneData = ModData.get("ZOMBIE_EMITTER_DATA").CullerZones[self.selectedZone.zoneName]
        local ui = ISZombieCullerEditZoneUI:new(0, 0, self.chr, self.selectedZone.zoneName, zoneData);
        ui:initialise();
        ui:addToUIManager();
    end
end

function ISZombieCullerUI:update()
    ISCollapsableWindow.update(self)

    local selectedZone = self.allZonesList.items[self.allZonesList.selected]
    if selectedZone and (self.selectedZone ~= selectedZone.item.data) then
        local selectedZoneData = selectedZone.item.data
        self.selectedZone = selectedZoneData
    end
end

function ISZombieCullerUI:prerender()
    ISCollapsableWindow.prerender(self);

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawText("Zombi Temizleyici",
        self.width / 2 - (getTextManager():MeasureStringX(UIFont.Title, "Zombi Temizleyici") / 2), 20, 1, 1, 1, 1,
        UIFont.Title)

    if not self.selectedZone then
        self.teleportBtn:setEnable(false)
        self.editBtn:setEnable(false)
        self.deleteBtn:setEnable(false)

        self.teleportBtn.tooltip = "<KIRMIZI> Hiçbir bölge seçilmedi"
        self.editBtn.tooltip = "<KIRMIZI> Hiçbir bölge seçilmedi"
        self.deleteBtn.tooltip = "<KIRMIZI> Hiçbir bölge seçilmedi"
    else
        self.teleportBtn:setEnable(true)
        self.editBtn:setEnable(true)
        self.deleteBtn:setEnable(true)

        self.teleportBtn.tooltip = "<YEŞİL> Seçili bölgeye ışınlan"
        self.editBtn.tooltip = "<YEŞİL> Seçili bölgeyi düzenle"
        self.deleteBtn.tooltip = "<KIRMIZI> Seçili bölgeyi sil"
    end
end

function ISZombieCullerUI:render()
    ISCollapsableWindow.render(self);
end

function ISZombieCullerUI:close()
    ISZombieCullerUI.instance = nil
    self:setVisible(false)
    self:removeFromUIManager()
end

function ISZombieCullerUI:getZones()
    local allZones = ZombieEmitterUtils.getAllCullerZones()
    if allZones then
        self.allZones = allZones
        self:populateZonesList()
    end
end

function ISZombieCullerUI:populateZonesList()
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

function ISZombieCullerUI:drawZonesDatas(y, item, alt)
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

function ISZombieCullerUI:RefreshUI()
    self.allZonesList:clear()
    self.selectedZones = nil

    self:getZones()
end

function ISZombieCullerUI:new(character)
    local o = {}
    local width = 500;
    local height = 520
    local x = getCore():getScreenWidth() / 2 - width / 2
    local y = getCore():getScreenHeight() / 2 - height / 2
    o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 1 };
    o.backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 };
    o.listHeaderColor = { r = 0.2, g = 0.2, b = 0.2, a = 0.85 };
    o.moveWithMouse = true;
    o.chr = character
    o:setResizable(false)
    ISZombieCullerUI.instance = o;
    return o;
end