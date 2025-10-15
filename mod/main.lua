local CustomSkinMod = RegisterMod("Custom Skin Loader", 1)

local function include_script(name)
  local path = "scripts/" .. name .. ".lua"
  local chunk, err = loadfile(path)
  if not chunk then
    error("无法加载脚本 " .. path .. ": " .. tostring(err))
  end
  local result = chunk()
  if not result then
    error("脚本 " .. path .. " 未返回模块表")
  end
  return result
end

local json = include_script("json")
local schema = include_script("skin_schema")
local SkinManager = include_script("skin_manager")

local manager = SkinManager.new(json, schema)
CustomSkinMod.SkinManager = manager

local function log(message)
  if Isaac and Isaac.DebugString then
    Isaac.DebugString("[CustomSkinLoader] " .. tostring(message))
  else
    print("[CustomSkinLoader] " .. tostring(message))
  end
end

CustomSkinMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
  local ok, err = pcall(function()
    manager:Refresh()
  end)
  if not ok then
    log("载入皮肤时发生错误: " .. tostring(err))
  elseif not isContinued then
    manager:LogAvailableSkins()
  end
end)

CustomSkinMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, command, params)
  if command == "skinlist" then
    manager:LogAvailableSkins()
    return true
  elseif command == "skinreload" then
    manager:Refresh()
    log("已重新扫描 exported_skins 目录")
    return true
  end
end)

function CustomSkinMod:GetSkin(id)
  return manager:GetSkin(id)
end

function CustomSkinMod:GetSkins()
  return manager:GetSkins()
end

return CustomSkinMod
