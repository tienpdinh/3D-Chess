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

function remap(v, min1, max1, min2, max2)
    v = (v-min1) / (max1-min1)
    v = v*(max2-min2) + min2
    return v
end

function easeInCubic(t)
    return t*t*t
end

function easeOutCubic(t)
    t = t-1
    return (t*t*t) + 1
end

function easeInOutCubic(t)
    if t < 0.5 then
        return 4*t*t*t
    else
        return (t-1)*(2*t-2)*(2*t-2)+1
    end
end

-- TODO: write easing functions in here
-- to sample with the timer variable.
