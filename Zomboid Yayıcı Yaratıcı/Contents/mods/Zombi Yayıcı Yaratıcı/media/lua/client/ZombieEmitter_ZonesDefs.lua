ZombieEmitter = ZombieEmitter or {}
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

---ModData işlemlerini yönetir
---@param key string ModData anahtarı
---@param data table ModData verisi
local function handleModData(key, data)
    if key == "ZOMBIE_EMITTER_DATA" then
        ModData.add(key, data)
        ModData.transmit(key)
    end
end

---Dairesel bir bölge ekler
---@param args table Bölge bilgilerini içeren tablo
function ZombieEmitter.AddCircularZone(args)
    args.type = "circular" -- Bölge tipi: dairesel
    args.totalSpawnedZombies = 0 -- Toplam doğan zombi sayısı
    args.lastTimestamp = 0 -- Son zaman damgası

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
    local square = getSquare(args.x, args.y, args.z)
    if square then
        ZombieEmitterUtils.startFire(square) -- Bölgeye ateş ekle
    end
end

---Dairesel bir bölgeyi düzenler
---@param args table Yeni bölge bilgileri
---@param zoneToEdit table Düzenlenecek bölge bilgileri
function ZombieEmitter.EditCircularZone(args, zoneToEdit)
    args.type = "circular" -- Bölge tipi: dairesel
    args.totalSpawnedZombies = zoneToEdit.totalSpawnedZombies -- Mevcut toplam doğan zombi sayısını koru
    args.lastTimestamp = zoneToEdit.lastTimestamp -- Mevcut son zaman damgasını koru

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Halka şeklinde bir bölge ekler
---@param args table Bölge bilgilerini içeren tablo
function ZombieEmitter.AddDonutZone(args)
    args.type = "donut" -- Bölge tipi: halka
    args.totalSpawnedZombies = 0 -- Toplam doğan zombi sayısı
    args.lastTimestamp = 0 -- Son zaman damgası

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Halka şeklinde bir bölgeyi düzenler
---@param args table Yeni bölge bilgileri
---@param zoneToEdit table Düzenlenecek bölge bilgileri
function ZombieEmitter.EditDonutZone(args, zoneToEdit)
    args.type = "donut" -- Bölge tipi: halka
    args.totalSpawnedZombies = zoneToEdit.totalSpawnedZombies -- Mevcut toplam doğan zombi sayısını koru
    args.lastTimestamp = zoneToEdit.lastTimestamp -- Mevcut son zaman damgasını koru

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Çizgi şeklinde bir bölge ekler
---@param args table Bölge bilgilerini içeren tablo
function ZombieEmitter.AddLineZone(args)
    args.type = "line" -- Bölge tipi: çizgi
    args.totalSpawnedZombies = 0 -- Toplam doğan zombi sayısı
    args.lastTimestamp = 0 -- Son zaman damgası

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Çizgi şeklinde bir bölgeyi düzenler
---@param args table Yeni bölge bilgileri
---@param zoneToEdit table Düzenlenecek bölge bilgileri
function ZombieEmitter.EditLineZone(args, zoneToEdit)
    args.type = "line" -- Bölge tipi: çizgi
    args.totalSpawnedZombies = zoneToEdit.totalSpawnedZombies -- Mevcut toplam doğan zombi sayısını koru
    args.lastTimestamp = zoneToEdit.lastTimestamp -- Mevcut son zaman damgasını koru

    sendClientCommand("ZombieEmitter", "CreateOrUpdateZone", { zone = args })
end

---Sunucuya bağlanıldığında ModData'yı talep eder
local function ZombieEmitter_OnConnected()
    ModData.request("ZOMBIE_EMITTER_DATA")
end

Events.OnConnected.Add(ZombieEmitter_OnConnected)

Events.OnReceiveGlobalModData.Add(handleModData)