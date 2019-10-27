-- Setup the board.
Board = require "scenes/Chess/scripts/board"
board, boardColliderLayer = Board:new()

-- Setup the pieces.
require "scenes/Chess/scripts/setup"
pieces, piecesID, piecesColliderLayer, lightKingIndex, darkKingIndex = getPieces()

-- Set the board indices to the pieces index.
for i = 1,#pieces do
    local x = pieces[i].x
    local z = pieces[i].z
    board.chessboard[x][z].pieceIndex = i
end

-- Load and play the background music (loop infinitely)
-- https://soundimage.org/fantasy-2/
local bgmusic = loadAudio("scenes/Chess/sounds/background.wav")
playSong(bgmusic)

-- Load selection sound
-- https://www.fesliyanstudios.com/royalty-free-sound-effects-download/video-game-menu-153
selectionSound = loadAudio("scenes/Chess/sounds/selection.wav")

-- http://soundbible.com/783-Click.html
clickSound1 = loadAudio("scenes/Chess/sounds/click.wav")
clicksound2 = loadAudio("scenes/Chess/sounds/tick.wav")

-- landing sound
landingSound = loadAudio("scenes/Chess/sounds/landing.wav")
