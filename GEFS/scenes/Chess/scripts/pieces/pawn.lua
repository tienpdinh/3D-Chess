local Pawn = {
  x = 0,
  y = 0,
  z = 0,
  team = "Light",
  visible = true,
  ID = 0,
  angle = 0,
  type = "Pawn",
  theKing = nil
}

-- Create a new instance of pieces which will be inherited by specific pieces.
function Pawn:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Attach the model to this pawn instance.
function Pawn:addModel(colliderLayer)
    self.ID = addModel("Pawn" .. self.team, self.x, self.y, self.z)
    addCollider(self.ID, colliderLayer, 0.5, 0, 0, 0)
    -- self.angle = math.random()*math.pi*2.0
    if self.team == "Light" then
        self.angle = math.pi
    end
    rotateModel(self.ID, self.angle, 0, 1, 0)
    return self.ID
end

function Pawn:placeModel()
    placeModel(self.ID, self.x, self.y, self.z)
    rotateModel(self.ID, self.angle, 0, 1, 0)
end

function Pawn:safeMove(pieces, board, x, z)
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

function Pawn:getLegalMoves(pieces, board)
    local moves = {}
    local i = 1

    if self.team == "Light" then
        -- Pawns can move forward +2 if they haven't moved yet and
        -- the space is not friendly-occupied and the +1 space isn't occupied.
        if self.z == 2 and not board:occupied(self.x, self.z+2) and not board:occupied(self.x, self.z+1) and self:safeMove(pieces, board, self.x, self.z+2) then
            moves[i] = {self.x, self.z+2}
            i = i + 1
        end

        -- Pawns can move forward +1 if the space is not friendly-occupied and within the board.
        if self.z < 8 and not board:occupied(self.x, self.z+1) and self:safeMove(pieces, board, self.x, self.z+1) then
            moves[i] = {self.x, self.z+1}
            i = i + 1
        end

        -- Pawns can move diagonal (+x+z, -x+z) if an enemy piece exists there.
        -- Check left diagonal.
        if self.x > 1 and self.z < 8 and board:enemyOccupied(self.x-1, self.z+1, pieces, self.team) and self:safeMove(pieces, board, self.x-1, self.z+1) then
            moves[i] = {self.x-1, self.z+1}
            i = i + 1
        end

        -- Check right diagonal.
        if self.x < 8 and self.z < 8 and board:enemyOccupied(self.x+1, self.z+1, pieces, self.team) and self:safeMove(pieces, board, self.x+1, self.z+1) then
            moves[i] = {self.x+1, self.z+1}
            i = i + 1
        end
    elseif self.team == "Dark" then
        if self.z == 7 and not board:occupied(self.x, self.z-2) and not board:occupied(self.x, self.z-1) and self:safeMove(pieces, board, self.x, self.z-2) then
            moves[i] = {self.x, self.z-2}
            i = i + 1
        end

        if self.z > 1 and not board:occupied(self.x, self.z-1) and self:safeMove(pieces, board, self.x, self.z-1) then
            moves[i] = {self.x, self.z-1}
            i = i + 1
        end

        if self.x > 1 and self.z > 1 and board:enemyOccupied(self.x-1, self.z-1, pieces, self.team) and self:safeMove(pieces, board, self.x-1, self.z-1) then
            moves[i] = {self.x-1, self.z-1}
            i = i + 1
        end

        if self.x < 8 and self.z > 1 and board:enemyOccupied(self.x+1, self.z-1, pieces, self.team) and self:safeMove(pieces, board, self.x+1, self.z-1) then
            moves[i] = {self.x+1, self.z-1}
            i = i + 1
        end
    else
        error("ERROR in Pawn:getLegalMoves()")
        return nil
    end

    return moves, i - 1
end

function Pawn:getLegalMovesRaw(pieces, board)
    local moves = {}
    local i = 1

    if self.team == "Light" then
        -- Pawns can move forward +2 if they haven't moved yet and
        -- the space is not friendly-occupied and the +1 space isn't occupied.
        if self.z == 2 and not board:occupied(self.x, self.z+2) and not board:occupied(self.x, self.z+1) then
            moves[i] = {self.x, self.z+2}
            i = i + 1
        end

        -- Pawns can move forward +1 if the space is not friendly-occupied and within the board.
        if self.z < 8 and not board:occupied(self.x, self.z+1) then
            moves[i] = {self.x, self.z+1}
            i = i + 1
        end

        -- Pawns can move diagonal (+x+z, -x+z) if an enemy piece exists there.
        -- Check left diagonal.
        if (self.x > 1 and self.z < 8 and board:enemyOccupied(self.x-1, self.z+1, pieces, self.team)) then
            moves[i] = {self.x-1, self.z+1}
            i = i + 1
        end

        -- Check right diagonal.
        if (self.x < 8 and self.z < 8 and board:enemyOccupied(self.x+1, self.z+1, pieces, self.team)) then
            moves[i] = {self.x+1, self.z+1}
            i = i + 1
        end
    elseif self.team == "Dark" then
        if self.z == 7 and not board:occupied(self.x, self.z-2) and not board:occupied(self.x, self.z-1) then
            moves[i] = {self.x, self.z-2}
            i = i + 1
        end

        if self.z > 1 and not board:occupied(self.x, self.z-1) then
            moves[i] = {self.x, self.z-1}
            i = i + 1
        end

        if (self.x > 1 and self.z > 1 and board:enemyOccupied(self.x-1, self.z-1, pieces, self.team)) then
            moves[i] = {self.x-1, self.z-1}
            i = i + 1
        end

        if (self.x < 8 and self.z > 1 and board:enemyOccupied(self.x+1, self.z-1, pieces, self.team)) then
            moves[i] = {self.x+1, self.z-1}
            i = i + 1
        end
    else
        error("ERROR in Pawn:getLegalMoves()")
        return nil
    end

    return moves, i - 1
end

return Pawn
