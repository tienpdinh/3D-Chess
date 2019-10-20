-- ///////// --
-- VARIABLES --
-- ///////// --

-- Setup the camera.
require "scenes/Chess/cameraSetup"
CameraTheta = math.pi/2.0

cameraT = 0  -- 0 = dark turn, 1 = light turn
cameraTSpeed = 1

-- Interaction flags
spacePressed = false
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
turn = "Light"
turnInProgress = false
playablePieces = nil
pieceToPlay = nil
piecePicked = false
playableTiles = nil
tileToPlay = nil
tilePicked = false


-- /////// --
-- METHODS --
-- /////// --

-- Runs every frame.
function frameUpdate(dt)
    if not turnInProgress then
        turnInProgress = true
        -- Setup turn.

        -- Get the pieces that can move this turn.
        playablePieces = board:canMove(pieces, turn)
        -- Highlight them all.
        for i, index in pairs(playablePieces) do
            setModelMaterial(pieces[index].ID, "Highlight")
        end
        -- Set the flags for the turn.
        pieceToPlay = nil
        piecePicked = false
        tileToPlay = nil
        tilePicked = false
    else
        -- Advance turn.
        if not piecePicked then
            -- Pick the piece to play.
            local hitID, dist = getMouseClickWithLayer(piecesColliderLayer)
            if hitID and leftClicked then
                -- Save the picked piece.
                piecePicked = true
                pieceToPlay = pieces[piecesID[hitID]]

                -- Unhighlight all the playable pieces.
                for i, index in pairs(playablePieces) do
                    setModelMaterial(pieces[index].ID, "ChessPiece"..turn)
                end

                -- Get all the playable tiles.
                playableTiles = pieceToPlay:getLegalMoves(pieces, board)

                -- Highlight them all.
                for i, pos in pairs(playableTiles) do
                    setModelMaterial(board.chessboard[pos[1]][pos[2]].id, "Highlight")
                end
                -- leftClicked = false
            end
        elseif not tilePicked then
            -- Pick the tile to play.
            local hitID, dist = getMouseClickWithLayer(boardColliderLayer)
            print "picking tile"
            if hitID and leftClicked then
                -- Save the picked tile
                print "PICKED tile"
                tilePicked = true
                tileToPlay = board.tileIDs[hitID]
                print(hitID)

                -- Unhighlight all playable tiles.
                for i, pos in pairs(playableTiles) do
                    local tile = board.chessboard[pos[1]][pos[2]]
                    setModelMaterial(tile.id, "TileMarble"..tile.color)
                end
            end
        else
            -- Animate piece moving to tile.
            -- print "animating tile"
        end
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
    if keys.space then
        if not spacePressed then
            spacePressed = true
            if turn == "Light" then
                turn = "Dark"
            else
                turn = "Light"
            end
        end
    else
        spacePressed = false
    end
end

-- Called when the mouse moves.
function mouseHandler(mouse)
    local mousePressed = nil
    boardHitID, boardDist = getMouseClickWithLayer(boardColliderLayer)
    if mouse.left and not selectedID and not mousePressed then
        selectedID = hitID
        chosenTileID = nil
        finished = false
    end
    if mouse.left and not mousePressed then
        chosenTileID = boardHitID
    end
    -- Prepare for the move
    if selectedID and chosenTileID and mouse.left and not mousePressed then
        local moves, tot = pieces[piecesID[selectedID]]:getLegalMoves(pieces, board)
        for i = 1, tot do
            local tile = tileIDs[chosenTileID]
            if tile.x == moves[i][1] and tile.z == moves[i][2] then
                local xTile = tile.x
                local zTile = tile.z
                newDest = {xTile, zTile}
                pieceInMotion = pieces[piecesID[selectedID]]
                xOld = pieceInMotion.x
                zOld = pieceInMotion.z
                xVel = newDest[1] - xOld
                zVel = newDest[2] - zOld
                break
            end
        end
    end
    mousePressed = mouse.left
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
