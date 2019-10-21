function lerp(a, b, t)
    return (1-t)*a + t*b
end

function clamp(v, min, max)
    if v < min then
        return min
    elseif v > max then
        return max
    else
        return v
    end
end

-- TODO: write easing functions in here
-- to sample with the timer variable.
