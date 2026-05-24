pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include globals.lua
#include test.lua
#include lib.lua
#include start_menu.lua
#include batter.lua
 -- must be before ball
#include pitcher.lua
#include ball.lua
#include main.lua
#include game.lua

--tests
#include tests/lib_tests.lua

frames = 0

-- TESTS

test(
    'Game class Tests', function(desc, it)
        desc(
            'walk_batter', function()
                it(
                    'should walk a batter, and game.runners should be {1,2}', function()
                        local g = game
                        g.runners = {1}
                        rnrs = g:walk_runner()
                        printh(unpack(rnrs))
                        return #g.runners == 2
                    end
                )
                it(
                    'should walk a batter and state should go to idle.', function()
                        local g = game
                        g.ball = ball
                        g.batter = batter
                        rnrs = g:walk_runner()
                        update = g:update()
                        return g.state == 'idle'
                    end
                )
                
                it(
                    'should walk a batter with bases loaded, and a run should score', function()
                        local g = game
                        g.ball = ball
                        g.batter = batter
                        -- full bases
                        game.runners = {3,2,1}
                        -- walk runners
                        rnrs = game:walk_runner()
                        return game.score[1] == 1
                    end
                )
            end
        )
        desc(
            'adv_runner', function()
                it(
                    'should advance a batter, and game.runners should be {1,2}', function()
                        local g = game

                        exp_num = 1
                        g.runners = {}
                        g:adv_runners(2)
                        return #g.runners == exp_num
                    end
                )
            end
        )
        desc(
            'Game State Machine', function()
                it('should verify transitions for idle state',function()
                    local g = game
                    g.state = "idle"
                    return g:verify_transition('pitch') and 
                    g:verify_transition('menu') and not 
                    g:verify_transition('hit')
                end)
                it('should verify transitions for pitch state',function()
                    local g = game
                    g.state = 'pitch'
                    return g:verify_transition('hit') and 
                    g:verify_transition('miss') and
                    g:verify_transition('strike') and
                    g:verify_transition('ball') 
                end)
                it('should verify transitions for hit state',function()
                    local g = game
                    g.state = 'hit'
                    return
                    g:verify_transition('foul') and
                    g:verify_transition('out') and
                    g:verify_transition('base') 
                end)
                it('should verify transitions for menu state',function()
                    local g = game
                    g.state = 'menu'
                    return
                    g:verify_transition('idle')
                end)
                it('should verify transitions for menu state',function()
                    local g = game
                    g.state = 'strike'
                    return
                    g:verify_transition('out') and
                    g:verify_transition('idle')
                end)
                it('should verify transitions for base state',function()
                    local g = game
                    g.state = 'base'
                    return
                    g:verify_transition('idle')
                end)
                it('should verify transitions for out state',function()
                    local g = game
                    g.state = 'out'
                    return
                    g:verify_transition('idle')
                end)
                it('should verify transitions for foul state',function()
                    local g = game
                    g.state = 'out'
                    return
                    g:verify_transition('idle')
                end)
                it('should not allow bad state transitions',function()
                    local g = game
                    g.state = 'out'
                    return
                    g:verify_transition('out') == false
                end)
                it('should change state from idle to pitch',function()
                    local g = game
                    g.state = 'out'
                    return
                    g:verify_transition('out') == false
                end)
                it(
                    'State should change from ball to run', function()
                        local g = game
                        g.ball = ball
                        g.batter = batter
                        g.count[2] = 0
                        
                        g.state = "miss"
                        update = g:update()
                        return g.state == "idle" and g.count[2] == 1
                    end
                )
            end
        )
        
    end
)
      extcmd("quit")





function _draw(
)
cls()
    print("running tests!")

end

function _init()
end

function _update()
    
  frames += 1

  if frames > 60 then
    extcmd( 'shutdown' )
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
