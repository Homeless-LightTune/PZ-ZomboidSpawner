local ZombieEmitterUtils = {}

---Tüm mevcut bölgeleri döndürür
---@return table
function ZombieEmitterUtils.getAllZones()
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if zombieEmitterData and zombieEmitterData.zones then
        return zombieEmitterData.zones
    else
        return {}
    end
end

---Tüm mevcut spawner'ları döndürür
---@return table
function ZombieEmitterUtils.getAllSpawners()
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if zombieEmitterData and zombieEmitterData.spawners then
        return zombieEmitterData.spawners
    else
        return {}
    end
end

---Bir bölgenin var olup olmadığını kontrol eder
---@param name string Kontrol edilecek bölgenin adı
---@return boolean Bölge varsa true, yoksa false
function ZombieEmitterUtils.doesZoneExist(name)
    local data = ModData.get("ZOMBIE_EMITTER_DATA").zones
    if not data then return false end

    if data[name] then return true else return false end
end

---Bir spawner'ın var olup olmadığını kontrol eder
---@param name string Kontrol edilecek spawner'ın adı
---@return boolean Spawner varsa true, yoksa false
function ZombieEmitterUtils.doesSpawnerExist(name)
    local data = ModData.get("ZOMBIE_EMITTER_DATA").spawners
    if not data then return false end

    if data[name] then return true else return false end
end

---Bir temizleyici bölgesinin var olup olmadığını kontrol eder
---@param name string Kontrol edilecek bölgenin adı
---@return boolean Bölge varsa true, yoksa false
function ZombieEmitterUtils.doesCullerZoneExist(name)
    local data = ModData.get("ZOMBIE_EMITTER_DATA").CullerZones
    if not data then return false end

    if data[name] then return true else return false end
end

---Bir modal iletişim kutusu oluşturur
---@param text string İletişim kutusunda gösterilecek metin
---@param yesno boolean Evet/Hayır butonları gösterilsin mi?
---@param onClick function|nil Butona tıklandığında çağrılacak fonksiyon
---@param param1 any İsteğe bağlı parametre 1
---@param param2 any İsteğe bağlı parametre 2
---@return ISModalDialog
function ZombieEmitterUtils.createModalDialog(text, yesno, target, onClick, param1, param2)
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local font = UIFont.Small
    local textWidth = getTextManager():MeasureStringX(font, text)
    local textHeight = getTextManager():MeasureStringY(font, text)

    local panelWidth = math.min(screenWidth - 40, textWidth + 20)    -- Panel genişliğini sınırla
    local panelHeight = math.min(screenHeight - 25, textHeight + 50) -- Panel yüksekliğini sınırla

    local x = (screenWidth - panelWidth) / 2
    local y = (screenHeight - panelHeight) / 2

    local character = getPlayer()
    local playerNum = character:getPlayerNum()

    if not yesno then
        return ISModalDialog:new(x, y, panelWidth, panelHeight, text, false)
    else
        return ISModalDialog:new(x, y, panelWidth, panelHeight, text, true, target, onClick, playerNum,
            param1, param2)
    end
end

---Bir bölgeyi siler
---@param zoneName string Silinecek bölgenin adı
function ZombieEmitterUtils.deleteZone(zoneName)
    if not zoneName or zoneName == "" then
        return
    end

    sendClientCommand("ZombieEmitter", "DeleteZone", { name = zoneName })
end

---Bir spawner'ı siler
---@param spawnerName string Silinecek spawner'ın adı
function ZombieEmitterUtils.deleteSpawner(spawnerName)
    if not spawnerName or spawnerName == "" then
        return
    end

    sendClientCommand("ZombieEmitter", "DeleteSpawner", { name = spawnerName })
end

---Bir temizleyici bölgesini siler
---@param name string Silinecek bölgenin adı
function ZombieEmitterUtils.deleteCullerZone(name)
    if not name or name == "" then
        return
    end

    sendClientCommand("ZombieEmitter", "DeleteCullerZone", { name = name })
end

---Bir bölgenin koordinatlarını döndürür
---@param zoneName string Bölgenin adı
---@return table coords Bölgenin koordinatları
function ZombieEmitterUtils.getZonesCoords(zoneName)
    local coords = {}

    local data = ModData.get("ZOMBIE_EMITTER_DATA").zones
    if data then
        local zoneData = data[zoneName]
        if zoneData then
            local zoneType = zoneData.type
            if zoneType == "circular" or zoneType == "donut" then
                coords.x = zoneData.x
                coords.y = zoneData.y
                coords.z = zoneData.z
            else
                coords.x = zoneData.Ax
                coords.y = zoneData.Ay
                coords.z = zoneData.Az
            end
        end
    end

    return coords
end

---Bir karede kalıcı bir ateş nesnesi başlatır
---@param square IsoGridSquare
function ZombieEmitterUtils.startFire(square)
    local fireObj = IsoFire.new(getCell(), square)

    -- Ateş animasyonunu ekle (kamp ateşi benzeri parametreler kullanarak)
    fireObj:AttachAnim("Fire", "01", 4, IsoFireManager.FireAnimDelay, -16, -78, true, 0, false, 0.7,
        IsoFireManager.FireTintMod)

    -- Ateş nesnesini kareye ekle
    square:AddSpecialObject(fireObj)

    -- Ateş nesnesinin ateş yöneticisi tarafından güncellenmesini sağla
    IsoFireManager.Add(fireObj)

    fireObj:transmitCompleteItemToServer()
end

---Spawner'ların genel yapılandırma ayarlarını döndürür
---@return table
function ZombieEmitterUtils.getSpawnersConfig()
    return ModData.get("ZOMBIE_EMITTER_DATA").SpawnersConfig or {}
end

---Tüm mevcut temizleyici bölgelerini döndürür
---@return table
function ZombieEmitterUtils.getAllCullerZones()
    local zombieEmitterData = ModData.get("ZOMBIE_EMITTER_DATA")

    if zombieEmitterData and zombieEmitterData.CullerZones then
        return zombieEmitterData.CullerZones
    else
        return {}
    end
end

return ZombieEmitterUtils