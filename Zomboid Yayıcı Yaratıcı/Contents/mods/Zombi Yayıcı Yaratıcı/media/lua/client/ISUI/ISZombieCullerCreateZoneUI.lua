require "ISUI/ISPanelJoypad"
ZombieEmitter = ZombieEmitter or {}

ISZombieCullerCreateZoneUI = ISCollapsableWindow:derive("ISZombieCullerCreateZoneUI");
local ZombieEmitterUtils = require("ZombieEmitter_Utils")
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISZombieCullerCreateZoneUI:createChildren()
    local btnWid = 120
    local btnHgt = math.max(25, FONT_HGT_SMALL + 5 * 2)
    local padBottom = 10
    local y = 40
    local f = 0.8

    ISCollapsableWindow.createChildren(self)

    -- Bölge Seç Butonu
    self.selectZoneBtn = ISButton:new(10, y, btnWid * f, btnHgt, "Bölge Seç", self, ISZombieCullerCreateZoneUI.onClick);
    self.selectZoneBtn.anchorTop = false
    self.selectZoneBtn.anchorBottom = true
    self.selectZoneBtn.internal = "SELECT_ZONE"
    self.selectZoneBtn:initialise();
    self.selectZoneBtn:instantiate();
    self.selectZoneBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self.selectZoneBtn.font = UIFont.Medium
    self:addChild(self.selectZoneBtn);

    -- X1 ve Y1 Koordinatları
    self.x1Lbl = ISLabel:new(10, self.selectZoneBtn:getBottom() + 10, 10, "X1: 0", 1, 1, 1, 1, UIFont.Large, true);
    self:addChild(self.x1Lbl);

    self.y1Lbl = ISLabel:new(10, self.x1Lbl:getBottom() + 10, 10, "Y1: 0", 1, 1, 1, 1, UIFont.Large, true);
    self:addChild(self.y1Lbl);

    -- X2 ve Y2 Koordinatları
    self.x2Lbl = ISLabel:new(self.x1Lbl:getRight() + 80, self.x1Lbl.y, 10, "X2: 0", 1, 1, 1, 1, UIFont.Large, true);
    self:addChild(self.x2Lbl);

    self.y2Lbl = ISLabel:new(self.x2Lbl.x, self.x2Lbl:getBottom() + 10, 10, "Y2: 0", 1, 1, 1, 1, UIFont.Large, true);
    self:addChild(self.y2Lbl);

    -- İptal Butonu
    self.closeBtn = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid * f, btnHgt, "İptal", self,
        ISZombieCullerCreateZoneUI.onClick);
    self.closeBtn.anchorTop = false
    self.closeBtn.anchorBottom = true
    self.closeBtn.internal = "CLOSE"
    self.closeBtn:initialise();
    self.closeBtn:instantiate();
    self.closeBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.closeBtn);

    -- Bölge Oluştur Butonu
    local x = self:getWidth() - btnWid - 10
    self.createZoneBtn = ISButton:new(x, self.closeBtn.y, btnWid, btnHgt, "Oluştur", self,
        ISZombieCullerCreateZoneUI.onClick);
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

    -- Bölge Adı
    self.zoneNameLbl = ISLabel:new(10, self.x1Lbl:getBottom() + 70, 10, "Bölge Adı", 1, 1, 1, 1, UIFont.Medium, true);
    self:addChild(self.zoneNameLbl);

    self.zoneName = ISTextEntryBox:new("İsimsiz Temizleyici", self.zoneNameLbl.x, self.zoneNameLbl:getBottom() + 5, 120, 20);
    self.zoneName.font = UIFont.Medium
    self.zoneName:initialise();
    self.zoneName:instantiate();
    self.zoneName.tooltip = "Bölgenin adı"
    self:addChild(self.zoneName);

    -- Maksimum Zombi Sayısı
    local x = self.zoneNameLbl:getRight() + 60
    local y = self.zoneNameLbl.y
    self.maxZombiesLbl = ISLabel:new(x, y, 10, "Maksimum Zombi", 1, 1, 1, 1, UIFont.Medium, true);
    self:addChild(self.maxZombiesLbl);

    self.maxZombies = ISTextEntryBox:new("1000", self.maxZombiesLbl.x, self.maxZombiesLbl:getBottom() + 5, 120, 20);
    self.maxZombies.font = UIFont.Medium
    self.maxZombies:initialise();
    self.maxZombies:instantiate();
    self.maxZombies.tooltip = "Bu bölgede aynı anda bulunabilecek maksimum zombi sayısı"
    self:addChild(self.maxZombies);
end

function ISZombieCullerCreateZoneUI.onOverwriteZone(this, button, args)
    if button.internal == "YES" then
        local instance = ISZombieCullerCreateZoneUI.instance
        if instance then
            sendClientCommand("ZombieEmitter", "AddCullerZone", args)
            instance:close()
        end
    end
end

function ISZombieCullerCreateZoneUI:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
    elseif button.internal == "SELECT_ZONE" then
        self.selectEnd = false
        self.startPos = nil
        self.endPos = nil
        self.zPos = self.chr:getZ()
        self.selectStart = true

        self.selectByClick = false
        self.isAdd = true
    elseif button.internal == "CREATE_ZONE" then
        local zoneName = self.zoneName:getInternalText() or "İsimsiz"
        local maxZombies = self.maxZombies:getInternalText() or "1000"
        maxZombies = tonumber(maxZombies)
        local x1, y1, x2, y2 = self.startPos.x, self.startPos.y, self.endPos.x, self.endPos.y

        local args =
        {
            zoneName = zoneName,
            zoneData =
            {
                maxZombies = maxZombies,
                x1 = x1,
                y1 = y1,
                x2 = x2,
                y2 = y2,
                z = self.zPos
            }
        }

        if ZombieEmitterUtils.doesCullerZoneExist(zoneName) then
            if ZombieEmitterUtils.OverwriteCullerZoneModal then
                ZombieEmitterUtils.OverwriteCullerZoneModal:setVisible(false)
                ZombieEmitterUtils.OverwriteCullerZoneModal:removeFromUIManager()
                ZombieEmitterUtils.OverwriteCullerZoneModal = nil
            end

            local text =
            "Bu isimde bir temizleyici bölgesi zaten var. Devam ederseniz, üzerine yazılacaktır. Devam etmek istediğinize emin misiniz?"

            ZombieEmitterUtils.OverwriteCullerZoneModal = ZombieEmitterUtils.createModalDialog(text, true, nil,
                ISZombieEmitterCircularZoneUI.onOverwriteZone, args, nil)
            ZombieEmitterUtils.OverwriteCullerZoneModal:initialise()
            ZombieEmitterUtils.OverwriteCullerZoneModal:addToUIManager()
        else
            sendClientCommand("ZombieEmitter", "AddCullerZone", args)
            self:close()
        end
    end
end

function ISZombieCullerCreateZoneUI:prerender()
    ISCollapsableWindow.prerender(self);

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    if not self.isZoneSelected then
        self.createZoneBtn:setEnable(false)
        self.createZoneBtn.tooltip = "<KIRMIZI> Önce bir bölge seçmelisiniz"
    else
        self.createZoneBtn:setEnable(true)
        self.createZoneBtn.tooltip = "Bölgeyi oluştur"
    end
end

function ISZombieCullerCreateZoneUI:render()
    ISCollapsableWindow.render(self);

    if self.selectStart or self.selectByClick then
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        local sq = getCell():getGridSquare(math.floor(xx), math.floor(yy), self.zPos)
        if sq and sq:getFloor() then
            sq:getFloor():setHighlighted(true)
            sq:getFloor():setHighlightColor(1, 0, 0, 1)
        end
    elseif self.selectEnd then
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        xx = math.floor(xx)
        yy = math.floor(yy)
        local cell = getCell()
        local x1 = math.min(xx, self.startPos.x)
        local x2 = math.max(xx, self.startPos.x)
        local y1 = math.min(yy, self.startPos.y)
        local y2 = math.max(yy, self.startPos.y)

        for x = x1, x2 do
            for y = y1, y2 do
                local sq = cell:getGridSquare(x, y, self.zPos)
                if sq and sq:getFloor() then
                    sq:getFloor():setHighlighted(true)
                    sq:getFloor():setHighlightColor(1, 0, 0, 1)
                end
            end
        end
    elseif self.startPos ~= nil and self.endPos ~= nil then
        local cell = getCell()
        local x1 = math.min(self.startPos.x, self.endPos.x)
        local x2 = math.max(self.startPos.x, self.endPos.x)
        local y1 = math.min(self.startPos.y, self.endPos.y)
        local y2 = math.max(self.startPos.y, self.endPos.y)
        for x = x1, x2 do
            for y = y1, y2 do
                local sq = cell:getGridSquare(x, y, self.zPos)
                if sq and sq:getFloor() then
                    sq:getFloor():setHighlighted(true)
                    sq:getFloor():setHighlightColor(1, 0, 0, 1)
                end
            end
        end
    end
end

function ISZombieCullerCreateZoneUI:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function ISZombieCullerCreateZoneUI:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function ISZombieCullerCreateZoneUI:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end

function ISZombieCullerCreateZoneUI:onMouseUp(x, y)
    if not self:getIsVisible() then
        return;
    end
    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x, y)
    end
    ISMouseDrag.dragView = nil
end

function ISZombieCullerCreateZoneUI:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end

function ISZombieCullerCreateZoneUI:onMouseDownOutside(x, y)
    if x >= 0 and x <= self:getWidth() and y >= 0 and y <= self:getHeight() then return end

    local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
    if self.selectStart then
        self.startPos = { x = math.floor(xx), y = math.floor(yy) }
        self.selectStart = false
        self.selectEnd = true
    elseif self.selectEnd then
        self.endPos = { x = math.floor(xx), y = math.floor(yy) }
        self.selectEnd = false
        self.isZoneSelected = true

        self.x1Lbl:setName("X1:   " .. tostring(self.startPos.x))
        self.y1Lbl:setName("Y1:   " .. tostring(self.startPos.y))
        self.x2Lbl:setName("X2:   " .. tostring(self.endPos.x))
        self.y2Lbl:setName("Y2:   " .. tostring(self.endPos.y))
    end
end

function ISZombieCullerCreateZoneUI:close()
    ISZombieCullerCreateZoneUI.instance = nil;
    self:setVisible(false);
    self:removeFromUIManager();
end

function ISZombieCullerCreateZoneUI:new(x, y, character)
    local width = 300;
    local height = 300;
    local o = ISCollapsableWindow.new(self, x, y, width, height);
    o.playerNum = character:getPlayerNum()
    if y == 0 then
        o.y = getPlayerScreenTop(o.playerNum) + (getPlayerScreenHeight(o.playerNum) - height) / 2
        o:setY(o.y)
    end
    if x == 0 then
        o.x = getPlayerScreenLeft(o.playerNum) + (getPlayerScreenWidth(o.playerNum) - width) / 2
        o:setX(o.x)
    end
    o.width = width;
    o.height = height;
    o.chr = character;
    o.moveWithMouse = true;
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    o.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 1 };
    o.backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 };
    o.listHeaderColor = { r = 0.2, g = 0.2, b = 0.2, a = 0.85 };
    o.moveWithMouse = true;
    o:setResizable(false)

    o.isAdd = true

    o.selectStart = false
    o.selectEnd = false
    o.startPos = nil
    o.endPos = nil
    o.zPos = 0

    ISZombieCullerCreateZoneUI.instance = o;
    return o;
end