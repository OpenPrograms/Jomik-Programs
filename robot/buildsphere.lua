local vector = require("vector")

local center = vector(tonumber(select(1, ...) or 0),
                      tonumber(select(2, ...) or 0),
                      tonumber(select(3, ...) or 0))
                    
local radius = vector(tonumber(select(4, ...) or 1),
                      tonumber(select(5, ...) or 1),
                      tonumber(select(6, ...) or 1))
                      + vector(0.5, 0.5, 0.5))
                    
local scale = tonumber(select(7, ...) or 0.7)
  
local function getRadius()
  return radius - vector(0.5, 0.5, 0.5)
end

local function contains(position)
  return ((position - center) / radius):len2() <= 1
end

local function isShell(position)
  return contains(position) and not 
        (contains(position + vector(-1, 0, 0))
     and contains(position + vector(1, 0, 0))
     and contains(position + vector(0, -1, 0))
     and contains(position + vector(0, 1, 0))
     and contains(position + vector(0, 0, -1))
     and contains(position + vector(0, 0, 1)))
end

local min = center - getRadius()
local max = center + getRadius()

-- We need a special case for the top and bottom.
min.y = min.y - 1
max.y = max.y + 1

--[[
local function drawPlane(y)
  for x = min.x, max.x do
    for z = min.z, max.z do
      if (isShell(vector(math.floor(x), y, math.floor(z)))) then
         Block at (x, y, z)
        os.sleep(0)
      end
    end
  end
end

local plane = min.y
--]]


--[[
if (Should there be a block straight ahead?)
  Go forward, place block behind
else if (Should there be a block to the right?)
  turn right, go forward, place block behind
else if (Should there be a block to the left?)
 turn left, go forward, place block behind
else
  turn right, go forward, place block behind, turn left, go forward
--]]