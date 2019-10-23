local easing = {}

-- NOTE:
-- Lua port of: https://github.com/nicolausYes/easing-functions/blob/master/src/easing.cpp

-- SINUSOIDAL

function easing.easeInSine(t)
	return math.sin(math.pi/2.0 * t)
end

function easing.easeOutSine(t)
	return 1 + easing.easeInSine(t-1)
end

function easing.easeInOutSine(t)
    return 0.5 * (1 + math.sin(math.pi * (t-0.5)))
end

-- CUBIC

function easing.easeInCubic(t)
    return t * t * t;
end

function easing.easeOutCubic(t)
    local t2 = t - 1
    return 1 + t2 * t2 * t2
end

function easing.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        local t2 = t - 1
        return 1 + 4 * t2 * t2 * t2
    end
end

-- EXPONENTIAL

function easing.easeInExpo(t)
    return (2^(8 * t) - 1) / 255.0
end

function easing.easeOutExpo(t)
    return 1 - 2^(-8 * t)
end

function easing.easeInOutExpo(t)
    if t < 0.5 then
        return (2^(16 * t) - 1) / 510.0
    else
        return 1 - 0.5 * 2^(-16 * (t - 0.5))
    end
end

-- CIRCULAR

function easing.easeInCirc(t)
    return 1 - math.sqrt(1 - t)
end

function easing.easeOutCirc(t)
    return math.sqrt(t)
end

function easing.easeInOutCirc(t)
    if t < 0.5 then
        return (1 - math.sqrt(1 - 2 * t)) * 0.5
    else
        return (1 + math.sqrt(2 * t - 1)) * 0.5
    end
end

-- BACK

function easing.easeInBack(t)
    return t * t * (2.70158 * t - 1.70158)
end

function easing.easeOutBack(t)
    local t2 = t - 1
    return 1 + t2 * t2 * (2.70158 * t2 + 1.70158)
end

function easing.easeInOutBack(t)
    if t < 0.5 then
        return t * t * (7 * t - 2.5) * 2
    else
        local t2 = t - 1
        return 1 + t2 * t2 * 2 * (7 * t2 + 2.5)
    end
end

-- ELASTIC

function easing.easeInElastic(t)
    local t2 = t * t
    return t2 * t2 * math.sin(t * math.pi * 4.5)
end

function easing.easeOutElastic(t)
    local t2 = (t - 1) * (t - 1)
    return 1 - t2 * t2 * math.cos(t * math.pi * 4.5)
end

function easing.easeInOutElastic(t)
    local t2 = -1
    if t < 0.45 then
        t2 = t * t;
        return 8 * t2 * t2 * math.sin(t * math.pi * 9)
    elseif t < 0.55 then
        return 0.5 + 0.75 * math.sin(t * math.pi * 4)
    else
        t2 = (t - 1) * (t - 1)
        return 1 - 8 * t2 * t2 * math.sin(t * math.pi * 9)
    end
end

-- BOUNCE

function easing.easeInBounce(t)
    return 2^(6 * (t - 1)) * math.abs(math.sin(t * math.pi * 3.5))
end

function easing.easeOutBounce(t)
    return 1 - 2^(-6 * t) * math.abs(math.cos(t * math.pi * 3.5))
end

function easing.easeInOutBounce(t)
    if t < 0.5 then
        return 8 * 2^(8 * (t - 1)) * math.abs(math.sin(t * math.pi * 7))
    else
        return 1 - 8 * 2^(-8 * t) * math.abs(math.sin(t * math.pi * 7))
    end
end

return easing
