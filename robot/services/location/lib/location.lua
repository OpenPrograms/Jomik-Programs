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
  assert(ensureDataDirectory(),
    "an error occurred trying to create directory at " .. DATA_PATH)
  local stream = io.open(DATA_PATH .. DATA_FILE, "w")
  stream:write(serialization.serialize(position),
    "\n", serialization.serialize(orientation))
  stream:close()
end

local function loadData()
  local stream = io.open(DATA_PATH .. DATA_FILE, "r")
  
  local serialized_position, serialized_orientation
  -- read file if it exists
  if stream then
    serialized_position = stream:read("*l")
    serialized_orientation = stream:read("*l")
    stream:close()
  end
  
  -- if we got some text, unserialize it
  if serialized_position and serialized_orientation then
    position = vector.from(serialization.unserialize(serialized_position))
    orientation = vector.from(serialization.unserialize(serialized_orientation))
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