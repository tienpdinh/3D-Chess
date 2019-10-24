local utils = {}

function utils.lerp(a, b, t)
    return (1-t)*a + t*b
end

function utils.lerpAngle(a, b, t)
    while a > b + math.pi do
        b = b + 2*math.pi
    end

    while b > a + math.pi do
        b = b - 2*math.pi
    end

    return utils.lerp(a, b, t)
end

function utils.crossProduct(a, b)
    local x = a[2]*b[3] - a[3]*b[2]
    local y = a[1]*b[3] - a[3]*b[1]
    local z = a[1]*b[2] - a[2]*b[1]
    return {x,y,z}
end

function utils.clamp(v, min, max)
    if v < min then
        return min
    elseif v > max then
        return max
    else
        return v
    end
end

function utils.saturate(v)
    return utils.clamp(v, 0, 1)
end

function utils.remap(v, min1, max1, min2, max2)
    v = (v-min1) / (max1-min1)
    v = v*(max2-min2) + min2
    return v
end

-- Returns a triangle wave (linearly 0 to 1 to 0 over t=0 to 1)
function utils.triangle(t)
    return 1 - math.abs(1-2*t)
end

function utils.delay(t, d)
    return utils.saturate((t-d) / (1-2*d))
end

function utils.atan2(y, x)
    if x > 0 then
        return math.atan(y/x)
    elseif x < 0 and y >= 0 then
        return math.atan(y/x) + math.pi
    elseif x < 0 and y < 0 then
        return math.atan(y/x) - math.pi
    elseif x == 0 and y > 0 then
        return math.pi/2.0
    elseif x == 0 and y < 0 then
        return -math.pi/2.0
    else  -- x == 0 and y == 0
        print ("ERROR in utils.atan2. Undefined.")
        return nil
    end
end

function utils.contains(table, element)
    for _, elem in pairs(table) do
        if elem[1] == element[1] and elem[2] == element[2] then
            return true
        end
    end
    return false
end

return utils
