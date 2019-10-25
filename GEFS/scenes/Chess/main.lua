-- Chess in GEFS
-- Tien Dinh, Dan Shervheim

require "scenes/Chess/scripts/camera"  -- Sets up the camera.
require "scenes/Chess/scripts/chess"  -- Sets up the chess game.
require "scenes/Chess/scripts/digitalclock"  -- Sets up the player clocks.
utils = require "scenes/Chess/scripts/utils"
easing = require "scenes/Chess/scripts/easing"
Queen = require "scenes/Chess/scripts/pieces/queen"


-- How long it takes (s) for a highlights to dis/appear.
highlightDuration = 0.25

-- How long it takes (s) for a piece to move.
moveDuration = 0.75

-- How quickly the cursor follows the mouse.
cursorFollowSpeed = 7.5
cursorScaleSpeed = 15
cursorDefaultScale = 0.75
cursorScale = 0.75

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
-- 8 = Check for pawn evolution.
-- 9 = Check for endgame.
-- 10 = End turn.

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
gameOverYaw = 0

-- The clock.
clockIsRunning = false
clockHasRunOut = false

-- Pawn promotion
pawnPromotion = nil

-- Runs every frame.
function frameUpdate(dt)
    -- Check for endgame if the player is out of time.
    if turnState >= 0 and clockRunOut(turn) then
        turnState = 9
    end

    -- Update the game clock if the state is correct.
    if clockIsRunning then
        -- clock() will return true if one of the team hits 0 in their clock, false otherwise
        if turnState >= 2 and turnState <= 5 then
            clock(dt, turn, clicksound2)
        end
    end

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
        CheckForPawnEvolution(dt)
    elseif turnState == 9 then
        CheckForEndgame()
    elseif turnState == 10 then
        EndTurn()
    else
        print "ERROR invalid turn state."
    end

    -- Update the cursor.
    updateCursor(dt)

    -- Update the camera position and rotation based on the turn.
    updateCamera(dt, turn)
end

function GameOver(dt)
    -- Scale down all pieces and highlights.
    local s = 1-timer
    -- for _, piece in pairs(pieces) do
    --     scaleModel(piece.ID, s, s, s)
    -- end
    for _, highlight in pairs(pieceHighlights) do
        scaleModel(highlight, s, s, s)
    end
    for _, highlight in pairs(tileHighlights) do
        scaleModel(highlight, s, s, s)
    end

    -- Move the game over text down.
    resetModelTansform(gameOverID)
    rotateModel(gameOverID, 0.5*(gameOverYaw-0.5*math.pi), 1, 0, 0)  -- Rotate to face player.
    rotateModel(gameOverID, gameOverYaw, 0, 1, 0)
    translateModel(gameOverID, 4.5, utils.lerp(10, 0.1, easing.easeOutBounce(timer)), 4.5)

    -- Increment the timer.
    timer = timer + dt

    -- Delete the highlights if they are completely shrunk.
    if timer >= 1.0 then
        if #pieceHighlights > 0 then
            for _, ID in pairs(pieceHighlights) do
                deleteModel(ID)
            end
            pieceHighlights = {}
            playablePieces = {}
        end
        if #tileHighlights > 0 then
            for _, ID in pairs(tileHighlights) do
                deleteModel(ID)
            end
            tileHighlights = {}
            playableTiles = {}
        end
    end

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
        scaleModel(pieceHighlights[h], 0, 0, 0)
        translateModel(pieceHighlights[h], pieces[index].x, 0, pieces[index].z)
        h = h + 1
    end

    -- Go to the next state.
    turnState = turnState + 1
end

function CreatePieceHighlights(dt)
    -- Inflate the piece highlights to their proper scales.
    for _, id in pairs(pieceHighlights) do
    local s = timer
        setModelScale(id, s, s, s)
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

    -- Play a sound as the player hover over a piece
    if hitID == nil or hitID ~= soundPlayedOn then
        if hitID then soundPlayedOn = hitID end
        selectionPlaying = false
    end
    if hitID and not selectionPlaying then
        selectionPlaying = true
        playSoundEffect(selectionSound)
    end

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

            -- Clear playable pieces.
            playablePieces = {}

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
        local s = timer
        setModelScale(id, s, s, s)
    end

    -- Decrement the timer.
    timer = timer - dt/highlightDuration

    -- If the models are fully deflated then delete them,
    -- reset the timer, and move to the next state.
    if timer <= 0.0 then
        for _, id in pairs(pieceHighlights) do
            deleteModel(id)
        end

        pieceHighlights = {}

        timer = 0.0
        turnState = turnState + 1
    end
end

function CreateTileHighlights(dt)
    -- Inflate the tile highlights to their proper scales.
    for _, id in pairs(tileHighlights) do
        local s = timer
        setModelScale(id, s, s, s)
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

            -- Clear playable tiles.
            playableTiles = {}

            -- Move to the next state.
            turnState = turnState + 1
        end
    end
end

function DestroyTileHighlights(dt)
    -- Deflate the tile highlights to 0.
    for _, id in pairs(tileHighlights) do
        local s = timer
        setModelScale(id, s, s, s)
    end

    -- Decrement the timer.
    timer = timer - dt/highlightDuration

    -- If the models are fully deflated then delete them,
    -- reset the timer, and move to the next state.
    if timer <= 0.0 then
        for _, id in pairs(tileHighlights) do
            deleteModel(id)
        end

        tileHighlights = {}

        timer = 0.0
        turnState = turnState + 1
    end
end

function MovePieceToTile(dt)
    -- Start the clock after the first move.
    if not clockIsRunning then
        clockIsRunning = true
    end

    -- Reset the models transform.
    resetModelTansform(pieceToPlay.ID)

    -- Calculate the movement vector from the start and end points.
    local startX = pieceToPlay.x
    local startZ = pieceToPlay.z
    local endX = tileToPlay.x
    local endZ = tileToPlay.z
    local dirX = endX - startX
    local dirZ = endZ - startZ
    local dirMag = math.sqrt(dirX^2 + dirZ^2)

    -- Certain movements are "delayed". Define the delay here (in %/100)
    local movementDelay = 0.15
    local delayed = utils.delay(timer, movementDelay)
    local delayedInOut = utils.triangle(utils.delay(timer, movementDelay))

    -- Stretch the model in the movement direction and make it wobble up and down
    -- for a squash-and-stretch effect.
    local bounceStrength = 0  -- 0.25
    local bounceDirStrength = 0  -- 0.5

    bounceDirStrength = bounceDirStrength * delayedInOut  -- Fade in/out over move duration.
    local sx = 1 + (bounceStrength*math.sin(3*math.pi*timer)) + (bounceDirStrength*math.abs(dirX / dirMag))
    local sy = 1 - (bounceStrength*math.sin(3*math.pi*timer))
    local sz = 1 + (bounceStrength*math.sin(3*math.pi*timer)) + (bounceDirStrength*math.abs(dirZ / dirMag))
    scaleModel(pieceToPlay.ID, sx, sy, sz)

    -- Calculate the rotation angles for the move.
    local startAngle = pieceToPlay.angle
    local endAngle = utils.atan2(-dirX, -dirZ)

    -- Rotate the model back and forth perpendicular to the movement direction, and
    -- to face the movement direction.
    local angle = math.rad(12.5) * math.sin(math.pi * 2.0 * timer)
    rotateModel(pieceToPlay.ID, angle, dirZ/dirMag, 0, -dirX/dirMag)
    angle = utils.lerpAngle(startAngle, endAngle, easing.easeOutExpo(timer))
    rotateModel(pieceToPlay.ID, angle, 0, 1, 0)

    -- Translate the model across the board, and up and down.
    local x = startX + delayed*dirX
    local y = 1 - (1-delayedInOut)^1.5
    local z = startZ + delayed*dirZ
    translateModel(pieceToPlay.ID, x, y, z)

    -- Check if an enemy piece will be captured by moving to this new tile position.
    local pieceWasCaptured = board:enemyOccupied(endX, endZ, pieces, turn)

    -- Move the enemy piece off the board.
    if pieceWasCaptured then
        local capturedPiece = pieces[board.chessboard[endX][endZ].pieceIndex]
        resetModelTansform(capturedPiece.ID)
        rotateModel(capturedPiece.ID, capturedPiece.angle, 0, 1, 0)
        translateModel(capturedPiece.ID, endX, timer*10, endZ)
    end

    -- Increment the timer.
    timer = timer + dt/moveDuration

    -- End of turn.
    if timer >= 1.0 then
        -- Finalize the played piece transform.
        pieceToPlay.x = endX
        pieceToPlay.y = 0
        pieceToPlay.z = endZ
        pieceToPlay.angle = endAngle

        -- Reset the piece's transform to its correct position, scale, rotation.
        resetModelTansform(pieceToPlay.ID)
        scaleModel(pieceToPlay.ID, 1, 1, 1)
        rotateModel(pieceToPlay.ID, pieceToPlay.angle, 0, 1, 0)
        translateModel(pieceToPlay.ID, pieceToPlay.x, pieceToPlay.y, pieceToPlay.z)

        -- Delete the captured piece from the engine and the board.
        if pieceWasCaptured then
            local capturedPieceIndex = board.chessboard[endX][endZ].pieceIndex

            -- Remove the piece from the board.
            board.chessboard[endX][endZ].pieceIndex = -1

            -- Delete the model itself from the engine.
            deleteModel(pieces[capturedPieceIndex].ID)

            -- Delete the model from the pieces array.
            pieces[capturedPieceIndex] = nil
        end

        -- Update the chess board by swapping the pieceIndices of the tiles.
        board.chessboard[startX][startZ].pieceIndex = -1
        board.chessboard[endX][endZ].pieceIndex = piecesID[pieceToPlay.ID]

        -- Reset the timer.
        timer = 0.0

        turnState = turnState + 1
    end
end

function CheckForPawnEvolution(dt)
    local pawnHasCrossed = false
    if pieceToPlay.type == "Pawn" then
        if pieceToPlay.team == "Light" and pieceToPlay.z == 8 then
            pawnHasCrossed = true
        elseif pieceToPlay.team == "Dark" and pieceToPlay.z == 1 then
            pawnHasCrossed = true
        end
    end

    if pawnHasCrossed then
        if pawnPromotion == nil then
            local queen = Queen:new()
            queen.x = pieceToPlay.x
            queen.y = 0
            queen.z = pieceToPlay.z
            queen.team = pieceToPlay.team
            queen:addModel(piecesColliderLayer)
            scaleModel(queen.ID, 0, 0, 0)
            pawnPromotion = queen
        end

        -- Move the pawn up.
        resetModelTansform(pieceToPlay.ID)
        rotateModel(pieceToPlay.ID, pieceToPlay.angle, 0, 1, 0)
        translateModel(pieceToPlay.ID, pieceToPlay.x, timer*10, pieceToPlay.z)

        -- Scale in the queen.
        resetModelTansform(pawnPromotion.ID)
        scaleModel(pawnPromotion.ID, timer, timer, timer)
        rotateModel(pawnPromotion.ID, pawnPromotion.angle, 0, 1, 0)
        translateModel(pawnPromotion.ID, pawnPromotion.x, pawnPromotion.y, pawnPromotion.z)

        timer = timer + dt/moveDuration

        if timer >= 1.0 then
            -- Destroy the pawn.
            local pieceIndex = piecesID[pieceToPlay.ID]
            pieces[pieceIndex] = nil
            deleteModel(pieceToPlay.ID)
            board.chessboard[pieceToPlay.x][pieceToPlay.z].pieceIndex = -1
            piecesID[pieceToPlay.ID] = nil

            -- Replace the pawn with the pawn promotion.
            pieces[pieceIndex] = pawnPromotion
            board.chessboard[pawnPromotion.x][pawnPromotion.z].pieceIndex = pieceIndex
            piecesID[pawnPromotion.ID] = pieceIndex

            -- Set the pawn promotion to nil for next time.
            pieceToPlay = pawnPromotion
            pawnPromotion = nil

            turnState = turnState + 1
        end
    else
        turnState = turnState + 1
    end
end

function CheckForEndgame()
    local gameOverModel = nil
    local gameOver = false

    if board:gameOver(pieces) then
        gameOver = true
        gameOverModel = "YouWon"
    end

    if clockRunOut(turn) then
        gameOver = true
        gameOverModel = "TimesUp"
    end

    if gameOver then
        gameOverID = addModel(gameOverModel, 4.5, 10, 4.5)
        scaleModel(gameOverID, 0, 0, 0)
        if turn == "Light" then
            gameOverYaw = math.pi
            rotateModel(gameOverID, gameOverYaw, 0, 1, 0)
        end
        setModelMaterial(gameOverID, "Clock" .. turn)

        -- Reset the timer.
        timer = 0.0

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

    isSelecting = false

    if playablePieces ~= nil then
        for _, index in pairs(playablePieces) do
            if pieces[index].x == cursorTargetX and pieces[index].z == cursorTargetZ then
                isSelecting = true
            end
        end
    end

    if playableTiles ~= nil then
        for _, tile in pairs(playableTiles) do
            if tile[1] == cursorTargetX and tile[2] == cursorTargetZ then
                isSelecting = true
            end
        end
    end

    if isSelecting then
        cursorScale = utils.lerp(cursorScale, cursorDefaultScale, math.min(dt*cursorScaleSpeed, 1))
    else
        cursorScale = utils.lerp(cursorScale, 1, math.min(dt*cursorScaleSpeed, 1))
    end

    cursorX = utils.lerp(cursorX, cursorTargetX, math.min(dt*cursorFollowSpeed, 1))
    cursorZ = utils.lerp(cursorZ, cursorTargetZ, math.min(dt*cursorFollowSpeed, 1))

    resetModelTansform(cursorID)
    scaleModel(cursorID, cursorScale, 1, cursorScale)
    translateModel(cursorID, cursorX, 0, cursorZ)
end
