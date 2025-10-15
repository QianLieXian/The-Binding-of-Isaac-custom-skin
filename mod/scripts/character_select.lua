local CharacterSelectUi = {}
CharacterSelectUi.__index = CharacterSelectUi

local ButtonAction = ButtonAction
local InputHook = InputHook
local KColor = KColor
local Vector = Vector

local function build_character_state_list()
  local states = {}
  if GameState then
    if GameState.STATE_CHARACTER_SELECT then
      table.insert(states, GameState.STATE_CHARACTER_SELECT)
    end
    if GameState.STATE_PLAYER_SELECT then
      table.insert(states, GameState.STATE_PLAYER_SELECT)
    end
    if GameState.STATE_GREEDMODE_SELECT then
      table.insert(states, GameState.STATE_GREEDMODE_SELECT)
    end
  end
  return states
end

local function contains(list, value)
  for _, candidate in ipairs(list) do
    if candidate == value then
      return true
    end
  end
  return false
end

local function colour(r, g, b, a)
  local tone = KColor(r, g, b, a or 1)
  tone:SetColorize(1, 1, 1, 1)
  return tone
end

function CharacterSelectUi.new(mod, manager, persistentState)
  local self = setmetatable({}, CharacterSelectUi)
  self.mod = mod
  self.manager = manager
  self.state = persistentState or {}
  self.game = Game()
  self.characterStates = build_character_state_list()
  self.font = Font()
  self.font:Load("font/terminus.fnt")
  self.smallFont = Font()
  self.smallFont:Load("font/terminus.fnt")
  self.primaryColor = colour(0.96, 0.86, 0.35, 1)
  self.textColor = colour(0.88, 0.92, 0.99, 1)
  self.mutedColor = colour(0.62, 0.72, 0.88, 1)
  self.shadowColor = colour(0, 0, 0, 0.75)
  self.focused = false
  self.menuOpen = false
  self.controllerIndex = 0
  self.cachedSkins = {}
  self.selectionIndex = 1
  self.scrollOffset = 0
  self.maxVisibleEntries = 6
  self.lastRefreshFrame = -1
  self.slotPosition = Vector(456, 112)
  self.slotWidth = 180
  self.slotLineHeight = 14
  self.slotPadding = 12
  self.captureActions = {
    [ButtonAction.ACTION_MENULEFT] = true,
    [ButtonAction.ACTION_MENURIGHT] = true,
    [ButtonAction.ACTION_MENUUP] = true,
    [ButtonAction.ACTION_MENUDOWN] = true,
    [ButtonAction.ACTION_MENUCONFIRM] = true,
    [ButtonAction.ACTION_MENUBACK] = true,
    [ButtonAction.ACTION_MENUTAB] = true,
  }
  self:RefreshSkins(true)
  return self
end

function CharacterSelectUi:IsCharacterSelect()
  local currentState = self.game:GetState()
  if contains(self.characterStates, currentState) then
    return true
  end
  return false
end

function CharacterSelectUi:GetActiveSkinId()
  return self.state.selectedSkinId or ""
end

function CharacterSelectUi:SetActiveSkinId(id)
  self.state.selectedSkinId = id or ""
  self.selectionIndex = self:FindSelectionIndex(self.state.selectedSkinId)
  self:ClampScrollToSelection()
end

function CharacterSelectUi:RefreshSkins(force)
  if not force and self.lastRefreshFrame == self.game:GetFrameCount() then
    return
  end
  local list = {
    {
      id = "",
      name = "默认外观",
      author = "原版",
      baseCharacter = self.state.lastBaseCharacter or "Isaac",
      notes = "使用原版角色皮肤",
    },
  }
  local summaries = self.manager:GetSkinSummaries() or {}
  for _, entry in ipairs(summaries) do
    list[#list + 1] = entry
  end
  self.cachedSkins = list
  self.selectionIndex = self:FindSelectionIndex(self:GetActiveSkinId())
  self:ClampScrollToSelection()
  self.lastRefreshFrame = self.game:GetFrameCount()
end

function CharacterSelectUi:FindSelectionIndex(skinId)
  if not skinId or skinId == "" then
    return 1
  end
  for index, entry in ipairs(self.cachedSkins) do
    if entry.id == skinId then
      return index
    end
  end
  return 1
end

function CharacterSelectUi:ClampScrollToSelection()
  local count = #self.cachedSkins
  if count <= self.maxVisibleEntries then
    self.scrollOffset = 0
    return
  end
  local minOffset = 0
  local maxOffset = math.max(0, count - self.maxVisibleEntries)
  if self.selectionIndex < self.scrollOffset + 1 then
    self.scrollOffset = self.selectionIndex - 1
  elseif self.selectionIndex > self.scrollOffset + self.maxVisibleEntries then
    self.scrollOffset = self.selectionIndex - self.maxVisibleEntries
  end
  if self.scrollOffset < minOffset then
    self.scrollOffset = minOffset
  elseif self.scrollOffset > maxOffset then
    self.scrollOffset = maxOffset
  end
end

function CharacterSelectUi:MoveSelection(delta)
  if #self.cachedSkins == 0 then
    return
  end
  local target = self.selectionIndex + delta
  if target < 1 then
    target = 1
  elseif target > #self.cachedSkins then
    target = #self.cachedSkins
  end
  if target ~= self.selectionIndex then
    self.selectionIndex = target
    self:ClampScrollToSelection()
  end
end

function CharacterSelectUi:ConfirmSelection()
  local entry = self.cachedSkins[self.selectionIndex]
  if not entry then
    return
  end
  self.state.lastBaseCharacter = entry.baseCharacter or self.state.lastBaseCharacter
  self.mod:OnSkinSelected(entry)
  self:SetActiveSkinId(entry.id)
  self.menuOpen = false
  self.focused = false
end

function CharacterSelectUi:HandleNavigation()
  if not self.focused then
    return
  end
  local input = Input
  local controller = self.controllerIndex
  if input:IsActionTriggered(ButtonAction.ACTION_MENUBACK, controller) then
    if self.menuOpen then
      self.menuOpen = false
    else
      self.focused = false
    end
    return
  end
  if not self.menuOpen and input:IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, controller) then
    self.menuOpen = true
    self:RefreshSkins(true)
    return
  end
  if not self.menuOpen then
    return
  end
  if input:IsActionTriggered(ButtonAction.ACTION_MENUUP, controller) then
    self:MoveSelection(-1)
  elseif input:IsActionTriggered(ButtonAction.ACTION_MENUDOWN, controller) then
    self:MoveSelection(1)
  elseif input:IsActionTriggered(ButtonAction.ACTION_MENULEFT, controller) then
    self:MoveSelection(-self.maxVisibleEntries)
  elseif input:IsActionTriggered(ButtonAction.ACTION_MENURIGHT, controller) then
    self:MoveSelection(self.maxVisibleEntries)
  elseif input:IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, controller) then
    self:ConfirmSelection()
  end
end

function CharacterSelectUi:Update()
  if not self:IsCharacterSelect() then
    self.focused = false
    self.menuOpen = false
    self:RefreshSkins(true)
    return
  end
  self:RefreshSkins()
  local input = Input
  if input:IsActionTriggered(ButtonAction.ACTION_MENUTAB, self.controllerIndex) then
    if not self.focused then
      self.focused = true
      self.menuOpen = true
      self:RefreshSkins(true)
    else
      if self.menuOpen then
        self.menuOpen = false
      else
        self.focused = false
      end
    end
  end
  self:HandleNavigation()
end

function CharacterSelectUi:OnInputAction(_, hook, action)
  if not self.focused then
    return nil
  end
  if not self.captureActions[action] then
    return nil
  end
  if hook == InputHook.IS_ACTION_PRESSED or hook == InputHook.IS_ACTION_TRIGGERED then
    return false
  end
  if hook == InputHook.GET_ACTION_VALUE then
    return 0.0
  end
  return nil
end

local function draw_shadowed(font, text, x, y, color, shadow)
  font:DrawString(text, x + 1, y + 1, shadow, 0, false)
  font:DrawString(text, x, y, color, 0, false)
end

local function format_summary(entry)
  local author = entry.author or "未知"
  local base = entry.baseCharacter or "Isaac"
  return string.format("%s  ·  %s", author, base)
end

function CharacterSelectUi:RenderSlotSkeleton(topY)
  local x = self.slotPosition.X
  local y = topY or self.slotPosition.Y
  local widthChars = 18
  local horizontal = string.rep("─", widthChars)
  draw_shadowed(self.font, "┌" .. horizontal .. "┐", x, y, self.mutedColor, self.shadowColor)
  local bodyLines = self.maxVisibleEntries * 2 + 3
  for i = 1, bodyLines do
    draw_shadowed(self.font, "│" .. string.rep(" ", widthChars) .. "│", x, y + i * self.slotLineHeight, self.mutedColor, self.shadowColor)
  end
  draw_shadowed(self.font, "└" .. horizontal .. "┘", x, y + (bodyLines + 1) * self.slotLineHeight, self.mutedColor, self.shadowColor)
  return y + self.slotLineHeight * 2
end

function CharacterSelectUi:RenderList(startY)
  local x = self.slotPosition.X + self.slotPadding
  local y = startY
  local visible = self.maxVisibleEntries
  local total = #self.cachedSkins
  if total == 0 then
    draw_shadowed(self.smallFont, "尚未导入皮肤", x, y, self.mutedColor, self.shadowColor)
    return
  end
  local startIndex = math.max(1, math.min(self.scrollOffset + 1, total))
  local endIndex = math.min(total, startIndex + visible - 1)
  for index = startIndex, endIndex do
    local entry = self.cachedSkins[index]
    local isSelected = index == self.selectionIndex
    local marker = isSelected and "▶" or ""
    local titleColor = isSelected and self.primaryColor or self.textColor
    draw_shadowed(self.smallFont, string.format("%s%s", marker, entry.name), x, y, titleColor, self.shadowColor)
    y = y + self.slotLineHeight
    draw_shadowed(self.smallFont, format_summary(entry), x + 12, y, self.mutedColor, self.shadowColor)
    y = y + self.slotLineHeight
  end
  if endIndex < total then
    draw_shadowed(self.smallFont, "▼ 更多皮肤...", x + 12, y, self.mutedColor, self.shadowColor)
  end
end

function CharacterSelectUi:RenderStatusFooter(baseY)
  local x = self.slotPosition.X + self.slotPadding
  local y = baseY + self.slotLineHeight
  local activeId = self:GetActiveSkinId()
  if activeId == "" then
    draw_shadowed(self.smallFont, "当前：默认外观", x, y, self.textColor, self.shadowColor)
  else
    local entry = self.cachedSkins[self:FindSelectionIndex(activeId)]
    if entry then
      draw_shadowed(self.smallFont, "当前：" .. entry.name, x, y, self.textColor, self.shadowColor)
      y = y + self.slotLineHeight
      draw_shadowed(self.smallFont, format_summary(entry), x + 12, y, self.mutedColor, self.shadowColor)
    end
  end
  y = y + self.slotLineHeight
  if not self.focused then
    draw_shadowed(self.smallFont, "按 Tab 聚焦皮肤入口", x, y, self.mutedColor, self.shadowColor)
  elseif not self.menuOpen then
    draw_shadowed(self.smallFont, "按确认打开皮肤列表", x, y, self.mutedColor, self.shadowColor)
  else
    draw_shadowed(self.smallFont, "确认应用 / 返回关闭", x, y, self.mutedColor, self.shadowColor)
  end
end

function CharacterSelectUi:Render()
  if not self:IsCharacterSelect() then
    return
  end
  local baseY = self:RenderSlotSkeleton()
  draw_shadowed(self.font, "自定义皮肤入口", self.slotPosition.X + self.slotPadding, baseY - self.slotLineHeight, self.textColor, self.shadowColor)
  if self.menuOpen then
    self:RenderList(baseY)
  else
    local x = self.slotPosition.X + self.slotPadding
    local y = baseY
    draw_shadowed(self.smallFont, "按确认查看皮肤列表", x, y, self.mutedColor, self.shadowColor)
    y = y + self.slotLineHeight
    local activeId = self:GetActiveSkinId()
    if activeId ~= "" then
      local entry = self.cachedSkins[self:FindSelectionIndex(activeId)]
      if entry then
        draw_shadowed(self.smallFont, "已选择：" .. entry.name, x, y, self.textColor, self.shadowColor)
        y = y + self.slotLineHeight
        draw_shadowed(self.smallFont, format_summary(entry), x + 12, y, self.mutedColor, self.shadowColor)
      end
    else
      draw_shadowed(self.smallFont, "当前沿用原版外观", x, y, self.textColor, self.shadowColor)
    end
  end
  local footerBase = self.slotPosition.Y + (self.maxVisibleEntries * 2 + 3) * self.slotLineHeight
  self:RenderStatusFooter(footerBase)
end

function CharacterSelectUi:OnPlayerInit(player)
  if not player then
    return
  end
  local activeId = self:GetActiveSkinId()
  if activeId ~= "" then
    local skin = self.manager:GetSkin(activeId)
    if skin then
      local data = player:GetData()
      data.customSkinId = skin.id
      data.customSkinMeta = skin.meta
    end
  end
end

return CharacterSelectUi
