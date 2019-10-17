
-- Setup each chess piece.

ID = 1
POS = 2
TYPE = 3 -- 0=pawn, 1=rook, 2=knight, 3=bishop, 4=queen, 5=king
SIDE = 4 -- 0=dark, 1=light

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
    lightPawns[i] = {}
    lightPawns[i][ID] = addModel("PawnLight")
    lightPawns[i][POS] = {i,0,2}
    lightPawns[i][TYPE] = 0
    lightPawns[i][SIDE] = 1
    translateModel(lightPawns[i][ID], lightPawns[i][POS][1], lightPawns[i][POS][2], lightPawns[i][POS][3])
    rotateModel(lightPawns[i][ID], math.random()*math.pi*2.0, 0, 1, 0)

    darkPawns[i] = {}
    darkPawns[i][ID] = addModel("PawnDark")
    darkPawns[i][POS] = {i, 0, 7}
    darkPawns[i][TYPE] = 0
    darkPawns[i][SIDE] = 0
    translateModel(darkPawns[i][ID], darkPawns[i][POS][1], darkPawns[i][POS][2], darkPawns[i][POS][3])
    rotateModel(darkPawns[i][ID], math.random()*math.pi*2.0, 0, 1, 0)
end

-- Setup Rooks.
for i = 1, 2 do
    local xPos = 1
    if i == 2 then
        xPos = 8
    end

    lightRooks[i] = {}
    lightRooks[i][ID] = addModel("RookLight")
    lightRooks[i][POS] = {xPos, 0, 1}
    lightRooks[i][TYPE] = 1
    lightRooks[i][SIDE] = 1
    translateModel(lightRooks[i][ID], lightRooks[i][POS][1], lightRooks[i][POS][2], lightRooks[i][POS][3])

    darkRooks[i] = {}
    darkRooks[i][ID] = addModel("RookDark")
    darkRooks[i][POS] = {xPos, 0, 8}
    darkRooks[i][TYPE] = 1
    darkRooks[i][SIDE] = 0
    translateModel(darkRooks[i][ID], darkRooks[i][POS][1], darkRooks[i][POS][2], darkRooks[i][POS][3])
end

-- Setup Knights.
for i = 1, 2 do
    local xPos = 2
    if i == 2 then
        xPos = 7
    end

    lightKnights[i] = {}
    lightKnights[i][ID] = addModel("KnightLight")
    lightKnights[i][POS] = {xPos, 0, 1}
    lightKnights[i][TYPE] = 2
    lightKnights[i][SIDE] = 1
    translateModel(lightKnights[i][ID], lightKnights[i][POS][1], lightKnights[i][POS][2], lightKnights[i][POS][3])
    rotateModel(lightKnights[i][ID], math.pi, 0, 1, 0)

    darkKnights[i] = {}
    darkKnights[i][ID] = addModel("KnightDark")
    darkKnights[i][POS] = {xPos, 0, 8}
    darkKnights[i][TYPE] = 2
    darkKnights[i][SIDE] = 0
    translateModel(darkKnights[i][ID], darkKnights[i][POS][1], darkKnights[i][POS][2], darkKnights[i][POS][3])
    -- rotateModel(darkKnights[i][ID], 0.0, 0, 1, 0)
end

-- Setup Bishops.
for i = 1, 2 do
    local xPos = 3
    if i == 2 then
        xPos = 6
    end

    lightBishops[i] = {}
    lightBishops[i][ID] = addModel("BishopLight")
    lightBishops[i][POS] = {xPos, 0, 1}
    lightBishops[i][TYPE] = 3
    lightBishops[i][SIDE] = 1
    translateModel(lightBishops[i][ID], lightBishops[i][POS][1], lightBishops[i][POS][2], lightBishops[i][POS][3])
    rotateModel(lightBishops[i][ID], math.pi, 0, 1, 0)

    darkBishops[i] = {}
    darkBishops[i][ID] = addModel("BishopDark")
    darkBishops[i][POS] = {xPos, 0, 8}
    darkBishops[i][TYPE] = 3
    darkBishops[i][SIDE] = 0
    translateModel(darkBishops[i][ID], darkBishops[i][POS][1], darkBishops[i][POS][2], darkBishops[i][POS][3])
    -- rotateModel(darkBishops[i][ID], 0.0, 0, 1, 0)
end

-- Setup Queens.
lightQueen = {}
lightQueen[ID] = addModel("QueenLight")
lightQueen[POS] = {5, 0, 1}
lightQueen[TYPE] = 4
lightQueen[SIDE] = 1
translateModel(lightQueen[ID], lightQueen[POS][1], lightQueen[POS][2], lightQueen[POS][3])
rotateModel(lightQueen[ID], math.pi, 0, 1, 0)

darkQueen = {}
darkQueen[ID] = addModel("QueenDark")
darkQueen[POS] = {5, 0, 8}
darkQueen[TYPE] = 4
darkQueen[SIDE] = 0
translateModel(darkQueen[ID], darkQueen[POS][1], darkQueen[POS][2], darkQueen[POS][3])
-- rotateModel(darkQueen[ID], 0.0, 0, 1, 0)


-- Setup Kings.
lightKing = {}
lightKing[ID] = addModel("KingLight")
lightKing[POS] = {4, 0, 1}
lightKing[TYPE] = 5
lightKing[SIDE] = 1
translateModel(lightKing[ID], lightKing[POS][1], lightKing[POS][2], lightKing[POS][3])
rotateModel(lightKing[ID], math.pi, 0, 1, 0)

darkKing = {}
darkKing[ID] = addModel("KingDark")
darkKing[POS] = {4, 0, 8}
darkKing[TYPE] = 5
darkKing[SIDE] = 0
translateModel(darkKing[ID], darkKing[POS][1], darkKing[POS][2], darkKing[POS][3])
-- rotateModel(darkKing[ID], 0.0, 0, 1, 0)
