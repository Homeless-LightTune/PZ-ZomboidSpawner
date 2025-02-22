ZombieEmitter = ZombieEmitter or {}
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

---Mod verilerini işler
---@param key string Mod veri anahtarı
---@param data table Mod verisi
local function handleModData(key, data)
    if key == "ZOMBIE_EMITTER_DATA" then
        ModData.add(key, data)
        ModData.transmit(key)
    end
end

---Dairesel bir bölge ekler
---@param args table Bölge argümanları
function ZombieEmitter.AddCircularZone(args)
    args.type = "circular"
    args.totalSpawnedZombies = 0
    args.lastTimestamp = 0

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
    local square = getSquare(args.x, args.y, args.z)
    if square then
        ZombieEmitterUtils.startFire(square)
    end
end

---Dairesel bir bölgeyi düzenler
---@param args table Yeni bölge argümanları
---@param zoneToEdit table Düzenlenecek bölge
function ZombieEmitter.EditCircularZone(args, zoneToEdit)
    args.type = "circular"
    args.totalSpawnedZombies = zoneToEdit.totalSpawnedZombies
    args.lastTimestamp = zoneToEdit.lastTimestamp

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Halka şeklinde bir bölge ekler
---@param args table Bölge argümanları
function ZombieEmitter.AddDonutZone(args)
    args.type = "donut"
    args.totalSpawnedZombies = 0
    args.lastTimestamp = 0

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Halka şeklinde bir bölgeyi düzenler
---@param args table Yeni bölge argümanları
---@param zoneToEdit table Düzenlenecek bölge
function ZombieEmitter.EditDonutZone(args, zoneToEdit)
    args.type = "donut"
    args.totalSpawnedZombies = zoneToEdit.totalSpawnedZombies
    args.lastTimestamp = zoneToEdit.lastTimestamp

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Çizgi şeklinde bir bölge ekler
---@param args table Bölge argümanları
function ZombieEmitter.AddLineZone(args)
    args.type = "line"
    args.totalSpawnedZombies = 0
    args.lastTimestamp = 0

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Çizgi şeklinde bir bölgeyi düzenler
---@param args table Yeni bölge argümanları
---@param zoneToEdit table Düzenlenecek bölge
function ZombieEmitter.EditLineZone(args, zoneToEdit)
    args.type = "line"
    args.totalSpawnedZombies = zoneToEdit.totalSpawnedZombies
    args.lastTimestamp = zoneToEdit.lastTimestamp

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Oyuncu bağlandığında Zombie Emitter verilerini iste
local function ZombieEmitter_OnConnected()
    ModData.request("ZOMBIE_EMITTER_DATA")
end

-- Oyuncu bağlandığında tetiklenen olay
Events.OnConnected.Add(ZombieEmitter_OnConnected)

-- Global mod verisi alındığında tetiklenen olay
Events.OnReceiveGlobalModData.Add(handleModData)