-- ///////// --
-- VARIABLES --
-- ///////// --

-- Setup the camera.
require "scenes/Chess/cameraSetup"
CameraTheta = math.pi/2.0

-- General.
frameDt = 0

-- Setup the chess game
require "scenes/Chess/GameComponents/chess"



-- /////// --
-- METHODS --
-- /////// --

-- Runs every frame.
function frameUpdate(dt)
    frameDt = dt

    CameraDirX = math.cos(CameraTheta);
    CameraDirZ = math.sin(CameraTheta);
end

-- Called when a key event occurs.
function keyHandler(keys)
    local rSpeed = 1
    local tSpeed = 5
    if keys.left then
        CameraTheta = CameraTheta - frameDt*rSpeed
    end
    if keys.right then
        CameraTheta = CameraTheta + frameDt*rSpeed
    end
    if keys.up then
        CameraPosX = CameraPosX + frameDt*tSpeed*CameraDirX
        CameraPosZ = CameraPosZ + frameDt*tSpeed*CameraDirZ
    end
    if keys.down then
        CameraPosX = CameraPosX - frameDt*tSpeed*CameraDirX
        CameraPosZ = CameraPosZ - frameDt*tSpeed*CameraDirZ
    end
    if keys.shift then
        CameraPosY = CameraPosY - frameDt*tSpeed
    end
    if keys.space then
        CameraPosY = CameraPosY + frameDt*tSpeed
    end
    if keys.d then
        local vp = getValidPositions(lightPawns[1], {1,2,3})
        print(validPositionsToString(vp))
    end
end

-- Called when the mouse moves.
function mouseHandler(mouse)
    -- Do nothing initially.
end
