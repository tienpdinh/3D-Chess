-- Chess in GEFS
-- Tien Dinh, Dan Shervheim

require "scenes/Chess/utils"
require "scenes/Chess/camera"  -- Sets up the camera.
require "scenes/Chess/GameComponents/chess"  -- Sets up the chess game.
require "scenes/Chess/GameComponents/digitalclock"

-- How long it takes (s) for a highlights to dis/appear.
highlightDuration = 0.25

-- How long it takes (s) for a piece to move.
moveDuration = 1.0

-- How quickly the cursor follows the mouse.
cursorFollowSpeed = 7.5

-- Whether the left mouse button is clicked or not.
leftClicked = false

 -- Whose turn it is.
turn = "Light"

 -- What part of the turn we are on.
turnState = 0
-- -1 = Game over.
-- 0 = Start turn.
-- 1 = Creating piece highlights.
-- 2 = Picking playable piece.
-- 3 = Destroying piece highlights.
-- 4 = Creating tile highlights.
-- 5 = Picking playable tile.
-- 6 = Destroying tile highlights.
-- 7 = Moving playable piece to playable tile.
-- 8 = Check for endgame.
-- 9 = End turn.

-- Which pieces can be played for the given turn.
-- (List of indices into the pieces array).
playablePieces = nil

-- The piece the user chooses to play for the current turn.
pieceToPlay = nil

-- List holding the model ID of the playable piece highlights.
pieceHighlights = {}

 -- Which tiles the pieceToPlay can move to.
 -- (List of positions {x, z}).
playableTiles = nil

-- Which tile the user chooses to move to for the current turn.
tileToPlay = nil

-- List holding the model ID of the playable tile highlights.
tileHighlights = {}

-- Timer to lerp between different values during a given turn.
timer = 0.0

-- The cursor mesh.
cursorID = addModel("Cursor", 1, 0, 1)
cursorX = 1
cursorZ = 1
cursorTargetX = 1
cursorTargetZ = 1

-- The game over mesh.
gameOverID = -1
clockStart = false
-- Runs every frame.
function frameUpdate(dt)
    -- Run the correct method depending on which part
    -- of the turn we are in.
    if turnState == -1 then
        GameOver(dt)
    elseif turnState == 0 then
        StartTurn()
    elseif turnState == 1 then
        CreatePieceHighlights(dt)
    elseif turnState == 2 then
        GetPieceToPlay()
    elseif turnState == 3 then
        DestroyPieceHighlights(dt)
    elseif turnState == 4 then
        CreateTileHighlights(dt)
    elseif turnState == 5 then
        GetTileToPlay()
    elseif turnState == 6 then
        DestroyTileHighlights(dt)
    elseif turnState == 7 then
        MovePieceToTile(dt)
    elseif turnState == 8 then
        CheckForEndgame()
    elseif turnState == 9 then
        EndTurn()
    else
        print "ERROR invalid turn state."
    end

    if clockStart then
        -- clock() will return true if one of the team hits 0 in their clock, false otherwise
        endgame = clock(dt, turn)
    end

    -- Update the cursor.
    updateCursor(dt)

    -- Update the camera position and rotation based on the turn.
    updateCamera(dt, turn)
end

function GameOver(dt)
    -- Move all the pieces off the board.
    for _, piece in pairs(pieces) do
        local dirX = piece.x - 4.5
        local dirZ = piece.z - 4.5

        -- Normalize.
        local mag = math.sqrt(dirX*dirX + dirZ*dirZ)
        dirX = dirX / mag
        dirZ = dirZ / mag

        -- Set magnitude to 10.
        dirX = dirX * 10
        dirZ = dirZ * 10

        -- Move piece away from center.
        setModelTranslate(piece.ID, piece.x + dirX*timer, 0, piece.z + dirZ*timer)
    end

    -- Move the game over text down.
    setModelTranslate(gameOverID, 4.5, lerp(10, 0.1, timer), 4.5)

    -- Increment the timer.
    timer = timer + dt/moveDuration
    timer = math.min(timer, 1.0)
end

function StartTurn()
    -- Reset the turn variables.
    timer = 0.0
    pieceToPlay = nil
    tileToPlay = nil

    -- Get the list of pieces that we can play this turn.
    playablePieces = board:canMove(pieces, turn)

    -- Load the highlighted pieces and scale them to 0.
    local h = 1
    for _, index in pairs(playablePieces) do
        pieceHighlights[h] = addModel("HighlightedTile")
        translateModel(pieceHighlights[h], pieces[index].x, 0, pieces[index].z)
        scaleModel(pieceHighlights[h], 0, 0, 0)
        h = h + 1
    end

    -- Go to the next state.
    turnState = turnState + 1
end

function CreatePieceHighlights(dt)
    -- Inflate the piece highlights to their proper scales.
    for _, id in pairs(pieceHighlights) do
        setModelScale(id, timer, timer, timer)
    end

    -- Increment the timer.
    timer = timer + dt/highlightDuration

    -- If the models are fully inflated, then reset the timer
    -- and move to the next state.
    if timer >= 1.0 then
        timer = 1.0
        turnState = turnState + 1
    end
end

function GetPieceToPlay()
    -- Get the piece currently under the mouse.
    local hitID, _ = getMouseClickWithLayer(piecesColliderLayer)

    -- If the mouse is over a piece and left clicking...
    if (hitID and leftClicked) then
        -- Check if the piece is a valid piece to play.
        local canPlaySelectedPiece = false
        for _, index in pairs(playablePieces) do
            if pieces[index].ID == hitID then
                canPlaySelectedPiece = true
            end
        end

        if canPlaySelectedPiece then
            -- Save the selected piece.
            pieceToPlay = pieces[piecesID[hitID]]

            -- Get the list of tiles the piece can move to.
            playableTiles = pieceToPlay:getLegalMoves(pieces, board)

            -- Load the highlighted tiles and scale them to 0.
            local h = 1
            for _, pos in pairs(playableTiles) do
                tileHighlights[h] = addModel("HighlightedTile")
                translateModel(tileHighlights[h], pos[1], 0, pos[2])
                scaleModel(tileHighlights[h], 0, 0, 0)
                h = h + 1
            end

            -- Move to the next state.
            turnState = turnState + 1
        end
    end
end

function DestroyPieceHighlights(dt)
    -- Deflate the piece highlights to 0.
    for _, id in pairs(pieceHighlights) do
        setModelScale(id, timer, timer, timer)
    end

    -- Decrement the timer.
    timer = timer - dt/highlightDuration

    -- If the models are fully deflated then delete them,
    -- reset the timer, and move to the next state.
    if timer <= 0.0 then
        for _, id in pairs(pieceHighlights) do
            deleteModel(id)
        end

        timer = 0.0
        turnState = turnState + 1
    end
end

function CreateTileHighlights(dt)
    -- Inflate the tile highlights to their proper scales.
    for _, id in pairs(tileHighlights) do
        setModelScale(id, timer, timer, timer)
    end

    -- Increment the timer.
    timer = timer + dt/highlightDuration

    -- If the models are fully inflated, then reset the timer
    -- and move to the next state.
    if timer >= 1.0 then
        timer = 1.0
        turnState = turnState + 1
    end
end

function GetTileToPlay()
    -- Get the piece currently under the mouse.
    local hitID, _ = getMouseClickWithLayer(boardColliderLayer)

    -- If the mouse is over a tile and left clicking...
    if (hitID and leftClicked) then
        -- Check if the tile is a valid tile to play.
        local canPlaySelectedTile = false
        for _, pos in pairs(playableTiles) do
            local tile = board.chessboard[pos[1]][pos[2]]
            if tile.id == hitID then
                canPlaySelectedTile = true
            end
        end

        if canPlaySelectedTile then
            -- Save the selected piece.
            tileToPlay = board.tileIDs[hitID]

            -- Move to the next state.
            turnState = turnState + 1
        end
    end
end

function DestroyTileHighlights(dt)
    -- Deflate the tile highlights to 0.
    for _, id in pairs(tileHighlights) do
        setModelScale(id, timer, timer, timer)
    end

    -- Decrement the timer.
    timer = timer - dt/highlightDuration

    -- If the models are fully deflated then delete them,
    -- reset the timer, and move to the next state.
    if timer <= 0.0 then
        for _, id in pairs(tileHighlights) do
            deleteModel(id)
        end

        timer = 0.0
        turnState = turnState + 1
    end
end

function MovePieceToTile(dt)
    local startX = pieceToPlay.x
    local startZ = pieceToPlay.z
    local endX = tileToPlay.x
    local endZ = tileToPlay.z

    -- Get direction from start to end.
    local dirX =  (endX - startX) * timer
    local dirZ =  (endZ - startZ) * timer

    -- Make the piece "jump" during its move.
    local jump = 1.0 - (2*timer-1)*(2*timer-1)

    -- Move the model.
    setModelTranslate(pieceToPlay.ID, startX + dirX, jump, startZ + dirZ)

    -- Check if an enemy piece will be captured by moving to this new tile position.
    local pieceWasCaptured = board:enemyOccupied(endX, endZ, pieces, turn)

    -- Move the enemy piece off the board.
    if pieceWasCaptured then
        local capturedID = pieces[board.chessboard[endX][endZ].pieceIndex].ID
        setModelTranslate(capturedID, endX, timer*10, endZ)
    end

    -- Increment the timer.
    timer = timer + dt/moveDuration

    -- End of turn.
    if timer >= 1.0 then
        -- Finalize the played piece position.
        pieceToPlay.x = endX;
        pieceToPlay.z = endZ;
        setModelTranslate(pieceToPlay.ID, endX, 0, endZ)

        -- Delete the captured piece from the engine and the board.
        if pieceWasCaptured then
            deleteModel(pieces[board.chessboard[endX][endZ].pieceIndex].ID)
            pieces[board.chessboard[endX][endZ].pieceIndex] = nil
            board.chessboard[endX][endZ].pieceIndex = -1
        end

        -- Update the chess board.
        board.chessboard[startX][startZ].pieceIndex = -1
        board.chessboard[endX][endZ].pieceIndex = piecesID[pieceToPlay.ID]

        turnState = turnState + 1
    end
end

function CheckForEndgame()
    if board:gameOver(pieces) then
        -- Reset the timer.
        timer = 0.0

        -- Instantiate the game over mesh.
        gameOverID = addModel("GameOver", 4.5, 10, 4.5)
        if turn == "Light" then
            rotateModel(gameOverID, math.pi, 0, 1, 0)
        end
        rotateModel(gameOverID, -math.pi/2.0, 1, 0, 0)

        -- Set the turn state to game over.
        turnState = -1
    else
        turnState = turnState + 1
    end
end

function EndTurn()
    -- Swap turns.
    if turn == "Light" then
        turn = "Dark"
    elseif turn == "Dark" then
        turn = "Light"
    else
        print "ERROR in EndTurn(). Invalid current turn."
    end

    -- Reset turn state.
    turnState = 0
end

-- Called when a key event occurs.
function keyHandler(keys)
    -- Do nothing.
    if keys.space then clockStart=true end
end

-- Called when the mouse moves.
function mouseHandler(mouse)
    -- Save whether the left click button is clicked.
    leftClicked = mouse.left
end

function updateCursor(dt)
    local hitID, _ = getMouseClickWithLayer(boardColliderLayer)

    if hitID then
        cursorTargetX = board.tileIDs[hitID].x
        cursorTargetZ = board.tileIDs[hitID].z
    end

    cursorX = lerp(cursorX, cursorTargetX, math.min(dt*cursorFollowSpeed, 1))
    cursorZ = lerp(cursorZ, cursorTargetZ, math.min(dt*cursorFollowSpeed, 1))

    resetModelTansform(cursorID)
    translateModel(cursorID, cursorX, 0, cursorZ)
end
