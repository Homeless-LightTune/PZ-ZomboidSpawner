require "ISUI/ISPanelJoypad"
ZombieEmitter = ZombieEmitter or {}

ISZombieEmitterDonutZoneUI = ISCollapsableWindow:derive("ISZombieEmitterDonutZoneUI");
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

function ISZombieEmitterDonutZoneUI:createChildren()
    local btnWid = 100
    local btnHgt = 25
    local padBottom = 0
    local y = 60
    local f = 0.8

    ISCollapsableWindow.createChildren(self)

    -- Bölge Adı
    self.zoneNameLbl = ISLabel:new(10, y, 10, "Bölge Adı", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.zoneNameLbl);

    local name
    if self.isEditing then
        name = self.zoneToEdit.zoneName
    else
        name = "Halka Bölge"
    end
    self.zoneName = ISTextEntryBox:new(name, self.zoneNameLbl.x, self.zoneNameLbl.y + 15, 100, 20);
    self.zoneName:initialise();
    self.zoneName:instantiate();
    self.zoneName.tooltip = "Bölgeniz için benzersiz bir ad"
    self:addChild(self.zoneName);

    -- Doğum Aralığı
    self.spawnIntervalLbl = ISLabel:new(150, y, 10, "Doğum Aralığı", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.spawnIntervalLbl);

    -- Yarıçap
    self.radiusLbl = ISLabel:new(400, y, 10, "Yarıçap", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.radiusLbl);

    local radius
    if self.isEditing then
        radius = tostring(self.zoneToEdit.radius)
    else
        radius = "3"
    end
    self.radius = ISTextEntryBox:new(radius, self.radiusLbl.x, self.radiusLbl.y + 15, 120, 20);
    self.radius:initialise();
    self.radius:instantiate();
    self.radius:setOnlyNumbers(true);
    self.radius.tooltip = "Bölgenin yarıçapı"
    self:addChild(self.radius);
    y = y + 15

    local spawnInterval
    if self.isEditing then
        spawnInterval = tostring(self.zoneToEdit.spawnInterval)
    else
        spawnInterval = "1"
    end
    self.spawnInterval = ISTextEntryBox:new(spawnInterval, self.spawnIntervalLbl.x, y, 120, 20);
    self.spawnInterval:initialise();
    self.spawnInterval:instantiate();
    self.spawnInterval:setOnlyNumbers(true);
    self.spawnInterval.tooltip = "Zombi doğumları arasındaki gerçek zaman aralığı"
    self:addChild(self.spawnInterval);

    -- Zaman Türü
    self.timeType = ISComboBox:new(280, y, 110, 20)
    self.timeType:initialise()
    self:addChild(self.timeType)
    self.timeType:addOptionWithData("Saniye", "s");
    self.timeType:addOptionWithData("Dakika", "m");
    self.timeType:addOptionWithData("Saat", "h");
    self.timeType:addOptionWithData("Gün", "d");
    if self.isEditing then
        if self.zoneToEdit.timeType == "s" then
            self.timeType:select("Saniye")
        elseif self.zoneToEdit.timeType == "m" then
            self.timeType:select("Dakika")
        elseif self.zoneToEdit.timeType == "h" then
            self.timeType:select("Saat")
        elseif self.zoneToEdit.timeType == "d" then
            self.timeType:select("Gün")
        end
    end
    y = y + 30

    -- Zombi Sayısı
    self.zombiesNbrLabel = ISLabel:new(10, y, 10, "Zombi Sayısı", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.zombiesNbrLabel);

    local zombiesNbr
    if self.isEditing then
        zombiesNbr = tostring(self.zoneToEdit.count)
    else
        zombiesNbr = "1"
    end
    self.zombiesNbr = ISTextEntryBox:new(zombiesNbr, self.zombiesNbrLabel.x, self.zombiesNbrLabel.y + 15, 100, 20);
    self.zombiesNbr:initialise();
    self.zombiesNbr:instantiate();
    self.zombiesNbr:setOnlyNumbers(true);
    self.zombiesNbr.tooltip = "Her doğumda oluşacak zombi sayısı"
    self:addChild(self.zombiesNbr);

    -- İç Yarıçap
    self.innerRadiusLbl = ISLabel:new(400, y, 10, "İç Yarıçap", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.innerRadiusLbl);

    -- Maksimum Zombi Sayısı
    self.maxZombiesLbl = ISLabel:new(150, y, 10, "Maksimum Zombi", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.maxZombiesLbl);

    local maxZombies
    if self.isEditing then
        maxZombies = tostring(self.zoneToEdit.maxZombies)
    else
        maxZombies = "-1"
    end
    self.maxZombies = ISTextEntryBox:new(maxZombies, self.maxZombiesLbl.x, self.maxZombiesLbl.y + 15, 100, 20);
    self.maxZombies:initialise();
    self.maxZombies:instantiate();
    self.maxZombies:setOnlyNumbers(true);
    self.maxZombies.tooltip = "Bölgenin doğumu durduracağı maksimum zombi sayısı. Sonsuz için -1 olarak ayarlayın"
    self:addChild(self.maxZombies);
    y = y + 15

    local innerRadius
    if self.isEditing then
        innerRadius = tostring(self.zoneToEdit.innerRadius)
    else
        innerRadius = "2"
    end
    self.innerRadius = ISTextEntryBox:new(innerRadius, self.innerRadiusLbl.x, self.innerRadiusLbl.y + 15, 100, 20);
    self.innerRadius:initialise();
    self.innerRadius:instantiate();
    self.innerRadius:setOnlyNumbers(true);
    self.innerRadius.tooltip = "Bölgenin iç yarıçapı. Yarıçaptan küçük olmalıdır"
    self:addChild(self.innerRadius);
    y = y + 30

    -- Zombi Kıyafeti
    self.outfitLbl = ISLabel:new(10, y, 10, "Zombi Kıyafeti", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.outfitLbl);
    y = y + 15

    self.outfit = ISComboBox:new(self.outfitLbl.x, y, 200, 20)
    self.outfit:initialise()
    self:addChild(self.outfit)
    self.maleOutfits = getAllOutfits(false);
    self.femaleOutfits = getAllOutfits(true);
    self.outfit:addOptionWithData("Yok", nil);
    for i = 0, self.maleOutfits:size() - 1 do
        local text = "";
        if not self.femaleOutfits:contains(self.maleOutfits:get(i)) then
            text = " - Sadece Erkek";
        end
        self.outfit:addOptionWithData(self.maleOutfits:get(i) .. text, self.maleOutfits:get(i));
    end
    for i = 0, self.femaleOutfits:size() - 1 do
        if not self.maleOutfits:contains(self.femaleOutfits:get(i)) then
            self.outfit:addOptionWithData(self.femaleOutfits:get(i) .. " - Sadece Kadın", self.femaleOutfits:get(i));
        end
    end
    if self.isEditing then
        self.outfit:select(self.zoneToEdit.outfit)
    end
    y = y + 30

    -- Seçenekler
    self.boolOptions = ISTickBox:new(10, y, 200, 20, "", self, ISZombieEmitterDonutZoneUI.onBoolOptionsChange);
    self.boolOptions:initialise()
    self:addChild(self.boolOptions)
    self.boolOptions:addOption("Yere Yıkılmış");
    self.boolOptions:addOption("Sürünen");
    self.boolOptions:addOption("Sahte Ölü");
    self.boolOptions:addOption("Öne Düşme");
    y = y + self.boolOptions:getHeight() + 10
    if self.isEditing then
        local knockedDown = self.zoneToEdit.knockedDown == "true"
        local crawler = self.zoneToEdit.crawler == "true"
        local isFakeDead = self.zoneToEdit.isFakeDead == "true"
        local isFallOnFront = self.zoneToEdit.isFallOnFront == "true"
        self.boolOptions:setSelected(1, knockedDown)
        self.boolOptions:setSelected(2, crawler)
        self.boolOptions:setSelected(3, isFakeDead)
        self.boolOptions:setSelected(4, isFallOnFront)
    end

    -- Sağlık
    _, self.healthSliderTitle = ISDebugUtils.addLabel(self, "Sağlık", 10, y, "Sağlık", UIFont.Small, true);

    local health
    if self.isEditing then
        health = tostring(self.zoneToEdit.health)
    else
        health = "1"
    end
    _, self.healthSliderLabel = ISDebugUtils.addLabel(self, "Sağlık", 80, y, health, UIFont.Small, false);

    _, self.healthSlider = ISDebugUtils.addSlider(self, "health", 130, y, 200, 20,
        ISZombieEmitterDonutZoneUI.onSliderChange)
    self.healthSlider.pretext = "Sağlık: ";
    self.healthSlider.valueLabel = self.healthSliderLabel;
    self.healthSlider:setValues(0, 2, 0.1, 0.1, true);
    self.healthSlider.currentValue = 1.0;
    if self.isEditing then
        self.healthSlider.currentValue = self.zoneToEdit.health;
    else
        self.healthSlider.currentValue = 1.0;
    end
    y = y + 30

    -- Yeni Kare Seç Butonu
    self.pickNewSq = ISButton:new(250, 20, btnWid, btnHgt, "Yeni Kare Seç", self,
        ISZombieEmitterDonutZoneUI.onSelectNewSquare);
    self.pickNewSq.anchorTop = false
    self.pickNewSq.anchorBottom = true
    self.pickNewSq:initialise();
    self.pickNewSq:instantiate();
    self.pickNewSq.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self.pickNewSq.tooltip = "Bölgenin merkezi"
    self:addChild(self.pickNewSq);

    -- Bölge Oluştur/Düzenle Butonu
    local addLabel
    if self.isEditing then
        addLabel = "Bölgeyi Düzenle"
    else
        addLabel = "Bölge Oluştur"
    end
    self.add = ISButton:new(10, self:getHeight() - padBottom - btnHgt - 22, btnWid * f, btnHgt, addLabel, self,
        ISZombieEmitterDonutZoneUI.onCreateZone);
    self.add.anchorTop = false
    self.add.anchorBottom = true
    self.add:initialise();
    self.add:instantiate();
    self.add.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.add);

    -- Kapat Butonu
    self.closeButton2 = ISButton:new(self.width - btnWid * f - 10, self.add.y, btnWid * f, btnHgt, "Kapat", self,
        ISZombieEmitterDonutZoneUI.close);
    self.closeButton2.anchorTop = false
    self.closeButton2.anchorBottom = true
    self.closeButton2:initialise();
    self.closeButton2:instantiate();
    self.closeButton2.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.closeButton2);
end

function ISZombieEmitterDonutZoneUI:onBoolOptionsChange(index, selected)
    if index == 1 then
        if not selected then
            self.boolOptions.selected[2] = false
            self.boolOptions.selected[3] = false
        end
    end
    if index == 2 then
        self.boolOptions.selected[1] = selected
        if selected then
            self.boolOptions.selected[4] = true
        end
    end
    if index == 3 then
        self.boolOptions.selected[1] = selected
    end
    if index == 4 then
        if not selected then
            self.boolOptions.selected[2] = false
        end
    end
end

function ISZombieEmitterDonutZoneUI:onSliderChange(_newval, _slider)
    if _slider.valueLabel then
        _slider.valueLabel:setName(ISDebugUtils.printval(_newval, 3));
    end
end

function ISZombieEmitterDonutZoneUI:getRadius()
    local radius = self.radius:getInternalText();
    return (tonumber(radius) or 3);
end

function ISZombieEmitterDonutZoneUI:getInnerRadius()
    local radius = self.innerRadius:getInternalText();
    return (tonumber(radius) or 2);
end

function ISZombieEmitterDonutZoneUI.onOverwriteZone(this, button, args)
    if button.internal == "YES" then
        local instance = ISZombieEmitterDonutZoneUI.instance
        if instance then
            if not instance.isEditing then
                ZombieEmitter.AddDonutZone(args)
            else
                ZombieEmitter.EditDonutZone(args, instance.zoneToEdit)
            end
            instance:close()
        end
    end
end

function ISZombieEmitterDonutZoneUI:onCreateZone()
    local zoneName = self:getZoneName();
    local args =
    {
        count = self:getZombiesNumber(),
        radius = self:getRadius(),
        innerRadius = self:getInnerRadius(),
        outfit = self:getOutfit() or "",
        zoneName = zoneName,
        spawnInterval = self:getSpawnInterval(),
        timeType = self:getTimeType(),
        maxZombies = self:getMaxZombies(),
        knockedDown = tostring(self.boolOptions.selected[1]),
        crawler = tostring(self.boolOptions.selected[2]),
        isFakeDead = tostring(self.boolOptions.selected[3]),
        isFallOnFront = tostring(self.boolOptions.selected[4]),
        health = self.healthSlider:getCurrentValue(),
        x = self.selectX,
        y = self.selectY,
        z = self.selectZ
    }

    if not ZombieEmitterUtils.doesZoneExist(zoneName) then
        if not self.isEditing then
            ZombieEmitter.AddDonutZone(args)
        else
            ZombieEmitter.EditDonutZone(args, self.zoneToEdit)
        end

        self:close()
    else
        if ZombieEmitterUtils.overwriteZoneModal then
            ZombieEmitterUtils.overwriteZoneModal:setVisible(false)
            ZombieEmitterUtils.overwriteZoneModal:removeFromUIManager()
            ZombieEmitterUtils.overwriteZoneModal = nil
        end

        local text =
        "Bu isimde bir bölge zaten var. Devam ederseniz, mevcut bölge üzerine yazılacaktır. Devam etmek istediğinize emin misiniz?"

        ZombieEmitterUtils.overwriteZoneModal = ZombieEmitterUtils.createModalDialog(text, true, nil,
            ISZombieEmitterDonutZoneUI.onOverwriteZone, args, nil)
        ZombieEmitterUtils.overwriteZoneModal:initialise()
        ZombieEmitterUtils.overwriteZoneModal:addToUIManager()
    end
end

function ISZombieEmitterDonutZoneUI:getZombiesNumber()
    local nbr = self.zombiesNbr:getInternalText();
    return tonumber(nbr) or 1;
end

function ISZombieEmitterDonutZoneUI:getZoneName()
    local name = self.zoneName:getInternalText();
    return name or "İsimsiz Bölge";
end

function ISZombieEmitterDonutZoneUI:getSpawnInterval()
    local interval = self.spawnInterval:getInternalText();
    return interval or 1;
end

function ISZombieEmitterDonutZoneUI:getMaxZombies()
    local maxZombies = self.maxZombies:getInternalText();
    return maxZombies or -1;
end

function ISZombieEmitterDonutZoneUI:getOutfit()
    return self.outfit.options[self.outfit.selected].data;
end

function ISZombieEmitterDonutZoneUI:getTimeType()
    return self.timeType.options[self.timeType.selected].data
end

function ISZombieEmitterDonutZoneUI:onSelectNewSquare()
    self.cursor = ISSelectCursor:new(self.chr, self, self.onSquareSelected)
    getCell():setDrag(self.cursor, self.chr:getPlayerNum())
end

function ISZombieEmitterDonutZoneUI:onSquareSelected(square)
    self.cursor = nil;
    self:removeMarker();
    self:removeInnerMarker();
    self.selectX = square:getX();
    self.selectY = square:getY();
    self.selectZ = square:getZ();
    self:addMarker(square, self:getRadius());
    self:addInnerMarker(square, self:getInnerRadius());
end

function ISZombieEmitterDonutZoneUI:prerender()
    ISCollapsableWindow.prerender(self);

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)

    local radius = (self:getRadius());
    if self.marker and (self.marker:getSize() ~= radius) then
        self.marker:setSize(radius)
    end

    local innerRadius = (self:getInnerRadius());
    if self.innerMarker and (self.innerMarker:getSize() ~= innerRadius) then
        self.innerMarker:setSize(innerRadius)
    end
end

function ISZombieEmitterDonutZoneUI:render()
    ISCollapsableWindow.render(self);

    self:drawText("Seçilen Kare: " .. self.selectX .. ", " .. self.selectY .. ", " .. self.selectZ, 10, 25, 1, 1, 1, 1,
        self.font);
end

function ISZombieEmitterDonutZoneUI:addMarker(square, radius)
    self.marker = getWorldMarkers():addGridSquareMarker(square, 1, 0, 0.0, true, radius);
    self.marker:setScaleCircleTexture(true);
    local texName = nil;
    self.arrow = getWorldMarkers():addDirectionArrow(self.chr, self.selectX, self.selectY, self.selectZ, texName, 1.0,
        1.0, 1.0, 1.0);
end

function ISZombieEmitterDonutZoneUI:addInnerMarker(square, radius)
    self.innerMarker = getWorldMarkers():addGridSquareMarker(square, 0, 1, 0.0, true, radius);
    self.innerMarker:setScaleCircleTexture(true);
end

function ISZombieEmitterDonutZoneUI:removeMarker()
    if self.marker then
        self.marker:remove();
        self.marker = nil;
    end
    if self.arrow then
        self.arrow:remove();
        self.arrow = nil;
    end
end

function ISZombieEmitterDonutZoneUI:removeInnerMarker()
    if self.innerMarker then
        self.innerMarker:remove();
        self.innerMarker = nil;
    end
end

function ISZombieEmitterDonutZoneUI:close()
    ISZombieEmitterDonutZoneUI.instance = nil;
    self:removeMarker();
    self:removeInnerMarker();
    self:setVisible(false);
    self:removeFromUIManager();
end

function ISZombieEmitterDonutZoneUI:new(x, y, character, square, isEditing, zoneToEdit)
    local width = 550;
    local height = 400;
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
    o.isEditing = isEditing
    o.zoneToEdit = zoneToEdit
    o.moveWithMouse = true;
    o.selectX = square:getX();
    o.selectY = square:getY();
    o.selectZ = square:getZ();
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    o:addMarker(square, 3);
    o:addInnerMarker(square, 2);
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 };
    o.listHeaderColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.75 };
    o.moveWithMouse = true;
    o:setResizable(false)
    ISZombieEmitterDonutZoneUI.instance = o;
    return o;
end