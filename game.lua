-- handle wall collision not working correctly
game = {
    _states = {
        'pitch',
        'hit',
        'miss',
        'ball',
        'strike',
        'foul',
        'out',
        'walk',
        'switch',
        'gameover'
    },
    _transitions = {
        idle = { "pitch", "menu", "gameover" },
        pitch = { "hit", "miss", "strike", "ball" },
        hit = { "foul", "out", "base" },
        menu = { "idle" },
        strike = { "out", "idle" },
        base = { "idle" },
        out = { "idle" },
        foul = { "idle" }
    },
    ball = {}, -- ball object
    back_wall = {
        x1 = 0,
        x2 = 15,
        y1 = 0,
        y2 = 1
    },
    runners = {},
    _runners = {
        bases = { 0, 0, 0 }, --1/2/3
        check = function(self, num)
            if (num > 3) assert(true == false, "check_base only takes 0-3")
            return self[num]
        end,
        adv = function(self, num)
        end
    },
    count = {
        0, 0,
        addStrike = function(self)
            self[1] += 1
        end,
        addBall = function(self)
            self[2] += 1
        end,
        reset = function(self)
            self[1] = 0
            self[2] = 0
        end,
        get = function(self, t)
            -- strike/ball
            if t == "ball" then
                return self[1]
            end
            if t == "strike" then
                return self[2]
            end
        end,
        add = function(self, t)
            -- strike/ball
            if t == "ball" then
                self[1] += 1
            end
            if t == "strike" then
                self[2] += 1
            end
        end
    }, -- balls,strikes
    hit_type = "None",
    inning = 0,
    inning_type = "top", -- bot,top, denotes .5 inning
    max_balls = 5, -- changeable?
    max_inning = 2, --changeable?
    max_outs = 3, --changeable?
    max_strikes = 3, -- changeable?
    outs = 0,
    role = 'p', -- 'b' for batter, 'p' pitcher
    score = { 0, 0 },
    stop_play_timer = false,
    strike_zone = {
        x = 51,
        y = 92,
        spr_num = 128,

        coords = function(self)
            return {
                x1 = self.x + 3,
                x2 = self.x + 14,
                y1 = self.y + 13,
                y2 = self.y + 14
            }
        end,

        draw = function(self)
            spr(self.spr_num, self.x, self.y, 2, 2)
        end
    },
    bases = {
        {
            id = 1,
            color = 7,
            x1 = 14 * TILE_SIZE,
            y1 = 12 * TILE_SIZE,
            x2 = 14 * TILE_SIZE + 4,
            y2 = 12 * TILE_SIZE + 4
        },
        {
            id = 2,
            color = 7,
            x1 = 13 * TILE_SIZE,
            y1 = 12 * 7 + 4,
            x2 = 13 * TILE_SIZE + 4,
            y2 = 12 * 7 + TILE_SIZE
        },
        {
            id = 3,
            color = 7,
            x1 = 12 * TILE_SIZE,
            y1 = 12 * TILE_SIZE,
            x2 = 12 * TILE_SIZE + 4,
            y2 = 12 * TILE_SIZE + 4
        }
    },
    right_menu = {
        x = 94,
        y = 85,
        w = 24,
        h = 25,
        col = 0, -- black

        draw = function(self)
            rrectfill(self.x, self.y, self.w, self.h, 3, 0)
        end
    },
    team1 = {
        color = uni_colors[2] -- changeable?
    },
    team2 = {
        color = uni_colors[1] --changeable?
    },
    scr_max_x = 127,
    scr_min_x = 0,
    scr_max_y = 127,
    state = "idle", -- pitch/hit/miss/switch/idle/out/menu

    score_board = {
        x1 = 2,
        y1 = 9 * TILE_SIZE + 4,
        w = 4 * TILE_SIZE,
        h = 32,

        draw = function(self)
            rrectfill(self.x1, self.y1, self.w, self.h, 3, 0)
        end
    },

    reset_count = function(self)
        self.count:reset()
        self.stop_play_timer = false
    end,

    get_state = function(self)
        return self.state
    end,

    throw_ball = function(self)
        if self.pitcher.state == "idle" and ball.state == "idle" then
            self.state = "pitch"
            self.pitcher:throw()
            self.ball:throw()
        end
    end,

    cpu_throw = function(self)
        coords = self.strike_zone:coords()

        random_spd = 1 + rnd(2.4)
        random_target = (rnd(coords.x2 - coords.x1) + coords.x1)
        frames = (coords.y2 - ball._start_y) / random_spd

        local dx = (random_target - ball._start_x) * random_spd / (coords.y2 - ball._start_y) + rnd(1.5) - .7

        if not self.throw_timer then
            self.throw_timer = time()
        end

        if time() - self.throw_timer >= WAIT_T then
            if self.pitcher.state == "idle" and self.ball.state == "idle" then
                self.batter:reset() -- reset random swings
                self.state = "pitch"
                self.pitcher:throw()
                self.ball:cpu_throw(dx, random_spd)

                -- reset timer so the next throw happens 5 seconds later
                self.throw_timer = time()
            end
        end
    end,

    walk_runner = function(self)
        runners = { 0, 0, 0 }
        local i = 1
        while i <= #self.runners do
            --     -- adv current runner
            self.runners[i] += 1
            if i < #self.runners and self.runners[i + 1] == self.runners[i] then
                self.runners[i + 1] += 1
            end
            i += 1
        end
        -- add walked batter
        self.runners[#self.runners + 1] = 1
        for i, r in ipairs(self.runners) do
            if r > 3 then
                self.score[1] += 1
                deli(self.runners, i)
            end
        end

        return self.runners
    end,

    verify_transition = function(self, s)
        return value_exists(self._transitions[self.state], s)
    end,

    change_state = function(self, s)
        if self:verify_transition(s) then
            self.state = s
        else
            printh("Invalid State Transition w:" .. self.state .. '=>' .. s)
        end
    end,

    did_ball_hit_zone = function(self, s)
        local strike_zone_coords = self.strike_zone:coords()
        if (self.ball.y > strike_zone_coords.y1)
                and (self.ball.y < strike_zone_coords.y2)
                and (self.ball.x > strike_zone_coords.x1)
                and (self.ball.x < strike_zone_coords.x2)
                and (self.ball.hght > 1) then
            sfx(4)
            return true
        else
            return false
        end
    end,

    did_ball_leave_scrn = function(self)
        if self.ball.x > self.scr_max_x or self.ball.x < self.scr_min_x or self.ball.y > self.scr_max_y then
            return true
        end
        return false
    end,

    adv_runners = function(self, num_of_bases)
        local runners_to_update = {}
        local runners_to_remove = {}
        for rnr in all(self.runners) do
            local t = rnr + num_of_bases
            if t > 3 then
                self.score[1] += 1
                runners_to_remove[rnr] = true
            else
                runners_to_update[rnr] = t
            end
        end
        for rnr, new_val in ipairs(runners_to_update) do
            self.runners[rnr] = new_val
        end
        for rnr in pairs(runners_to_remove) do
            self.runners[rnr] = nil
        end

        if num_of_bases > 3 then
            self.score[1] += 1
        else
            add(self.runners, num_of_bases)
        end
    end,

    reset_pitch = function(self)
        self.ball:reset_ball()
        self.batter:reset()
        self.state = "idle"
    end,

    is_pitching = function(self) return self.state == 'pitch' end,
    is_out = function(self) return self.state == "out" end,
    is_strike_out = function(self) return self.count:get('strike') == self.max_strikes end,
    is_walk = function(self) return self.count:get('ball') == self.max_balls end,
    is_hit = function(self) return self.state == "hit" end,
    is_wall = function(self) return self.state == "wall" end,
    is_missed = function(self) return self.state == "miss" end,
    is_ball = function(self) return self.state == "ball" end,
    is_strike = function(self) return self.state == "strike" end,
    is_walked = function(self) return self.state == "walk" end,

    -- transitions
    to_ball = function(self) self:change_state('ball') end,
    to_hit = function(self) self:change_state('hit') end,
    to_idle = function(self) self:change_state('idle') end,
    to_out = function(self) self:change_state('out') end,
    to_pitch = function(self) self:change_state('pitch') end,
    to_strike = function(self) self:change_state('strike') end,
    to_miss = function(self) self:change_state('miss') end,
    to_foul = function(self) self:change_state('foul') end,
    to_base = function(self) self:change_state('base') end,


    did_ball_hit_wall = function(self)
        if self.ball.y < 8 and self.ball.state ~= "wall" or (self.ball.hght == 1 and self.ball.y < 12) then
            -- wall
            self.ball.state = "wall"
            self.ball.wall_hit_time = time()
        end
    end,

    handle_backwall_collision = function(self)
        if (self.ball.y < 8 and self.ball.state ~= "wall")
                or (self.ball.hght == 1 and self.ball.y < 12) then
            local tile = self.ball:get_tile_under_ball()

            if fget(tile, 0) then
                self.state = "out"
            elseif fget(tile, 1) then
                self.hit_type = "single"
                self:adv_runners(1)
                self:reset_count()
            elseif fget(tile, 2) then
                self.hit_type = "dbl"
                self:adv_runners(2)
                self:reset_count()
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
    end,

    -- game init
    init = function(self)
        -- randomly populate back wall
        for x = self.back_wall.x1, self.back_wall.x2 do
            local r_top_spr = rnd { 28, 29, 28 }
            local r_btm_spr = rnd { 26, 27 }
            mset(x, self.back_wall.y1, r_top_spr)
            mset(x, self.back_wall.y2, r_btm_spr)
        end
    end,

    -- game update
    update = function(self)
        self.ball:update()
        self.batter:update()

        if self:is_pitching() then
            bat_pos = self.batter:get_bat_coordinates()
            bat_hit_box = bat_pos.hit_box

            -- ball hits strike zone
            if (self.ball.y > self.strike_zone:coords().y1) then
                if self:did_ball_hit_zone() then
                    self:to_strike()
                else
                    if self.ball.state ~= "hit" and batter.did_swing ~= true then
                        self:to_ball()
                    elseif self.ball.state ~= "hit" and batter.did_swing then
                        -- batter misses ball
                        self:to_strike()
                    end
                end
            end

            -- batter hits ball
            did_batter_hit = did_ball_collide(
                ball,
                bat_hit_box.x1, bat_hit_box.y1, 10, 5
            )

            if did_batter_hit
                    and self.batter.state == "swing"
                    and self.batter.a_frame >= 2
                    and self.batter.a_frame <= 3
                    and self.ball.dy > 0 then
                sfx(3)
                bounce_ball_off_bat(self.ball, self.batter)
                self:to_hit()
            end
        end

        if self:is_hit() then
            -- if ball goes out of play
            if self:did_ball_leave_scrn() then
                -- foul ball
                if self.ball.state == "hit" and self.count:get('strike') < 2 then
                    self.count:add('strike')
                end
                self:reset_pitch()
            end
        end

        if self:is_missed() then
            self.count:add('strike')
            self:reset_pitch()
        end

        if self:is_ball() then
            self.count:add('ball')
            if self:is_walk() then
                self:walk_runner()
                self.state = "walk"
            else
                self:reset_pitch()
            end
        end

        if self:is_strike() then
            sfx(1)
            self.count:add('strike')

            if self:is_strike_out() then
                self:to_out()
            else
                self:reset_pitch()
            end
        end

        if self.state == "switch" then
        end

        if self:is_walked() then
            if not self.stop_time then
                self.stop_time = time()
            end
            if time() - self.stop_time >= WAIT_T then
                self:reset_count()
                self:reset_pitch()
            end
        end

        if self:is_out() then
            if not self.stop_play_timer then
                self.stop_play_timer = time()
                self.outs += 1
            end
            if time() - self.stop_play_timer >= WAIT_T then
                self:reset_count()
                self:reset_pitch()
            end
        end

        -- chk backwall col
        self:handle_backwall_collision()
        -- reset ball after 3 seconds hitting wall
        self:did_ball_hit_wall()

        if not self:is_out() then
            -- b_type = cpu_pitcher:det_pitch()
            r_x = rnd(2) - 1
            r_y = rnd(4)

            self:cpu_throw()
            -- pitcher controls, should this be in game, or in obj?
            -- if btn(5) then
            --     self:throw_ball()
            -- end
            -- if btn(0) then
            --     self.pitcher:move_pitcher('left')
            -- end
            -- if btn(1) then
            --     self.pitcher:move_pitcher('right')
            -- end

            -- batter controls, should this be in game, or in obj?

            if btn(4, 1) then
                self.batter:swing()
            end
            if btn(0, 1) then
                self.batter:move_bat("left")
            end
            if btn(1, 1) then
                self.batter:move_bat("right")
            end
            if btn(2, 1) then
                self.batter:move_bat("up")
            end
            if btn(3, 1) then
                self.batter:move_bat("down")
            end
        end
    end,

    -- game draw
    draw = function(self)
        --debug
        self.score_board:draw()
        self.strike_zone:draw()
        self.right_menu:draw()
        -- bases graphic

        for b = 1, #self.bases do
            clr = self.bases[b].color
            if value_exists(self.runners, self.bases[b].id) then
                clr = 10
            end
            rectfill(self.bases[b].x1, self.bases[b].y1, self.bases[b].x2, self.bases[b].y2, clr)
        end

        print("sCORE:" .. self.score[1], self.score_board.x1 + 2, self.score_board.y1 + 2, 7)

        -- strikeout
        if self.state == "out" then
            print("out", game.batter.x, game.batter.y - 14, 8)
        end
        -- walk
        if self.state == "walk" then
            print("walk", game.batter.x, game.batter.y - 14, 10)
        end

        for i = 1, self.count:get('ball') do
            -- ball count
            circfill((self.score_board.x1 + 4) * i, self.score_board.y1 + 10, 2, 10)
        end
        for i = 1, self.count:get('strike') do
            -- strike count
            circfill((self.score_board.x1 + 4) * i, self.score_board.y1 + 16, 2, 8)
        end
        for i = 1, self.outs do
            print("X", (self.score_board.x1 + 4) * i, self.score_board.y1 + 20, 8)
        end
    end
}