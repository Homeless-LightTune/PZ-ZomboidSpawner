if not isServer() then return end

local LAST_CHECK_TIMESTAMP = 0
local LAST_SPAWNER_CHECK_TIMESTAMP = 0

---Bir karedeki kalıcı ateş nesnesini bulur
---@param square IsoGridSquare Kare
---@return IsoFire|nil Ateş nesnesi veya nil
local function getFireObj(square)
    if square then
        for i = 0, square:getObjects():size() - 1 do
            local fireObj = square:getObjects():get(i)
            if instanceof(fireObj, 'IsoFire') and fireObj:isPermanent() then
                return fireObj
            end
        end
    end
    return nil
end

---Bir bölgeyi siler
---@param zoneName string Silinecek bölgenin adı
local function DeleteZone(zoneName)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if zombieEmitterData.zones then
        local zone = zombieEmitterData.zones[zoneName]
        if zone then
            local x = zone.x or zone.Ax
            local y = zone.y or zone.Ay
            local z = zone.z or zone.Az

            local square = getSquare(x, y, z)
            if square then
                -- Kalıcı ateş nesnesini kaldır
                local fireObj = getFireObj(square)
                if fireObj then
                    -- Ateşi söndür ve kareden kaldır
                    square:transmitRemoveItemFromSquare(fireObj)
                    square:getProperties():UnSet(IsoFlagType.burning)
                end

                -- Spawner tile'ını kaldır
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local object = objects:get(i)
                    if object then
                        local sprite = object:getSprite()
                        if sprite then
                            local spriteName = sprite:getName()
                            if sprite and spriteName and spriteName:contains("zombie_emitter_tiles") then
                                square:transmitRemoveItemFromSquare(object)
                            end
                        end
                    end
                end
            end

            zombieEmitterData.zones[zoneName] = nil

            ModData.transmit("ZOMBIE_EMITTER_DATA")

            sendServerCommand('ZombieEmitter', 'RefreshZonesUI', {})
        end
    end
end

---Zombilerin spawn olup olmayacağını kontrol eder
---@param lastTimestamp number Son spawn zaman damgası
---@param spawnInterval number Spawn aralığı
---@param timeType string Zaman tipi (saniye, dakika, saat, gün)
---@return boolean Zombiler spawn olmalı mı?
local function ShouldSpawnZombies(lastTimestamp, spawnInterval, timeType)
    local currentTimestamp = getTimestamp()

    local timeDifference = currentTimestamp - lastTimestamp

    if timeType == "s" and timeDifference >= spawnInterval then
        return true
    elseif timeType == "m" and timeDifference >= spawnInterval * 60 then
        return true
    elseif timeType == "h" and timeDifference >= spawnInterval * 60 * 60 then
        return true
    elseif timeType == "d" and timeDifference >= spawnInterval * 24 * 60 * 60 then
        return true
    end

    return false
end

---Geçerli bir spawn konumu olup olmadığını kontrol eder
---@param x number X koordinatı
---@param y number Y koordinatı
---@param z number Z koordinatı
---@param zone table Bölge verileri
---@return boolean Geçerli bir spawn konumu mu?
local function IsValidSpawnLocation(x, y, z, zone)
    -- Zombilerin sıkışabileceği veya yanabileceği tam koordinatlarda spawn olmamasını sağla
    if (x == zone.x and y == zone.y and z == zone.z) or (zone.type == "line" and x == zone.Ax and y == zone.Ay and z == zone.Az) then
        return false
    end
    return true
end

---Dairesel bölgede zombi spawn eder
---@param zoneName string Bölge adı
---@param zoneData table Bölge verileri
local function SpawnZombiesInCircularZone(zoneName, zoneData)
    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones

    local spawnInterval = tonumber(zoneData.spawnInterval)
    local timeType = zoneData.timeType
    local maxZombies = tonumber(zoneData.maxZombies)
    local x = tonumber(zoneData.x)
    local y = tonumber(zoneData.y)
    local z = zoneData.z
    local count = zoneData.count
    local radius = tonumber(zoneData.radius)
    local crawler = zoneData.crawler
    local isFallOnFront = zoneData.isFallOnFront
    local isFakeDead = zoneData.isFakeDead
    local knockedDown = zoneData.knockedDown
    local health = zoneData.health
    local outfit = zoneData.outfit
    local lastTimestamp = tonumber(zoneData.lastTimestamp) or 0

    if ShouldSpawnZombies(lastTimestamp, spawnInterval, timeType) then
        for i = 1, count do
            -- Belirtilen aralıkta rastgele bir açı hesapla
            local angle = math.rad(ZombRand(0, 360))

            -- Mesafeyi daire merkezi ile yarıçap arasında rastgele bir değer olarak ayarla
            local distance = ZombRand(0, radius)

            -- Yeni koordinatları hesapla
            local newX = x + distance * math.cos(angle)
            local newY = y + distance * math.sin(angle)

            -- Spawn konumunun geçerli olup olmadığını kontrol et
            if not IsValidSpawnLocation(newX, newY, z, zoneData) then
                newX = newX + 2
                newY = newY + 2
            end
            addZombiesInOutfit(newX, newY, z, 1, outfit, 50, crawler, isFallOnFront, isFakeDead, knockedDown, health)
        end

        -- Toplam spawn edilen zombi sayısını güncelle ve maksimum zombi sayısını kontrol et
        zoneData.totalSpawnedZombies = zoneData.totalSpawnedZombies + count

        -- Yeni sayı maksimum zombi sayısını aşıyorsa veya eşitse, bölgeyi sil
        if maxZombies ~= -1 and zoneData.totalSpawnedZombies >= maxZombies then
            DeleteZone(zoneName)
        end

        -- Bir sonraki spawn için zaman damgasını güncelle
        zoneData.lastTimestamp = getTimestamp()

        ModData.get("ZOMBIE_EMITTER_DATA").zones = zones
        ModData.transmit("ZOMBIE_EMITTER_DATA")
    end
end

---Halka şeklindeki bölgede zombi spawn eder
---@param zoneName string Bölge adı
---@param zoneData table Bölge verileri
local function SpawnZombiesInDonutZone(zoneName, zoneData)
    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones

    local spawnInterval = tonumber(zoneData.spawnInterval)
    local timeType = zoneData.timeType
    local maxZombies = tonumber(zoneData.maxZombies)
    local x = tonumber(zoneData.x)
    local y = tonumber(zoneData.y)
    local z = zoneData.z
    local count = zoneData.count
    local radius = zoneData.radius
    local innerRadius = zoneData.innerRadius
    local crawler = zoneData.crawler
    local isFallOnFront = zoneData.isFallOnFront
    local isFakeDead = zoneData.isFakeDead
    local knockedDown = zoneData.knockedDown
    local health = zoneData.health
    local outfit = zoneData.outfit
    local lastTimestamp = tonumber(zoneData.lastTimestamp) or 0

    if ShouldSpawnZombies(lastTimestamp, spawnInterval, timeType) then
        for i = 1, count do
            -- Belirtilen aralıkta rastgele bir açı hesapla
            local angle = math.rad(ZombRand(0, 360))

            -- Mesafeyi iç yarıçap ile yarıçap arasında rastgele bir değer olarak ayarla
            local distance = ZombRand(innerRadius + 1, radius)

            -- Yeni koordinatları hesapla
            local newX = x + distance * math.cos(angle)
            local newY = y + distance * math.sin(angle)

            -- Spawn konumunun geçerli olup olmadığını kontrol et
            if not IsValidSpawnLocation(newX, newY, z, zoneData) then
                newX = newX + 2
                newY = newY + 2
            end
            addZombiesInOutfit(newX, newY, z, 1, outfit, 50, crawler, isFallOnFront, isFakeDead, knockedDown, health)
        end

        -- Toplam spawn edilen zombi sayısını güncelle ve maksimum zombi sayısını kontrol et
        zoneData.totalSpawnedZombies = zoneData.totalSpawnedZombies + count

        -- Yeni sayı maksimum zombi sayısını aşıyorsa veya eşitse, bölgeyi sil
        if maxZombies ~= -1 and zoneData.totalSpawnedZombies >= maxZombies then
            DeleteZone(zoneName)
        end

        -- Bir sonraki spawn için zaman damgasını güncelle
        zoneData.lastTimestamp = getTimestamp()

        ModData.get("ZOMBIE_EMITTER_DATA").zones = zones
        ModData.transmit("ZOMBIE_EMITTER_DATA")
    end
end

---Çizgi şeklindeki bölgede zombi spawn eder
---@param zoneName string Bölge adı
---@param zoneData table Bölge verileri
local function SpawnZombiesInLineZone(zoneName, zoneData)
    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones

    local spawnInterval = tonumber(zoneData.spawnInterval)
    local timeType = zoneData.timeType
    local maxZombies = tonumber(zoneData.maxZombies)
    local Ax = zoneData.Ax
    local Ay = zoneData.Ay
    local Az = zoneData.Az
    local Bx = zoneData.Bx
    local By = zoneData.By
    local Bz = zoneData.Bz
    local count = zoneData.count
    local crawler = zoneData.crawler
    local isFallOnFront = zoneData.isFallOnFront
    local isFakeDead = zoneData.isFakeDead
    local knockedDown = zoneData.knockedDown
    local health = zoneData.health
    local outfit = zoneData.outfit
    local lastTimestamp = tonumber(zoneData.lastTimestamp) or 0

    if ShouldSpawnZombies(lastTimestamp, spawnInterval, timeType) then
        for i = 1, count do
            -- Çizgi boyunca pozisyonu hesapla
            local ratio = i / count
            local newX = Ax + ratio * (Bx - Ax)
            local newY = Ay + ratio * (By - Ay)
            local newZ = Az + ratio * (Bz - Az)

            -- Spawn konumunun geçerli olup olmadığını kontrol et
            if not IsValidSpawnLocation(newX, newY, newZ, zoneData) then
                newX = newX + 2
                newY = newY + 2
            end
            addZombiesInOutfit(newX, newY, newZ, 1, outfit, 50, crawler, isFallOnFront, isFakeDead, knockedDown,
                health)
        end

        -- Toplam spawn edilen zombi sayısını güncelle ve maksimum zombi sayısını kontrol et
        zoneData.totalSpawnedZombies = zoneData.totalSpawnedZombies + count

        -- Yeni sayı maksimum zombi sayısını aşıyorsa veya eşitse, bölgeyi sil
        if maxZombies ~= -1 and zoneData.totalSpawnedZombies >= maxZombies then
            DeleteZone(zoneName)
        end

        -- Bir sonraki spawn için zaman damgasını güncelle
        zoneData.lastTimestamp = getTimestamp()

        ModData.get("ZOMBIE_EMITTER_DATA").zones = zones
        ModData.transmit("ZOMBIE_EMITTER_DATA")
    end
end

---Bölgelerde zombi spawn eder
local function SpawnZombiesInZones()
    local currentTime = getTimestamp()
    if currentTime == LAST_CHECK_TIMESTAMP then return end

    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones

    if zones then
        for zoneName, zoneData in pairs(zones) do
            if zoneData.type == "circular" then
                SpawnZombiesInCircularZone(zoneName, zoneData)
            elseif zoneData.type == "donut" then
                SpawnZombiesInDonutZone(zoneName, zoneData)
            elseif zoneData.type == "line" then
                SpawnZombiesInLineZone(zoneName, zoneData)
            end
        end
    end

    LAST_CHECK_TIMESTAMP = currentTime
end

---Bir sonraki spawn zaman damgasını hesaplar
---@param lastSpawnTimestamp number Son spawn zaman damgası
---@param spawnInterval number Spawn aralığı
---@param timeType string Zaman tipi (saniye, dakika, saat, gün)
---@return number Bir sonraki spawn zaman damgası
local function getNextSpawnTimestamp(lastSpawnTimestamp, spawnInterval, timeType)
    local intervalInSeconds = spawnInterval
    if timeType == "m" then
        intervalInSeconds = spawnInterval * 60
    elseif timeType == "h" then
        intervalInSeconds = spawnInterval * 3600
    elseif timeType == "d" then
        intervalInSeconds = spawnInterval * 86400
    end
    return lastSpawnTimestamp + intervalInSeconds
end

---Manuel olarak yerleştirilen spawner'larda zombi spawn eder
local function SpawnSpawnersZombies()
    local currentTime = getTimestamp()
    if currentTime <= LAST_SPAWNER_CHECK_TIMESTAMP then return end

    local spawners = ModData.get("ZOMBIE_EMITTER_DATA").spawners
    if spawners then
        local spawnersConfig = ModData.get("ZOMBIE_EMITTER_DATA").SpawnersConfig
        for _, spawnerData in pairs(spawners) do
            local lastSpawnTimestamp = tonumber(spawnerData.lastSpawnTimestamp) or 0
            local spawnerInterval = spawnersConfig.spawnInterval or 1
            local spawnerTimeType = spawnersConfig.timeType or "s"

            -- Spawner için bir sonraki spawn zamanını hesapla
            local nextSpawnTime = getNextSpawnTimestamp(lastSpawnTimestamp, spawnerInterval, spawnerTimeType)

            if currentTime >= nextSpawnTime then
                local spawnedZombies = tonumber(spawnerData.spawnedZombies)
                local maxZombies = tonumber(spawnersConfig.maxZombies)
                if spawnedZombies < maxZombies or maxZombies == -1 then
                    -- Zombi spawn özelliklerini tanımla
                    local x = spawnerData.x + 2
                    local y = spawnerData.y + 2
                    local z = spawnerData.z
                    local count = tonumber(spawnersConfig.count)
                    local outfit = spawnersConfig.outfit or ""
                    local crawler = spawnersConfig.crawler
                    local isFallOnFront = spawnersConfig.isFallOnFront
                    local isFakeDead = spawnersConfig.isFakeDead
                    local knockedDown = spawnersConfig.knockedDown
                    local health = spawnersConfig.health

                    -- Belirtilen parametrelerle zombi spawn et
                    addZombiesInOutfit(x, y, z, count, outfit, 50, crawler, isFallOnFront, isFakeDead, knockedDown,
                        health)

                    -- Spawner zaman damgasını ve zombi sayısını güncelle
                    spawnerData.lastSpawnTimestamp = currentTime
                    spawnerData.spawnedZombies = spawnedZombies + count
                end
            end
        end
        LAST_SPAWNER_CHECK_TIMESTAMP = currentTime
        ModData.get("ZOMBIE_EMITTER_DATA").spawners = spawners
        ModData.transmit("ZOMBIE_EMITTER_DATA")
    end
end

-- Her tick'te bölgelerde zombi spawn et
Events.OnTick.Add(SpawnZombiesInZones)

-- Her tick'te spawner'larda zombi spawn et
Events.OnTick.Add(SpawnSpawnersZombies)