local utils = {}

function utils.lerp(a, b, t)
    return (1-t)*a + t*b
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

function utils.remap(v, min1, max1, min2, max2)
    v = (v-min1) / (max1-min1)
    v = v*(max2-min2) + min2
    return v
end

return utils
