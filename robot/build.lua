local VERSION = "0.1a"
local RELATIVE_BUILD_LIB = "lib/build/"

local filesystem = require("filesystem")
local robot = require("robot")
local shell = require("shell")
local vector = require("vector")

local args, opts = shell.parse(...)

local root_path = filesystem.path(filesystem.path(os.getenv("_")), "..")
local lib_dir = filesystem.concat(root_path, RELATIVE_BUILD_LIB)

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
          print(f)
        end
      end
  else
    print("build library directory not found (" .. lib_dir .. ")")
  end
  return
elseif not opts.shape or opts.h or opts.help then
  print(usage)
  return
end

local shape_file = lib_dir .. opts.shape .. ".lua"
assert(filesystem.exists(shape_file) and not filesystem.isDirectory(shape_file),
  "build file not found (" .. opts.shape .. ")")

local shape_lib = require(lib_dir .. opts.shape)
if opts.i or opts.info then
  shape_lib.info()
  return
elseif opts.d or opts.dry then
  shape_lib.dry(table.unpack(args))
  return
end

local shape = shape_lib:fromargs(table.unpack(args))
if not shape then
  return
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