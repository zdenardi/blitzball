function did_ball_collide(ball, box_x, box_y, box_w, box_h)
    if ball.y + ball.r < box_y then return false end
    if ball.y - ball.r > box_y + box_h then return false end
    if ball.x + ball.r < box_x then return false end
    if ball.x - ball.r > box_x + box_w then return false end
    return true
end

function bounce_ball_off_bat(ball, batter)
    ball.state = "hit"
    local bat_pos = batter:get_bat_coordinates()
    local hitbox = bat_pos.hit_box

    local bat_center = (hitbox.x1 + hitbox.x2) / 2
    local bat_width = hitbox.x2 - hitbox.x1

    local hit_pos = ball.x - bat_center
    local normalized = hit_pos / (bat_width / 2)

    normalized = mid(-1, normalized, 1)

    local timing_offset = (batter.a_frame - 2) * 0.3

    local max_angle = 60
    local angle = (normalized + timing_offset)
            * max_angle
            * 0.0174533

    local speed = sqrt(ball.dx ^ 2 + ball.dy ^ 2)

    local sweet_spot = 1 - abs(normalized)
    local power = 1 + sweet_spot * 0.1

    ball.dx = speed * power * sin(angle)
    ball.dy = -speed * power * cos(angle)

    -- pseudo height launch
    local launch = (sweet_spot * 0.5) + 0.3
    ball.dh = launch
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
            -- send hand pos
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
                if self.state == "idle" and ball.state == "idle" then
                    pitcher:throw()
                    ball:throw()
                end
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
        min_x = 40,
        max_x = 46,
        min_y = 83,
        max_y = 88,
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
            if btn(4, 1) then
                batter:swing()
            end
            if btn(0, 1) then
                batter:move_bat("left")
            end
            if btn(1, 1) then
                batter:move_bat("right")
            end
            if btn(2, 1) then
                batter:move_bat("up")
            end
            if btn(3, 1) then
                batter:move_bat("down")
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
        hght = 1,
        dh = 0,
        r = 1,
        color = 10,
        shadow_color = 5,
        wall_hit_time = 0,
        state = "idle", -- idle,throw,hit
        strike_zone = {
            x = (7 * 7) + 2,
            y = (11 * 8) + 4
        },

        throw = function(self)
            local hand_pos = pitcher:get_throw_pos()
            local hght_frame = 1
            self.state = "throw"
            self.x = hand_pos.x
            self.y = hand_pos.y
            self.dx = self._start_dx
            self.dy = self._start_dy
            self.hght = 1
            self.dh = 0.5
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

        get_tile_under_ball = function(self)
            local tile_x = flr(self.x / 8)
            local tile_y = flr(self.y / 8)
            return mget(tile_x, tile_y)
        end,


        update = function(self)
            if self.state ~= "idle" then
                -- hit/thrown
                self.x = self.x + self.dx
                self.y = self.y + self.dy

                -- vertical visualization
                self.hght += self.dh

                -- fake arc
                self.dh -= 0.03
                self.hght += self.dh

                -- ground
                if self.hght < 1 then
                    self.hght = 1
                    self.dh = 0
                end

                -- collisions
                if self.x > 127 or self.x < 0 then
                    self:reset_ball()
                end
                if self.y > self.strike_zone.y + 13 then
                    sfx(1)
                    game.count[2] += 1
                    self:reset_ball()
                end
                --backwall
                -- remember, Pixels, not cell/tiles
                if self.y < 8 and self.state ~= "wall" or (self.hght == 1 and self.y < 12) then
                    -- wall
                    self.state = "wall"
                    self.wall_hit_time = time()
                end
                if self.state == "wall" then
                    -- wait then reset ball
                    if time() - self.wall_hit_time >= 3 then
                        self:reset_ball()
                    end
                end
            end
        end,

        draw = function(self)
            local shad_x = (self.x - 2) * self.hght
            local shad_y = (self.y - 2)
            local tile_x = self.x / 8
            local tile_y = self.y / 8

            ---
            if self.state ~= "idle" then
                local effective_radius = self.r * self.hght / 8

                -- shadow
                circfill(self.x, self.y, effective_radius / 2, 5)
                circfill(
                    self.x,
                    self.y - self.hght * 0.7,
                    effective_radius,
                    self.color
                )
                print(self.state, 8, 12)
                print(abs(self.dx), 30, 12)
                print(abs(self.dy), 50, 12)
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
        ball = {},
        role = 'p', -- 'b' for batter, 'p' pitcher
        menu = false,
        inning = 0,
        inning_type = "top", -- bot,top, denotes .5 inning
        outs = 0,
        max_inning = 2, --changeable?
        max_strikes = 3, -- changeable?
        max_balls = 5, -- changeable?
        max_outs = 3, --changeable?
        count = { 0, 0 }, -- balls,strikes
        bases = { 0, 0, 0 }, -- {1st,2nd,3rd}
        score = { 0, 0 },
        hit_type = "None",
        strikeout_time = false,
        team1 = {
            color = 0 -- changeable?
        },
        team2 = {
            color = 1 --changeable?
        },
        update = function(self)
            -- only check when ball reaches the back wall
            if (self.ball.y < 8 and self.ball.state ~= "wall")
                    or (self.ball.hght == 1 and self.ball.y < 12) then
                local tile = self.ball:get_tile_under_ball()

                if fget(tile, 0) then
                    self.hit_type = "out"
                elseif fget(tile, 1) then
                    self.hit_type = "single"
                elseif fget(tile, 2) then
                    self.hit_type = "dbl"
                end

                -- bounce the ball
                self.ball.dx = -self.ball.dx * 0.1
                self.ball.dy = -self.ball.dy * 0.1

                -- prevent repeated bouncing every frame
                self.ball.state = "wall"
                self.ball.wall_hit_time = time()

                -- keep the ball just inside the playfield
                self.ball.y = 16
            end

            -- reset after 3 seconds
            if self.ball.state == "wall" then
                if time() - self.ball.wall_hit_time >= 3 then
                    self.ball:reset_ball()
                end
            end
            -- strikeout
        end,

        reset_count = function(self)
            self.count = { 0, 0 }
            self.strikeout_time = false
        end,
        score_board = {
            x1 = 2,
            y1 = 10 * 8,
            x2 = 4 * 8,
            y2 = 14 * 8 + 4,

            draw = function(self)
                rectfill(self.x1, self.y1, self.x2, self.y2, 0)
            end
        },

        base_logo = {
            fst = false,
            scd = false,
            thd = false,
            bg_x1 = 12 * 8,
            bg_x2 = 14 * 8,
            bg_y1 = 0,
            bg_y2 = 0,


            draw = function(self)
                --bg
                rectfill(self.x1, self.y1, self.x2, self.y2, 0)
            end
        },
        draw = function(self)
            self.score_board:draw()
            print("sCORE", self.score_board.x1 + 2, self.score_board.y1 + 2, 7)
            print("b:" .. self.count[1])
            print("s:" .. self.count[2])
            -- strikeout
            if self.count[2] == 3 then
                if not self.strikeout_time then
                    self.strikeout_time = time()
                end
                print("out", game.batter.x, game.batter.y - 14, 8)
                if time() - self.strikeout_time >= 3 then
                    self:reset_count()
                end
            end
        end
    }

    game.ball = ball
    game.bat = bat
    game.batter = batter
    game.pitcher = pitcher
    x1 = 1
    x2 = 15
    y = 2
    y2 = 1
    -- randomly populate back wall
    for x = 0, 15 do
        local r_top_spr = rnd { 28, 29, 28 }
        local r_btm_spr = rnd { 26, 27, 26 }
        mset(x, 0, r_top_spr)
        mset(x, 1, r_btm_spr)
    end
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
    game:update()

    did_hit = did_ball_collide(
        ball,
        bat_hit_box.x1, bat_hit_box.y1, 10, 5
    )
    if did_hit
            and batter.state == "swing"
            and batter.a_frame >= 2
            and batter.a_frame <= 3
            and ball.dy > 0 then
        sfx(3)
        bounce_ball_off_bat(ball, batter)
    end
end

function _draw()
    palt(0, false)
    palt(14, true)
    cls()
    map(0, 0, 0, 0, 128, 32)

    spr(128, (7 * 7) + 2, 11 * 8 + 4, 2, 2)

    game.ball = ball

    ball:draw()
    pitcher:draw()
    batter:draw()
    bat:draw()
    tile = fget(ball:get_tile_under_ball())
    print(tile, 0, 16)
    game:draw()
    print(ball.hght, 0, 24)
    print(game.hit_type)

    --debug--
end