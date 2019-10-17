local Bishop = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0
}

-- Create a new instance of pieces which will be inherited by specific pieces.
function Bishop:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Attach a model to this bishop instance.
function Bishop:addModel()
    self.ID = addModel("Bishop" .. self.team, self.x, self.y, self.z)
    if self.team == "Light" then
        rotateModel(self.ID, math.pi, 0, 1, 0)
    end
end

function Bishop:getLegalMoves(pieces, board)
    local moves = {}
    local i = 1

    -- Bishops can move diagonally until they run into a non-empty board space.

    -- Check +x+z diagonal
    local x = self.x + 1
    local z = self.z + 1
    while x <= 8 and z <= 8 do
        if not board:occupied(x, z) then
            moves[i] = {x, z}
            i = i + 1
        else
            if board:enemyOccupied(x, z, pieces, self.team) then
                moves[i] = {x, z}
                i = i + 1
            end
            x = 8+1
            z = 8+1
        end
        x = x + 1
        z = z + 1
    end

    -- Check -x-z diagonal
    x = self.x - 1
    z = self.z - 1
    while x >= 1 and z >= 1 do
        if not board:occupied(x, z) then
            moves[i] = {x, z}
            i = i + 1
        else
            if board:enemyOccupied(x, z, pieces, self.team) then
                moves[i] = {x, z}
                i = i + 1
            end
            x = 1-1
            z = 1-1
        end
        x = x - 1
        z = z - 1
    end

    -- Check +x-z diagonal
    x = self.x + 1
    z = self.z - 1
    while x <= 8 and z >= 1 do
        if not board:occupied(x, z) then
            moves[i] = {x, z}
            i = i + 1
        else
            if board:enemyOccupied(x, z, pieces, self.team) then
                moves[i] = {x, z}
                i = i + 1
            end
            x = 8+1
            z = 1-1
        end
        x = x + 1
        z = z - 1
    end

    -- Check -x+z diagonal
    x = self.x - 1
    z = self.z + 1
    while x >= 1 and z <= 8 do
        if not board:occupied(x, z) then
            moves[i] = {x, z}
            i = i + 1
        else
            if board:enemyOccupied(x, z, pieces, self.team) then
                moves[i] = {x, z}
                i = i + 1
            end
            x = 1-1
            z = 8+1
        end
        x = x - 1
        z = z + 1
    end

    return moves
end

-- function Bishop:legalmoves ()
--   -- Return an array of the legal moves based on the current location
--   -- TODO: Is this inefficient? Replace with a islegalmove instead maybe?
--   return {}
-- end
--
-- function Bishop:islegalmove (move)
--   -- TODO: Implement this, graph search?
--   return false
-- end
--
-- function Bishop:capture (opponent)
--   -- TODO: Implement this
-- end

return Bishop
