local Board = { chessboard = {}, tileIDs = {} }

-- Initialize a new board with 8x8 size, filled with nils.
function Board:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local colliderLayer = 1
    for x = 1, 8 do
        self.chessboard[x] = {}
        for z = 1, 8 do
            self.chessboard[x][z] = {}
            self.chessboard[x][z].x = x
            self.chessboard[x][z].z = z
            self.chessboard[x][z].pieceIndex = -1

            if (x % 2 ~= z % 2) then
                self.chessboard[x][z].id = addModel("LightTile", x, 0, z)
                self.chessboard[x][z].color = "Light"
            else
                self.chessboard[x][z].id = addModel("DarkTile", x, 0, z)
                self.chessboard[x][z].color = "Dark"
            end
            self.tileIDs[self.chessboard[x][z].id] = self.chessboard[x][z]
            addCollider(self.chessboard[x][z].id, colliderLayer, 0.75, 0, 0, 0)
            local r = math.floor(math.random()*4.0)/4.0  -- 0, 0.25, 0.5, or 0.75
            rotateModel(self.chessboard[x][z].id,r*math.pi*2, 0, 1, 0)
        end
    end
    return o, colliderLayer
end

-- Returns whether the board is occupied at (x, z)
function Board:occupied(x, z)
    return self.chessboard[math.floor(x)][math.floor(z)].pieceIndex > 0
end

-- Returns whether the board is occupied by a friendly piece at (x, z)
function Board:friendlyOccupied(x, z, pieces, myTeam)
    if not self:occupied(x, z) then
        return false
    else
        local i = self.chessboard[math.floor(x)][math.floor(z)].pieceIndex
        if pieces[i] == nil then
            return false
        end
        return myTeam ==pieces[i].team
    end
end

-- Returns whether the board is occupied by an enemy piece at (x, z)
function Board:enemyOccupied(x, z, pieces, myTeam)
    if not self:occupied(x, z) then
        return false
    else
        local i = self.chessboard[math.floor(x)][math.floor(z)].pieceIndex
        if pieces[i] == nil then
            return false
        end
        return myTeam ~= pieces[i].team
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

function Board:gameOver(pieces)
    return pieces[31] == nil or pieces[32] == nil
end

return Board
