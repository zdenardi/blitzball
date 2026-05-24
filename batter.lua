batter = {
    a_frame = 1,
    a_frames = { 66, 68, 70, 64 },
    did_swing = false,
    frame_timer = 0,
    max_x = 43.5,
    max_y = 88,
    min_x = 40,
    min_y = 83,
    spr = 64,
    spr_h = 2,
    spr_w = 2,
    state = "idle",
    x = 43.5,
    y = 85,

    -- methods --
    swing = function(self)
        if self.state == "idle" then
            self.did_swing = true
            self.state = "swing"
        end
    end,
    reset = function(self)
        self.state = "idle"
        self.did_swing = false
    end,

    bat = {
        spr = 130,
        spr_w = 2,
        spr_h = 2,
        a_frames = { 132, 134, 136, 138, 140, 130 },

        draw = function(self, pos, batter_state, a_frame)
            local x = pos.x
            local y = pos.y

            -- sets (10, 10) to yellow

            if batter_state == "idle" then
                spr(self.spr, x, y, self.spr_w, self.spr_h)
            elseif batter_state == "swing" then
                local frame = self.a_frames[a_frame]
                spr(frame, x, y, self.spr_w, self.spr_h)
            end
        end
    },

    move_bat = function(self, dir)
        if dir == "left" and self.x > self.min_x then
            self.x -= 1
        elseif dir == "right" and self.x < self.max_x then
            self.x += 1
        elseif dir == "down" and self.y < self.max_y then
            self.y += 1
        elseif dir == "up" and self.y > self.min_y then
            self.y -= 1
        end
    end,

    get_bat_coordinates = function(self)
        local bat_x = self.state == "idle" and self.x - 6 or self.x + 5
        local bat_y = self.y - 5
        local box_x1 = bat_x + 7
        local box_y1 = bat_y + 10
        local box_x2 = bat_x + 17
        local box_y2 = bat_y + 14

        return {
            x = bat_x,
            y = bat_y,


            hit_box = {
                x1 = box_x1,
                y1 = box_y1,
                x2 = box_x2,
                y2 = box_y2
            }
        }
    end,

    get_player_state = function(self)
        return self.state
    end,

    get_a_frame = function(self)
        return self.a_frame
    end,

    get_frame_timer = function(self)
        return self.frame_timer
    end,

    update = function(self)
    end,

    draw = function(self)
        -- change color
        pal(8, game.team1.color)

        local bat_pos = self:get_bat_coordinates()
        local state = batter.state
        local a_frame = batter.a_frame
        if self.state == "idle" then
            spr(self.spr, self.x, self.y, self.spr_w, self.spr_h)
        elseif self.state == "swing" then
            local frame = self.a_frames[self.a_frame]
            spr(frame, self.x, self.y, self.spr_w, self.spr_h)

            -- Update the animation frame after a certain number of frames have passed
            if self.frame_timer < 2 then
                -- Adjust this value to control the speed
                self.frame_timer = self.frame_timer + 1
            else
                if self.a_frame < #self.a_frames then
                    self.a_frame = self.a_frame + 1
                else
                    self.a_frame = 1
                    self.state = 'idle'
                end
                self.frame_timer = 0 -- Reset the timer
            end
        end
        self.bat:draw(bat_pos, state, a_frame)
        pal(8, 8)
    end -- batter:draw
}