local Parent = require(pieces)


Castle = Parent:new()

function Castle:legalmoves ()
  -- Return an array of the legal moves based on the current location
  -- TODO: Is this inefficient? Replace with a islegalmove instead maybe?
  return {}
end

function Castle:islegalmove (move)
  -- TODO: Implement this, graph search?
  return false
end

function Castle:capture (opponent)
  -- TODO: Implement this
end