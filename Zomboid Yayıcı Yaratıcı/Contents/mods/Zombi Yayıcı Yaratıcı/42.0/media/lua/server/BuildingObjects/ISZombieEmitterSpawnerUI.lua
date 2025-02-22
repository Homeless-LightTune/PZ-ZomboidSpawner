ISZombieEmitterSpawnerUI = ISBuildingObject:derive("ISZombieEmitterSpawnerUI")
local ZombieEmitterUtils = require("ZombieEmitter_Utils")

---Spawner'ı oluşturur
---@param x number X koordinatı
---@param y number Y koordinatı
---@param z number Z koordinatı
---@param north boolean Kuzey yönünde mi?
---@param sprite string Sprite adı
function ISZombieEmitterSpawnerUI:create(x, y, z, north, sprite)
    local square = getCell():getGridSquare(x, y, z)
    local objs = square:getObjects()

    -- Aynı sprite'ın karede zaten olup olmadığını kontrol et
    local tileAlreadyOnSquare = false
    for i = 0, objs:size() - 1 do
        if objs:get(i):getSprite() ~= nil and objs:get(i):getSprite():getName() == sprite then
            tileAlreadyOnSquare = true
        end
    end

    -- Eğer sprite karede yoksa, spawner'ı oluştur ve ateş başlat
    if not tileAlreadyOnSquare then
        ZombieEmitterUtils.startFire(square)
        sendClientCommand("ZombieEmitter", "AddSpawner", { x = x, y = y, z = z })
    end
end

---Spawner'ı ekranda render et
---@param x number X koordinatı
---@param y number Y koordinatı
---@param z number Z koordinatı
---@param square IsoGridSquare Kare
function ISZombieEmitterSpawnerUI:render(x, y, z, square)
    ISBuildingObject.render(self, x, y, z, square)
end

---Yeni bir ISZombieEmitterSpawnerUI örneği oluştur
---@param sprite string Sprite adı
---@param northSprite string Kuzey sprite'ı
---@param character IsoPlayer Karakter
---@return table ISZombieEmitterSpawnerUI örneği
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