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

function value_exists(array, value)
    for i = 1, #array do
        if array[i] == value then
            return true
        end
    end
    return false
end

function get_index(tbl, value)
    for i = 1, #tbl do
        if tbl[i] == value then
            return i -- Return the index if found
        end
    end
    return nil
    -- Return nil if not found
end

function create_win(x, y, w, h, txt)
end