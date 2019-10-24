Rook = require "scenes/Chess/scripts/pieces/rook"
Pawn = require "scenes/Chess/scripts/pieces/pawn"
Knight = require "scenes/Chess/scripts/pieces/knight"
Bishop = require "scenes/Chess/scripts/pieces/bishop"
Queen = require "scenes/Chess/scripts/pieces/queen"
King = require "scenes/Chess/scripts/pieces/king"

function getPieces()
    local pieces = {}
    local piecesID = {}
    local colliderLayer = 0
    local index = 1

    -- Add light pawns.
    for i = 1, 8 do
        local lightPawn = Pawn:new()
        lightPawn.x = i
        lightPawn.y = 0
        lightPawn.z = 2
        lightPawn.team = "Light"
        local ID = lightPawn:addModel(colliderLayer)
        pieces[index] = lightPawn
        piecesID[ID] = index
        index = index + 1
    end

    -- Add dark pawns.
    for i = 1, 8 do
        local darkPawn = Pawn:new()
        darkPawn.x = i
        darkPawn.y = 0
        darkPawn.z = 7
        darkPawn.team = "Dark"
        local ID = darkPawn:addModel(colliderLayer)
        pieces[index] = darkPawn
        piecesID[ID] = index
        index = index + 1
    end

    -- Add light rooks.
    for i = 1, 2 do
        local xPos = 1
        if i == 2 then
            xPos = 8
        end

        local lightRook = Rook:new()
        lightRook.x = xPos
        lightRook.y = 0
        lightRook.z = 1
        lightRook.team = "Light"
        local ID = lightRook:addModel(colliderLayer)
        pieces[index] = lightRook
        piecesID[ID] = index
        index = index + 1
    end

    -- Add dark rooks.
    for i = 1, 2 do
        local xPos = 1
        if i == 2 then
            xPos = 8
        end

        local darkRook = Rook:new()
        darkRook.x = xPos
        darkRook.y = 0
        darkRook.z = 8
        darkRook.team = "Dark"
        local ID = darkRook:addModel(colliderLayer)
        piecesID[ID] = index
        pieces[index] = darkRook
        index = index + 1
    end

    -- Add light knights.
    for i = 1, 2 do
        local xPos = 2
        if i == 2 then
            xPos = 7
        end

        local lightKnight = Knight:new()
        lightKnight.x = xPos
        lightKnight.y = 0
        lightKnight.z = 1
        lightKnight.team = "Light"
        local ID = lightKnight:addModel(colliderLayer)
        piecesID[ID] = index
        pieces[index] = lightKnight
        index = index + 1
    end

    -- Add dark knights.
    for i = 1, 2 do
        local xPos = 2
        if i == 2 then
            xPos = 7
        end

        local darkKnight = Knight:new()
        darkKnight.x = xPos
        darkKnight.y = 0
        darkKnight.z = 8
        darkKnight.team = "Dark"
        local ID = darkKnight:addModel(colliderLayer)
        piecesID[ID] = index
        pieces[index] = darkKnight
        index = index + 1
    end

    -- Add light bishops.
    for i = 1, 2 do
        local xPos = 3
        if i == 2 then
            xPos = 6
        end

        local lightBishop = Bishop:new()
        lightBishop.x = xPos
        lightBishop.y = 0
        lightBishop.z = 1
        lightBishop.team = "Light"
        local ID = lightBishop:addModel(colliderLayer)
        piecesID[ID] = index
        pieces[index] = lightBishop
        index = index + 1
    end

    -- Add dark bishops.
    for i = 1, 2 do
        local xPos = 3
        if i == 2 then
            xPos = 6
        end

        local darkBishop = Bishop:new()
        darkBishop.x = xPos
        darkBishop.y = 0
        darkBishop.z = 8
        darkBishop.team = "Dark"
        local ID = darkBishop:addModel(colliderLayer)
        piecesID[ID] = index
        pieces[index] = darkBishop
        index = index + 1
    end

    -- Add light queen.
    local lightQueen = Queen:new()
    lightQueen.x = 5
    lightQueen.y = 0
    lightQueen.z = 1
    lightQueen.team = "Light"
    local ID = lightQueen:addModel(colliderLayer)
    piecesID[ID] = index
    pieces[index] = lightQueen
    index = index + 1

    -- Add dark queen.
    local darkQueen = Queen:new()
    darkQueen.x = 5
    darkQueen.y = 0
    darkQueen.z = 8
    darkQueen.team = "Dark"
    local ID = darkQueen:addModel(colliderLayer)
    piecesID[ID] = index
    pieces[index] = darkQueen
    index = index + 1

    -- Add light king.
    local lightKing = King:new()
    lightKing.x = 4
    lightKing.y = 0
    lightKing.z = 1
    lightKing.team = "Light"
    local ID = lightKing:addModel(colliderLayer)
    piecesID[ID] = index
    pieces[index] = lightKing
    index = index + 1

    -- Add dark king.
    local darkKing = King:new()
    darkKing.x = 4
    darkKing.y = 0
    darkKing.z = 8
    darkKing.team = "Dark"
    local ID = darkKing:addModel(colliderLayer)
    piecesID[ID] = index
    pieces[index] = darkKing
    index = index + 1

    return pieces, piecesID, colliderLayer
end

-- Helper variables
soundPlayedOn = nil

-- function highlightPiece(piece, dt)
--     if piece.y < 0.4 then
--         translateModel(piece.ID, 0, 3*dt, 0)
--         piece.y = piece.y + 3*dt
--     end
-- end

-- function unhighlight(pieces, curID, dt)
--     for i = 1, 32 do
--         if (not curID or pieces[i].ID ~= curID) and pieces[i].y > 0 then
--             translateModel(pieces[i].ID, 0, -3*dt, 0)
--             pieces[i].y = pieces[i].y - 3*dt
--         end
--         if pieces[i].y < 0 then
--             pieces[i].y = 0
--             pieces[i]:placeModel()
--         end
--     end
-- end

-- Function to animate a piece movement, returns true if the animation
-- is finished, false otherwise
-- function movePiece(piece, dest, xVel, zVel, dt)
--     local xFin = false
--     local zFin = false
--     if math.abs(piece.x - dest[1]) <= math.abs(xVel*dt) then
--         piece.x = dest[1]
--         piece:placeModel()
--         xFin = true
--     end
--     if math.abs(piece.z - dest[2]) <= math.abs(zVel*dt) then
--         piece.z = dest[2]
--         piece:placeModel()
--         zFin = true
--     end
--     if math.abs(piece.x - dest[1]) > math.abs(xVel*dt) and not xFin then
--         translateModel(piece.ID, xVel*dt, 0, 0)
--         piece.x = piece.x + xVel*dt
--     end
--     if math.abs(piece.z - dest[2]) > math.abs(zVel*dt) and not zFin then
--         translateModel(piece.ID, 0, 0, zVel*dt)
--         piece.z = piece.z + zVel*dt
--     end
--     return xFin and zFin
-- end
