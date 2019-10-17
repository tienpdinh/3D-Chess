
-- Returns the valid positions of the current piece (not accounting for
-- occupied board positions).
function getValidPositions(piece, board)
    local positions = {}

    if piece[TYPE] == 0 then
        positions = getValidPositionsPawn(piece, board)
    elseif piece[TYPE] == 1 then
        positions = getValidPositionsRook(piece, board)
    elseif piece[TYPE] == 2 then
        positions = getValidPositionsKnight(piece, board)
    elseif piece[TYPE] == 3 then
        positions = getValidPositionsBishop(piece, board)
    elseif piece[TYPE] == 4 then
        positions = getValidPositionsQueen(piece, board)
    elseif piece[TYPE] == 5 then
        positions = getValidPositionsKing(piece, board)
    else
        print("ERROR: piece TYPE " + piece[TYPE] + " is not a valid type.")
        return nil
    end

    -- Verify no friendly-occupied space slipped in.
    validPositions = {}
    for i, pos in pairs(positions) do
        if not friendlyOccupied(pos, piece[SIDE], board) then
            table.insert(validPositions, pos)
        end
    end

    return validPositions
end

function getValidPositionsPawn(piece, board)
    -- print ("Getting positions for pawn")

    local validPositions = {}
    local i = 0
    local x = piece[POS][1]
    local z = piece[POS][3]

    -- Light piece.
    if piece[TYPE] == 0 then
        -- Pawns can move +2 forward if they haven't moved yet.
        if z == 2 then
            validPositions[i] = {x, z+2}
            i = i + 1
        end

        -- Check forward for valid spot (i.e. not off the board).
        if z < 8 then
            validPositions[i] = {x, z+1}
            i = i + 1
        end

        -- Check left diagonal for enemy piece.
        if x > 1 and z < 8 then
            if enemyOccupied({x-1, z+1}, piece[SIDE], board) then
                validPositions[i] = {x-1, z+1}
                i = i + 1
            end
        end

        -- Check right diagonal for enemy piece.
        if x < 8 and z < 8 then
            if enemyOccupied({x+1, z+1}, piece[SIDE], board) then
                validPositions[i] = {x+1, z+1}
                i = i + 1
            end
        end
    end

    -- Dark piece.
    if piece[TYPE] == 1 then
        if z == 7 then
            validPositions[i] = {x, z-2}
            i = i + 1
        end

        if z > 1 then
            validPositions[i] = {x, z-1}
            i = i + 1
        end

        if x > 1 and z > 1 then
            if enemyOccupied({x-1, z-1}, piece[SIDE], board) then
                validPositions[i] = {x-1, z-1}
                i = i + 1
            end
        end

        if x < 8 and z > 1 then
            if enemyOccupied({x+1, z-1}, piece[SIDE], board) then
                validPositions[i] = {x+1, z-1}
                i = i + 1
            end
        end
    end

    return validPositions
end

function getValidPositionsRook(piece, board)
    print ("Getting positions for rook")
end

function getValidPositionsKnight(piece, board)
    print ("Getting positions for knight")
end

function getValidPositionsBishop(piece, board)
    print ("Getting positions for bishop")
end

function getValidPositionsQueen(piece, board)
    print ("Getting positions for queen")
end

function getValidPositionsKing(piece, board)
    print ("Getting positions for king")
end

-- Returns a formatted string of the input valid positions.
function validPositionsToString(positions)
    if type(positions) == 'table' then
        local s = '{'
        for k, v in pairs(positions) do
            if type(v) == 'table' then
                s = s..'('..v[1]..', '..v[2]..') : '
            else
                return "ERROR"
            end
        end
        return s .. '}'
    else
        return "ERROR"
    end
end

require "scenes/Chess/board"
