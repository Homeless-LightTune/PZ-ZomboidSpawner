require "ISUI/ISPanelJoypad"
ZombieEmitter = ZombieEmitter or {}

ISZombieEmitterLineZoneUI = ISCollapsableWindow:derive("ISZombieEmitterLineZoneUI");
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

function ISZombieEmitterLineZoneUI:createChildren()
    local btnWid = 100
    local btnHgt = 25
    local padBottom = 0
    local y = 60
    local f = 0.8

    ISCollapsableWindow.createChildren(self)

    self.PointASqrLbl = ISLabel:new(10, y - 30, 10,
        "A Noktası Kare: " .. self.AselectX .. ", " .. self.AselectY .. ", " .. self.AselectZ, 1, 1, 1, 1, UIFont.Small,
        true);
    self:addChild(self.PointASqrLbl);

    self.pickNewSqA = ISButton:new(10, self.PointASqrLbl.y + 15, btnWid, btnHgt, "Yeni A Noktası Seç", self,
        ISZombieEmitterLineZoneUI.onSelectNewSquareA);
    self.pickNewSqA.anchorTop = false
    self.pickNewSqA.anchorBottom = true
    self.pickNewSqA:initialise();
    self.pickNewSqA:instantiate();
    self.pickNewSqA.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self.pickNewSqA.tooltip = "Bölgenin başlangıç noktası"
    self:addChild(self.pickNewSqA);
    y = y + 50

    self.PointBSqrLbl = ISLabel:new(10, y - 30, 10,
        "B Noktası Kare: " .. self.BselectX .. ", " .. self.BselectY .. ", " .. self.BselectZ, 1, 1, 1, 1, UIFont.Small,
        true);
    self:addChild(self.PointBSqrLbl);

    self.pickNewSqB = ISButton:new(10, self.PointBSqrLbl.y + 15, btnWid, btnHgt, "Yeni B Noktası Seç", self,
        ISZombieEmitterLineZoneUI.onSelectNewSquareB);
    self.pickNewSqB.anchorTop = false
    self.pickNewSqB.anchorBottom = true
    self.pickNewSqB:initialise();
    self.pickNewSqB:instantiate();
    self.pickNewSqB.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self.pickNewSqB.tooltip = "Bölgenin bitiş noktası"
    self:addChild(self.pickNewSqB);
    y = y + 30

    self.zoneNameLbl = ISLabel:new(10, y, 10, "Bölge Adı", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.zoneNameLbl);

    local name
    if self.isEditing then
        name = self.zoneToEdit.zoneName
    else
        name = "Çizgi Bölge"
    end
    self.zoneName = ISTextEntryBox:new(name, self.zoneNameLbl.x, self.zoneNameLbl.y + 15, 100, 20);
    self.zoneName:initialise();
    self.zoneName:instantiate();
    self.zoneName.tooltip = "Bölgeniz için benzersiz bir ad"
    self:addChild(self.zoneName);

    self.spawnIntervalLbl = ISLabel:new(150, y, 10, "Zombi Çıkış Aralığı", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.spawnIntervalLbl);
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
    self.spawnInterval.tooltip = "Zombi çıkışları arasındaki gerçek zaman aralığı"
    self:addChild(self.spawnInterval);

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
    self.zombiesNbr.tooltip = "Her çıkışta oluşacak zombi sayısı"
    self:addChild(self.zombiesNbr);

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
    self.maxZombies.tooltip = "Bölgenin oluşturacağı maksimum zombi sayısı. Sonsuz için -1 girin."
    self:addChild(self.maxZombies);
    y = y + 45

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

    self.boolOptions = ISTickBox:new(10, y, 200, 20, "", self, ISZombieEmitterLineZoneUI.onBoolOptionsChange);
    self.boolOptions:initialise()
    self:addChild(self.boolOptions)
    self.boolOptions:addOption("Yere Düşmüş");
    self.boolOptions:addOption("Emekleyen");
    self.boolOptions:addOption("Sahte Ölü");
    self.boolOptions:addOption("Öne Düşmüş");
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


    _, self.healthSliderTitle = ISDebugUtils.addLabel(self, "Sağlık", 10, y, "Sağlık", UIFont.Small, true);

    local health
    if self.isEditing then
        health = tostring(self.zoneToEdit.health)
    else
        health = "1"
    end
    _, self.healthSliderLabel = ISDebugUtils.addLabel(self, "Sağlık", 80, y, health, UIFont.Small, false);

    _, self.healthSlider = ISDebugUtils.addSlider(self, "health", 130, y, 200, 20,
        ISZombieEmitterLineZoneUI.onSliderChange)
    self.healthSlider.pretext = "Sağlık: ";
    self.healthSlider.valueLabel = self.healthSliderLabel;
    self.healthSlider:setValues(0, 2, 0.1, 0.1, true);
    if self.isEditing then
        self.healthSlider.currentValue = self.zoneToEdit.health;
    else
        self.healthSlider.currentValue = 1.0;
    end
    y = y + 30

    local addLabel
    if self.isEditing then
        addLabel = "Bölgeyi Düzenle"
    else
        addLabel = "Bölge Oluştur"
    end
    self.add = ISButton:new(10, self:getHeight() - padBottom - btnHgt - 22, btnWid * f, btnHgt, addLabel, self,
        ISZombieEmitterLineZoneUI.onCreateZone);
    self.add.anchorTop = false
    self.add.anchorBottom = true
    self.add:initialise();
    self.add:instantiate();
    self.add.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.add);

    self.closeButton2 = ISButton:new(self.width - btnWid * f - 10, self.add.y, btnWid * f, btnHgt, "Kapat", self,
        ISZombieEmitterLineZoneUI.close);
    self.closeButton2.anchorTop = false
    self.closeButton2.anchorBottom = true
    self.closeButton2:initialise();
    self.closeButton2:instantiate();
    self.closeButton2.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.closeButton2);
end

function ISZombieEmitterLineZoneUI:onBoolOptionsChange(index, selected)
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

function ISZombieEmitterLineZoneUI:onSliderChange(_newval, _slider)
    if _slider.valueLabel then
        _slider.valueLabel:setName(ISDebugUtils.printval(_newval, 3));
    end
end

function ISZombieEmitterLineZoneUI.onOverwriteZone(this, button, args)
    if button.internal == "YES" then
        local instance = ISZombieEmitterLineZoneUI.instance
        if instance then
            if not instance.isEditing then
                ZombieEmitter.AddLineZone(args)
            else
                ZombieEmitter.EditLineZone(args, instance.zoneToEdit)
            end
            instance:close()
        end
    end
end

function ISZombieEmitterLineZoneUI:onCreateZone()
    local zoneName = self:getZoneName();
    local args =
    {
        count = self:getZombiesNumber(),
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
        Ax = self.AselectX,
        Ay = self.AselectY,
        Az = self.AselectZ,
        Bx = self.BselectX,
        By = self.BselectY,
        Bz = self.BselectZ
    }

    if not ZombieEmitterUtils.doesZoneExist(zoneName) then
        if not self.isEditing then
            ZombieEmitter.AddLineZone(args)
        else
            ZombieEmitter.EditLineZone(args, self.zoneToEdit)
        end

        self:close()
    else
        if ZombieEmitterUtils.overwriteZoneModal then
            ZombieEmitterUtils.overwriteZoneModal:setVisible(false)
            ZombieEmitterUtils.overwriteZoneModal:removeFromUIManager()
            ZombieEmitterUtils.overwriteZoneModal = nil
        end

        local text =
        "Bu isimde bir bölge zaten var. Devam ederseniz, mevcut bölge üzerine yazılacak. Devam etmek istediğinize emin misiniz?"

        ZombieEmitterUtils.overwriteZoneModal = ZombieEmitterUtils.createModalDialog(text, true, nil,
            ISZombieEmitterLineZoneUI.onOverwriteZone, args, nil)
        ZombieEmitterUtils.overwriteZoneModal:initialise()
        ZombieEmitterUtils.overwriteZoneModal:addToUIManager()
    end
end

function ISZombieEmitterLineZoneUI:getZombiesNumber()
    local nbr = self.zombiesNbr:getInternalText();
    return tonumber(nbr) or 1;
end

function ISZombieEmitterLineZoneUI:getZoneName()
    local name = self.zoneName:getInternalText();
    return name or "İsimsiz Bölge";
end

function ISZombieEmitterLineZoneUI:getSpawnInterval()
    local interval = self.spawnInterval:getInternalText();
    return interval or 1;
end

function ISZombieEmitterLineZoneUI:getMaxZombies()
    local maxZombies = self.maxZombies:getInternalText();
    return maxZombies or -1;
end

function ISZombieEmitterLineZoneUI:getOutfit()
    return self.outfit.options[self.outfit.selected].data;
end

function ISZombieEmitterLineZoneUI:getTimeType()
    return self.timeType.options[self.timeType.selected].data
end

function ISZombieEmitterLineZoneUI:onSelectNewSquareA()
    ZombieEmitter.CurrentTypeSquare = "A"
    self.cursor = ISSelectCursor:new(self.chr, self, self.onSquareSelected)
    getCell():setDrag(self.cursor, self.chr:getPlayerNum())
end

function ISZombieEmitterLineZoneUI:onSelectNewSquareB()
    ZombieEmitter.CurrentTypeSquare = "B"
    self.cursor = ISSelectCursor:new(self.chr, self, self.onSquareSelected)
    getCell():setDrag(self.cursor, self.chr:getPlayerNum())
end

function ISZombieEmitterLineZoneUI:onSquareSelected(square)
    self.cursor = nil;
    local currentTypeSquare = ZombieEmitter.CurrentTypeSquare

    if currentTypeSquare == "A" then
        self:removeAMarker();
        self.AselectX = square:getX();
        self.AselectY = square:getY();
        self.AselectZ = square:getZ();

        self:addAMarker(square, 1);
    else
        self:removeBMarker();
        self.BselectX = square:getX();
        self.BselectY = square:getY();
        self.BselectZ = square:getZ();

        self:addBMarker(square, 1);
    end
end

function ISZombieEmitterLineZoneUI:prerender()
    ISCollapsableWindow.prerender(self);

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)

    if self.markerA then
        self.markerA:setSize(1)
    end

    if self.markerB then
        self.markerB:setSize(1)
    end

    self.PointASqrLbl:setName("A Noktası Kare: " .. self.AselectX .. ", " .. self.AselectY .. ", " .. self.AselectZ)
    self.PointBSqrLbl:setName("B Noktası Kare: " .. self.BselectX .. ", " .. self.BselectY .. ", " .. self.BselectZ)

    if self.BselectX == 0 and self.BselectY == 0 and self.BselectZ == 0 then
        self.add:setEnable(false)
        self.add.tooltip = "<RED> Lütfen bir bitiş noktası seçin"
    else
        self.add:setEnable(true)
        self.add.tooltip = ""
    end
end

function ISZombieEmitterLineZoneUI:render()
    ISCollapsableWindow.render(self);
end

function ISZombieEmitterLineZoneUI:addAMarker(square, radius)
    self.markerA = getWorldMarkers():addGridSquareMarker(square, 0, 1, 0.0, true, radius);
    self.markerA:setScaleCircleTexture(true);
    local texName = nil;
    self.arrowA = getWorldMarkers():addDirectionArrow(self.chr, self.AselectX, self.AselectY, self.AselectZ, texName, 1.0,
        1.0, 1.0, 1.0);
end

function ISZombieEmitterLineZoneUI:removeAMarker()
    if self.markerA then
        self.markerA:remove();
        self.markerA = nil;
    end
    if self.arrowA then
        self.arrowA:remove();
        self.arrowA = nil;
    end
end

function ISZombieEmitterLineZoneUI:addBMarker(square, radius)
    self.markerB = getWorldMarkers():addGridSquareMarker(square, 1, 0, 0.0, true, radius);
    self.markerB:setScaleCircleTexture(true);
    local texName = nil;
    self.arrowB = getWorldMarkers():addDirectionArrow(self.chr, self.BselectX, self.BselectY, self.BselectZ, texName, 1.0,
        1.0, 1.0, 1.0);
end

function ISZombieEmitterLineZoneUI:removeBMarker()
    if self.markerB then
        self.markerB:remove();
        self.markerB = nil;
    end
    if self.arrowB then
        self.arrowB:remove();
        self.arrowB = nil;
    end
end

function ISZombieEmitterLineZoneUI:close()
    ISZombieEmitterLineZoneUI.instance = nil;
    self:removeAMarker();
    self:removeBMarker();
    self:setVisible(false);
    self:removeFromUIManager();
    ZombieEmitter.CurrentTypeSquare = nil
end

function ISZombieEmitterLineZoneUI:new(x, y, character, square, isEditing, zoneToEdit)
    local width = 470;
    local height = 450;
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
    o.isEditing = isEditing;
    o.zoneToEdit = zoneToEdit
    o.moveWithMouse = true;

    if isEditing then
        o.AselectX = zoneToEdit.Ax
        o.AselectY = zoneToEdit.Ay
        o.AselectZ = zoneToEdit.Az
        o.BselectX = zoneToEdit.Bx
        o.BselectY = zoneToEdit.By
        o.BselectZ = zoneToEdit.Bz
    else
        o.AselectX = square:getX();
        o.AselectY = square:getY();
        o.AselectZ = square:getZ();
        o.BselectX = 0;
        o.BselectY = 0;
        o.BselectZ = 0;
    end
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    if isEditing then
        o:addAMarker(getSquare(zoneToEdit.Ax, zoneToEdit.Ay, zoneToEdit.Az), 1);
        o:addBMarker(getSquare(zoneToEdit.Bx, zoneToEdit.By, zoneToEdit.Bz), 1)
    else
        o:addAMarker(square, 1);
    end
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 };
    o.listHeaderColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.75 };
    o.moveWithMouse = true;
    o:setResizable(false)
    ISZombieEmitterLineZoneUI.instance = o;
    return o;
end