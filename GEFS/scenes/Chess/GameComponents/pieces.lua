-- This file contains information of chess pieces
-- such as position, type, available moves

local Pieces = {
  x = 0,
  y = 0,
  z = 0,
  team = "white",
  visible = true
}

-- Create a new instance of pieces which will be inherited by specific pieces
function Pieces:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Set the location of the piece
function Pieces:setlocation (newx, newy, newz)
  self.x = newx
  self.y = newy
  self.z = newz
end

function Pieces:getlocation ()
  return {self.x, self.y, self.z}
end

function Pieces:setteam (newteam)
  self.team = newteam
end

function Pieces:getteam ()
  return self.team
end

function Pieces:setvisibility (visibility)
  self.visible = visibility
end

function Pieces:getvisibility ()
  return self.visible
end

return Pieces