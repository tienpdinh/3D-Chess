local Pawn = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0
}

-- Create a new instance of pieces which will be inherited by specific pieces
function Pawn:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Pawn:legalmoves ()
  -- Return an array of the legal moves based on the current location
  -- TODO: Is this inefficient? Replace with a islegalmove instead maybe?
  return {}
end

function Pawn:islegalmove (move)
  -- TODO: Implement this, graph search?
  return false
end

function Pawn:capture (opponent)
  -- TODO: Implement this
end

function Pawn:drawpiece ()
  self.ID = addModel("Pawn" .. self.team, self.x, self.y, self.z)
  rotateModel(self.ID, math.random()*math.pi*2.0, 0, 1, 0)
end

return Pawn