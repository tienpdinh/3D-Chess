
-- Setup each chess piece.
-- TODO: apply edge split modifier in blender before exporting to get rid of the smoothed look.

ID = 1
POS = 2
TYPE = 3  -- (pawn = 0, rook = 1, knight = 2, bishop = 3, queen = 4, king = 5)

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
    lightPawns[i][POS] = {2,0,i}
    lightPawns[i][TYPE] = 0
    translateModel(lightPawns[i][ID], lightPawns[i][POS][1], lightPawns[i][POS][2], lightPawns[i][POS][3])
    rotateModel(lightPawns[i][ID], math.random()*math.pi*2.0, 0, 1, 0)

    darkPawns[i] = {}
    darkPawns[i][ID] = addModel("PawnDark")
    darkPawns[i][POS] = {7, 0, i}
    lightPawns[i][TYPE] = 0
    translateModel(darkPawns[i][ID], darkPawns[i][POS][1], darkPawns[i][POS][2], darkPawns[i][POS][3])
    rotateModel(darkPawns[i][ID], math.random()*math.pi*2.0, 0, 1, 0)
end

-- Setup Rooks.
for i = 1, 2 do
    local zPos = 1
    if i == 2 then
        zPos = 8
    end

    lightRooks[i] = {}
    lightRooks[i][ID] = addModel("RookLight")
    lightRooks[i][POS] = {1, 0, zPos}
    lightRooks[i][TYPE] = 1
    translateModel(lightRooks[i][ID], lightRooks[i][POS][1], lightRooks[i][POS][2], lightRooks[i][POS][3])

    darkRooks[i] = {}
    darkRooks[i][ID] = addModel("RookDark")
    darkRooks[i][POS] = {8, 0, zPos}
    darkRooks[i][TYPE] = 1
    translateModel(darkRooks[i][ID], darkRooks[i][POS][1], darkRooks[i][POS][2], darkRooks[i][POS][3])
end

-- Setup Knights.
for i = 1, 2 do
    local zPos = 2
    if i == 2 then
        zPos = 7
    end

    lightKnights[i] = {}
    lightKnights[i][ID] = addModel("KnightLight")
    lightKnights[i][POS] = {1, 0, zPos}
    lightKnights[i][TYPE] = 2
    translateModel(lightKnights[i][ID], lightKnights[i][POS][1], lightKnights[i][POS][2], lightKnights[i][POS][3])

    darkKnights[i] = {}
    darkKnights[i][ID] = addModel("KnightDark")
    darkKnights[i][POS] = {8, 0, zPos}
    darkKnights[i][TYPE] = 2
    translateModel(darkKnights[i][ID], darkKnights[i][POS][1], darkKnights[i][POS][2], darkKnights[i][POS][3])
end

-- Setup Bishops.
for i = 1, 2 do
    local zPos = 3
    if i == 2 then
        zPos = 6
    end

    lightBishops[i] = {}
    lightBishops[i][ID] = addModel("BishopLight")
    lightBishops[i][POS] = {1, 0, zPos}
    lightBishops[i][TYPE] = 3
    translateModel(lightBishops[i][ID], lightBishops[i][POS][1], lightBishops[i][POS][2], lightBishops[i][POS][3])

    darkBishops[i] = {}
    darkBishops[i][ID] = addModel("BishopDark")
    darkBishops[i][POS] = {8, 0, zPos}
    darkBishops[i][TYPE] = 3
    translateModel(darkBishops[i][ID], darkBishops[i][POS][1], darkBishops[i][POS][2], darkBishops[i][POS][3])
end

-- Setup Queens.
lightQueen = {}
lightQueen[ID] = addModel("QueenLight")
lightQueen[POS] = {1, 0, 5}
lightQueen[TYPE] = 4
translateModel(lightQueen[ID], lightQueen[POS][1], lightQueen[POS][2], lightQueen[POS][3])

darkQueen = {}
darkQueen[ID] = addModel("QueenDark")
darkQueen[POS] = {8, 0, 5}
darkQueen[TYPE] = 4
translateModel(darkQueen[ID], darkQueen[POS][1], darkQueen[POS][2], darkQueen[POS][3])


-- Setup Kings.
lightKing = {}
lightKing[ID] = addModel("KingLight")
lightKing[POS] = {1, 0, 4}
lightKing[TYPE] = 5
translateModel(lightKing[ID], lightKing[POS][1], lightKing[POS][2], lightKing[POS][3])

darkKing = {}
darkKing[ID] = addModel("KingDark")
darkKing[POS] = {8, 0, 4}
darkKing[TYPE] = 5
translateModel(darkKing[ID], darkKing[POS][1], darkKing[POS][2], darkKing[POS][3])
