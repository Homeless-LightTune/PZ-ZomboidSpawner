local ZombieEmitterUtils = require("ZombieEmitter_Utils")

local function onOpenZombieEmitterUI(playerObj)
    if ISZombieEmitterPanelUI.instance then
        ISZombieEmitterPanelUI.instance:close()
    end

    local ui = ISZombieEmitterPanelUI:new(playerObj);
    ui:initialise();
    ui:addToUIManager();
end

local function onAddSpawner(playerObj)
    local cursor = ISZombieEmitterSpawnerUI:new("zombie_emitter_tiles_0", "zombie_emitter_tiles_0", playerObj)
    getCell():setDrag(cursor, playerObj:getPlayerNum())
end

local function onConfigSpawners(playerObj)
    if ISZombieEmitterSpawnerConfigUI.instance then
        ISZombieEmitterSpawnerConfigUI.instance:close()
    end

    local ui = ISZombieEmitterSpawnerConfigUI:new(playerObj);
    ui:initialise();
    ui:addToUIManager();
end

local function onZombieCuller(playerObj)
    if ISZombieCullerUI.instance then
        ISZombieCullerUI.instance:close()
    end

    local ui = ISZombieCullerUI:new(playerObj);
    ui:initialise();
    ui:addToUIManager();
end

local function onFillWorldObjectContextMenu(player, context, worldobjects)
    if isAdmin() or isDebugEnabled() or getSpecificPlayer(player):isAccessLevel('admin') then
        local playerObj = getSpecificPlayer(player)

        local emitterOption = context:addOption("Zombi Yayıcı")

        local subMenu = ISContextMenu:getNew(context);
        context:addSubMenu(emitterOption, subMenu);

        local emitterZones = subMenu:addOption("Yayıcı Bölgeleri", playerObj, onOpenZombieEmitterUI)
        local addSpawner = subMenu:addOption("Spawner Ekle", playerObj, onAddSpawner)
        local configSpawners = subMenu:addOption("Spawner'ları Yapılandır", playerObj, onConfigSpawners)
        local zombieCuller = subMenu:addOption("Zombi Temizleyici", playerObj, onZombieCuller)

    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)