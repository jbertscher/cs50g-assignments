--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    
    for k, brick in pairs(self.bricks) do
        if brick.isLocked then
            self.isLockedBrickInPlay = true
        end
    end

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    -- keeps track of score so that we can grow the paddle after a certain number
    -- of points have been achieved
    self.paddleGrowScoreTracker = 0

    -- create powerup objects, initialised to be out of play, indexed by table
    self.powerups = {
        ['bonus'] = Powerup(7),
        ['key'] = Powerup(10)
    }
    
    self.maxBonusPowerupProb = 1.0  --  0.1
    self.incrBonusPowerupProbPerSec = 1.0  -- 1/600 
    self.avgMinsTillKeyPowerup = 0.3  -- 3
    self.minTimeTillBonusPowerup = 1  -- 20
    
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    -- if the locked brick is in play, then allow for the possibility that the key power spawns
    if self.isLockedBrickInPlay and not self.powerups['key'].inPlay and not self.powerups['key'].isVisible then
        -- key powerup spawns on average once every self.avgMinsTillKeyPowerup minutes
        if math.random() < 1/(60 * self.avgMinsTillKeyPowerup) * dt then
            self.powerups['key'].isVisible = true   
            -- spawn it at a random x coordinate and above the top edge of the screen
            self.powerups['key'].x = math.random(VIRTUAL_WIDTH) - self.powerups['key'].width
            self.powerups['key'].y = -self.powerups['key'].height
        end
    end

    for j, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do
            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                if not brick.isLocked or self.powerups['key'].inPlay then
                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()

                    -- add to score
                    self.scoreIncrease = (brick.tier * 200 + brick.color * 25) + (brick.isLocked == true and 1 or 0 * 50000)
                    self.score = self.score + self.scoreIncrease
                    -- add to the score tracker for growing the paddle, unless the paddle is 
                    -- at its maximum size
                    if self.paddle.size ~= self.paddle.maxSize then
                        self.paddleGrowScoreTracker = self.paddleGrowScoreTracker + self.scoreIncrease
                    end

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)

                        -- multiply recover points by 2
                        self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            ball = ball,
                            recoverPoints = self.recoverPoints
                        })
                    end

                    -- if brick was locked, we must have unlocked it so no locked brick is in play anymore
                    if brick.isLocked then
                        self.isLockedBrickInPlay = false
                    end

                    -- for checking whether to spawn bonus powerup when brick is hit
                    elapsed_time = os.difftime(os.time(), self.powerups['bonus'].startTime)
                    -- only allow powerup if at least self.minTimeTillBonusPowerup seconds have elapsed
                    if elapsed_time > self.minTimeTillBonusPowerup and not self.powerups['bonus'].isVisible then
                        -- randomly spawn powerup. every second the probability that the powerup spawns 
                        -- when a brick is hit increases by self.incrBrickPowerupProbPerSec, up to a maximum probability of 0.1
                        if math.random() < math.min(self.maxBonusPowerupProb, self.incrBonusPowerupProbPerSec) then
                            self.powerups['bonus'].isVisible = true
                            -- spawn in the middle of the brick that was just hit
                            self.powerups['bonus'].x = brick.x + 8
                            self.powerups['bonus'].y = brick.y + 16
                            -- reset the elapsed time
                            self.powerups['bonus'].startTime = os.time()
                        end
                    end
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- accumulating 20,000 points grows the paddle (until the largest size is reached)
                if self.paddleGrowScoreTracker >= 2000 then
                    self.paddle:changeSize(1)
                    -- reset the tracker
                    self.paddleGrowScoreTracker = 0
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

        if ball.y >= VIRTUAL_HEIGHT then
            table.remove(self.balls, j)
        end
    end

    -- if we have no more balls left, revert to serve state and decrease health
    if #self.balls == 0 then
        self.health = self.health - 1
        -- losing health shrinks the paddle (until the smallest size is reached)
        self.paddle:changeSize(-1)
        -- reset the score tracker for growing the paddle
        self.paddleGrowScoreTracker = 0
        gSounds['hurt']:play()

        for k, powerup in pairs(self.powerups) do
            powerup.inPlay = false
            -- restart the time
            powerup.startTime = os.time()
        end

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    -- if powerup is visible, check for collision or dropping below screen
    for k, powerup in pairs(self.powerups) do   
        if powerup.isVisible then

            -- if powerup collides with paddle, do something depending on the type of powerup
            if powerup:collides(self.paddle) then
                if k == 'bonus' then
                    for i = #self.balls + 1, #self.balls + 2 do
                        self.balls[i] = Ball(math.random(7))
                        -- spawn ball in the middle of the paddle
                        self.balls[i].x = self.paddle.x + self.paddle.width/2
                        self.balls[i].y = self.paddle.y
                        -- give ball random starting velocity
                        self.balls[i].dx = math.random(-200, 200)
                        self.balls[i].dy = math.random(-50, -60)
                    end
                elseif k == 'key' then
                    powerup.inPlay = true
                end
                powerup.isVisible = false
                powerup.startTime = os.time()

            -- if powerup drops below screen, set it to not be in play and reset timer
            elseif powerup.y > VIRTUAL_HEIGHT then
                powerup.isVisible = false
                powerup.startTime = os.time()
            end                
        end

        powerup:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    -- render powerup (if visible)
    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end