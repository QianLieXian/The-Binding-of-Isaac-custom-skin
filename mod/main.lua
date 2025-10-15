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
local CharacterSelectUi = include_script("character_select")

local manager = SkinManager.new(json, schema)
CustomSkinMod.SkinManager = manager

local persistentState = {
  selectedSkinId = nil,
  lastBaseCharacter = "Isaac",
}

local function decode_saved_state()
  if not CustomSkinMod:HasData() then
    return
  end
  local ok, data = pcall(json.decode, CustomSkinMod:LoadData())
  if not ok then
    Isaac.DebugString("[CustomSkinLoader] 无法解析存档数据: " .. tostring(data))
    return
  end
  if type(data) ~= "table" then
    return
  end
  persistentState.selectedSkinId = data.selectedSkinId
  if data.lastBaseCharacter then
    persistentState.lastBaseCharacter = data.lastBaseCharacter
  end
end

local function encode_saved_state()
  local ok, payload = pcall(json.encode, {
    selectedSkinId = persistentState.selectedSkinId,
    lastBaseCharacter = persistentState.lastBaseCharacter,
  })
  if not ok then
    Isaac.DebugString("[CustomSkinLoader] 无法序列化存档数据: " .. tostring(payload))
    return nil
  end
  return payload
end

decode_saved_state()

local characterSelectUi = CharacterSelectUi.new(CustomSkinMod, manager, persistentState)
CustomSkinMod.CharacterSelectUi = characterSelectUi

local function log(message)
  if Isaac and Isaac.DebugString then
    Isaac.DebugString("[CustomSkinLoader] " .. tostring(message))
  else
    print("[CustomSkinLoader] " .. tostring(message))
  end
end

CustomSkinMod.Log = log

local function save_state_to_disk()
  local payload = encode_saved_state()
  if payload then
    CustomSkinMod:SaveData(payload)
  end
end

function CustomSkinMod:GetPersistentState()
  return persistentState
end

function CustomSkinMod:GetActiveSkinId()
  return persistentState.selectedSkinId
end

function CustomSkinMod:GetActiveSkin()
  local id = persistentState.selectedSkinId
  if not id or id == "" then
    return nil
  end
  return manager:GetSkin(id)
end

function CustomSkinMod:OnSkinSelected(entry)
  if type(entry) ~= "table" then
    persistentState.selectedSkinId = nil
    save_state_to_disk()
    log("已重置为默认外观")
    return
  end
  persistentState.selectedSkinId = entry.id and entry.id ~= "" and entry.id or nil
  if entry.baseCharacter then
    persistentState.lastBaseCharacter = entry.baseCharacter
  end
  if persistentState.selectedSkinId then
    log(string.format("已选择皮肤 %s (作者 %s)", entry.name or persistentState.selectedSkinId, entry.author or "未知"))
  else
    log("已切换回默认外观")
  end
  save_state_to_disk()
end

characterSelectUi:SetActiveSkinId(persistentState.selectedSkinId)

CustomSkinMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
  local ok, err = pcall(function()
    manager:Refresh()
    characterSelectUi:RefreshSkins(true)
    characterSelectUi:SetActiveSkinId(persistentState.selectedSkinId)
  end)
  if not ok then
    log("载入皮肤时发生错误: " .. tostring(err))
  elseif not isContinued then
    manager:LogAvailableSkins()
  end
end)

CustomSkinMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
  characterSelectUi:Update()
end)

CustomSkinMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
  characterSelectUi:Render()
end)

CustomSkinMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
  return characterSelectUi:OnInputAction(entity, hook, action)
end)

CustomSkinMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
  characterSelectUi:OnPlayerInit(player)
end)

CustomSkinMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
  save_state_to_disk()
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
