local Knight = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0,
  angle = 0
}

-- Create a new instance of pieces which will be inherited by specific pieces
function Knight:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Attach the model to this knight instance.
function Knight:addModel(colliderLayer)
    self.ID = addModel("Knight" .. self.team, self.x, self.y, self.z)
    addCollider(self.ID, colliderLayer, 0.5, 0, 0, 0)
    if self.team == "Light" then
        self.angle = math.pi
    end
    rotateModel(self.ID, self.angle, 0, 1, 0)
    return self.ID
end

function Knight:placeModel()
    placeModel(self.ID, self.x, self.y, self.z)
    if self.team == "Light" then
        rotateModel(self.ID, math.pi, 0, 1, 0)
    end
end

function Knight:getLegalMoves(pieces, board)
    local moves = {}
    local i = 1

    -- Knights can move ++x+z, ++x-z, +x++z, +x--z, --x+z, --x-z, -x++z, -x--z
    local offsets = {
        { 1, 2},
        { 1,-2},
        { 2, 1},
        { 2,-1},
        {-1, 2},
        {-1,-2},
        {-2, 1},
        {-2,-1}
    }

    for j =1,8 do
        local x = self.x + offsets[j][1]
        local z = self.z + offsets[j][2]

        if (x >= 1 and x <= 8 and z >= 1 and z <= 8 and not board:friendlyOccupied(x, z, pieces, self.team)) then
            moves[i] = {x, z}
            i = i + 1
        end
    end

    return moves, i - 1
end

return Knight