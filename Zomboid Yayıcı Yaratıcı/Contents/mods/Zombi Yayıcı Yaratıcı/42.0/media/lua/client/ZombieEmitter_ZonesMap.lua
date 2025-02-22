ZombieEmitter = ZombieEmitter or {}

-- ISWorldMap.render fonksiyonunu üst katman olarak sakla ve özelleştir
local upperLayerISWorldMap_render = ISWorldMap.render
function ISWorldMap:render()
    upperLayerISWorldMap_render(self)

    -- Zombie Emitter bölgelerini al
    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones

    -- Her bölgeyi harita üzerinde çiz
    for i, zone in ipairs(zones) do
        if zone.type == "circular" then
            local r = 0
            local g = 1
            local b = 0
            local alpha = 1
            ZombieEmitter.renderIsoCircleOnMap(self, self.mapAPI, zone.x, zone.y, zone.radius, r, g, b, alpha)
        elseif zone.type == "donut" then
            local alpha = 1
            ZombieEmitter.renderIsoCircleOnMap(self, self.mapAPI, zone.x, zone.y, zone.innerRadius, 0, 1, 0, alpha)
            ZombieEmitter.renderIsoCircleOnMap(self, self.mapAPI, zone.x, zone.y, zone.radius, 1, 0, 0, alpha)
        end
    end
end

-- ISMiniMapOuter.render fonksiyonunu üst katman olarak sakla ve özelleştir
local upperLayerISMiniMapOuter_render = ISMiniMapOuter.render
function ISMiniMapOuter:render()
    upperLayerISMiniMapOuter_render(self)

    -- Minimap üzerinde bölgeleri çiz (şu an çalışmıyor çünkü maske eksik)
    -- Ayrıca minimap konumunun ofseti eksik (kolayca eklenebilir)
    -- if Convergence.isCircleDisplayedOnMap() then
    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones
    for i, zone in ipairs(zones) do
        if zone.type == "circular" or zone.types == "donut" then
            local r = 0
            local g = 1
            local b = 0
            local alpha = 1
            local miniMapXOffset = self:getX() + self.inner:getX() --TODO: inner ofset kullanılmalı mı kontrol et
            local miniMapYOffset = self:getY() + self.inner:getY()
            local mask = {
                x1 = miniMapXOffset,
                x2 = miniMapXOffset + self.inner:getWidth(),
                y1 = miniMapYOffset,
                y2 = miniMapYOffset + self.inner:getHeight()
            }
            if zone.type == "circular" then
                ZombieEmitter.renderIsoCircleOnMap(self, self.inner.mapAPI, zone.x, zone.y, zone.radius, r, g, b,
                    alpha, miniMapXOffset, miniMapYOffset, mask)
            else
                ZombieEmitter.renderIsoCircleOnMap(self, self.inner.mapAPI, zone.x, zone.y, zone.innerRadius, 0, 1, 0,
                    alpha, miniMapXOffset, miniMapYOffset, mask)
                ZombieEmitter.renderIsoCircleOnMap(self, self.inner.mapAPI, zone.x, zone.y, zone.radius, r, g, b,
                    alpha, miniMapXOffset, miniMapYOffset, mask)
            end
        end
    end
end

---Harita üzerinde bir daire çizer
---@param self table
---@param mapAPI table Harita API'si
---@param posX number X konumu
---@param posY number Y konumu
---@param ray number Yarıçap
---@param r number Kırmızı renk değeri
---@param g number Yeşil renk değeri
---@param b number Mavi renk değeri
---@param a number Alfa değeri
---@param uiXOffset number UI X ofseti (isteğe bağlı)
---@param uiYOffset number UI Y ofseti (isteğe bağlı)
---@param mask table Maske (isteğe bağlı)
function ZombieEmitter.renderIsoCircleOnMap(self, mapAPI, posX, posY, ray, r, g, b, a, uiXOffset, uiYOffset, mask)
    local angularStep = 0.1163552834662886D

    -- 0'dan 2 PI'ye kadar açısal adımlarla daire çiz
    for angularIter = 0, 6.283185307179586D, angularStep do
        local xStart = posX + ray * Math.cos(angularIter)
        local yStart = posY + ray * Math.sin(angularIter)
        local xEnd = posX + ray * Math.cos(angularIter + angularStep)
        local yEnd = posY + ray * Math.sin(angularIter + angularStep)
        local xScreen1 = mapAPI:worldToUIX(xStart, yStart)
        local yScreen1 = mapAPI:worldToUIY(xStart, yStart)
        local xScreen2 = mapAPI:worldToUIX(xEnd, yEnd)
        local yScreen2 = mapAPI:worldToUIY(xEnd, yEnd)

        -- Minimap ofseti ekle
        if uiXOffset then
            xScreen1 = xScreen1 + uiXOffset
            xScreen2 = xScreen2 + uiXOffset
        end
        if uiYOffset then
            yScreen1 = yScreen1 + uiYOffset
            yScreen2 = yScreen2 + uiYOffset
        end

        -- Minimap maskesi uygula
        local hide = false
        if mask then
            hide, xScreen1, yScreen1, xScreen2, yScreen2 = luautils.applyMask(xScreen1, yScreen1, xScreen2, yScreen2, mask)
        end

        -- Çizgiyi çiz
        if not hide then
            local angle = angularIter + angularStep / 2.0
            luautils.drawLine2(xScreen1, yScreen1, xScreen2, yScreen2, a, r, g, b, angle, 2)
        end
    end
end