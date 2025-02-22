ZombieEmitter = ZombieEmitter or {}

-- ISWorldMap.render fonksiyonunu üst katman olarak sakla ve harita üzerinde bölgeleri çiz
local upperLayerISWorldMap_render = ISWorldMap.render
function ISWorldMap:render()
    upperLayerISWorldMap_render(self)

    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones

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

-- ISMiniMapOuter.render fonksiyonunu üst katman olarak sakla ve mini harita üzerinde bölgeleri çiz
local upperLayerISMiniMapOuter_render = ISMiniMapOuter.render
function ISMiniMapOuter:render()
    upperLayerISMiniMapOuter_render(self)

    -- Maske olmadığı için çalışmıyor (henüz nasıl yapılacağını bilmiyorum) semboller kullanılabilir mi?
    -- Ayrıca mini harita konumunun ofseti eksik (kolayca hesaba katılabilir)
    -- if Convergence.isCircleDisplayedOnMap() then
    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones
    for i, zone in ipairs(zones) do
        if zone.type == "circular" or zone.types == "donut" then
            local r = 0
            local g = 1
            local b = 0
            local alpha = 1
            local miniMapXOffset = self:getX() + self.inner:getX() --TODO: inner ofsetinin kullanılması gerekip gerekmediğini kontrol et
            local miniMapYOffset = self:getY() + self.inner:getY()
            local mask = {
                x1 = miniMapXOffset,
                x2 = miniMapXOffset + self.inner:getWidth(),
                y1 = miniMapYOffset,
                y2 = miniMapYOffset + self.inner:getHeight()
            }
            if zone.type == "circular" then
                ZombieEmitter.renderIsoCircleOnMap(self, self.inner.mapAPI, zone.x, zone.y, zone.radius, r, g, b,
                    alpha,
                    miniMapXOffset, miniMapYOffset, mask)
            else
                ZombieEmitter.renderIsoCircleOnMap(self, self.inner.mapAPI, zone.x, zone.y, zone.innerRadius, 0, 1, 0,
                    alpha,
                    miniMapXOffset, miniMapYOffset, mask)
                ZombieEmitter.renderIsoCircleOnMap(self, self.inner.mapAPI, zone.x, zone.y, zone.radius, r, g, b,
                    alpha,
                    miniMapXOffset, miniMapYOffset, mask)
            end
        end
    end
end

---Harita üzerinde bir dairesel bölge çizer
---@param self table ISWorldMap veya ISMiniMapOuter örneği
---@param mapAPI table Harita API'si
---@param posX number Bölgenin X koordinatı
---@param posY number Bölgenin Y koordinatı
---@param ray number Bölgenin yarıçapı
---@param r number Çizgi rengi (kırmızı)
---@param g number Çizgi rengi (yeşil)
---@param b number Çizgi rengi (mavi)
---@param a number Çizgi opaklığı
---@param uiXOffset number UI X ofseti (isteğe bağlı)
---@param uiYOffset number UI Y ofseti (isteğe bağlı)
---@param mask table Maske bilgisi (isteğe bağlı)
function ZombieEmitter.renderIsoCircleOnMap(self, mapAPI, posX, posY, ray, r, g, b, a, uiXOffset, uiYOffset, mask)
    local angularStep = 0.1163552834662886D

    for angularIter = 0, 6.283185307179586D, angularStep do -- 0'dan 2 PI'ye kadar
        local xStart = posX + ray * Math.cos(angularIter)
        local yStart = posY + ray * Math.sin(angularIter)
        local xEnd = posX + ray * Math.cos(angularIter + angularStep)
        local yEnd = posY + ray * Math.sin(angularIter + angularStep)
        local xScreen1 = mapAPI:worldToUIX(xStart, yStart)
        local yScreen1 = mapAPI:worldToUIY(xStart, yStart)
        local xScreen2 = mapAPI:worldToUIX(xEnd, yEnd)
        local yScreen2 = mapAPI:worldToUIY(xEnd, yEnd)

        -- Mini harita ofseti
        if uiXOffset then
            xScreen1 = xScreen1 + uiXOffset; xScreen2 = xScreen2 + uiXOffset
        end
        if uiYOffset then
            yScreen1 = yScreen1 + uiYOffset; yScreen2 = yScreen2 + uiYOffset
        end

        -- Mini harita maskesi
        local hide = false
        if mask then
            hide, xScreen1, yScreen1, xScreen2, yScreen2 = luautils.applyMask(xScreen1, yScreen1, xScreen2, yScreen2,
                mask)
        end

        if not hide then
            local angle = angularIter + angularStep / 2.0
            luautils.drawLine2(xScreen1, yScreen1, xScreen2, yScreen2, a, r, g, b, angle, 2)
        end
    end
end