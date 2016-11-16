local filesystem = require("filesystem")
local serialization = require("serialization")
local vector = require("vector")

local DATA_PATH = "/var/location/"
local DATA_FILE = "location.dat"
local DEFAULT_POSITION, DEFAULT_ORIENTATION = vector(0, 0, 0), vector(1, 0, 0)

local location = {}
local position, orientation

local function ensureDataDirectory()
  if not filesystem.exists(DATA_PATH) then
    return filesystem.makeDirectory(DATA_PATH)
  end
  return filesystem.isDirectory(DATA_PATH)
end

local function saveData()
  assert(ensureDataDirectory,
    "an error occurred trying to create directory at " .. DATA_PATH)
  local stream = io.open(DATA_PATH .. DATA_FILE, "w")
  stream:write(serialization.serialize(position),
    "\n", serialization.serialize(orientation))
  stream:close()
end

local function loadData()
  local stream = io.open(DATA_PATH .. DATA_FILE, "r")
  
  local serializedpos, serializedori
  if stream then
    serializedpos = stream:read("*l")
    serializedori = stream:read("*l")
    stream:close()
  end
  
  if serializedpos and serializedori then
    position = vector(serialization.unserialize(serializedpos))
    orientation = vector(serialization.unserialize(serializedori))
  end
  
  return position, orientation
end

function location.set(pos, ori)
  position, orientation = pos, ori
  saveData()
end

function location.get()
  if not position then
    -- Try to load the position and orientation from file.
    position, orientation = loadData()
    if not position then
      position, orientation = DEFAULT_POSITION, DEFAULT_ORIENTATION
    end
  end
  
  return position, orientation
end

return location