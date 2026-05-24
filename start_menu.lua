start_menu = {
    state = "p1", -- p1/p2

    change_player = function(self)
        if self.state == "p1" then
            self.state = "p2"
        else
            self.state = "p1"
        end
    end,
    change_player_color = function(self, dir)
        local p1_i = get_index(uni_colors, game.team1.color)
        local p2_i = get_index(uni_colors, game.team2.color)

        if dir == 'r' then
            if self.state == "p1" then
                p1_i = p1_i % #uni_colors + 1
                game.team1.color = uni_colors[p1_i]
            else
                p2_i = p2_i % #uni_colors + 1
                game.team2.color = uni_colors[p2_i]
            end
        end
        if dir == 'l' then
            if self.state == "p1" then
                p1_i = (p1_i + #uni_colors) % #uni_colors + 1
                game.team1.color = uni_colors[p1_i]
            else
                p2_i = (p2_i + #uni_colors) % #uni_colors + 1
                game.team2.color = uni_colors[p2_i]
            end
        end
    end,


    update = function(self)
        self.t_col_sel.state = self.state
        if btnp(0) then
            --left
            self:change_player_color('l')
        end
        if btnp(1) then
            self:change_player_color('r')
        end
        if btnp(2) then
            -- up
            self:change_player()
        end
        if btnp(3) then
            self:change_player()
        end

        if btnp(5) then
            -- x
            scene = 'game'
        end
    end,

    t_col_sel = {
        p1 = {
            bg_x = 28,
            bg_y = 15,
            l_x = 18,
            r_x = 106,
            y = 16
        },
        p2 = {
            bg_x = 28,
            bg_y = 29,
            l_x = 18,
            r_x = 106,
            y = 30
        },
        draw = function(self)
            local text = {
                teamColor1 = "team color 1 : ",
                teamColor2 = "team color 2 : "
            }
            p = self.p1
            if (self.state == 'p2') then
                p = self.p2
            end

            print('⬅️', p.l_x, p.y)
            rrectfill(p.bg_x, p.bg_y, 75, 7, 2, 7)
            print('➡️', p.r_x, p.y)

            print(text.teamColor1, 32, 16, 0)
            print('█', 90, 16, game.team1.color)
            print(text.teamColor2, 32, 30, 0)
            print('█', 90, 30, game.team2.color)
        end
    },

    draw = function(self)
        cls()
        map(0, 0, 0, 0, 128, 32)

        self.t_col_sel:draw()

        print("press ❎ to play", 32, 64, 7)
    end
}