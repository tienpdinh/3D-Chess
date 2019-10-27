local Rook = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0,
  angle = 0,
  type = "Rook",
  theKing = nil
}

-- Create a new instance of pieces which will be inherited by specific pieces.
function Rook:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Attach the model to this rook instance.
function Rook:addModel(colliderLayer)
    self.ID = addModel("Rook" .. self.team, self.x, self.y, self.z)
    addCollider(self.ID, colliderLayer, 0.5, 0, 0, 0)
    local r = math.floor(math.random()*4.0)/4.0
    self.angle = r*math.pi*2
    rotateModel(self.ID, self.angle, 0, 1, 0)
    return self.ID
end

function Rook:placeModel()
    placeModel(self.ID, self.x, self.y, self.z)
    rotateModel(self.ID, self.angle, 0, 1, 0)
end

function Rook:safeMove(pieces, board, x, z)
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

function Rook:getLegalMoves(pieces, board)
    local moves = {}
    local i = 1

    -- Rooks can move L,R, U, D for as long as they remain on the board and
    -- don't run into a friendly piece.

    -- Check -x direction.
    local x = self.x - 1
    while x >= 1 do
        if not board:occupied(x, self.z) and self:safeMove(pieces, board, x, self.z) then
            moves[i] = {x, self.z}
            i = i + 1
        elseif board:occupied(x, self.z) then
            if board:enemyOccupied(x, self.z, pieces, self.team) and self:safeMove(pieces, board, x, self.z) then
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
        if not board:occupied(x, self.z) and self:safeMove(pieces, board, x, self.z) then
            moves[i] = {x, self.z}
            i = i + 1
        elseif board:occupied(x, self.z) then
            if board:enemyOccupied(x, self.z, pieces, self.team) and self:safeMove(pieces, board, x, self.z) then
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
        if not board:occupied(self.x, z) and self:safeMove(pieces, board, self.x, z) then
            moves[i] = {self.x, z}
            i = i + 1
        elseif board:occupied(self.x, z) then
            if board:enemyOccupied(self.x, z, pieces, self.team) and self:safeMove(pieces, board, self.x, z) then
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
        if not board:occupied(self.x, z) and self:safeMove(pieces, board, self.x, z) then
            moves[i] = {self.x, z}
            i = i + 1
        elseif board:occupied(self.x, z) then
            if board:enemyOccupied(self.x, z, pieces, self.team) and self:safeMove(pieces, board, self.x, z) then
                moves[i] = {self.x, z}
                i = i + 1
            end
            z = 8+1
        end
        z = z + 1
    end

    return moves, i - 1
end

function Rook:getLegalMovesRaw(pieces, board)
    local moves = {}
    local i = 1

    -- Rooks can move L,R, U, D for as long as they remain on the board and
    -- don't run into a friendly piece.

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

    return moves, i - 1
end

return Rook
