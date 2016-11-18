local vector = require("vector")

local ellipsoid = {}
ellipsoid.__index = ellipsoid

local function new(center, radius)
  assert(vector.isvector(center) and vector.isvector(radius), "wrong argument types (expected <vector>")
  return setmetatable({center = center,
      radius = radius + vector(0.5, 0.5, 0.5),
      min = center - radius,
      max = center + radius
      }, ellipsoid)
end
local standard = new(vector(0, 0, 0), vector(1, 1, 1))

local function fromargs(cx, cy, cz, rx, ry, rz)
  return new(
    vector(
      tonumber(cx) > 0 and tonumber(cx) or 0,
      tonumber(cy) > 0 and tonumber(cy) or 0,
      tonumber(cz) > 0 and tonumber(cz) or 0),
    vector(
      tonumber(rx) > 1 and tonumber(rx) or 1,
      tonumber(ry) > 1 and tonumber(ry) or 1,
      tonumber(rz) > 1 and tonumber(rz) or 1))
                  
end

function ellipsoid:contains(position)
  return ((position - self.center) / self.radius):len2() <= 1
end

function ellipsoid:is_shell(position)
  return self:contains(position) and not 
        (self:contains(position + vector(-1, 0, 0))
     and self:contains(position + vector(1, 0, 0))
     and self:contains(position + vector(0, -1, 0))
     and self:contains(position + vector(0, 1, 0))
     and self:contains(position + vector(0, 0, -1))
     and self:contains(position + vector(0, 0, 1)))
end

return setmetatable({new = new, standard = standard, fromargs = fromargs},
                    {__call = function(_, ...) return new(...) end})