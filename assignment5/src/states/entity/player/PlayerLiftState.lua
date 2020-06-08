PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(entity, dungeon)
    self.entity = entity
    self.dungeon = dungoen

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
    
    -- lift object animation
    self.entity:changeAnimation('lift-' .. tostring(self.entity.direction))
    
    -- force render before update
    self:render()
end

function PlayerLiftState:enter(object)
    self.carriedObject = object
end

function PlayerLiftState:update(dt)
    self.entity:changeState('idle-carry', self.object)
end
    
function PlayerLiftState:render()
    -- render player
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
    
    -- render object
end
