local utils = require "scenes/Chess/scripts/utils"
local King = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0,
  angle = 0,
  type = "King"
}

-- Create a new instance of pieces which will be inherited by specific pieces
function King:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Attach a model to this king instance.
function King:addModel(colliderLayer)
    self.ID = addModel("King" .. self.team, self.x, self.y, self.z)
    addCollider(self.ID, colliderLayer, 0.5, 0, 0, 0)
    if self.team == "Light" then
        self.angle = math.pi
    end
    rotateModel(self.ID, self.angle, 0, 1, 0)
    return self.ID
end

function King:placeModel()
    placeModel(self.ID, self.x, self.y, self.z)
    if self.team == "Light" then
        rotateModel(self.ID, math.pi, 0, 1, 0)
    end
end

function King:safeMove(pieces, board, x, z)
    local safe = true
    local oldX = self.x
    local oldZ = self.z
    local oldIndex = board.chessboard[oldX][oldZ].pieceIndex
    local newIndex = board.chessboard[x][z].pieceIndex
    local newPiece = pieces[newIndex]
    -- simulation starts here
    self.x = x
    self.z = z
    board.chessboard[x][z].pieceIndex = oldIndex
    board.chessboard[oldX][oldZ].pieceIndex = -1
    pieces[newIndex] = nil
    -- simulation finished, check if current location is safe
    for _, piece in pairs(pieces) do
        if piece.team ~= self.team then
            local moves = piece:getLegalMovesRaw(pieces, board)
            if utils.containsMove(moves, {x, z}) then
                safe = false
                break
            end
        end
    end
    -- Restoration
    self.x = oldX
    self.z = oldZ
    board.chessboard[oldX][oldZ].pieceIndex = oldIndex
    board.chessboard[x][z].pieceIndex = newIndex
    pieces[newIndex] = newPiece
    return safe
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

        if (x >= 1 and x <= 8 and z >= 1 and z <= 8 and not board:friendlyOccupied(x, z, pieces, self.team) and self:safeMove(pieces, board, x, z)) then
            moves[i] = {x, z}
            i = i + 1
        end
    end

    return moves, i - 1
end

function King:getLegalMovesRaw(pieces, board)
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

    return moves, i - 1
end

return King
