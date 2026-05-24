-- todo
-- team  switching
-- Three outs
-- figure out homeruns

function _init()
    win = {}
    cls()

    scene = "game"

    -- menu/game

    cpu_pitcher = {
        confidence = 0,
        next_throw = "s",
        det_pitch = function(self)
            if game.count[2] / game.max_strikes > game.count[1] / game.max_balls then
                self.next_throw = "s"
            else
                self.next_throw = "b"
            end
        end
    }

    game.ball = ball
    game.bat = bat
    game.batter = batter
    game.pitcher = pitcher
    game:init()
end

function _update()
    if scene == 'start_menu' then
        start_menu:update()
    end

    if scene == 'game' then
        game:update()
        cpu_pitcher.balls = game.count[1]
        cpu_pitcher.strikes = game.count[2]
        cpu_pitcher:det_pitch()
        if game.role == 'p' then
            -- pitcher
            pitcher:update()
        end
    end
end

function game_draw()
    cls()
    map(0, 0, 0, 0, 128, 32)

    game.ball = ball

    ball:draw()
    pitcher:draw()
    batter:draw()

    game:draw()
    palt(0, false)
    palt(14, true)
end

function _draw()
    if (scene == 'start_menu') then
        start_menu:draw()
    end
    if (scene == 'game') then
        game_draw()
    end

    function draw_window(x, y, w, h, tc, bgc)
        rrectfill(2.75 * TILE_SIZE, 1.75 * TILE_SIZE, 10.5 * TILE_SIZE, 2.5 * TILE_SIZE, 2, 0)
        rrectfill(3 * TILE_SIZE, 2 * TILE_SIZE, 10 * TILE_SIZE, 2 * TILE_SIZE, 2, 2)
        print('homerun', 5.5 * TILE_SIZE + 4, 2.65 * TILE_SIZE, 7)
    end
    draw_window(3, 2, 10, 2)
    --debug--
end