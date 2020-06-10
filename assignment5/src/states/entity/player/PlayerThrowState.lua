PlayerThrowState = Class{__includes = BaseState}

function PlayerThrowState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    
    self.thrownObject = nil

    -- throw pot animation (depends on which direction player is in)
    self.entity:changeAnimation('throw-' .. tostring(self.entity.direction))
end

function PlayerThrowState:enter(object)
    self.thrownObject = object
    
    -- force render before update
    self:render()
end

function PlayerThrowState:update(dt)
    self.thrownObject:fire(self.entity, self.dungeon.currentRoom)
    self.entity:changeState('idle')
end

function PlayerThrowState:render()
    -- render player
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
end