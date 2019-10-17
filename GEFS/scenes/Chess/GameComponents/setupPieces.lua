Rook = require "scenes/Chess/GameComponents/Pieces/rook"
Pawn = require "scenes/Chess/GameComponents/Pieces/pawn"
Knight = require "scenes/Chess/GameComponents/Pieces/knight"
Bishop = require "scenes/Chess/GameComponents/Pieces/bishop"
Queen = require "scenes/Chess/GameComponents/Pieces/queen"
King = require "scenes/Chess/GameComponents/Pieces/king"

function getPieces()
    local pieces = {}
    local index = 1

    -- Add light pawns.
    for i = 1, 8 do
        local lightPawn = Pawn:new()
        lightPawn.x = i
        lightPawn.y = 0
        lightPawn.z = 2
        lightPawn.team = "Light"
        lightPawn:addModel()
        pieces[index] = lightPawn
        index = index + 1
    end

    -- Add dark pawns.
    for i = 1, 8 do
        local darkPawn = Pawn:new()
        darkPawn.x = i
        darkPawn.y = 0
        darkPawn.z = 7
        darkPawn.team = "Dark"
        darkPawn:addModel()
        pieces[index] = darkPawn
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
        lightRook:addModel()
        pieces[index] = lightRook
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
        darkRook:addModel()
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
        lightKnight:addModel()
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
        darkKnight:addModel()
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
        lightBishop:addModel()
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
        darkBishop:addModel()
        pieces[index] = darkBishop
        index = index + 1
    end

    -- Add light queen.
    local lightQueen = Queen:new()
    lightQueen.x = 5
    lightQueen.y = 0
    lightQueen.z = 1
    lightQueen.team = "Light"
    lightQueen:addModel()
    pieces[index] = lightQueen
    index = index + 1

    -- Add dark queen.
    local darkQueen = Queen:new()
    darkQueen.x = 5
    darkQueen.y = 0
    darkQueen.z = 8
    darkQueen.team = "Dark"
    darkQueen:addModel()
    pieces[index] = darkQueen
    index = index + 1

    -- Add light king.
    local lightKing = King:new()
    lightKing.x = 4
    lightKing.y = 0
    lightKing.z = 1
    lightKing.team = "Light"
    lightKing:addModel()
    pieces[index] = lightKing
    index = index + 1

    -- Add dark king.
    local darkKing = King:new()
    darkKing.x = 4
    darkKing.y = 0
    darkKing.z = 8
    darkKing.team = "Dark"
    darkKing:addModel()
    pieces[index] = darkKing
    index = index + 1

    return pieces
end
