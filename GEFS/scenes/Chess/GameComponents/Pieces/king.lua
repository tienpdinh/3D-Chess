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

-- Attach a model to this king instance.
function King:addModel()
    self.ID = addModel("King" .. self.team, self.x, self.y, self.z)
    if self.team == "Light" then
        rotateModel(self.ID, -math.pi/2.0, 0, 1, 0)
    else
        rotateModel(self.ID, math.pi/2.0, 0, 1, 0)
    end
end

function King:getLegalMoves(pieces, board)
    local moves = {}
    local i = 1

    -- Kings can move in a +1 square around its current position.
    local offsets = {
        {-1,-1},
        {-1, 0},
        {-1, 1},
        {0, -1},
        {0, 1},
        {1, -1},
        {1, 0},
        {1, 1}
    }

    for j=1,8 do
        local x = self.x + offsets[j][1]
        local z = self.z + offsets[j][2]

        if (x >= 1 and x <= 8 and z >= 1 and z <= 8 and not board:friendlyOccupied(x, z, pieces, self.team)) then
            moves[i] = {x, z}
            i = i + 1
        end
    end

    return moves
end

-- function King:legalmoves ()
--   -- Return an array of the legal moves based on the current location
--   -- TODO: Is this inefficient? Replace with a islegalmove instead maybe?
--   return {}
-- end
--
-- function King:islegalmove (move)
--   -- TODO: Implement this, graph search?
--   return false
-- end
--
-- function King:capture (opponent)
--   -- TODO: Implement this
-- end

return King