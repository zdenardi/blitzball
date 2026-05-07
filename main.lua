function did_ball_collide(ball, box_x, box_y, box_w, box_h)
    if ball.y + ball.r < box_y then return false end
    if ball.y - ball.r > box_y + box_h then return false end
    if ball.x + ball.r < box_x then return false end
    if ball.x - ball.r > box_x + box_w then return false end
    return true
end

function bounce_ball_off_bat(ball, batter)
    local bat_pos = batter:get_bat_coordinates()
    local hitbox = bat_pos.hit_box

    local bat_center = (hitbox.x1 + hitbox.x2) / 2
    local bat_width = hitbox.x2 - hitbox.x1

    local hit_pos = ball.x - bat_center
    local normalized = hit_pos / (bat_width / 2)

    -- clamp
    normalized = mid(-1, normalized, 1)

    -- timing influence
    local timing_offset = (batter.a_frame - 2) * 0.3

    local max_angle = 60
    local angle = (normalized + timing_offset) * max_angle * 0.0174533

    local speed = sqrt(ball.dx ^ 2 + ball.dy ^ 2)

    -- sweet spot power
    local sweet_spot = 1 - abs(normalized)
    local power = 1 + sweet_spot * 0.5

    ball.dx = speed * power * sin(angle)
    ball.dy = -speed * power * cos(angle)
end

-- sx - sprite coordinate to be used
-- sy - sprite y coordinate to be used
-- x - sprite x position to be drawn
-- y - sprite y position to be drawn
-- a - sprite rotation angle in degrees
-- w - half width in pixels
-- h - half heigth in pixels
function r_spr(sx, sy, x, y, a, w, h)
    local ca, sa = cos_sin(a)
    local xst = x - (sa * h) - (ca * w)
    local yst = y - (ca * h) + (sa * w)
    w *= 2
    h *= 2
    for ix = 0, w, 0.5 do
        for iy = 0, h, 0.5 do
            local c = sget(ix + sx, iy + sy)
            if (c > 0) pset(xst + (sa * iy) + (ca * ix), yst - (sa * ix) + (ca * iy), c)
        end
    end
end

function _init()
    cls()
    pitcher = {
        min_x = (7 * 8) - 9,
        max_x = (7 * 8) - 1,
        x = (7 * 8) - 5,
        y = 5 * 8,
        spr = 102,
        spr_w = 2,
        spr_h = 2,
        state = "idle",
        a_frames = { 96, 98, 100, 102 },
        a_frame = 1,

        get_throw_pos = function(self)
            return { x = self.x + 5, y = self.y + 8 }
        end,
        throw = function(self)
            if self.state == "idle" and ball.state == "idle" then
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
            if btn(5) then
                pitcher:throw()
                ball:throw()
            end
            if btn(0) then
                pitcher:move_pitcher('left')
            end
            if btn(1) then
                pitcher:move_pitcher('right')
            end
            -- Add any necessary update logic here
        end,
        draw = function(self)
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
        end,
        frame_timer = 0 -- Variable to keep track of the number of frames since the last update
    }
    batter = {
        x = 44,
        y = 85,
        spr = 64,
        spr_w = 2,
        spr_h = 2,
        state = "idle",
        a_frames = { 66, 68, 70, 64 },
        a_frame = 1,
        frame_timer = 0,

        -- methods --
        swing = function(self)
            if self.state == "idle" then
                self.state = "swing"
            end
        end,

        move_bat = function(self, dir)
            if dir == "left" and self.x > self.min_x then
                self.x -= 1
            elseif dir == "right" and self.x < self.max_x then
                self.x += 1
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
            if btn(4) then
                batter:swing()
            end
        end,


        draw = function(self)
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
        end
    }
    hand_pos = pitcher:get_throw_pos()
    ball = {
        _start_x = hand_pos.x,
        _start_y = hand_pos.y,
        _start_dx = 0.3,
        _start_dy = 2,
        x = hand_pos.x,
        dx = 0,
        y = hand_pos.y,
        dy = 10,
        height = 0,
        r = 1,
        color = 10,
        state = "idle", -- idle,throw,hit
        strike_zone = {
            x = (7 * 7) + 2,
            y = (11 * 8) + 4
        },

        throw = function(self)
            local hand_pos = pitcher:get_throw_pos()
            self.state = "throw"
            self.x = hand_pos.x
            self.y = hand_pos.y
            self.dx = self._start_dx
            self.dy = self._start_dy
        end,
        reset_ball = function(self)
            local hand_pos = pitcher:get_throw_pos()

            self.state = "idle"
            self.x = hand_pos.x
            self.y = hand_pos.y
            self.dx = 0
            self.dy = 0
        end,
        init = function(self)
            self:reset_ball()
        end,
        update = function(self)
            if self.state ~= "idle" then
                -- hit/thrown
                self.x = self.x + self.dx
                self.y = self.y + self.dy

                if self.x > 127 or self.x < 0 then
                    self:reset_ball()
                end
                if self.y > self.strike_zone.y + 13 then
                    sfx(1)
                    self:reset_ball()
                end
                if self.y < 0 then
                    self:reset_ball()
                end
            end
        end,
        draw = function(self)
            -- debug
            print(self.x, 8, 8, 4)
            print(self.y, 30, 8, 4)
            print(self.dx, 50, 8, 4)
            print(self.state)
            ---
            if self.state ~= "idle" then
                circfill(self.x, self.y, self.r, self.color)
            end
        end
    }

    bat = {
        spr = 130,
        spr_w = 2,
        spr_h = 2,
        a_frames = { 132, 134, 136, 138, 140, 130 },

        draw = function(self)
            local pos = batter:get_bat_coordinates()
            local state = batter.state
            local a_frame = batter.a_frame

            local x = pos.x
            local y = pos.y

            -- sets (10, 10) to yellow

            if state == "idle" then
                spr(self.spr, x, y, self.spr_w, self.spr_h)
            elseif state == "swing" then
                local frame = self.a_frames[a_frame]
                spr(frame, x, y, self.spr_w, self.spr_h)
            end
        end
    }
    game = {
        -- more for later. not implemented
        role = 'p', -- 'b' for batter, 'p' pitcher
        menu = false,
        inning = 0,
        inning_type = "top", -- bot,top, denotes .5 inning
        outs = 0,
        max_inning = 2, --changeable?
        max_strikes = 3, -- changeable?
        max_balls = 5, -- changeable?
        max_outs = 3, --changeable?
        the_count = { 0, 0 }, -- balls,strikes
        bases = { 0, 0, 0 }, -- {1st,2nd,3rd}
        score = { 0, 0 },
        team1 = {
            color = 0 -- changeable?
        },
        team2 = {
            color = 1 --changeable?
        }
    }
end

function _update()
    bat_pos = batter:get_bat_coordinates()
    bat_hit_box = bat_pos.hit_box
    ball:update()
    if game.role == 'p' then
        -- pitcher
        pitcher:update()
    end

    batter:update()

    did_hit = did_ball_collide(
        ball,
        bat_hit_box.x1, bat_hit_box.y1, 10, 5
    )
    if did_hit then
        sfx(3)
        bounce_ball_off_bat(ball, batter)
    end
    -- function did_ball_collide(ball, box_x, box_y, box_w, box_h)
end

function _draw()
    palt(0, false)
    palt(14, true)
    cls()
    map(0, 0, 0, 0, 128, 32)
    spr(128, (7 * 7) + 2, 11 * 8 + 4, 2, 2)

    ball:draw()
    pitcher:draw()
    batter:draw()
    bat:draw()

    --debug--
end