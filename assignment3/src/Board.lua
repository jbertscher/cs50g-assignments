--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.level = level
    self.matches = {}
    -- map colours in sprite sheet to indices in table
    self.colorMap = {1, 2, 5, 6, 11, 12, 14, 15}

    self:initializeTiles(level)
end

function Board:initializeTiles(level)
    self.tiles = {}
    level=1
    -- every 2 levels, we increase the variety (from min of 1 up to max of 6)
    maxVariety = math.min(math.max(1, math.floor(level / 2)), 6)
    
    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, self.colorMap[math.random(8)], math.random(maxVariety)))
        end
    end

    while self:calculateMatches() and self:potentialMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board (but that has the potential to match) on start
        self:initializeTiles()
    end
end

--[[
    Swaps 2 tiles. This logically was originally a block of code in PlayState but since it's being
    re-used quite often, I embedded it into a function, which made sense to houe in the Board class.
]]
function Board:swapTiles(x1, y1, x2, y2)
    local tile1 = self.tiles[y1][x1]
  
    local tempX = tile1.gridX
    local tempY = tile1.gridY

    local tile2 = self.tiles[y2][x2]

    tile1.gridX = tile2.gridX
    tile1.gridY = tile2.gridY
    tile2.gridX = tempX
    tile2.gridY = tempY

    -- swap tiles in the tiles table
    self.tiles[tile1.gridY][tile1.gridX] = tile1
    self.tiles[tile2.gridY][tile2.gridX] = tile2
    
    return tile1, tile2
end

--[[
    Checks if swap between 2 results in a match. Uses similar logic to Board:calculateMatches 
    but only checks for match within the row and column of the swapped tiles and returns whether 
    the swap results in a match so we don't need to check the entire board.
]]
function Board:checkIfSwapCreatesMatch(x1, y1, x2, y2)
    local tiles = {self.tiles[y1][x1], self.tiles[y2][x2]}
    
    local foundMatch = false
    
    -- check if either tile's new position will result in a match
    for k, tile in pairs(tiles) do       
        local colorToMatch = tile.color
        
        -- horizontal matches first
        y = tile.gridY
        local matchNum = 1
        
        -- start 1 tile to the left and continue moving left to look for matches
        for x = tile.gridX - 1, 1, -1 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                if matchNum >= 3 then
                    foundMatch = true
                    break
                end
            else
                break
            end
        end
        -- if we're here, we didn't find enough matches on the left so look on the right
        for x = tile.gridX + 1, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                if matchNum >= 3 then 
                    foundMatch = true
                    break
                end
            else
                break
            end
        end
        
        -- since we're here, we haven't found enough horizonal matches so now look vertically:
        x = tile.gridX
        matchNum = 1
        
        -- start 1 tile above tile and continue moving up to look for matches
        for y = tile.gridY - 1, 1, -1 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                if matchNum >= 3 then
                    foundMatch = true
                    break
                end
            else
                break
            end
        end
        -- if we're here, we didn't find enough matches above, so look down
        for y = tile.gridY + 1, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                if matchNum >= 3 then
                    foundMatch = true
                    break
                end
            else
                break
            end
        end
    end
      
    if foundMatch then
        return {tile1, tile2}
    else
        return false
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        -- set this to the shiny tile if it's shiny
        local shinyTile = self.tiles[y][1].shiny and self.tiles[y][1] or false
        
        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                -- record a shiny tile in the match, if we have one
                if self.tiles[y][x].shiny then
                    shinyTile = self.tiles[y][x]
                end
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- if there's a shiny tile in the match, go backwards from end of the row to beginning
                    if shinyTile then  
                        for x2 = 8, 1, -1 do             
                          -- add each tile to the match that's in that match
                          table.insert(match, self.tiles[y][x2])
                        end
                    -- we don't need to handle match within row if entire row is removed
                    else
                        -- go backwards from here by matchNum
                        for x2 = x - 1, x - matchNum, -1 do             
                          -- add each tile to the match that's in that match
                          table.insert(match, self.tiles[y][x2])
                        end
                    end
                    
                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- set this to the shiny tile if it's shiny
                local shinyTile = self.tiles[y][x].shiny and self.tiles[y][x] or false
                
                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match (we do this because match is only checked 
        -- when string of matches ends and if the final row ends in a match then this will never happen)
        if matchNum >= 3 then
            local match = {}
            
            -- if there's a shiny tile in the match, go backwards from end of the row to beginning
            if shinyTile then  
                for x2 = 8, 1, -1 do             
                  -- add each tile to the match that's in that match
                  table.insert(match, self.tiles[y][x2])
                end
            -- we don't need to handle match within row if entire row is removed
            else
                -- go backwards from here by matchNum
                for x2 = 8, 8 - matchNum + 1, -1 do             
                  -- add each tile to the match that's in that match
                  table.insert(match, self.tiles[y][x2])
                end
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        -- set this to the shiny tile if it's shiny
        local shinyTile = self.tiles[1][x].shiny and self.tiles[1][x] or false
        
        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                -- record the shiny tile in the match, if we have one
                if self.tiles[y][x].shiny then
                    shinyTile = self.tiles[y][x]
                end
            else
                colorToMatch = self.tiles[y][x].color
        
                if matchNum >= 3 then
                    local match = {}
                    
                    if shinyTile then
                        for x = 8, 1, -1 do
                            table.insert(match, self.tiles[shinyTile.gridY][x])
                        end
                    end
                    
                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- set this to the shiny tile if it's shiny
                local shinyTile = self.tiles[y][x].shiny and self.tiles[y][x] or false
                
                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            if shinyTile then
                for x = 8, 1, -1 do
                    table.insert(match, self.tiles[shinyTile.gridY][x])
                end
            end
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Works out whether its possible to create a match on the board
]]
function Board:potentialMatches()
    -- for each row (y-value)
    for y = 1, 8 do
        -- for each column (x-value)
        for x = 1, 7 do
            -- swap tile with tile to the right of it
            self:swapTiles(x, y, x + 1, y)
            
            -- check if match occurs
            -- if so, return true after swapping tiles back
            if self:checkIfSwapCreatesMatch(x, y, x + 1, y) then
                self:swapTiles(x, y, x + 1, y)
                return true
            -- otherwise, just swap tiles back
            else
                self:swapTiles(x, y, x + 1, y)
            end
        end
    end
        
    -- for each column (x-value)
    for x = 1, 8 do
        -- for each row (y-value)
        for y = 1, 7 do
            -- swap tile with tile below it
            self:swapTiles(x, y, x, y + 1)
            
            -- check if match occurs
            -- if so, return true after swapping tiles back
            if self:checkIfSwapCreatesMatch(x, y, x, y + 1) then
                self:swapTiles(x, y, x, y + 1)
                return true
            -- otherwise, just swap tiles back
            else
                self:swapTiles(x, y, x, y + 1)
            end
        end
    end
    
    -- if we get here, it means there was not match 
    return false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, self.colorMap[math.random(8)], math.random(maxVariety))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end