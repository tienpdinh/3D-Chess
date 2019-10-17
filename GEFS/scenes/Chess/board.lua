require "scenes/Chess/movementLogic"
require "scenes/Chess/setupPieces"

-- DECLARE chess board.

chessboard = {}
for i = 1, 8 do
    chessboard[i] = {}
    for j = 1, 8 do
        chessboard[i][j] = -1
    end
end

-- CREATE array to hold all chess pieces.

pieces = {}
local index = 1

-- Add light pieces to array
for i = 1, 8 do
    pieces[index] = lightPawns[i]
    index = index + 1
end
for i = 1, 2 do
    pieces[index] = lightRooks[i]
    index = index + 1
end
for i = 1, 2 do
    pieces[index] = lightKnights[i]
    index = index + 1
end
for i = 1, 2 do
    pieces[index] = lightBishops[i]
    index = index + 1
end
pieces[index] = lightQueen
index = index + 1
pieces[index] = lightKing
index = index + 1

-- Add dark pieces to array
for i = 1, 8 do
    pieces[index] = darkPawns[i]
    index = index + 1
end
for i = 1, 2 do
    pieces[index] = darkRooks[i]
    index = index + 1
end
for i = 1, 2 do
    pieces[index] = darkKnights[i]
    index = index + 1
end
for i = 1, 2 do
    pieces[index] = darkBishops[i]
    index = index + 1
end
pieces[index] = darkQueen
index = index + 1
pieces[index] = darkKing
index = index + 1

-- SET BOARD VALUES TO INDICES OF piece at that location
for i = 1,32 do
    local x = pieces[i][POS][1]
    local z = pieces[i][POS][3]

    board[x][z] = i
end


-- Whether the position {x,z} on the board is occupied or not.
function occupied(pos, board)
    -- TODO: implement this.
    return false
end

-- Whether the position {x,z} on the board is occupied by a piece whose side
-- matches the input "side".
function friendlyOccupied(pos, side, board)
    if occupied(pos, board) then
        return false
    else
        -- return side == board[pos[1]][pos[2]].piece[SIDE]
        return false
    end
end

-- Whether the position {x,z} on the board is occupied by a piece whose side
-- opposes the input "side".
function enemyOccupied(pos, side, board)
    if occupied(pos, board) then
        return false
    else
        -- return side != board[pos[1]][pos[2]].piece[SIDE]
        return false
    end
end
