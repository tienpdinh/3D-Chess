--Simple Example
print("Starting Lua for Big Example")

--Todo:
-- Lua modules (for better organization, and maybe reloading?)

CameraPosX = -3.0
CameraPosY = 2.0
CameraPosZ = 0.0

CameraDirX = 1.0
CameraDirY = -0.1
CameraDirZ = -0.0

CameraUpX = 0.0
CameraUpY = 1.0
CameraUpZ = 0.0

animatedModels = {}
velModel = {}
rotYVelModel = {}

teapotLayer = 0

function frameUpdate(dt)
  hitID, dist = getMouseClickWithLayer(teapotLayer)
  --print("Dist to object:" ,dist, hitID)
  if hitID then
    rotateModel(hitID,0.1,0,1,0)
  end
end

ang = 0
function keyHandler(keys)
  if keys.left then
    ang = ang + .02
  end
  if keys.right then
    ang = ang - .02
  end
  if keys.up then
    CameraPosX = CameraPosX + .1*CameraDirX
    CameraPosZ = CameraPosZ + .1*CameraDirZ
  end
  if keys.down then
    CameraPosX = CameraPosX - .1*CameraDirX
    CameraPosZ = CameraPosZ - .1*CameraDirZ
  end
  if keys.shift then
    CameraPosY = CameraPosY - 0.1
  end
  if keys.space then
    CameraPosY = CameraPosY + 0.1
  end
  CameraDirX = math.cos(ang);
  CameraDirZ = -math.sin(ang);
end

function mouseHandler(mouse)
  if (mouse.left) then
    print("Mouse XY", mouse.x, mouse.y)
  end
end

--id = addModel("Teapot",0,0,0)
--setModelMaterial(id,"Shiny Red Plastic")
--setModelMaterial(id,"Steel")
--animatedModels[id] = true
--rotYVelModel[id] = 1

id = addModel("Castle",0,0,0)
-- placeModel(id,0,-.04,0)
-- scaleModel(id,60,1,60)
setModelMaterial(id,"Gold")
