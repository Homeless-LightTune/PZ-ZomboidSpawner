require "ISUI/ISPanelJoypad"
ZombieEmitter = ZombieEmitter or {}

ISEditSpawnerConfigUI = ISCollapsableWindow:derive("ISEditSpawnerConfigUI");
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

---Yapılandırma düzenleme onayını işler
---@param this ISEditSpawnerConfigUI
---@param button ISButton
function ISEditSpawnerConfigUI.onConfirmEditConfig(this, button)
    if button.internal == "YES" then
        local instance = ISEditSpawnerConfigUI.instance
        if instance then
            local args =
            {
                count = instance:getZombiesNumber(),
                outfit = instance:getOutfit() or "",
                spawnInterval = instance:getSpawnInterval(),
                timeType = instance:getTimeType(),
                maxZombies = instance:getMaxZombies(),
                knockedDown = tostring(instance.boolOptions.selected[1]),
                crawler = tostring(instance.boolOptions.selected[2]),
                isFakeDead = tostring(instance.boolOptions.selected[3]),
                isFallOnFront = tostring(instance.boolOptions.selected[4]),
                health = instance.healthSlider:getCurrentValue(),
            }

            sendClientCommand("ZombieEmitter", "EditSpawnersConfig", args)
            instance:close()
        end
    end
end

---Panelin alt bileşenlerini oluşturur
function ISEditSpawnerConfigUI:createChildren()
    local btnWid = 120
    local btnHgt = math.max(25, FONT_HGT_SMALL + 5 * 2)
    local padBottom = 0
    local y = 40
    local f = 0.8

    ISCollapsableWindow.createChildren(self)

    -- Spawn Aralığı Etiketi
    self.spawnIntervalLbl = ISLabel:new(10, y, 10, "Spawn Aralığı", 1, 1, 1, 1, UIFont.Medium, true);
    self:addChild(self.spawnIntervalLbl);

    local x = self.spawnIntervalLbl.x
    y = self.spawnIntervalLbl.y + 20
    local value = (self.CURRENT_SETTINGS.spawnInterval and tostring(self.CURRENT_SETTINGS.spawnInterval)) or "1"
    self.spawnInterval = ISTextEntryBox:new(value, self.spawnIntervalLbl.x, y, 120, 20);
    self.spawnInterval:initialise();
    self.spawnInterval:instantiate();
    self.spawnInterval:setOnlyNumbers(true);
    self.spawnInterval.tooltip = "Zombi spawnları arasındaki gerçek zaman aralığı"
    self:addChild(self.spawnInterval);

    -- Zaman Tipi Seçimi
    self.timeType = ISComboBox:new(self.spawnInterval:getRight() + 10, y, 110, 20)
    self.timeType:initialise()
    self:addChild(self.timeType)
    self.timeType:addOptionWithData("Saniye", "s");
    self.timeType:addOptionWithData("Dakika", "m");
    self.timeType:addOptionWithData("Saat", "h");
    self.timeType:addOptionWithData("Gün", "d");

    value = tostring(self.CURRENT_SETTINGS.timeType)
    if value then
        if value == "s" then
            self.timeType:select("Saniye")
        elseif value == "m" then
            self.timeType:select("Dakika")
        elseif value == "h" then
            self.timeType:select("Saat")
        elseif value == "d" then
            self.timeType:select("Gün")
        end
    end

    -- Zombi Sayısı Etiketi
    self.zombiesNbrLabel = ISLabel:new(10, self.spawnInterval:getBottom() + 10, 10, "Zombi Sayısı", 1, 1, 1, 1,
        UIFont.Medium, true);
    self:addChild(self.zombiesNbrLabel);

    value = (self.CURRENT_SETTINGS.count and tostring(self.CURRENT_SETTINGS.count)) or "1"
    self.zombiesNbr = ISTextEntryBox:new(value, 10, self.zombiesNbrLabel:getBottom() + 10, 100, 20);
    self.zombiesNbr:initialise();
    self.zombiesNbr:instantiate();
    self.zombiesNbr:setOnlyNumbers(true);
    self.zombiesNbr.tooltip = "Her spawn örneğinde doğacak zombi sayısı (spawner başına)"
    self:addChild(self.zombiesNbr);

    -- Maksimum Zombi Sayısı Etiketi
    x = self.zombiesNbrLabel:getRight() + 20
    y = self.zombiesNbrLabel.y
    self.maxZombiesLbl = ISLabel:new(x, y, 10, "Maks. Zombi", 1, 1, 1, 1, UIFont.Medium, true);
    self:addChild(self.maxZombiesLbl);

    x = self.maxZombiesLbl.x
    y = self.zombiesNbr.y
    value = (self.CURRENT_SETTINGS.maxZombies and tostring(self.CURRENT_SETTINGS.maxZombies)) or "-1"
    self.maxZombies = ISTextEntryBox:new(value, x, y, 100, 20);
    self.maxZombies:initialise();
    self.maxZombies:instantiate();
    self.maxZombies:setOnlyNumbers(true);
    self.maxZombies.tooltip =
    "Bölgenin spawnlamayı durduracağı maksimum zombi sayısı. Sonsuz için -1 olarak ayarlayın (spawner başına)"
    self:addChild(self.maxZombies);

    -- Zombi Kıyafeti Etiketi
    x = 10
    y = self.zombiesNbr:getBottom() + 10
    self.outfitLbl = ISLabel:new(x, y, 10, "Zombi Kıyafeti", 1, 1, 1, 1, UIFont.Medium, true);
    self:addChild(self.outfitLbl);

    x = 10
    y = self.outfitLbl:getBottom() + 10
    self.outfit = ISComboBox:new(x, y, 200, 20)
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
    if self.CURRENT_SETTINGS.outfit and self.CURRENT_SETTINGS.outfit ~= "" then
        self.outfit:select(self.CURRENT_SETTINGS.outfit)
    end

    -- Boolean Seçenekler
    local x = 10
    local y = self.outfit:getBottom() + 10
    self.boolOptions = ISTickBox:new(x, y, 200, 20, "", self, ISEditSpawnerConfigUI.onBoolOptionsChange);
    self.boolOptions:initialise()
    self:addChild(self.boolOptions)
    self.boolOptions:addOption("Yere Ser");
    self.boolOptions:addOption("Crawler");
    self.boolOptions:addOption("Sahte Ölü");
    self.boolOptions:addOption("Öne Düşme");

    local knockedDownValue = self.CURRENT_SETTINGS.knockedDown or "false"
    self.boolOptions:setSelected(1, knockedDownValue == "true")

    local crawlerValue = self.CURRENT_SETTINGS.crawler or "false"
    self.boolOptions:setSelected(2, crawlerValue == "true")

    local isFakeDeadValue = self.CURRENT_SETTINGS.isFakeDead or "false"
    self.boolOptions:setSelected(3, isFakeDeadValue == "true")

    local isFallOnFrontValue = self.CURRENT_SETTINGS.isFallOnFront or "false"
    self.boolOptions:setSelected(4, isFallOnFrontValue == "true")

    -- Sağlık Kaydırıcısı
    local x = 10
    local y = self.boolOptions:getBottom() + 30
    _, self.healthSliderTitle = ISDebugUtils.addLabel(self, "Sağlık: ", x, y, "Sağlık: ", UIFont.Medium, true);

    value = (self.CURRENT_SETTINGS.health and tostring(self.CURRENT_SETTINGS.health)) or "1"
    _, self.healthSliderLabel = ISDebugUtils.addLabel(self, "Sağlık: ", 80, y, value, UIFont.Medium, false);

    _, self.healthSlider = ISDebugUtils.addSlider(self, "health", 130, y, 200, 20,
        ISEditSpawnerConfigUI.onSliderChange)
    self.healthSlider.pretext = "Sağlık: ";
    self.healthSlider.valueLabel = self.healthSliderLabel;
    self.healthSlider:setValues(0, 2, 0.1, 0.1, true);

    value = self.CURRENT_SETTINGS.health
    if value then
        self.healthSlider.currentValue = value
    else
        self.healthSlider.currentValue = 1.0
    end

    -- Düzenle Butonu
    self.editBtn = ISButton:new(10, self:getHeight() - padBottom - btnHgt - 22, btnWid * f, btnHgt, "Düzenle", self,
        ISEditSpawnerConfigUI.onClick);
    self.editBtn.anchorTop = false
    self.editBtn.anchorBottom = true
    self.editBtn.internal = "EDIT"
    self.editBtn:initialise();
    self.editBtn:instantiate();
    self.editBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.editBtn);

    -- Kapat Butonu
    self.closeBtn = ISButton:new(self.width - btnWid * f - 10, self.editBtn.y, btnWid * f, btnHgt, "İptal", self,
        ISEditSpawnerConfigUI.onClick);
    self.closeBtn.anchorTop = false
    self.closeBtn.anchorBottom = true
    self.closeBtn.internal = "CLOSE"
    self.closeBtn:initialise();
    self.closeBtn:instantiate();
    self.closeBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.closeBtn);
end

---Buton tıklama olaylarını işler
---@param button ISButton
function ISEditSpawnerConfigUI:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
    elseif button.internal == "EDIT" then
        if ZombieEmitterUtils.editSpawnerConfigModal then
            ZombieEmitterUtils.editSpawnerConfigModal:setVisible(false)
            ZombieEmitterUtils.editSpawnerConfigModal:removeFromUIManager()
            ZombieEmitterUtils.editSpawnerConfigModal = nil
        end

        local text =
        "Spawner yapılandırmasını düzenlemek istediğinizden emin misiniz? Bu, tüm manuel olarak yerleştirilen spawner'lara uygulanacaktır!"

        ZombieEmitterUtils.editSpawnerConfigModal = ZombieEmitterUtils.createModalDialog(text, true, nil,
            ISEditSpawnerConfigUI.onConfirmEditConfig, nil)
        ZombieEmitterUtils.editSpawnerConfigModal:initialise()
        ZombieEmitterUtils.editSpawnerConfigModal:addToUIManager()
    end
end

---Boolean seçeneklerdeki değişiklikleri işler
---@param index number
---@param selected boolean
function ISEditSpawnerConfigUI:onBoolOptionsChange(index, selected)
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

---Kaydırıcı değişikliklerini işler
---@param _newval number
---@param _slider ISSliderPanel
function ISEditSpawnerConfigUI:onSliderChange(_newval, _slider)
    if _slider.valueLabel then
        _slider.valueLabel:setName(ISDebugUtils.printval(_newval, 3));
    end
end

---Zombi sayısını döndürür
---@return number
function ISEditSpawnerConfigUI:getZombiesNumber()
    local nbr = self.zombiesNbr:getInternalText();
    return tonumber(nbr) or 1;
end

---Spawn aralığını döndürür
---@return number
function ISEditSpawnerConfigUI:getSpawnInterval()
    local interval = self.spawnInterval:getInternalText();
    return interval or 1;
end

---Maksimum zombi sayısını döndürür
---@return number
function ISEditSpawnerConfigUI:getMaxZombies()
    local maxZombies = self.maxZombies:getInternalText();
    return maxZombies or -1;
end

---Zombi kıyafetini döndürür
---@return string|nil
function ISEditSpawnerConfigUI:getOutfit()
    return self.outfit.options[self.outfit.selected].data;
end

---Zaman tipini döndürür
---@return string
function ISEditSpawnerConfigUI:getTimeType()
    return self.timeType.options[self.timeType.selected].data
end

---Panelin ön render işlemlerini gerçekleştirir
function ISEditSpawnerConfigUI:prerender()
    ISCollapsableWindow.prerender(self);

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
end

---Panelin render işlemlerini gerçekleştirir
function ISEditSpawnerConfigUI:render()
    ISCollapsableWindow.render(self);
end

---Paneli kapatır
function ISEditSpawnerConfigUI:close()
    ISEditSpawnerConfigUI.instance = nil;
    self:setVisible(false);
    self:removeFromUIManager();
end

---Yeni bir ISEditSpawnerConfigUI örneği oluşturur
---@param x number
---@param y number
---@param character IsoPlayer
---@return ISEditSpawnerConfigUI
function ISEditSpawnerConfigUI:new(x, y, character)
    local width = 470;
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
    o.moveWithMouse = true;
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    o.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 1 };
    o.backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 };
    o.listHeaderColor = { r = 0.2, g = 0.2, b = 0.2, a = 0.85 };
    o.moveWithMouse = true;
    o.CURRENT_SETTINGS = ZombieEmitterUtils.getSpawnersConfig()
    o:setResizable(false)
    ISEditSpawnerConfigUI.instance = o;
    return o;
end