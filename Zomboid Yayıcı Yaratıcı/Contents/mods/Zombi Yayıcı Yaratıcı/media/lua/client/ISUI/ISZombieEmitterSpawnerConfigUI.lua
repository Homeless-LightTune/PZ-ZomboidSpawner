ISZombieEmitterSpawnerConfigUI = ISCollapsableWindow:derive("ISZombieEmitterSpawnerConfigUI")
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local HEADER_HGT = FONT_HGT_SMALL + 2 * 2

function ISZombieEmitterSpawnerConfigUI.onRename(_, button)
    if button.internal == "OK" then
        if button.parent.entry:getText() and button.parent.entry:getText() ~= "" then
            local instance = ISZombieEmitterSpawnerConfigUI.instance
            if instance then
                local newName = button.parent.entry:getText()
                local spawnerExists = ZombieEmitterUtils.doesSpawnerExist(newName)
                if spawnerExists then
                    if ZombieEmitterUtils.overwriteSpawnerModal then
                        ZombieEmitterUtils.overwriteSpawnerModal:setVisible(false)
                        ZombieEmitterUtils.overwriteSpawnerModal:removeFromUIManager()
                        ZombieEmitterUtils.overwriteSpawnerModal = nil
                    end

                    local text =
                    "Bu isimde bir spawner zaten var. Devam etmek üzerine yazacaktır. Devam etmek istediğinizden emin misiniz?"

                    local args =
                    {
                        oldName = instance.selectedSpawner.spawnerName,
                        newName = newName
                    }

                    ZombieEmitterUtils.overwriteSpawnerModal = ZombieEmitterUtils.createModalDialog(text, true, nil,
                        ISZombieEmitterSpawnerConfigUI.onOverwriteSpawner, args, nil)
                    ZombieEmitterUtils.overwriteSpawnerModal:initialise()
                    ZombieEmitterUtils.overwriteSpawnerModal:addToUIManager()
                else
                    local args =
                    {
                        oldName = instance.selectedSpawner.spawnerName,
                        newName = newName
                    }
                    sendClientCommand('ZombieEmitter', 'SetSpawnerName', args)
                end
            end
        end
    end
end

function ISZombieEmitterSpawnerConfigUI.onOverwriteSpawner(this, button, args)
    if button.internal == "YES" then
        sendClientCommand('ZombieEmitter', 'SetSpawnerName', args)
        if ZombieEmitterUtils.overwriteSpawnerModal then
            ZombieEmitterUtils.overwriteSpawnerModal:close()
        end
    end
end

function ISZombieEmitterSpawnerConfigUI.onDeleteSpawner(this, button, name)
    if button.internal == "YES" then
        ZombieEmitterUtils.deleteSpawner(name)
    end
end

function ISZombieEmitterSpawnerConfigUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    local y = FONT_HGT_MEDIUM + HEADER_HGT + 30

    -- Tüm spawner'ları göstermek için bir liste ekle
    local x = (self:getWidth() / 2) - (320 / 2)
    self.allSpawnersList = ISScrollingListBox:new(x, y + 20, 320, 300)
    self.allSpawnersList:initialise();
    self.allSpawnersList:instantiate();
    self.allSpawnersList.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.allSpawnersList.selected = 0;
    self.allSpawnersList.joypadParent = self;
    self.allSpawnersList.font = UIFont.NewSmall;
    self.allSpawnersList.doDrawItem = self.drawSpawnersDatas;
    self.allSpawnersList.drawBorder = true;
    self.allSpawnersList.borderColor = { r = 1, g = 1, b = 1, a = 1 }
    self.allSpawnersList:addColumn("Spawner Adı", 0)
    self:addChild(self.allSpawnersList);
    self:getSpawners();

    -- İptal Butonu
    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self,
        ISZombieEmitterSpawnerConfigUI.onClick);
    self.no.internal = "CANCEL";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.no);

    -- Yenile Butonu
    self.refreshBtn = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        getText("IGUI_DbViewer_Refresh"), self, ISZombieEmitterSpawnerConfigUI.onClick);
    self.refreshBtn.internal = "REFRESH";
    self.refreshBtn.anchorTop = false
    self.refreshBtn.anchorBottom = true
    self.refreshBtn:initialise();
    self.refreshBtn:instantiate();
    self.refreshBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.refreshBtn);

    local x = self.refreshBtn.x - btnWid - 10
    -- Spawner'ları Yapılandır Butonu
    self.configBtn = ISButton:new(x, self.refreshBtn.y, btnWid, btnHgt, "Yapılandır", self,
        ISZombieEmitterSpawnerConfigUI.onClick);
    self.configBtn.internal = "CONFIG";
    self.configBtn.anchorTop = false
    self.configBtn.anchorBottom = true
    self.configBtn:initialise();
    self.configBtn:instantiate();
    self.configBtn.borderColor = { r = 0, g = 1, b = 0, a = 1 };
    self.configBtn.backgroundColor = { r = 0, g = 0.75, b = 0, a = 1 };
    self.configBtn.backgroundColorMouseOver = { r = 0, g = 0.5, b = 0, a = 1 };
    self.configBtn.textColor = { r = 0, g = 0, b = 0, a = 1 };
    self.configBtn.tooltip = "<RED> Bu, tüm manuel olarak yerleştirilmiş spawner'ları yapılandıracaktır!"
    self:addChild(self.configBtn);

    -- Işınlanma Butonu
    self.teleportBtn = ISButton:new(self.allSpawnersList:getX(), self.allSpawnersList:getBottom() + 10, btnWid, btnHgt,
        "Işınlan", self, ISZombieEmitterSpawnerConfigUI.onClick);
    self.teleportBtn.internal = "TELEPORT";
    self.teleportBtn.anchorTop = false
    self.teleportBtn.anchorBottom = false
    self.teleportBtn:initialise();
    self.teleportBtn:instantiate();
    self.teleportBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self.teleportBtn.tooltip = "<RED> UYARI: Yenilmezlik etkin değilse, yanabilirsiniz."
    self:addChild(self.teleportBtn);

    -- Yeniden Adlandır Butonu
    self.renameBtn = ISButton:new(self.teleportBtn:getRight() + 10, self.teleportBtn.y, btnWid, btnHgt,
        "Yeniden Adlandır", self, ISZombieEmitterSpawnerConfigUI.onClick);
    self.renameBtn.internal = "RENAME";
    self.renameBtn.anchorTop = false
    self.renameBtn.anchorBottom = false
    self.renameBtn:initialise();
    self.renameBtn:instantiate();
    self.renameBtn.borderColor = { r = 1, g = 1, b = 1, a = 1 };
    self:addChild(self.renameBtn);

    -- Spawner Sil Butonu
    self.deleteBtn = ISButton:new(self.renameBtn:getRight() + 10, self.renameBtn.y, btnWid,
        btnHgt, "Spawner Sil", self, ISZombieEmitterSpawnerConfigUI.onClick);
    self.deleteBtn.internal = "DELETE_SPAWNER";
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

function ISZombieEmitterSpawnerConfigUI:onClick(button)
    local player = self.chr

    if button.internal == "CANCEL" then
        self:close();
    elseif button.internal == "TELEPORT" then
        local x, y, z = self.selectedSpawner.x, self.selectedSpawner.y, self.selectedSpawner.z
        if x and y and z then
            player:setX(x);
            player:setY(y);
            player:setZ(z);
            player:setLx(x)
            player:setLy(y)
            player:setLz(z)
        end
    elseif button.internal == "RENAME" then
        local modal = ISTextBox:new(0, 0, 280, 180, "Spawner'ı Yeniden Adlandır", self.selectedSpawner.spawnerName, nil,
            ISZombieEmitterSpawnerConfigUI.onRename);
        modal:initialise();
        modal:addToUIManager();
        modal.entry:focus();
    elseif button.internal == "REFRESH" then
        self:RefreshUI()
    elseif button.internal == "DELETE_SPAWNER" then
        if not self.selectedSpawner then return end
        if not ZombieEmitterUtils.doesSpawnerExist(self.selectedSpawner.spawnerName) then return end

        if ZombieEmitterUtils.deleteSpawnerModal then
            ZombieEmitterUtils.deleteSpawnerModal:setVisible(false)
            ZombieEmitterUtils.deleteSpawnerModal:removeFromUIManager()
            ZombieEmitterUtils.deleteSpawnerModal = nil
        end

        local text = "\"" .. self.selectedSpawner.spawnerName .. "\" spawner'ını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz!"

        ZombieEmitterUtils.deleteSpawnerModal = ZombieEmitterUtils.createModalDialog(text, true, nil,
            ISZombieEmitterSpawnerConfigUI.onDeleteSpawner, self.selectedSpawner.spawnerName)
        ZombieEmitterUtils.deleteSpawnerModal:initialise()
        ZombieEmitterUtils.deleteSpawnerModal:addToUIManager()
    elseif button.internal == "CONFIG" then
        if ISEditSpawnerConfigUI.instance then
            ISEditSpawnerConfigUI.instance:close()
        end

        local ui = ISEditSpawnerConfigUI:new(0, 0, player);
        ui:initialise();
        ui:addToUIManager();
    end
end

function ISZombieEmitterSpawnerConfigUI:update()
    ISCollapsableWindow.update(self)

    local selectedSpawner = self.allSpawnersList.items[self.allSpawnersList.selected]

    if selectedSpawner and (self.selectedSpawner ~= selectedSpawner.item.data) then
        local selectedSpawnerData = selectedSpawner.item.data
        self.selectedSpawner = selectedSpawnerData
    end
end

function ISZombieEmitterSpawnerConfigUI:prerender()
    ISCollapsableWindow.prerender(self);

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawText("Zombi Spawner'ları",
        self.width / 2 - (getTextManager():MeasureStringX(UIFont.Title, "Zombi Spawner'ları") / 2), 20, 1, 1, 1, 1,
        UIFont.Title)

    if not self.selectedSpawner then
        self.teleportBtn:setEnable(false)
        self.renameBtn:setEnable(false)
        self.deleteBtn:setEnable(false)

        self.teleportBtn.tooltip = "<RED> Hiçbir spawner seçilmedi"
        self.renameBtn.tooltip = "<RED> Hiçbir spawner seçilmedi"
        self.deleteBtn.tooltip = "<RED> Hiçbir spawner seçilmedi"
    else
        self.teleportBtn:setEnable(true)
        self.renameBtn:setEnable(true)
        self.deleteBtn:setEnable(true)

        self.teleportBtn.tooltip = "<RED> UYARI: Yenilmezlik etkin değilse, yanabilirsiniz."
        self.renameBtn.tooltip = "<GREEN> Seçili spawner'ı yeniden adlandır"
        self.deleteBtn.tooltip = "<RED> Seçili spawner'ı sil"
    end
end

function ISZombieEmitterSpawnerConfigUI:render()
    ISCollapsableWindow.render(self);
end

function ISZombieEmitterSpawnerConfigUI:close()
    ISZombieEmitterSpawnerConfigUI.instance = nil
    self:setVisible(false)
    self:removeFromUIManager()
end

function ISZombieEmitterSpawnerConfigUI:getSpawners()
    local allSpawners = ZombieEmitterUtils.getAllSpawners()
    if allSpawners then
        self.allSpawners = allSpawners
        self:populateSpawnersList()
    end
end

function ISZombieEmitterSpawnerConfigUI:populateSpawnersList()
    self.allSpawnersList:clear()
    self.selectedSpawner = nil

    if not self.allSpawners then
        return
    end

    local spawnersNames = {}

    for spawnerName, _ in pairs(self.allSpawners) do
        table.insert(spawnersNames, spawnerName)
    end

    table.sort(spawnersNames, function(a, b)
        return a:lower() < b:lower()
    end)

    for i, spawnerName in ipairs(spawnersNames) do
        local spawnerData = self.allSpawners[spawnerName]
        spawnerData.spawnerName = spawnerName

        local item = { data = spawnerData }
        self.allSpawnersList:addItem(spawnerName, item)

        if i == 1 then
            self.selectedSpawner = spawnerData
        end
    end
end

function ISZombieEmitterSpawnerConfigUI:drawSpawnersDatas(y, item, alt)
    local alpha = 0.9
    local itemHeightWithPadding = self.itemheight + 4
    local spawner = item.item.data
    local isSelected = self.selected == item.index

    self:drawRectBorder(0, y, self:getWidth(), itemHeightWithPadding, alpha, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    if isSelected then
        self:drawRect(0, y, self:getWidth(), itemHeightWithPadding, 0.3, 0.7, 0.35, 0.15)
        self.selectedSpawner = spawner
    end

    local spawnerName = spawner.spawnerName

    self:drawText(spawnerName, 10, y + 2, 1, 1, 1, alpha, UIFont.Medium)

    item.item.yPosition = y

    return y + itemHeightWithPadding
end

function ISZombieEmitterSpawnerConfigUI:RefreshUI()
    self.allSpawnersList:clear()
    self.selectedSpawners = nil

    self:getSpawners()
end

function ISZombieEmitterSpawnerConfigUI:new(character)
    local o = {}
    local width = 500;
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
    ISZombieEmitterSpawnerConfigUI.instance = o;
    return o;
end