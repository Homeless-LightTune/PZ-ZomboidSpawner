local ZombieEmitterServerCommands = {}

function ZombieEmitterServerCommands.RefreshZonesUI(args)
    if ISZombieEmitterPanelUI.instance then
        ISZombieEmitterPanelUI.instance:RefreshUI()
    end
end

function ZombieEmitterServerCommands.RefreshCullerZonesUI(args)
    if ISZombieCullerUI.instance then
        ISZombieCullerUI.instance:RefreshUI()
    end
end

function ZombieEmitterServerCommands.RefreshSpawnersUI(args)
    if ISZombieEmitterSpawnerConfigUI.instance then
        ISZombieEmitterSpawnerConfigUI.instance:RefreshUI()
    end
end

local function OnServerCommand(module, command, args)
    if module == 'ZombieEmitter' then
        ZombieEmitterServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
