--Simple Example
print("Starting Lua for Simple Example")

CameraPosX = -3.0
CameraPosY = 1.0
CameraPosZ = 0.0

CameraDirX = 1.0
CameraDirY = -0.0
CameraDirZ = -0.0

CameraUpX = 0.0
CameraUpY = 1.0
CameraUpZ = 0.0

animatedModels = {}
velModel = {}
rotYVelModel = {}

function frameUpdate(dt)
  for modelID,v in pairs(animatedModels) do
    --print("ID",modelID)
    local vel = velModel[modelID]
    if vel then
      translateModel(modelID,dt*vel[1],dt*vel[2],dt*vel[3])
    end

    local rotYvel = rotYVelModel[modelID]
    if rotYvel then
      rotateModel(modelID,rotYvel*dt, 0, 1, 0)
    end

  end
end

function keyHandler(keys)
  if keys.left then
    translateModel(statueID,0,0,-0.1)
  end
  if keys.right then
    translateModel(statueID,0,0,0.1)
  end
  if keys.up then
    translateModel(statueID,0.1,0,0)
  end
  if keys.down then
    translateModel(statueID,-0.1,0,0)
  end
  if keys.space then
      rotYVelModel[statueID] = 1
      rotYVelModel[statue2ID] = 1
  else
      rotYVelModel[statueID] = 0
      rotYVelModel[statue2ID] = 0
  end
end

statueID = addModel("Statue",0, 0, -0.5)
animatedModels[statueID] = true
rotYVelModel[statueID] = 0

statue2ID = addModel("Statue", 0, 0, 0.5)
setModelMaterial(statue2ID, "Clay")
animatedModels[statue2ID] = true
rotYVelModel[statue2ID] = 0
