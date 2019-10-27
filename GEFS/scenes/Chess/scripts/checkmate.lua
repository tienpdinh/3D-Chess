require "scenes/Chess/scripts/chess"
local utils = require "scenes/Chess/scripts/utils"

-- Check if a piece is safe, could be use for Check!
function isSafe(king)
  local attackers = {}
  local safe = true
  local count = 1
  local kingCoord = {king.x, king.z}
  for _, piece in pairs(pieces) do
    if piece.team ~= king.team then
      local moves = piece:getLegalMoves(pieces, board)
      if utils.containsMove(moves, kingCoord) then
        safe = false
        attackers[count] = piece
        count = count + 1
      end
    end
  end
  return safe, attackers
end

function simulate(piece, newX, newZ)
  local oldX = piece.x
  local oldZ = piece.z
  local oldIndex = board.chessboard[oldX][oldZ].pieceIndex
  local newIndex = board.chessboard[newX][newZ].pieceIndex
  local newPiece = pieces[newIndex]
  -- simulation starts here
  piece.x = newX
  piece.z = newZ
  board.chessboard[newX][newZ].pieceIndex = oldIndex
  board.chessboard[oldX][oldZ].pieceIndex = -1
  pieces[newIndex] = nil
  return oldX, oldZ, newIndex, newPiece
end

function restore(piece, oldX, oldZ, newIndex, newPiece)
  local newX = piece.x
  local newZ = piece.z
  local oldIndex = board.chessboard[newX][newZ].pieceIndex
  -- Restoration starts here
  piece.x = oldX
  piece.z = oldZ
  board.chessboard[oldX][oldZ].pieceIndex = oldIndex
  board.chessboard[newX][newZ].pieceIndex = newIndex
  pieces[newIndex] = newPiece
end

function checkmate(king)
  local kingMoves = king:getLegalMoves(pieces, board)
  for _, piece in pairs(pieces) do
    if piece.team == king.team then
      local pieceMoves = piece:getLegalMoves(pieces, board)
      for _, move in pairs(pieceMoves) do
        if utils.containsMove(kingMoves, move) then
          local oldX, oldZ, newIndex, newPiece = simulate(piece, move[1], move[2])
          if isSafe(king) then
            restore(piece, oldX, oldZ, newIndex, newPiece)
            return false
          end
          restore(piece, oldX, oldZ, newIndex, newPiece)
        end
      end
    end
  end
  return true
end

-- While in check, player has to escape check with these moves only
function escapeMoves()
end