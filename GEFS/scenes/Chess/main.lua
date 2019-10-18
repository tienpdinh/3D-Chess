-- ///////// --
-- VARIABLES --
-- ///////// --

-- Setup the camera.
require "scenes/Chess/cameraSetup"
CameraTheta = math.pi/2.0

cameraT = 0  -- 0 = dark turn, 1 = light turn
cameraTSpeed = 1

-- keyPressed Flags
spacePressed = false

-- Manage turns.
turn = "Light"

-- General.
frameDt = 0

-- Setup the chess game
require "scenes/Chess/GameComponents/chess"



-- /////// --
-- METHODS --
-- /////// --

-- Runs every frame.
function frameUpdate(dt)

    hitID, dist = getMouseClickWithLayer(colliderLayer)
    if hitID then
        print(hitID)
    end

    frameDt = dt

    if (turn == "Light") then
        cameraT = cameraT + dt*cameraTSpeed
        cameraT = math.min(1, cameraT)
    else
        cameraT = cameraT - dt*cameraTSpeed
        cameraT = math.max(0, cameraT)
    end

    setCameraPos()
end

-- Called when a key event occurs.
function keyHandler(keys)
    if keys.space then
        if not spacePressed then
            spacePressed = true
            if turn == "Light" then
                turn = "Dark"
            else
                turn = "Light"
            end
        end
    else
        spacePressed = false
    end
end

-- Called when the mouse moves.
function mouseHandler(mouse)
    -- Do nothing initially.
end

function setCameraPos()
    local distanceFromCenter = 6
    CameraPosX = 4.5 + math.sin(cameraT*math.pi)*distanceFromCenter  -- 4.5 is board center x.
    CameraPosY = 6
    CameraPosZ = 4.5 + math.cos(cameraT*math.pi)*distanceFromCenter  -- 4.5 is board center z.


    local angle = -50
    CameraDirX = math.cos(angle*math.pi/180.0) * math.sin(-(1-cameraT)*math.pi)
    CameraDirY = math.sin(angle*math.pi/180.0)
    CameraDirZ = math.cos(angle*math.pi/180.0) * math.cos(-(1-cameraT)*math.pi)
end

function lerp(a, b, t)
    return (1-t)*a + t*b
end
