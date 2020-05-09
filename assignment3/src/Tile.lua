--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    
    self.variety = variety
    
    -- indicates whether the tile is a special shiny tile than destroys on entire row
    -- when it's in a match. tiles are defaulted to be not shiny, unless otherwise specified
--    self.shiny = shiny or false
    self.shiny = math.random() < 0.5 and true or false
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
      
    -- if we have a shiny tile, we need to render it as such
    if self.shiny then
      love.graphics.setColor(255, 215, 0, 100)
      love.graphics.rectangle('line', self.x + x, self.y + y, 32, 32, 5, 5)
      love.graphics.setColor(255, 255, 255, 255)
    end
end