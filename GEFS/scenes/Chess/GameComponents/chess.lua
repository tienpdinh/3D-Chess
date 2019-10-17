-- Setup the board.
Board = require "scenes/Chess/GameComponents/board"
board = Board:new()

-- Setup the pieces.
require "scenes/Chess/GameComponents/setupPieces"
pieces = getPieces()

-- Set the board indices to the pieces index.
for i = 1,32 do
    local x = pieces[i].x
    local z = pieces[i].z
    board.chessboard[x][z].pieceIndex = i
end







function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            -- s = s .. '['..k..'] = ' .. dump(v) .. ','
            s = s .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- DEBUG
-- moveablePieces = board:canMove(pieces, "Light")
-- for k,v in pairs(moveablePieces) do
--     print(pieces[v].x .. "," .. pieces[v].z)
-- end
--
-- board.chessboard[4][2].pieceIndex = -1
-- print(dump(pieces[29]:getLegalMoves(pieces, board)))
--
-- s = dump(pieces[1]:getLegalMoves(pieces, board))
-- print (s)
--
-- print(board:friendlyOccupied(1,1, pieces, "Light"))
-- print(board:enemyOccupied(8,8, pieces, "Dark"))
--
-- for z = 1, 8 do
--     s = ""
--     for x = 1, 8 do
--         s = s .. "\t" .. board.chessboard[x][z].pieceIndex
--     end
--     print(s)
-- end
