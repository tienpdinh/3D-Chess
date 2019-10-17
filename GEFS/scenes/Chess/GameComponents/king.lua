local King = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0
}

-- Create a new instance of pieces which will be inherited by specific pieces
function King:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function King:legalmoves ()
  -- Return an array of the legal moves based on the current location
  -- TODO: Is this inefficient? Replace with a islegalmove instead maybe?
  return {}
end

function King:islegalmove (move)
  -- TODO: Implement this, graph search?
  return false
end

function King:capture (opponent)
  -- TODO: Implement this
end

function King:drawpiece ()
  self.ID = addModel("King" .. self.team, self.x, self.y, self.z)
  if self.team == "Light" then
    rotateModel(self.ID, -math.pi/2.0, 0, 1, 0)
  else
    rotateModel(self.ID, math.pi/2.0, 0, 1, 0)
  end
end

return King