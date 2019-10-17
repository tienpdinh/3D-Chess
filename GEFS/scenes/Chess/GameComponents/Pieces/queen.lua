local Queen = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0
}

-- Create a new instance of pieces which will be inherited by specific pieces
function Queen:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Attach a model to this queen instance.
function Queen:addModel()
    self.ID = addModel("Queen" .. self.team, self.x, self.y, self.z)
    if self.team == "Light" then
        rotateModel(self.ID, math.pi, 0, 1, 0)
    end
end

function Queen:getLegalMoves(pieces, board)
    local moves = {}
    local i = 1

    -- Queens can move diagonally and laterally.

    -- Check -x direction.
    local x = self.x - 1
    while x >= 1 do
        if not board:occupied(x, self.z) then
            moves[i] = {x, self.z}
            i = i + 1
        else
            if board:enemyOccupied(x, self.z, pieces, self.team) then
                moves[i] = {x, self.z}
                i = i + 1
            end
            x = 1-1
        end
        x = x - 1
    end

    -- Check +x direction.
    x = self.x + 1
    while x <= 8 do
        if not board:occupied(x, self.z) then
            moves[i] = {x, self.z}
            i = i + 1
        else
            if board:enemyOccupied(x, self.z, pieces, self.team) then
                moves[i] = {x, self.z}
                i = i + 1
            end
            x = 8+1
        end
        x = x + 1
    end

    -- Check -z direction.
    local z = self.z - 1
    while z >= 1 do
        if not board:occupied(self.x, z) then
            moves[i] = {self.x, z}
            i = i + 1
        else
            if board:enemyOccupied(self.x, z, pieces, self.team) then
                moves[i] = {self.x, z}
                i = i + 1
            end
            z = 1-1
        end
        z = z - 1
    end

    -- Check +z direction.
    z = self.z + 1
    while z <= 8 do
        if not board:occupied(self.x, z) then
            moves[i] = {self.x, z}
            i = i + 1
        else
            if board:enemyOccupied(self.x, z, pieces, self.team) then
                moves[i] = {self.x, z}
                i = i + 1
            end
            z = 8+1
        end
        z = z + 1
    end

    -- Check +x+z diagonal
    x = self.x + 1
    z = self.z + 1
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

-- function Queen:legalmoves ()
--   -- Return an array of the legal moves based on the current location
--   -- TODO: Is this inefficient? Replace with a islegalmove instead maybe?
--   return {}
-- end
--
-- function Queen:islegalmove (move)
--   -- TODO: Implement this, graph search?
--   return false
-- end
--
-- function Queen:capture (opponent)
--   -- TODO: Implement this
-- end

return Queen
