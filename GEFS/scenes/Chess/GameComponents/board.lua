local Board = { chessboard = {}}

-- Initialize a new board with 8x8 size, filled with nils.
function Board:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    for x = 1, 8 do
        self.chessboard[x] = {}
        for z = 1, 8 do
            self.chessboard[x][z] = {}
            self.chessboard[x][z].x = x
            self.chessboard[x][z].z = z
            self.chessboard[x][z].pieceIndex = -1

            if (x % 2 ~= z % 2) then
                self.chessboard[x][z].id = addModel("LightTile", x, 0, z)
            else
                self.chessboard[x][z].id = addModel("DarkTile", x, 0, z)
            end
            local r = math.floor(math.random()*4.0)/4.0  -- 0, 0.25, 0.5, or 0.75
            rotateModel(self.chessboard[x][z].id,r*math.pi*2, 0, 1, 0)
        end
    end
    return o
end

-- Returns whether the board is occupied at (x, z)
function Board:occupied(x, z)
    return self.chessboard[x][z].pieceIndex > 0
end

-- Returns whether the board is occupied by a friendly piece at (x, z)
function Board:friendlyOccupied(x, z, pieces, myTeam)
    if not self:occupied(x, z) then
        return false;
    else
        local i = self.chessboard[x][z].pieceIndex
        return myTeam ==pieces[i].team
    end
end

-- Returns whether the board is occupied by an enemy piece at (x, z)
function Board:enemyOccupied(x, z, pieces, myTeam)
    if not self:occupied(x, z) then
        return false;
    else
        local i = self.chessboard[x][z].pieceIndex
        return myTeam ~=pieces[i].team
    end
end

-- Returns a list of indices into the pieces array of which pieces can move
-- for the given team.
function Board:canMove(pieces, myTeam)
    local moveablePieces = {}
    local j = 1
    for i,piece in pairs(pieces) do
        if piece.team == myTeam and #piece:getLegalMoves(pieces, self) > 0 then
            moveablePieces[j] = i
            j = j + 1
        end
    end
    return moveablePieces
end

return Board
