local Parent = require "scenes/Chess/GameComponents/pieces"


Rook = Parent:new()

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

return Rook