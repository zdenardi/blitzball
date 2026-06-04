-- ball gets pos from pitcher object
hand_pos = pitcher:get_throw_pos()

ball = {
    _states = {
        'idle',
        'thrown',
        'hit',
        'wall'
    },
    _transitions = {
        idle = { "thrown" },
        thrown = { 'idle', 'hit' },
        hit = { 'idle', 'wall' },
        wall = { 'idle' }
    },
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
    cpu_throw = function(self, dx, dy)
        local hand_pos = pitcher:get_throw_pos()
        local hght_frame = 1
        self.state = "throw"
        self.x = hand_pos.x
        self.y = hand_pos.y
        self.dx = dx
        self.dy = dy
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

    -- ball update
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
        end
    end
}