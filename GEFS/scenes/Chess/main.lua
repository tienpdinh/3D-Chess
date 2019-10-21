-- ///////// --
-- VARIABLES --
-- ///////// --

-- Setup the camera.
require "scenes/Chess/chessCamera"


cameraT = 0  -- 0 = dark turn, 1 = light turn
cameraTSpeed = 1

-- Interaction flags
leftClicked = false


-- General.
frameDt = 0

-- Setup the chess game
require "scenes/Chess/GameComponents/chess"

-- Motion Variables
selectedID = nil
hitID = nil
chosenTileID = nil
newDest = nil
pieceInMotion = nil
finished = true
xVel = 0
zVel = 0
xOld = 0
zOld = 0
--================--



-- Turn stuff.
turn = "Light"  -- Whose turn it is.
turnInProgress = false  -- Whether a turn is currently in progress.
playablePieces = nil  -- List of indices into the pieces array of all playable pieces for the current turn.
pieceToPlay = nil  -- The piece the user picked to play.
playableTiles = nil  -- List of positions {x, z} that the piece to play can move to.
tileToPlay = nil  -- The index {x, z} into the board of the tile to move to.

turnFlow = -1

-- Turn flow:
-- No turn in progress (-1)
-- animate available pieces (0)
-- pick piece from available pieces (1)
-- de-animate available pieces (2)
-- animate available tiles (3)
-- pick tile from available tiles (4)
-- de-animate available tiles (5)
-- move piece to tile (6)

highlightedPieces = {}
timer = 0.0

highlightedTiles = {}

-- /////// --
-- METHODS --
-- /////// --

cursorID = addModel("Cursor", 1, 0, 1)

-- Runs every frame.
function frameUpdate(dt)
    -- print (turnFlow)
    -- Waiting for turn to start.
    if turnFlow == -1 then
        -- Reset turn variables.
        timer = 0.0

        -- Get the list of pieces that can play for the given turn.
        playablePieces = board:canMove(pieces, turn)

        -- Load highlights into the highlightedPieces array.
        local j = 0
        for _, index in pairs(playablePieces) do
            highlightedPieces[j] = addModel("HighlightedTile")
            translateModel(highlightedPieces[j], pieces[index].x, 0, pieces[index].z)
            scaleModel(highlightedPieces[j], 0, 0, 0)
            j = j + 1
        end

        -- Move to the next state.
        turnFlow = 0

    -- GROW PIECES
    elseif turnFlow == 0 then

        for _, index in pairs(highlightedPieces) do
            setModelScale(index, timer, timer, timer)
        end
        timer = timer + dt
        if timer >= 1.0 then
            turnFlow = 1
        end

    -- GET PLAY PIECE
    elseif turnFlow == 1 then
        local hitID, dist = getMouseClickWithLayer(piecesColliderLayer)

        if hitID and leftClicked then
            -- Check if the selected piece was in the playablePieces list.
            local canPlaySelectedPiece = false
            for _, index in pairs(playablePieces) do
                if pieces[index].ID == hitID then
                    canPlaySelectedPiece = true
                end
            end

            if canPlaySelectedPiece then
                -- Save the picked piece.
                pieceToPlay = pieces[piecesID[hitID]]

                -- Get the list of positions the piece can play from.
                playableTiles = pieceToPlay:getLegalMoves(pieces, board)

                turnFlow = 2;
            end
        end

    -- SHRINK PIECES
    elseif turnFlow == 2 then
        -- Scale down each highlighted piece.
        for _, index in pairs(highlightedPieces) do
            setModelScale(index, timer, timer, timer)
        end

        -- Decrease the highlied pieces timer.
        timer = timer - dt

        -- Move to next state if timer is 0.
        if timer <= 0.0 then
            -- Delete each highlighted piece.
            for _, index in pairs(highlightedPieces) do
                deleteModel(index)
            end

            -- Add each highlighted tile.
            local j = 0
            for _, pos in pairs(playableTiles) do
                highlightedTiles[j] = addModel("HighlightedTile")
                translateModel(highlightedTiles[j], pos[1], 0, pos[2])
                scaleModel(highlightedTiles[j], 0, 0, 0)
                j = j + 1
            end
            turnFlow = 3
            timer = 0.0
        end

    -- GROW TILES
    elseif turnFlow == 3 then

        for _, index in pairs(highlightedTiles) do
            setModelScale(index, timer, timer, timer)
        end
        timer = timer + dt
        if timer >= 1.0 then
            turnFlow = 4
        end

    -- GET PLAY TILE
    elseif turnFlow == 4 then

        local hitID, dist = getMouseClickWithLayer(boardColliderLayer)

        if hitID and leftClicked then
            -- Check if the selected tile is in the playableTiles list.
            local canPlaySelectedTile = false
            for i, pos in pairs(playableTiles) do
                local tile = board.chessboard[pos[1]][pos[2]]
                if tile.id == hitID then
                    canPlaySelectedTile = true
                end
            end

            if canPlaySelectedTile then
                -- Save the picked tile
                tileToPlay = board.tileIDs[hitID]
                turnFlow = 5
            end
        end

    -- SHRINK TILES
    elseif turnFlow == 5 then
        -- Scale down each highlighted tile.
        for _, index in pairs(highlightedTiles) do
            setModelScale(index, timer, timer, timer)
        end

        -- Decrease the highlied pieces timer.
        timer = timer - dt

        -- Move to next state if timer is 0.
        if timer <= 0.0 then
            -- Delete each highlighted tile.
            for _, index in pairs(highlightedTiles) do
                deleteModel(index)
            end
            turnFlow = 6
            timer = 0.0
        end

    -- MOVE PIECE TO TILE
    elseif turnFlow == 6 then
        local startX = pieceToPlay.x
        local startZ = pieceToPlay.z
        local endX = tileToPlay.x
        local endZ = tileToPlay.z

        -- Get vector dir from start to end (end-start)
        local dirX =  (endX - startX) * timer
        local dirZ =  (endZ - startZ) * timer

        local y = 1.0 - (2*timer-1)*(2*timer-1)

        setModelTranslate(pieceToPlay.ID,  startX + dirX, y, startZ + dirZ)

        timer = timer + dt

        if (timer >= 1.0) then
            -- End turn.
            pieceToPlay.x = endX
            pieceToPlay.z = endZ

            board.chessboard[startX][startZ].pieceIndex = -1
            board.chessboard[endX][endZ].pieceIndex = piecesID[pieceToPlay.ID]

            if turn == "Light" then
                turn = "Dark"
            else
                turn = "Light"
            end

            turnFlow = -1
        end
    end

    -- Move Cursor
    local hitID, _ = getMouseClickWithLayer(boardColliderLayer)
    if hitID then
        local x = board.tileIDs[hitID].x
        local z = board.tileIDs[hitID].z

        resetModelTansform(cursorID)
        translateModel(cursorID, x, 0, z)
    end




    -- -- Highlight logic
    -- hitID, dist = getMouseClickWithLayer(piecesColliderLayer)
    -- if hitID then
    --     highlightPiece(pieces[piecesID[hitID]], dt)
    -- end
    -- unhighlight(pieces, hitID, dt)
    -- --===============--
    -- if newDest and pieceInMotion and not finished then
    --     finished = movePiece(pieceInMotion, newDest, xVel, zVel, dt)
    -- end
    -- if newDest and finished then
    --     local pieceIndex = board.chessboard[xOld][zOld].pieceIndex
    --     board.chessboard[xOld][zOld].pieceIndex = -1
    --     board.chessboard[newDest[1]][newDest[2]].pieceIndex = pieceIndex
    --     if turn == "Light" then
    --         turn = "Dark"
    --     else
    --         turn = "Light"
    --     end
    -- end

    -- if finished then
    --     newDest = nil
    --     pieceInMotion = nil
    --     selectedID = nil
    --     chosenTileID = nil
    -- end

    -- Update the frame DT.
    frameDt = dt

    -- Update the camera position.
    -- TODO: move this into turn logic.
    if (turn == "Light") then
        cameraT = cameraT + dt*cameraTSpeed
        cameraT = math.min(1, cameraT)
    else
        cameraT = cameraT - dt*cameraTSpeed
        cameraT = math.max(0, cameraT)
    end
    setCameraPos()
end


-- Called when a key event occurs.
function keyHandler(keys)

end

-- Called when the mouse moves.
function mouseHandler(mouse)
    -- local mousePressed = nil
    -- boardHitID, boardDist = getMouseClickWithLayer(boardColliderLayer)
    -- if mouse.left and not selectedID and not mousePressed then
    --     selectedID = hitID
    --     chosenTileID = nil
    --     finished = false
    -- end
    -- if mouse.left and not mousePressed then
    --     chosenTileID = boardHitID
    -- end
    -- -- Prepare for the move
    -- if selectedID and chosenTileID and mouse.left and not mousePressed then
    --     local moves, tot = pieces[piecesID[selectedID]]:getLegalMoves(pieces, board)
    --     for i = 1, tot do
    --         local tile = tileIDs[chosenTileID]
    --         if tile.x == moves[i][1] and tile.z == moves[i][2] then
    --             local xTile = tile.x
    --             local zTile = tile.z
    --             newDest = {xTile, zTile}
    --             pieceInMotion = pieces[piecesID[selectedID]]
    --             xOld = pieceInMotion.x
    --             zOld = pieceInMotion.z
    --             xVel = newDest[1] - xOld
    --             zVel = newDest[2] - zOld
    --             break
    --         end
    --     end
    -- end
    -- mousePressed = mouse.left
    leftClicked = mouse.left
end

function setCameraPos()
    local distanceFromCenter = 6
    CameraPosX = 4.5 + math.sin(cameraT*math.pi)*distanceFromCenter  -- 4.5 is board center x.
    CameraPosY = 6
    CameraPosZ = 4.5 + math.cos(cameraT*math.pi)*distanceFromCenter  -- 4.5 is board center z.


    local angle = -50
    CameraDirX = math.cos(angle*math.pi/180.0) * math.sin(-(1-cameraT)*math.pi)
    CameraDirY = math.sin(angle*math.pi/180.0)
    CameraDirZ = math.cos(angle*math.pi/180.0) * math.cos(-(1-cameraT)*math.pi)
end

function lerp(a, b, t)
    return (1-t)*a + t*b
end
