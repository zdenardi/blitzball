pitcher = {
    min_x = (7 * TILE_SIZE) - 9,
    max_x = (7 * TILE_SIZE) - 1,
    x = (7 * TILE_SIZE) - 5,
    y = 5 * TILE_SIZE,
    spr = 102,
    spr_w = 2,
    spr_h = 2,
    state = "idle",
    a_frames = { 96, 98, 100, 102 },
    a_frame = 1,
    frame_timer = 0,

    get_throw_pos = function(self)
        -- send hand pos
        return { x = self.x + 5, y = self.y + TILE_SIZE }
    end,


    throw = function(self)
        if self.state == "idle" then
            -- is this check needed?
            self.state = "throw"
            sfx(2)
        end
    end,

    move_pitcher = function(self, dir)
        if dir == "left" and self.x > self.min_x then
            self.x -= 1
        elseif dir == "right" and self.x < self.max_x then
            self.x += 1
        end
    end,
    update = function(self)
        -- Add any necessary update logic here
    end,


    draw = function(self)
        pal(8, game.team2.color)
        if self.state == "idle" then
            spr(self.spr, self.x, self.y, self.spr_w, self.spr_h)
        elseif self.state == "throw" then
            local frame = self.a_frames[self.a_frame]
            spr(frame, self.x, self.y, self.spr_w, self.spr_h)
            -- Update the animation frame after a certain number of frames have passed
            if self.frame_timer < 1 then
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
        pal(8, 8)
    end -- pitcher draw
}