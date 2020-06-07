PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(entity, dungeon)
    self.entity = entity
    self.dungeon = dungoen

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
    
    -- lift object animation
    if self.entity.direction == 'left' then
        self.entity:changeAnimation('lift-left')
    elseif self.entity.direction == 'right' then
        self.entity:changeAnimation('lift-right')
    elseif self.entity.direction == 'up' then
        self.entity:changeAnimation('lift-up')
    elseif self.entity.direction == 'down' then
        self.entity:changeAnimation('lift-down')
    end
end

function PlayerLiftState:enter(object)
    self.carriedObject = object
end

function PlayerLiftState:update(dt)
    print('! just entered PlayerLiftState:update')
    self.entity:changeState('carry', self.object)
end
    
function PlayerLiftState:render()
    -- render player
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
    
    -- render object
end
