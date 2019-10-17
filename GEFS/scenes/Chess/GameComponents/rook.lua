local Rook = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0
}

-- Create a new instance of pieces which will be inherited by specific pieces
function Rook:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Rook:legalmoves ()
  -- Return an array of the legal moves based on the current location
  -- TODO: Is this inefficient? Replace with a islegalmove instead maybe?
  return {}
end

function Rook:islegalmove (move)
  -- TODO: Implement this, graph search?
  return false
end

function Rook:capture (opponent)
  -- TODO: Implement this
end

function Rook:drawpiece ()
  self.ID = addModel("Rook" .. self.team, self.x, self.y, self.z)
end

return Rook