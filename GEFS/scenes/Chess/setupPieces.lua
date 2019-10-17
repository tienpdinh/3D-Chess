
-- Setup each chess piece.
-- TODO: apply edge split modifier in blender before exporting to get rid of the smoothed look.

-- Set up game board
Board = require "scenes/Chess/GameComponents/board"
local board = Board:new()
board:fill(1)
board:drawboard()

ID = 1
POS = 2
TYPE = 3  -- (pawn = 0, rook = 1, knight = 2, bishop = 3, queen = 4, king = 5)

Rook = require "scenes/Chess/GameComponents/rook"
Pawn = require "scenes/Chess/GameComponents/pawn"
Knight = require "scenes/Chess/GameComponents/knight"
Bishop = require "scenes/Chess/GameComponents/bishop"
Queen = require "scenes/Chess/GameComponents/queen"
King = require "scenes/Chess/GameComponents/king"

lightPawns = {}
lightRooks = {}
lightKnights = {}
lightBishops = {}
lightQueen = -1
lightKing = -1

darkPawns = {}
darkRooks = {}
darkKnights = {}
darkBishops = {}
darkQueen = -1
darkKing = -1

-- Setup Pawns.
for i = 1, 8 do
  lightPawns[i] = Pawn:new()
  lightPawns[i].x = board.chessboard[2][i].x
  lightPawns[i].y = board.chessboard[2][i].y
  lightPawns[i].z = board.chessboard[2][i].z
  lightPawns[i].team = "Light"
  lightPawns[i]:drawpiece()
  board.chessboard[2][i].type = lightPawns[i]

  darkPawns[i] = Pawn:new()
  darkPawns[i].x = board.chessboard[7][i].x
  darkPawns[i].y = board.chessboard[7][i].y
  darkPawns[i].z = board.chessboard[7][i].z
  darkPawns[i].team = "Dark"
  darkPawns[i]:drawpiece()
  board.chessboard[2][i].type = darkPawns[i]
end

-- Setup Rooks.
for i = 1, 2 do
  local zPos = 1
  if i == 2 then
    zPos = 8
  end
  lightRooks[i] = Rook:new ()
  lightRooks[i].x = board.chessboard[1][zPos].x
  lightRooks[i].y = board.chessboard[1][zPos].y
  lightRooks[i].z = board.chessboard[1][zPos].z
  lightRooks[i].team = "Light"
  lightRooks[i]:drawpiece ()
  board.chessboard[1][zPos].type = lightRooks[i]

  darkRooks[i] = Rook:new ()
  darkRooks[i].x = board.chessboard[8][zPos].x
  darkRooks[i].y = board.chessboard[8][zPos].y
  darkRooks[i].z = board.chessboard[8][zPos].z
  darkRooks[i].team = "Dark"
  darkRooks[i]:drawpiece ()
  board.chessboard[8][zPos].type = darkRooks[i]
end

-- Setup Knights.
for i = 1, 2 do
  local zPos = 2
  if i == 2 then
    zPos = 7
  end

  lightKnights[i] = Knight:new ()
  lightKnights[i].x = board.chessboard[1][zPos].x
  lightKnights[i].y = board.chessboard[1][zPos].y
  lightKnights[i].z = board.chessboard[1][zPos].z
  lightKnights[i].team = "Light"
  lightKnights[i]:drawpiece ()
  board.chessboard[1][zPos].type = lightKnights[i]

  darkKnights[i] = Knight:new ()
  darkKnights[i].x = board.chessboard[8][zPos].x
  darkKnights[i].y = board.chessboard[8][zPos].y
  darkKnights[i].z = board.chessboard[8][zPos].z
  darkKnights[i].team = "Dark"
  darkKnights[i]:drawpiece ()
  board.chessboard[8][zPos].type = darkKnights[i]
end

-- Setup Bishops.
for i = 1, 2 do
    local zPos = 3
    if i == 2 then
        zPos = 6
    end

    lightBishops[i] = Bishop:new ()
    lightBishops[i].x = board.chessboard[1][zPos].x
    lightBishops[i].y = board.chessboard[1][zPos].y
    lightBishops[i].z = board.chessboard[1][zPos].z
    lightBishops[i].team = "Light"
    lightBishops[i]:drawpiece ()
    board.chessboard[1][zPos].type = lightBishops[i]

    darkBishops[i] = Bishop:new ()
    darkBishops[i].x = board.chessboard[8][zPos].x
    darkBishops[i].y = board.chessboard[8][zPos].y
    darkBishops[i].z = board.chessboard[8][zPos].z
    darkBishops[i].team = "Dark"
    darkBishops[i]:drawpiece ()
    board.chessboard[8][zPos].type = darkBishops[i]
end

-- Setup Queens.
lightQueen = Queen:new ()
lightQueen.x = board.chessboard[1][5].x
lightQueen.y = board.chessboard[1][5].y
lightQueen.z = board.chessboard[1][5].z
lightQueen.team = "Light"
lightQueen:drawpiece ()
board.chessboard[1][5].type = lightQueen

darkQueen = Queen:new ()
darkQueen.x = board.chessboard[8][5].x
darkQueen.y = board.chessboard[8][5].y
darkQueen.z = board.chessboard[8][5].z
darkQueen.team = "Dark"
darkQueen:drawpiece ()
board.chessboard[8][5].type = darkQueen

-- Setup Kings.
lightKing = King:new ()
lightKing.x = board.chessboard[1][4].x
lightKing.y = board.chessboard[1][4].y
lightKing.z = board.chessboard[1][4].z
lightKing.team = "Light"
lightKing:drawpiece ()
board.chessboard[1][4].type = lightKing

darkKing = King:new ()
darkKing.x = board.chessboard[8][4].x
darkKing.y = board.chessboard[8][4].y
darkKing.z = board.chessboard[8][4].z
darkKing.team = "Dark"
darkKing:drawpiece ()
board.chessboard[8][4].type = darkKing
