-- Defaults for camera movement.
-- SET THESE to change the camera behavior.
local CameraSpeed = 1
local CameraDistanceFromCenter = 6
local CameraHeight = 6
local CameraAngle = -50

-- Helper variables.
-- DO NOT set these.
local CameraTimer = 1.0

-- Required for engine.
-- DO NOT set these.
CameraPosX = 0
CameraPosY = 0
CameraPosZ = 0

-- Required for engine.
-- DO NOT set these.
CameraDirX = 0
CameraDirY = -1
CameraDirZ = 1

-- Required for engine.
-- DO NOT set these.
CameraUpX = 0
CameraUpY = 1
CameraUpZ = 0

-- Updates the camera to face the board based on who's turn it is.
function updateCamera(dt, turn)
    if turn == "Light" then
        CameraTimer = CameraTimer + dt*CameraSpeed
        CameraTimer = math.min(1, CameraTimer)
    elseif turn == "Dark" then
        CameraTimer = CameraTimer - dt*CameraSpeed
        CameraTimer = math.max(0, CameraTimer)
    else
        print "ERROR in updateCamera(). Illegal turn!"
    end

    -- NOTE: board is centered at (4.5, 0, 4.5)
    -- Set the camera position in a circle around the board center.
    CameraPosX = 4.5 + math.sin(CameraTimer * math.pi) * CameraDistanceFromCenter
    CameraPosY = CameraHeight
    CameraPosZ = 4.5 + math.cos(CameraTimer * math.pi) * CameraDistanceFromCenter

    -- Rotate the camera to face inwards towards the board.
    local alpha = math.rad(CameraAngle)
    local beta = -math.pi * (1.0-CameraTimer)
    CameraDirX = math.cos(alpha) * math.sin(beta)
    CameraDirY = math.sin(alpha)
    CameraDirZ = math.cos(alpha) * math.cos(beta)
end