-- ///////// --
-- VARIABLES --
-- ///////// --

-- Setup the camera.
require "scenes/Chess/cameraSetup"
CameraTheta = math.pi/2.0

-- General.
frameDt = 0



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
    local tSpeed = 1
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
end

-- Called when the mouse moves.
function mouseHandler(mouse)
    -- Do nothing initially.
end



-- ////// --
-- MODELS --
-- ////// --

-- Setup each chess piece.
-- TODO: export each chess piece centered at the origin.
-- Right now it appears tinyObj loader does not take blender origin definitions into account.
pos = 0
stride = 0
id1 = addModel("PawnDark", pos, 0, 0)
pos = pos + stride
id2 = addModel("RookDark", pos, 0, 0)
pos = pos + stride
id3 = addModel("KnightDark", pos, 0, 0)
pos = pos + stride
id4 = addModel("BishopDark", pos, 0, 0)
pos = pos + stride
id5 = addModel("QueenDark", pos, 0, 0)
pos = pos + stride
id6 = addModel("KingDark", pos, 0, 0)
