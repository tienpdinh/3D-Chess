require "scenes/Chess/scripts/chess"
local utils = require "scenes/Chess/scripts/utils"

-- Check if a king is safe, could be use for Check!
function isSafe(king)
  local kingCoord = {king.x, king.z}
  for _, piece in pairs(pieces) do
    if piece.team ~= king.team then
      local moves = piece:getLegalMoves(pieces, board)
      if utils.containsMove(moves, kingCoord) then
        return false
      end
    end
  end
  return true
end

function simulate(piece, newX, newZ)
  local oldX = piece.x
  local oldZ = piece.z
  local oldIndex = board.chessboard[oldX][oldZ].pieceIndex
  -- simulation starts here
  piece.x = newX
  piece.z = newZ
  board.chessboard[newX][newZ].pieceIndex = oldIndex
  board.chessboard[oldX][oldZ].pieceIndex = -1
  return oldX, oldZ
end

function restore(piece, oldX, oldZ)
  local newX = piece.x
  local newZ = piece.z
  local newIndex = board.chessboard[newX][newZ].pieceIndex
  -- Restoration starts here
  piece.x = oldX
  piece.z = oldZ
  board.chessboard[oldX][oldZ].pieceIndex = newIndex
  board.chessboard[newX][newZ].pieceIndex = -1
end

function checkmate(king)
  local kingMoves = king:getLegalMoves(pieces, board)
  for _, piece in pairs(pieces) do
    if piece.team == king.team then
      local pieceMoves = piece:getLegalMoves(pieces, board)
      for _, move in pairs(pieceMoves) do
        if utils.containsMove(kingMoves, move) then
          local oldX, oldZ = simulate(piece, move[1], move[2])
          if isSafe(king) then
            restore(piece, oldX, oldZ)
            return false
          end
          restore(piece, oldX, oldZ)
        end
      end
    end
  end
  return true
end