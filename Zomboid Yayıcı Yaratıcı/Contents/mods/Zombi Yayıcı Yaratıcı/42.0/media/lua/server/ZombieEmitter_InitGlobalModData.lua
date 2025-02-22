---Global ModData başlatıldığında Zombie Emitter verilerini oluşturur veya alır
local function ZombieEmitter_OnInitGlobalModData()
    -- ZOMBIE_EMITTER_DATA ModData'sini oluştur veya al
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA")

    -- Bölgeleri al veya oluştur
    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones or {}
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA").zones = zones

    -- Spawner'ları al veya oluştur
    local spawners = ModData.get("ZOMBIE_EMITTER_DATA").spawners or {}
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA").spawners = spawners

    -- Spawner yapılandırmasını al veya oluştur
    local spawnersConfig = ModData.get("ZOMBIE_EMITTER_DATA").SpawnersConfig or {}
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA").SpawnersConfig = spawnersConfig

    -- Culler bölgelerini al veya oluştur
    local cullerZones = ModData.get("ZOMBIE_EMITTER_DATA").CullerZones or {}
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA").CullerZones = cullerZones
end

-- Global ModData başlatıldığında tetiklenen olay
Events.OnInitGlobalModData.Add(ZombieEmitter_OnInitGlobalModData)