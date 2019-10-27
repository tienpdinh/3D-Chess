local Bishop = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0,
  angle = 0,
  type = "Bishop",
  theKing = nil
}

-- Create a new instance of pieces which will be inherited by specific pieces.
function Bishop:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Attach a model to this bishop instance.
function Bishop:addModel(colliderLayer)
    self.ID = addModel("Bishop" .. self.team, self.x, self.y, self.z)
    addCollider(self.ID, colliderLayer, 0.5, 0, 0, 0)
    if self.team == "Light" then
        self.angle = math.pi
    end
    rotateModel(self.ID, self.angle, 0, 1, 0)
    return self.ID
end

function Bishop:placeModel()
    placeModel(self.ID, self.x, self.y, self.z)
    if self.team == "Light" then
        rotateModel(self.ID, math.pi, 0, 1, 0)
    end
end

function Bishop:safeMove(pieces, board, x, z)
    local kingCoord = {pieces[self.theKing].x, pieces[self.theKing].z}
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
            if utils.containsMove(moves, kingCoord) then
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

function Bishop:getLegalMoves(pieces, board)
    local moves = {}
    local i = 1

    -- Bishops can move diagonally until they run into a non-empty board space.

    -- Check +x+z diagonal
    local x = self.x + 1
    local z = self.z + 1
    while x <= 8 and z <= 8 do
        if not board:occupied(x, z) and self:safeMove(pieces, board, x, z) then
            moves[i] = {x, z}
            i = i + 1
        elseif board:occupied(x, z) then
            if board:enemyOccupied(x, z, pieces, self.team) and self:safeMove(pieces, board, x, z) then
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
        if not board:occupied(x, z) and self:safeMove(pieces, board, x, z) then
            moves[i] = {x, z}
            i = i + 1
        elseif board:occupied(x, z) then
            if board:enemyOccupied(x, z, pieces, self.team) and self:safeMove(pieces, board, x, z) then
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
        if not board:occupied(x, z) and self:safeMove(pieces, board, x, z) then
            moves[i] = {x, z}
            i = i + 1
        elseif board:occupied(x, z) then
            if board:enemyOccupied(x, z, pieces, self.team) and self:safeMove(pieces, board, x, z) then
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
        if not board:occupied(x, z) and self:safeMove(pieces, board, x, z) then
            moves[i] = {x, z}
            i = i + 1
        elseif board:occupied(x, z) then
            if board:enemyOccupied(x, z, pieces, self.team) and self:safeMove(pieces, board, x, z) then
                moves[i] = {x, z}
                i = i + 1
            end
            x = 1-1
            z = 8+1
        end
        x = x - 1
        z = z + 1
    end

    return moves, i - 1
end

function Bishop:getLegalMovesRaw(pieces, board)
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

    return moves, i - 1
end

return Bishop
