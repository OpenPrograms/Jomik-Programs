local VERSION = "0.1a"
local BUILD_LIB_DIR = "build/"

local filesystem = require("filesystem")
local location = require("location")
local robot = require("robot")
local shell = require("shell")
local vector = require("vector")

local args, opts = shell.parse(...)
local charge_pos, chest_pos = vector(0, -1, 0), vector(0,1,0)

local root_path = filesystem.path(filesystem.path(os.getenv("_")), "..")
local lib_dir = filesystem.concat(root_path, "lib", BUILD_LIB_DIR)

local usage = [[
Usage:
  build --shape=<shape> [-d|--dry] [shape args]
  build --shape=<shape> [-i|--info]
  build -l | --list
  build -h | --help

Options:
  -h --help         Show this screen.
  -v | --version    Show version.
  -l --list         Lists all possible shapes.
  --shape=<shape>   Shape to build.
  --charge=<vector> Position of the charger.
  --chest=<vector>  Position of the chest.
  -i --info         Show info about the shape.
]]


if opts.v or opts.version then
  print("robot-build v" .. VERSION)
  return
elseif opts.l or opts.list then
  if filesystem.isDirectory(lib_dir) then
    print("Available shapes for robot-build:")
    for f in filesystem.list(lib_dir) do
      if not filesystem.isDirectory(f) and string.match(f, "[%a%d]+.lua") then
          print(select(3, string.find(f, "([%a%d]+).lua")))
        end
      end
  else
    print("build library directory not found (" .. lib_dir .. ")")
  end
  return
elseif opts.charge then
  charge_pos = vector(opts.charge)
elseif opts.chest then
  chest_pos = vector(opts.chest)
elseif not opts.shape or opts.h or opts.help then
  print(usage)
  return
end

local shape_file = filesystem.concat(lib_dir, opts.shape .. ".lua")
assert(filesystem.exists(shape_file)
  and not filesystem.isDirectory(shape_file)
  and not filesystem.isLink(shape_file),
  "build file not found (" .. opts.shape .. ")")

local shape_lib = require(filesystem.concat(BUILD_LIB_DIR, opts.shape))
if opts.i or opts.info then
  shape_lib.info()
  return
elseif opts.d or opts.dry then
  shape_lib.dry(table.unpack(args))
  return
end

local shape = shape_lib.fromargs(table.unpack(args))

local function next_block()
  local position, orientation = location.get()
  local right = vector(-orientation.z, orientation.y, orientation.x)
  if shape:is_shell(position - orientation) then
    -- Go forward, place block behind
    robot.back()
    -- place block
  elseif shape:is_shell(position - right) then
    -- turn right, go forward, place block behind
    robot.turnLeft()
    robot.Back()
    -- place block
  elseif shape:is_shell(position + right) then
    -- turn left, go forward, place block behind
    robot.turnRight()
    robot.back()
    -- place block
  else
    -- turn right, go forward, place block behind, turn left, go forward
    robot.turnLeft()
    robot.back()
    -- place block
    robot.turnLeft()
    robot.back()
  end
end

-- find edge
local position, orientation = location.get()
while shape:contains(position + orientation) do
  robot.forward()
  position, orientation = location.get()
end

robot.turnLeft()

while true do
  next_block()
end  

--[[
We need a special case for the top and bottom.

if (Should there be a block straight ahead?)
  Go forward, place block behind
else if (Should there be a block to the right?)
  turn right, go forward, place block behind
else if (Should there be a block to the left?)
 turn left, go forward, place block behind
else
  turn right, go forward, place block behind, turn left, go forward
--]]