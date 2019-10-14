local Board = { chessboard = nil }


-- Initialized a new board with 8x8 size, filled with nils
function Board:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  for i = 1, 8 do
    self.chessboard[i] = {}
    for j = 1, 8 do
      self.chessboard[i][j] = nil
    end
  end
  return o
end

return Board