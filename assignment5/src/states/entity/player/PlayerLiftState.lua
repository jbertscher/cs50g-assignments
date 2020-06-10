PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(entity, dungeon)
    self.entity = entity
    self.dungeon = dungoen

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
    
    -- lift object animation
    self.entity:changeAnimation('lift-' .. tostring(self.entity.direction))
end

function PlayerLiftState:enter(object)      
    self.carriedObject = object

    -- force render before update
    self:render()
end

function PlayerLiftState:update(dt)
    Timer.tween(0.1, {
        [self.carriedObject] = {
            x = self.entity.x,
            y = self.entity.y - self.carriedObject.height + 4
        }
    })

    self.entity:changeState('idle-carry', self.carriedObject)
end
    
function PlayerLiftState:render()
    -- render player
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
end
