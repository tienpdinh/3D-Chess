local Board = { chessboard = {}}


-- Initialized a new board with 8x8 size, filled with nils
function Board:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  for i = 1, 8 do
    self.chessboard[i] = {}
    for j = 1, 8 do
      self.chessboard[i][j] = {}
      self.chessboard[i][j].x = nil
      self.chessboard[i][j].z = nil
      self.chessboard[i][j].id = nil
      self.chessboard[i][j].col = nil
    end
  end
  return o
end

function Board:fill (dist)
  dist = dist or 2
  local currentcolor = nil
  for i = 1, 8 do
    if i % 2 == 0 then
      currentcolor = "Black"
    else
      currentcolor = "White"
    end
    for j = 1, 8 do
      self.chessboard[i][j].x = dist / 2 + dist * (i - 1)
      self.chessboard[i][j].z = dist / 2 + dist * (j - 1)
      if currentcolor == "Black" then
        self.chessboard[i][j].col = "White"
        currentcolor = "White"
      else
        self.chessboard[i][j].col = "Black"
        currentcolor = "Black"
      end
    end
  end
end

function Board:drawboard ()
  for i = 1, 8 do
    for j = 1, 8 do
      if self.chessboard[i][j].col == "White" then
        self.chessboard[i][j].id = addModel("WhiteTile", self.chessboard[i][j].x, 0, self.chessboard[i][j].z)
      else
        self.chessboard[i][j].id = addModel("BlackTile", self.chessboard[i][j].x, 0, self.chessboard[i][j].z)
      end
    end
  end
end

return Board