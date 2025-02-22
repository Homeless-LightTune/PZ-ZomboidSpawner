ISZombieEmitterSpawnerUI = ISBuildingObject:derive("ISZombieEmitterSpawnerUI")
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

function ISZombieEmitterSpawnerUI:create(x, y, z, north, sprite)
    local square = getCell():getGridSquare(x, y, z)
    local objs = square:getObjects()

    local tileAlreadyOnSquare = false
    for i = 0, objs:size() - 1 do
        if objs:get(i):getSprite() ~= nil and objs:get(i):getSprite():getName() == sprite then
            tileAlreadyOnSquare = true
        end
    end
    if not tileAlreadyOnSquare then
        ZombieEmitterUtils.startFire(square)
        sendClientCommand("ZombieEmitter", "AddSpawner", { x = x, y = y, z = z })
    end
end

function ISZombieEmitterSpawnerUI:render(x, y, z, square)
    ISBuildingObject.render(self, x, y, z, square)
end

function ISZombieEmitterSpawnerUI:new(sprite, northSprite, character)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o:setSprite(sprite)
    o:setNorthSprite(northSprite)
    o.character = character
    o.player = character:getPlayerNum()
    o.isTileCursor = true
    o.spriteName = sprite
    o.noNeedHammer = true
    o.skipBuildAction = true
    o.skipWalk2 = true
    o.canBeAlwaysPlaced = true
    return o
end
