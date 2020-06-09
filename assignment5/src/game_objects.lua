--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

--math.randomseed(os.time())

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'pots',
        width = 16,
        height = 16,
        solid = true,
        dx = 5,
        dy = 5,
        
        onInteraction = function(player, pot)
            player:changeState('lift', pot)
        end
    },
    ['heart'] = {
        type = 'heart',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        
        onConsume = function(heart, player)
            -- we don't want to increase health more than the max of 6
            addHealth = math.min(6 - player.health, 2)
            player:damage(-addHealth)
        end
    }
}