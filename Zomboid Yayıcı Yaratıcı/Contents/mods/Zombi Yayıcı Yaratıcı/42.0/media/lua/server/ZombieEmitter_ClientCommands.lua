local ZombieEmitterClientCommands = {}

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

---Yeni bir bölge oluşturur veya mevcut bir bölgeyi günceller
---@param args table Bölge argümanları
function ZombieEmitterClientCommands.CreateOrUpdateZone(args)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if not zombieEmitterData.zones then
        zombieEmitterData.zones = {}
    end

    local zoneName = args.zone.newName or args.zone.zoneName

    -- Eğer yeni bir isim verilmişse ve eski isimle bir bölge varsa, eski bölgeyi sil
    if args.zone.newName and zombieEmitterData.zones[args.zone.name] then
        zombieEmitterData.zones[args.zone.name] = nil
    end

    -- Mevcut bir bölgeyi düzenleme
    if zombieEmitterData.zones[zoneName] then
        zombieEmitterData.zones[zoneName].spawnInterval = args.zone.spawnInterval
        zombieEmitterData.zones[zoneName].timeType = args.zone.timeType
        zombieEmitterData.zones[zoneName].maxZombies = args.zone.maxZombies
        zombieEmitterData.zones[zoneName].x = args.zone.x
        zombieEmitterData.zones[zoneName].y = args.zone.y
        zombieEmitterData.zones[zoneName].z = args.zone.z
        zombieEmitterData.zones[zoneName].count = args.zone.count
        zombieEmitterData.zones[zoneName].crawler = args.zone.crawler
        zombieEmitterData.zones[zoneName].isFallOnFront = args.zone.isFallOnFront
        zombieEmitterData.zones[zoneName].isFakeDead = args.zone.isFakeDead
        zombieEmitterData.zones[zoneName].knockedDown = args.zone.knockedDown
        zombieEmitterData.zones[zoneName].health = args.zone.health
        zombieEmitterData.zones[zoneName].outfit = args.zone.outfit
        zombieEmitterData.zones[zoneName].type = args.zone.type
        zombieEmitterData.zones[zoneName].totalSpawnedZombies = args.zone.totalSpawnedZombies
        zombieEmitterData.zones[zoneName].lastTimestamp = args.zone.lastTimestamp

        -- Türüne özgü özellikler
        if args.zone.type == "circular" then
            zombieEmitterData.zones[zoneName].radius = args.zone.radius
            zombieEmitterData.zones[zoneName].x = args.zone.x
            zombieEmitterData.zones[zoneName].y = args.zone.y
            zombieEmitterData.zones[zoneName].z = args.zone.z
        elseif args.zone.type == "donut" then
            zombieEmitterData.zones[zoneName].radius = args.zone.radius
            zombieEmitterData.zones[zoneName].innerRadius = args.zone.innerRadius
            zombieEmitterData.zones[zoneName].x = args.zone.x
            zombieEmitterData.zones[zoneName].y = args.zone.y
            zombieEmitterData.zones[zoneName].z = args.zone.z
        elseif args.zone.type == "line" then
            zombieEmitterData.zones[zoneName].Ax = args.zone.Ax
            zombieEmitterData.zones[zoneName].Ay = args.zone.Ay
            zombieEmitterData.zones[zoneName].Az = args.zone.Az
            zombieEmitterData.zones[zoneName].Bx = args.zone.Bx
            zombieEmitterData.zones[zoneName].By = args.zone.By
            zombieEmitterData.zones[zoneName].Bz = args.zone.Bz
        end
    else
        -- Yeni bir bölge oluştur
        local newZone = {
            spawnInterval = args.zone.spawnInterval,
            timeType = args.zone.timeType,
            maxZombies = args.zone.maxZombies,
            count = args.zone.count,
            crawler = args.zone.crawler,
            isFallOnFront = args.zone.isFallOnFront,
            isFakeDead = args.zone.isFakeDead,
            knockedDown = args.zone.knockedDown,
            health = args.zone.health,
            outfit = args.zone.outfit,
            type = args.zone.type,
            totalSpawnedZombies = args.zone.totalSpawnedZombies,
            lastTimestamp = args.zone.lastTimestamp,
        }

        -- Türüne özgü özellikler
        if args.zone.type == "circular" then
            newZone.radius = args.zone.radius
            newZone.x = args.zone.x
            newZone.y = args.zone.y
            newZone.z = args.zone.z
        elseif args.zone.type == "donut" then
            newZone.radius = args.zone.radius
            newZone.innerRadius = args.zone.innerRadius
            newZone.x = args.zone.x
            newZone.y = args.zone.y
            newZone.z = args.zone.z
        elseif args.zone.type == "line" then
            newZone.Ax = args.zone.Ax
            newZone.Ay = args.zone.Ay
            newZone.Az = args.zone.Az
            newZone.Bx = args.zone.Bx
            newZone.By = args.zone.By
            newZone.Bz = args.zone.Bz
        end

        zombieEmitterData.zones[zoneName] = newZone
    end

    ModData.transmit("ZOMBIE_EMITTER_DATA")
    sendServerCommand('ZombieEmitter', 'RefreshZonesUI', {})

    local x = args.zone.x or args.zone.Ax
    local y = args.zone.y or args.zone.Ay
    local z = args.zone.z or args.zone.Az

    local square = getSquare(x, y, z)

    if square then
        local newObject = IsoThumpable.new(getCell(), square, "zombie_emitter_tiles_0", false, {})
        newObject:setIsThumpable(false)
        newObject:setCanPassThrough(false)
        newObject:setHoppable(false)
        square:transmitAddObjectToSquare(newObject, 1)
    end
end

---Bir bölgeyi siler
---@param args table Silinecek bölge argümanları
function ZombieEmitterClientCommands.DeleteZone(args)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if zombieEmitterData.zones then
        local zone = zombieEmitterData.zones[args.name]
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

            zombieEmitterData.zones[args.name] = nil

            ModData.transmit("ZOMBIE_EMITTER_DATA")

            sendServerCommand('ZombieEmitter', 'RefreshZonesUI', {})
        end
    end
end

---Yeni bir spawner ekler
---@param args table Spawner argümanları
function ZombieEmitterClientCommands.AddSpawner(args)
    local square = getSquare(args.x, args.y, args.z)
    if square then
        local newObject = IsoThumpable.new(getCell(), square, "zombie_emitter_tiles_0", false, {})
        newObject:setIsThumpable(false)
        newObject:setCanPassThrough(false)
        newObject:setHoppable(false)
        square:transmitAddObjectToSquare(newObject, 1)

        local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

        if zombieEmitterData.spawners then
            local newSpawnerData = { x = args.x, y = args.y, z = args.z, spawnedZombies = 0, lastSpawnTimestamp = 0 }
            local spawnerIndex = 1
            while zombieEmitterData.spawners["Spawner" .. spawnerIndex] do
                spawnerIndex = spawnerIndex + 1
            end
            zombieEmitterData.spawners["Spawner" .. spawnerIndex] = newSpawnerData
            ModData.transmit("ZOMBIE_EMITTER_DATA")
        end
    end
end

---Spawner'ın adını değiştirir
---@param args table Spawner adı argümanları
function ZombieEmitterClientCommands.SetSpawnerName(args)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    -- Eğer spawner tablosu varsa
    if zombieEmitterData.spawners then
        -- Eski isimle bir spawner varsa
        if zombieEmitterData.spawners[args.oldName] then
            -- Verilerini sakla
            local oldData = zombieEmitterData.spawners[args.oldName]
            -- Eski spawner'ı tablodan kaldır
            zombieEmitterData.spawners[args.oldName] = nil
            -- Yeni isimle bir spawner varsa (üzerine yazma modu)
            if zombieEmitterData.spawners[args.newName] then
                -- Mevcut spawner'ın nesnesini ve ateşini kaldır
                local x = zombieEmitterData.spawners[args.newName].x
                local y = zombieEmitterData.spawners[args.newName].y
                local z = zombieEmitterData.spawners[args.newName].z

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
            end
            zombieEmitterData.spawners[args.newName] = oldData
            ModData.transmit("ZOMBIE_EMITTER_DATA")
            sendServerCommand('ZombieEmitter', 'RefreshSpawnersUI', {})
        end
    end
end

---Bir spawner'ı siler
---@param args table Silinecek spawner argümanları
function ZombieEmitterClientCommands.DeleteSpawner(args)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if zombieEmitterData.spawners then
        local spawner = zombieEmitterData.spawners[args.name]
        if spawner then
            local x = spawner.x
            local y = spawner.y
            local z = spawner.z

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
                            if sprite and spriteName and spriteName == ("zombie_emitter_tiles_0") then
                                square:transmitRemoveItemFromSquare(object)
                            end
                        end
                    end
                end
            end
        end

        zombieEmitterData.spawners[args.name] = nil

        ModData.transmit("ZOMBIE_EMITTER_DATA")

        sendServerCommand('ZombieEmitter', 'RefreshSpawnersUI', {})
    end
end

---Spawner'ların yapılandırmasını düzenler
---@param args table Yapılandırma argümanları
function ZombieEmitterClientCommands.EditSpawnersConfig(args)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")
    zombieEmitterData.SpawnersConfig = args
    ModData.transmit("ZOMBIE_EMITTER_DATA")
end

---Yeni bir culler bölgesi ekler
---@param args table Culler bölgesi argümanları
function ZombieEmitterClientCommands.AddCullerZone(args)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if not zombieEmitterData.CullerZones then
        zombieEmitterData.CullerZones = {}
    end

    zombieEmitterData.CullerZones[args.zoneName] = args.zoneData
    ModData.transmit("ZOMBIE_EMITTER_DATA")
    sendServerCommand('ZombieEmitter', 'RefreshCullerZonesUI', {})
end

---Bir culler bölgesini düzenler
---@param args table Culler bölgesi argümanları
function ZombieEmitterClientCommands.EditCullerZone(args)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if not zombieEmitterData.CullerZones then
        zombieEmitterData.CullerZones = {}
    end

    if zombieEmitterData.CullerZones[args.oldZoneName] then
        if args.oldZoneName == args.zoneName then
            zombieEmitterData.CullerZones[args.zoneName] = args.zoneData
        else
            zombieEmitterData.CullerZones[args.oldZoneName] = nil
            zombieEmitterData.CullerZones[args.zoneName] = args.zoneData
        end

        ModData.transmit("ZOMBIE_EMITTER_DATA")
        sendServerCommand('ZombieEmitter', 'RefreshCullerZonesUI', {})
    end
end

---Bir culler bölgesini siler
---@param args table Silinecek culler bölgesi argümanları
function ZombieEmitterClientCommands.DeleteCullerZone(args)
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if zombieEmitterData.CullerZones then
        zombieEmitterData.CullerZones[args.name] = nil

        ModData.transmit("ZOMBIE_EMITTER_DATA")

        sendServerCommand('ZombieEmitter', 'RefreshCullerZonesUI', {})
    end
end

---İstemci komutlarını işler
---@param module string Modül adı
---@param command string Komut adı
---@param playerObj IsoPlayer Oyuncu nesnesi
---@param args table Komut argümanları
ZombieEmitterClientCommands.OnClientCommand = function(module, command, playerObj, args)
    if module == 'ZombieEmitter' then
        ZombieEmitterClientCommands[command](args)
    end
end

-- İstemci komutları dinleyen olay
Events.OnClientCommand.Add(ZombieEmitterClientCommands.OnClientCommand)