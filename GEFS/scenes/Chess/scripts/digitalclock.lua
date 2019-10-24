-- Array to digits for faster access
local digits = {"Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"}

-- Coordinates of the digits for the digital clock
local lightClockCoords = {
  min = { x = 8.7, y = 0, z = 3.6 },
  colon = { x = 8.7, y = 0, z = 4.1},
  tenthSec = { x = 8.7, y = 0, z = 4.6},
  sec = { x = 8.7, y = 0, z = 5.3}
}

local lightClockIDs = {
  min = nil,
  colon = nil,
  tenthSec = nil,
  sec = nil
}

local lightCurrentTimer = {
  min = 5,
  sec = 0,
  dt = 0
}

local darkClockCoords = {
  min = { x = 0.3, y = 0, z = 5.3 },
  colon = { x = 0.3, y = 0, z = 4.8 },
  tenthSec = { x = 0.3, y = 0, z = 4.3},
  sec = { x = 0.3, y = 0, z = 3.6}
}

local darkClockIDs = {
  min = nil,
  colon = nil,
  tenthSec = nil,
  sec = nil
}

local darkCurrentTimer = {
  min = 5,
  sec = 0,
  dt = 0
}

function clock (dt, turn, tickSound)
  if turn == "Light" then
    lightCurrentTimer.dt = lightCurrentTimer.dt + dt
    if math.floor(lightCurrentTimer.dt) == 1 then -- One second has passed
        playSoundEffect(tickSound)
      lightCurrentTimer.dt = 0
      if lightCurrentTimer.sec == 0 and lightCurrentTimer.min == 0 then
        return true
      elseif lightCurrentTimer.sec == 0 then
        lightCurrentTimer.min = lightCurrentTimer.min - 1
      end
      lightCurrentTimer.sec = (lightCurrentTimer.sec - 1) % 60
      deleteModel(lightClockIDs.min)
      lightClockIDs.min = addRotateModel(digits[lightCurrentTimer.min + 1], "Light", lightClockCoords.min.x, lightClockCoords.min.y, lightClockCoords.min.z)
      deleteModel(lightClockIDs.tenthSec)
      lightClockIDs.tenthSec = addRotateModel(digits[math.floor(lightCurrentTimer.sec / 10) + 1], "Light", lightClockCoords.tenthSec.x, lightClockCoords.tenthSec.y, lightClockCoords.tenthSec.z)
      deleteModel(lightClockIDs.sec)
      lightClockIDs.sec = addRotateModel(digits[math.floor(lightCurrentTimer.sec % 10) + 1], "Light", lightClockCoords.sec.x, lightClockCoords.sec.y, lightClockCoords.sec.z)
    end
  elseif turn == "Dark" then
    darkCurrentTimer.dt = darkCurrentTimer.dt + dt
    if math.floor(darkCurrentTimer.dt) == 1 then -- One second has passed
        playSoundEffect(tickSound)
      darkCurrentTimer.dt = 0
      if darkCurrentTimer.sec == 0 and darkCurrentTimer.min == 0 then
        return true
      elseif darkCurrentTimer.sec == 0 then
        darkCurrentTimer.min = darkCurrentTimer.min - 1
      end
      darkCurrentTimer.sec = (darkCurrentTimer.sec - 1) % 60
      deleteModel(darkClockIDs.min)
      darkClockIDs.min = addRotateModel(digits[darkCurrentTimer.min + 1], "Dark", darkClockCoords.min.x, darkClockCoords.min.y, darkClockCoords.min.z)
      deleteModel(darkClockIDs.tenthSec)
      darkClockIDs.tenthSec = addRotateModel(digits[math.floor(darkCurrentTimer.sec / 10) + 1], "Dark", darkClockCoords.tenthSec.x, darkClockCoords.tenthSec.y, darkClockCoords.tenthSec.z)
      deleteModel(darkClockIDs.sec)
      darkClockIDs.sec = addRotateModel(digits[math.floor(darkCurrentTimer.sec % 10) + 1], "Dark", darkClockCoords.sec.x, darkClockCoords.sec.y, darkClockCoords.sec.z)
    end
  end
  return false
end

function addRotateModel(name, team, x, y, z)
  local id = addModel(name..team, x, y, z)
  if team == "Light" then
    rotateModel(id, -math.pi/2, 0, 1, 0)
  elseif team == "Dark" then
    rotateModel(id, math.pi/2, 0, 1, 0)
  end
  return id
end

function initClock ()
  lightClockIDs.min = addRotateModel(digits[6], "Light", lightClockCoords.min.x, lightClockCoords.min.y, lightClockCoords.min.z)
  lightClockIDs.colon = addRotateModel("Colon", "Light", lightClockCoords.colon.x, lightClockCoords.colon.y, lightClockCoords.colon.z)
  lightClockIDs.tenthSec = addRotateModel(digits[1], "Light", lightClockCoords.tenthSec.x, lightClockCoords.tenthSec.y, lightClockCoords.tenthSec.z)
  lightClockIDs.sec = addRotateModel(digits[1], "Light", lightClockCoords.sec.x, lightClockCoords.sec.y, lightClockCoords.sec.z)

  darkClockIDs.min = addRotateModel(digits[6], "Dark", darkClockCoords.min.x, darkClockCoords.min.y, darkClockCoords.min.z)
  darkClockIDs.colon = addRotateModel("Colon", "Dark", darkClockCoords.colon.x, darkClockCoords.colon.y, darkClockCoords.colon.z)
  darkClockIDs.tenthSec = addRotateModel(digits[1], "Dark", darkClockCoords.tenthSec.x, darkClockCoords.tenthSec.y, darkClockCoords.tenthSec.z)
  darkClockIDs.sec = addRotateModel(digits[1], "Dark", darkClockCoords.sec.x, darkClockCoords.sec.y, darkClockCoords.sec.z)
end

initClock()
