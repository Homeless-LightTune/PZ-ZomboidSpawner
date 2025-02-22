local function ZombieEmitter_OnInitGlobalModData()
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA")

    local zones = ModData.get("ZOMBIE_EMITTER_DATA").zones or {}
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA").zones = zones

    local spawners = ModData.get("ZOMBIE_EMITTER_DATA").spawners or {}
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA").spawners = spawners

    local spawnersConfig = ModData.get("ZOMBIE_EMITTER_DATA").SpawnersConfig or {}
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA").SpawnersConfig = spawnersConfig

    local cullerZones = ModData.get("ZOMBIE_EMITTER_DATA").CullerZones or {}
    ModData.getOrCreate("ZOMBIE_EMITTER_DATA").CullerZones = cullerZones
end

Events.OnInitGlobalModData.Add(ZombieEmitter_OnInitGlobalModData)
