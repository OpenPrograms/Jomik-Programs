local component = require("component")
local location = require("location")
local sides = require("sides")
local vector = require("vector")

local original_move = component.robot.move
local original_turn = component.robot.turn

local function location_move(side)
  local result = original_move(side)
  
  if result then
    local position, orientation = location.get()
    
    if side == sides.down then
      position.y = position.y - 1
    elseif side == sides.up then
      position.y = position.y + 1
    elseif side == sides.back then
      position = position + orientation
    elseif side == sides.forward then
      position = position - orientation
    end
    
    location.set(position, orientation)
  end
  
  return result
end

local function location_turn(clockwise)
  local result = original_turn(clockwise)
  
  if result then
    local position, orientation = location.get()
    
    if clockwise then
      orientation = vector(-orientation.z, y, orientation.x)
    else
      orientation = vector(orientation.z, y, -orientation.x)
    end
    
    location.set(position, orientation)
  end
  
  return result
end

function start()
  component.robot.move = location_move
  component.robot.turn = location_turn
end

function stop()
  component.robot.move = original_move
  component.robot.turn = original_turn
end