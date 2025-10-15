local SkinManager = {}
SkinManager.__index = SkinManager

local DEFAULT_MANIFEST_PATH = "exported_skins/skins_manifest.json"

function SkinManager.new(jsonLib, schema)
  local instance = setmetatable({}, SkinManager)
  instance.json = jsonLib
  instance.schema = schema or {}
  instance.manifestPath = DEFAULT_MANIFEST_PATH
  instance.requiredFrames = instance.schema.requiredFrames or {}
  instance.aliasRules = instance.schema.aliasRules or {}
  instance.gridSize = instance.schema.gridSize or 32
  instance.skins = {}
  return instance
end

function SkinManager:Log(message)
  local text = "[CustomSkinLoader] " .. tostring(message)
  if Isaac and Isaac.DebugString then
    Isaac.DebugString(text)
  else
    print(text)
  end
end

function SkinManager:ReadFile(path)
  local file, err = io.open(path, "r")
  if not file then
    return nil, err or "unknown error"
  end
  local content = file:read("*a")
  file:close()
  return content
end

function SkinManager:DecodeJson(content)
  local ok, result = pcall(self.json.decode, content)
  if not ok then
    return nil, result
  end
  return result
end

function SkinManager:CloneFrame(frameData)
  local clone = {}
  local jsonNull = self.json and self.json.null
  for y = 1, self.gridSize do
    local row = frameData and frameData[y]
    clone[y] = {}
    if type(row) == "table" then
      for x = 1, self.gridSize do
        local value = row[x]
        if value == jsonNull then
          value = nil
        end
        clone[y][x] = value
      end
    end
  end
  return clone
end

function SkinManager:NormaliseFrames(frames)
  local normalised = {}
  if type(frames) == "table" then
    for frameId, frameData in pairs(frames) do
      if type(frameData) == "table" then
        normalised[frameId] = self:CloneFrame(frameData)
      end
    end
  end

  for _, rule in ipairs(self.aliasRules) do
    local sourceFrame
    if rule.sources then
      for _, sourceId in ipairs(rule.sources) do
        if normalised[sourceId] then
          sourceFrame = normalised[sourceId]
          break
        end
      end
    end
    if sourceFrame then
      for _, targetId in ipairs(rule.targets or {}) do
        if not normalised[targetId] then
          normalised[targetId] = self:CloneFrame(sourceFrame)
        end
      end
      if rule.removeSource ~= false then
        for _, sourceId in ipairs(rule.sources or {}) do
          normalised[sourceId] = nil
        end
      end
    end
  end

  return normalised
end

function SkinManager:ValidateFrames(frames)
  local missing = {}
  for _, frameId in ipairs(self.requiredFrames) do
    if not frames[frameId] then
      missing[#missing + 1] = frameId
    end
  end
  if #missing > 0 then
    return false, "缺少帧: " .. table.concat(missing, ", ")
  end

  for _, frameId in ipairs(self.requiredFrames) do
    local frameData = frames[frameId]
    if type(frameData) ~= "table" then
      return false, string.format("帧 %s 数据格式不正确", frameId)
    end
    if #frameData ~= self.gridSize then
      return false, string.format("帧 %s 行数不匹配 (期望 %d)", frameId, self.gridSize)
    end
    for rowIndex = 1, self.gridSize do
      local row = frameData[rowIndex]
      if type(row) ~= "table" then
        return false, string.format("帧 %s 第 %d 行不是数组", frameId, rowIndex)
      end
      if #row ~= self.gridSize then
        return false, string.format("帧 %s 第 %d 行列数不匹配 (期望 %d)", frameId, rowIndex, self.gridSize)
      end
    end
  end

  return true
end

function SkinManager:LoadManifest()
  local content, readErr = self:ReadFile(self.manifestPath)
  if not content then
    return nil, readErr
  end
  local data, decodeErr = self:DecodeJson(content)
  if not data then
    return nil, decodeErr
  end
  return data
end

function SkinManager:Refresh()
  self.skins = {}
  local manifest, manifestErr = self:LoadManifest()
  if not manifest then
    self:Log("无法载入皮肤清单：" .. tostring(manifestErr))
    return
  end

  if manifest.formatVersion and manifest.formatVersion ~= self.schema.formatVersion then
    self:Log(string.format(
      "皮肤清单格式版本不匹配 (当前 %s，期望 %s)",
      tostring(manifest.formatVersion),
      tostring(self.schema.formatVersion)
    ))
  end

  local entries = manifest.skins or {}
  local loaded = 0
  for _, entry in ipairs(entries) do
    local fileName = tostring(entry.file)
    local filePath = "exported_skins/" .. fileName
    local content, readErr = self:ReadFile(filePath)
    if not content then
      self:Log(string.format("无法读取皮肤 %s：%s", fileName, tostring(readErr)))
    else
      local data, decodeErr = self:DecodeJson(content)
      if not data then
        self:Log(string.format("无法解析皮肤 %s：%s", fileName, tostring(decodeErr)))
      else
        if data.formatVersion and data.formatVersion ~= self.schema.formatVersion then
          self:Log(string.format("皮肤 %s 的格式版本不兼容 (当前 %s)", fileName, tostring(data.formatVersion)))
        else
          local frames = self:NormaliseFrames(data.frames or {})
          local valid, validationErr = self:ValidateFrames(frames)
          if not valid then
            self:Log(string.format("皮肤 %s 校验失败：%s", fileName, tostring(validationErr)))
          else
            local skinId = tostring(entry.id or entry.file or (#self.skins + 1))
            self.skins[skinId] = {
              id = skinId,
              file = fileName,
              meta = data.meta or {},
              frames = frames,
              colors = data.colors or {},
              manifest = entry,
              raw = data,
            }
            loaded = loaded + 1
          end
        end
      end
    end
  end

  self:Log(string.format("已准备 %d 个皮肤条目", loaded))
end

function SkinManager:GetSkin(id)
  return self.skins[id]
end

function SkinManager:GetSkins()
  return self.skins
end

function SkinManager:GetSkinSummaries()
  local summaries = {}
  for id, skin in pairs(self.skins) do
    local meta = skin.meta or {}
    summaries[#summaries + 1] = {
      id = id,
      name = meta.name or id,
      author = meta.author or "未知",
      baseCharacter = meta.baseCharacter or "Isaac",
      notes = meta.notes or "",
      file = skin.file,
    }
  end
  table.sort(summaries, function(a, b)
    return a.id < b.id
  end)
  return summaries
end

function SkinManager:LogAvailableSkins()
  local summaries = self:GetSkinSummaries()
  if #summaries == 0 then
    self:Log("当前没有可用的皮肤")
    return
  end
  self:Log("可用皮肤列表：")
  for _, summary in ipairs(summaries) do
    self:Log(string.format("- %s (作者 %s，基础角色 %s)", summary.name, summary.author, summary.baseCharacter))
  end
end

return SkinManager
