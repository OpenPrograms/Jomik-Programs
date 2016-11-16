local vector = {}
vector.__index = vector

local function new(x, y, z)
  return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vector)
end
local zero = new(0,0,0)

local function isvector(v)
	return type(v) == 'table'
    and type(v.x) == 'number'
    and type(v.y) == 'number'
    and type(v.z) == 'number'
end

local function from(o)
  if type(o) == "table" then
    return new(o.x, o.y, o.z)
  elseif type(o) == "string" then
    local x, y, z = string.find(o, "[(<]*%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*[)>]*")
    return new(x, y, z)
  else
    error("wrong argument type (expected <table> or <string>)")
  end
end

function vector.__add(a, b)
  return new(a.x + b.x, a.y + b.y, a.z + b.z)
end

function vector.__sub(a, b)
  return new(a.x - b.x, a.y - b.y, a.z - b.z)
end

function vector.__div(a, b)
  return new(a.x / b.x, a.y / b.y, a.z / b.z)
end

function vector:len2()
  return self.x * self.x + self.y * self.y + self.z * self.z
end

function vector:__tostring()
  return "(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

return setmetatable({new = new, zero = zero, isvector = isvector, from = from},
                    {__call = function(_, ...) return new(...) end})