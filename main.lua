function did_ball_collide(ball, box_x, box_y, box_w, box_h)
    if ball.y - ball.r > box_y + box_h then
        return false
    end
    if ball.y - ball.r < box_y then
        return false
    end
    if ball.x - ball.r > box_x + box_w then
        return false
    end
    if ball.x - ball.r < box_x then
        return false
    end
    return true
end

function bounce_ball_off_paddle(ball, paddle)
    local paddle_center = paddle.x + paddle.w / 2
    local hit_pos = ball.x - paddle_center
    local normalized = hit_pos / (paddle.w / 2)

    local max_angle = 60
    local angle = normalized * max_angle * 0.01743533

    local speed = sqrt(ball.dx ^ 2 + ball.dy ^ 2)

    ball.dx = speed * sin(angle)
    ball.dy = -speed * cos(angle)
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

    ball = {
        _start_x = 54,
        _start_y = 54,
        _start_dx = 0.3,
        _start_dy = 2,
        x = 53,
        dx = 0,
        y = 54,
        dy = 10,
        height = 0,
        r = 1,
        color = 10,
        state = "idle", -- idle,throw,hit
        strike_zone = {
            x = (7 * 7) + 2,
            y = (11 * 8) + 2
        },

        throw = function(self)
            self.state = "throw"
            self.dx = self._start_dx
            self.dy = self._start_dy
        end,
        reset_ball = function(self)
            self.state = "idle"
            self.x = self._start_x
            self.y = self._start_y
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
                    self.dx = -self.dx
                    sfx(1)
                end
                if self.y > self.strike_zone.y + 13 then
                    sfx(1)
                    self:reset_ball()
                end
                if self.y < 0 then
                    self.dy = -self.dy
                    sfx(1)
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

    paddle = {
        x = 30,
        y = 120,
        w = 30,
        h = 2,
        color = 7,
        speed = 0,
        max_speed = 4,

        move = function(self, dir)
            while self.speed < self.max_speed do
                self.speed = self.speed + 1
            end

            if dir == "l" and self.x > 1 then
                self.x = self.x - self.speed
            end
            if dir == "r" and self.x < (127 - self.w) then
                self.x = self.x + self.speed
            end

            if self.x < 2 or self.x > (127 - self.w) then
                sfx(1)
            end
        end,
        stop = function(self)
            while self.speed > 0 do
                self.speed = self.speed - 1
            end
        end,
        update = function(self)
        end,
        draw = function(self)
            -- debug
            print(self.x, 120)
            print(self.speed, 100)
            rectfill(self.x, self.y, self.x + self.w, self.y + self.h, self.color)
        end
    }

    pitcher = {
        x = (7 * 8) - 5,
        y = 5 * 8,
        spr = 102,
        spr_w = 2,
        spr_h = 2,
        state = "idle",
        a_frames = { 96, 98, 100, 102 },
        a_frame = 1,
        throw = function(self)
            if self.state == "idle" then
                self.state = "throw"
            end
        end,
        update = function(self)
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

        draw = function(self)
            spr(self.spr, self.x, self.y, self.spr_w, self.spr_h)
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
    ball:update()
    if btn(5) then
        if game.role == 'p' then
            pitcher:throw()
            ball:throw()
        end
    end
end

function _draw()
    palt(0, false)
    palt(14, true)
    cls()
    map(0, 0, 0, 0, 128, 32)
    spr(128, (7 * 7) + 2, 11 * 8 + 2, 2, 2)

    ball:draw()
    pitcher:draw()
    batter:draw()
    -- paddle:draw()
end