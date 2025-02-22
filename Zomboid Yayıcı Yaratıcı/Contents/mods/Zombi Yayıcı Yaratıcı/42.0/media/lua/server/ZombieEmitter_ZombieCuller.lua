if not isServer() then return end

local LAST_CHECK_TIMESTAMP = 0

---Culler bölgelerindeki zombileri temizler
local function CullZombies()
    -- Mevcut zaman damgasını al
    local currentTime = getTimestamp()

    -- Fonksiyonun her tick'te birden fazla çalışmasını engelle
    if currentTime == LAST_CHECK_TIMESTAMP then return end

    -- Mod verilerine eriş
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")
    if zombieEmitterData and zombieEmitterData.CullerZones then
        local cullerZones = zombieEmitterData.CullerZones

        for _, zoneData in pairs(cullerZones) do
            -- Bölge verilerini doğrula
            if zoneData.x1 and zoneData.x2 and zoneData.y1 and zoneData.y2 and zoneData.z and zoneData.maxZombies then
                -- Dikdörtgen bölgenin koordinatları
                local x1, x2 = math.min(zoneData.x1, zoneData.x2), math.max(zoneData.x1, zoneData.x2)
                local y1, y2 = math.min(zoneData.y1, zoneData.y2), math.max(zoneData.y1, zoneData.y2)
                local z = zoneData.z

                -- Bölgedeki zombileri topla
                local zombiesInZone = {}
                local cell = getCell()
                for x = x1, x2 do
                    for y = y1, y2 do
                        local square = cell:getGridSquare(x, y, z)
                        if square then
                            local zombieList = square:getMovingObjects()
                            for i = 0, zombieList:size() - 1 do
                                local obj = zombieList:get(i)
                                if instanceof(obj, "IsoZombie") then
                                    table.insert(zombiesInZone, obj)
                                end
                            end
                        end
                    end
                end

                -- Zombi sayısı maksimum zombi sayısını aşıyorsa
                local zombieCount = #zombiesInZone
                if zombieCount > zoneData.maxZombies then
                    local excessZombies = zombieCount - zoneData.maxZombies

                    -- Fazla zombileri kaldır
                    for i = 1, excessZombies do
                        local zombieToRemove = table.remove(zombiesInZone)
                        if zombieToRemove then
                            zombieToRemove:removeFromWorld()
                            zombieToRemove:removeFromSquare()
                        end
                    end
                end
            else
                -- Geçersiz bölge verileri
            end
        end
    end

    -- Son kontrol zaman damgasını güncelle
    LAST_CHECK_TIMESTAMP = currentTime
end

-- Her tick'te zombi temizleme işlemini çalıştır
Events.OnTick.Add(CullZombies)