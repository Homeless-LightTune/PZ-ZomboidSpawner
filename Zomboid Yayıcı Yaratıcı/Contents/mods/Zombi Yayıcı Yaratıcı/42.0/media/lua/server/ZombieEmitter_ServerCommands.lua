local ZombieEmitterServerCommands = {}

---Zombie Emitter bölgeleri UI'sini yeniler
---@param args table Argümanlar
function ZombieEmitterServerCommands.RefreshZonesUI(args)
    if ISZombieEmitterPanelUI.instance then
        ISZombieEmitterPanelUI.instance:RefreshUI()
    end
end

---Culler bölgeleri UI'sini yeniler
---@param args table Argümanlar
function ZombieEmitterServerCommands.RefreshCullerZonesUI(args)
    if ISZombieCullerUI.instance then
        ISZombieCullerUI.instance:RefreshUI()
    end
end

---Spawner'ların UI'sini yeniler
---@param args table Argümanlar
function ZombieEmitterServerCommands.RefreshSpawnersUI(args)
    if ISZombieEmitterSpawnerConfigUI.instance then
        ISZombieEmitterSpawnerConfigUI.instance:RefreshUI()
    end
end

---Sunucu komutlarını işler
---@param module string Modül adı
---@param command string Komut adı
---@param args table Argümanlar
local function OnServerCommand(module, command, args)
    if module == 'ZombieEmitter' then
        ZombieEmitterServerCommands[command](args)
    end
end

-- Sunucu komutlarını dinleyen olay
Events.OnServerCommand.Add(OnServerCommand)