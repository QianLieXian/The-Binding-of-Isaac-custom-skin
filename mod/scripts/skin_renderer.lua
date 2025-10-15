local SkinRenderer = {}
SkinRenderer.__index = SkinRenderer

local schema = require("skin_schema")

local FRAME_LAYOUTS = schema.frameLayouts or {}

local MOD_DIRECTORY = "aaa_custom_skin_loader"
local BASE_TEXTURE_DIR = "mods/" .. MOD_DIRECTORY .. "/gfx/custom_skins"

local function join_path(a, b)
  if a:sub(-1) == "/" then
    return a .. b
  end
  return a .. "/" .. b
end

local function texture_exists(path)
  local file = io.open(path, "rb")
  if file then
    file:close()
    return true
  end
  return false
end

local function find_texture_paths(skin_id)
  local textures = {}
  for _, sheetInfo in pairs(FRAME_LAYOUTS.sheets or {}) do
    local relative = join_path(join_path(BASE_TEXTURE_DIR, skin_id), sheetInfo.sheet)
    if texture_exists(relative) then
      textures[sheetInfo.layerId or 0] = relative
    end
  end
  return textures
end

function SkinRenderer.new(mod)
  local instance = setmetatable({}, SkinRenderer)
  instance.mod = mod
  return instance
end

function SkinRenderer:Apply(player, skin)
  if not skin or not skin.id then
    return
  end
  local sprite = player:GetSprite()
  local textures = find_texture_paths(skin.id)
  for layerId, path in pairs(textures) do
    sprite:ReplaceSpritesheet(layerId, path)
  end
  sprite:LoadGraphics()
end

return SkinRenderer
