-- ///////////// --
-- DEFINE PIECES --
-- ///////////// --
pieces = {}

tmpPiece = {}
tmpPiece['MODELID'] = 0
tmpPiece['COLOR'] = "LIGHT"
tmpPiece['POSITION'] = {1,0,1}
tmpPiece['TYPE'] = "PAWN"

for i = 1, 32 do
    pieces[i] = tmpPiece
end

-- TODO: create a method in a seperate module which sets up the pieces
-- pieces = setupPieces()



-- //////////// --
-- DEFINE BOARD --
-- //////////// --
board = {}

-- clear the board.
for x = 1,8 do
    board[x] = {}
    for z = 1,8 do
        board[x][z] = -1
    end
end

-- set the pieces on the board.
for p = 1,32 do
    local x = pieces[p]['POSITION'][1]
    local z = pieces[p]['POSITION'][3]
    board[x][z] = p
end



-- ///////////// --
-- BOARD METHODS --
-- ///////////// --

function occupied(x, z)
    return board[x][z] > 0
end

function friendlyOccupied(x, z, myColor)
    if not occupied(x, z) then
        return false
    else
        return pieces[board[x][z]]['COLOR'] == myColor
    end
end

function enemyOccupied(x, z, myColor)
    if not occupied(x, z) then
        return false
    else
        return pieces[board[x][z]]['COLOR'] ~= myColor
    end
end



-- ///////////// --
-- PIECE METHODS --
-- ///////////// --

function getMovementOptions(piece)
    local positions = {}

    if piece['TYPE'] == "PAWN" then
        pos = getMovementOptionsPawn(piece)
    elseif piece['TYPE'] == "ROOK" then
        pos = getMovementOptionsRook(piece)
    elseif piece['TYPE'] == "KNIGHT" then
        pos = getMovementOptionsKnight(piece)
    elseif piece['TYPE'] == "BISHOP" then
        pos = getMovementOptionsBishop(piece)
    elseif piece['TYPE'] == "QUEEN" then
        pos = getMovementOptionsQueen(piece)
    elseif piece['TYPE'] == "KING" then
        pos = getMovementOptionsKing(piece)
    else
        print("ERROR in getMovementOptions. " .. piece['TYPE'] .. " is not a valid TYPE.")
        return nil
    end

    -- Filter out friendly occupied positions.
    local validPositions = {}
    for i, pos in pairs(positions) do
        local x = pos[1]
        local z = pos[2]
        if not friendlyOccupied(x, z, piece['COLOR']) then
            table.insert(validPositions, pos)
        end
    end
    return validPositions
end

function getMovementOptionsPawn(piece)
end

function getMovementOptionsRook(piece)
end

function getMovementOptionsKnight(piece)
end

function getMovementOptionsBishop(piece)
end

function getMovementOptionsQueen(piece)
end

function getMovementOptionsKing(piece)
end

function formatMovementOptions(movementOptions)
    if type(movementOptions) == 'table' then
        local s = '{'
        for i, pos in pairs(movementOptions) do
            if type(pos) == 'table' then
                s = s..'('..pos[1]..', '..pos[2]..') : '
            else
                print("ERROR in formatMovementOptions.")
                return nil
            end
        end
        return s .. '}'
    else
        print("ERROR in formatMovementOptions.")
        return nil
    end
end
