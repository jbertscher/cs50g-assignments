--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    
    -- keep track of whether key and lock generated
    local keyGenerated = false
    local lockGenerated = false
    
    -- keep track of last 2 columns where we can spawn the flag (want to place it in 2nd 
    -- last place because otherwise the flag gets cut off at the right edge of the screen.
    local last2ColsForFlag = {1, 2}

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        canSpawnFlag = true
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness (i.e. 'chasm')
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
            canSpawnFlag = false
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            -- generate ground for this colum (first 3 rows from the bottom of the screen)
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                    
                -- chance to generate key on pillar
                if not keyGenerated and math.random() < 1/width then
                    -- TODO
                -- chance to generate lock on pillar
                elseif not lockGenerated and math.random() < 1/width then
                    -- TODO
                
                -- chance to generate bush on pillar
                elseif math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
                
                canSpawnFlag = false
            
            -- chance to generate a key
            elseif not keyGenerated and math.random() < 1/width then
                table.insert(objects,
                    GameObject {
                        texture = 'keys_and_locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = math.random(4),
                        collidable = true,
                        consumable = true,
                        solid = false,
                        
                        onConsume = function(player, object)
                            gSounds['pickup']:play()
                            player.hasKey = true
                        end
                    }
                )
                keyGenerated = true
                canSpawnFlag = false
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to generate a lock block
            if not lockGenerated and math.random() < 1/width then
                table.insert(objects,
                    GameObject {
                        isLock = true,
                        texture = 'keys_and_locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = math.random(5, 8),
                        collidable = true,  
                        consumable = false,  
                        solid = true,
                                                
                        onCollide = function(player, object)
                            -- spawn flag and flag-pole object
                            if player.hasKey then
                                gSounds['powerup-reveal']:play()
                                
                                table.insert(objects,
                                    GameObject {
                                        texture = 'flag_and_poles',
                                        frameTexture = 'flag_poles',
                                        x = (last2ColsForFlag[1] - 1) * TILE_SIZE, 
                                        y = (4 - 1) * TILE_SIZE,
                                        width = 16, 
                                        height = 48,  
                                        frame = math.random(6),
                                        collidable = false,  
                                        consumable = true,  
                                        solid = false,
                                                                
                                        onConsume = function(player, object)
                                            -- end level and spawn a new one
                                            gStateMachine:change('play',
                                                {
                                                    score = player.score,
                                                    mapWidth = width
                                                }
                                            )
                                        end
                                    }
                                )
                                table.insert(objects,
                                    GameObject {
                                        texture = 'flag_and_poles',
                                        frameTexture = 'flags',
                                        x = (last2ColsForFlag[1] - 1) * TILE_SIZE + 8,
                                        y = (4 - 1) * TILE_SIZE,
                                        width = 16, 
                                        height = 16,  
                                        frame = math.random(8),
                                        collidable = false,  
                                        consumable = true,  
                                        solid = false,
                                                                
                                        onConsume = function(player, object)
                                            -- end level and spawn a new one
                                            gStateMachine:change('play',
                                                {
                                                    score = player.score,
                                                    mapWidth = width
                                                }
                                            )
                                        end
                                    }
                                )
                            end
                        end
                    }
                )
                lockGenerated = true
                canSpawnFlag = false
                
            -- chance to spawn a block
            elseif math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            canSpawnFlag = false
            end
            if canSpawnFlag then
                last2ColsForFlag = {last2ColsForFlag[2], x}
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles

    -- ensure that a lock and key are generated
    if (not keyGenerated) or (not lockGenerated) then
        return LevelMaker.generate(width, height)
    end

    return GameLevel(entities, objects, map)
end