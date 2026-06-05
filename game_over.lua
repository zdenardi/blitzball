game_over = {
    -- vars

    update = function(self)
        if btnp(5) then
            -- x
            game:reset()
            chg_scene('game')
        end
    end,

    draw = function(self)
        cls()
        map(0, 0, 0, 0, 128, 32)

        print("press ❎ to try again", 32, 64, 7)
        print(game.state)
        print(scene)
    end
}