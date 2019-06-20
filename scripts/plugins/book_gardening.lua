--- To Do Chores Book Gardening Plugin
-- @module choresPluginBookGardening

local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false
  self.placers = nil
  self.taskPlacers = nil
  self.seedPrefab = nil
  self.gap = 0
  self:InitWorld()
end)

function ChoresPlugin:InitWorld()
  self.opt = {
    acorn = false,
    beemine = false,
    dug_berrybush = false,
    dug_berrybush_juicy = false,
    dug_berrybush2 = false,
    dug_grass = false,
    dug_sapling = false,
    marblebean = false,
    pinecone = false,
    trap_teeth = false,
    twiggy_nut = true,
  }

  -- 可以被 deploy 的 prefab => 參考的選項開關
  self.deploies = {
    acorn = "acorn",
    beemine = "beemine",
    dug_berrybush = "dug_berrybush",
    dug_berrybush_juicy = "dug_berrybush_juicy",
    dug_berrybush2 = "dug_berrybush2",
    dug_grass = "dug_grass",
    dug_sapling = "dug_sapling",
    marblebean = "marblebean",
    pinecone = "pinecone",
    trap_teeth = "trap_teeth",
    twiggy_nut = "twiggy_nut",
  }

  -- 如果找不到種子時，能夠被製作的東西 => 參考的選項開關
  self.recipes = {
    beemine = "beemine",
    marblebean = "marblebean",
    trap_teeth = "trap_teeth",
  }

  -- 一開始 opt 選中的東西
  self.seedPrefab = 'twiggy_nut'
end

function ChoresPlugin:GetAction()
  -- 先嘗試撿起任何可以撿的東西
  local act = GetClosestPickupAction(function (...) return self:CanDeploy(...) end)
  if act then return act end

  -- 尋找種植目標，如果找不到就停止工作
  if self.taskPlacers == nil then return end
  local target = nil
  for _, placer in pairs(self.taskPlacers) do
    placer.components.placer:OnUpdate()
    if placer.components.placer.can_build then target = placer end
  end
  if target == nil then return end -- 找不到任何可種植的目標

  -- 如果種子不足 2 個，就嘗試製作
  local recipeName = self.recipes[self.seedPrefab]
  if recipeName and self.opt[self.seedPrefab] and not HasInvItem(self.seedPrefab, 2) then
    act = GetDeepMakeReciptAction(recipeName)
    if act then return act end
  end

  -- 找到目標以後，就開始找種子
  local item = FindOnePlayerItem(function (...) return self:CanDeploy(...) end)
  if item == nil then return end -- 找不到種子，所以停止工作

  return BufferedAction(ThePlayer, nil, ACTIONS.DEPLOY, item, target:GetPosition(), nil, nil, nil, target:GetRotation())
end

--- 判斷 item 是不是目前使用者所選擇要種植的東西
-- @param item 一個場上的道具或是物品欄內的道具
function ChoresPlugin:CanDeploy(item)
  if item == nil then return false end
  local ret = self.deploies[item.prefab] or false
  if type(ret) == "string" then return self.opt[ret] else return result end
end

--- 取得目前的選項
function ChoresPlugin:GetOpt()
  return self.opt
end

--- 當工作開始按鈕發生 hover 事件的時候，就顯示可種植的位置
function ChoresPlugin:OnTaskGainFocus()
  self:ShowPlacer()
end

function ChoresPlugin:ShowPlacer()
  if self.placers ~= nil then return end
  DebugLog("ShowPlacer")

  local placerItem = FindOnePlayerItem(function (...) return self:CanDeploy(...) end)
  if placerItem == nil or placerItem.replica.inventoryitem == nil then return end
  local seedInvitem = placerItem.replica.inventoryitem
  local placerName = seedInvitem:GetDeployPlacerName()
  self.gap = seedInvitem:DeploySpacingRadius() + env.CONFIG.planting_margin

  local planting_x = CONFIG.planting_x
  local planting_y = CONFIG.planting_y
  local offset_center_x = (planting_x - 1) * self.gap / 2
  self.placers = {}

  for xOff = 0, planting_x - 1, 1 do
    for zOff = 0, planting_y - 1, 1 do
      local deployPlacer = self:SpawnDeployPlacer(placerName, placerItem)
      deployPlacer.offset = Vector3( xOff * self.gap - offset_center_x, 0, (zOff + 1) * self.gap)
    end
  end
  chores:IncUpdatingLv(1)
  self:OnUpdate(0)
end

local function PlacerOnUpdate(self, dt)
  local inst = self.inst
  -- copy from placer.lua:76
  if self.testfn ~= nil then
      self.can_build, self.mouse_blocked = self.testfn(inst:GetPosition(), inst:GetRotation())
  else
      self.can_build = true
      self.mouse_blocked = false
  end
  local color = self.can_build and Vector3(.25,.75,.25) or Vector3(.75,.25,.25)
  if self.mouse_blocked then
      self.inst:Hide()
      for i, v in pairs(self.linked) do
          v:Hide()
      end
  else
      self.inst.AnimState:SetAddColour(color.x, color.y, color.z, 0)
      self.inst:Show()
      for i, v in pairs(self.linked) do
          v.AnimState:SetAddColour(color.x, color.y, color.z, 0)
          v:Show()
      end
  end
end

function ChoresPlugin:PlacerTestFn(pt, rot)
  local mouseover = FindEntityByPos(pt, 0.1)
  local placerItem = FindOnePlayerItem(function (...) return self:CanDeploy(...) end)

  -- if we can make seed, can_build = true and hide all placer
  if placerItem == nil then
    for recipeName, icon in pairs(self.recipes) do
      if self.opt[icon] and CanDeepMakeRecipt(recipeName) then return true, true end
    end
  end
  -- if something at point or camera heading not a multiple of 45 then hide
  return placerItem ~= nil and placerItem:IsValid() and placerItem.replica.inventoryitem and placerItem.replica.inventoryitem:CanDeploy(pt, mouseover), mouseover ~= nil or Fcmp(math.fmod(TheCamera:GetHeading(), 45), 0) ~= 0
end

local function PlacerReposition (self, snapPlayerToMeters)
  local pos1 = GetPositionByPlayerDirection(self.offset.x, self.offset.z)
  self.Transform:SetPosition((pos1 - snapPlayerToMeters):Get())

  if self.fixedcameraoffset ~= nil then
    local rot = self.fixedcameraoffset - TheCamera:GetHeading()
    self.inst.Transform:SetRotation(rot)
    for i, v in pairs(self.linked) do
      v.Transform:SetRotation(rot)
    end
  end
end

function ChoresPlugin:SpawnDeployPlacer(placerName, placerItem)
  local deployPlacer = SpawnPrefab(placerName)
  deployPlacer.components.placer:SetBuilder(ThePlayer, nil, placerItem)
  table.insert(self.placers, deployPlacer)

  deployPlacer.components.placer.OnUpdate = PlacerOnUpdate
  deployPlacer.components.placer.testfn = function (...) return self:PlacerTestFn(...) end
  deployPlacer.reposition = PlacerReposition
  return deployPlacer
end

function ChoresPlugin:OnUpdate(dt)
  if self.placers then
    -- regenerate Snap Player to Meters
    local deg = TheCamera:GetHeading() * DEGREES
    local p1 = ThePlayer:GetPosition()
    local p2 = Vector3RotateDeg(p1, -deg)
    local p3 = p2 - Vector3((math.floor(p2.x / self.gap) + .5) * self.gap, 0, (math.floor(p2.z / self.gap) + .5) * self.gap)
    local snapPlayerToMeters = Vector3RotateDeg(p3, deg)
    -- DiffPrint("ChoresPlugin:OnUpdate", "deg = "..TheCamera:GetHeading()..", p1 = "..tostring(p1)..", p2 = "..tostring(p2)..", p3 = "..tostring(p3)..", snapPlayerToMeters = "..tostring(snapPlayerToMeters))

    for k, v in pairs(self.placers) do
      v:reposition(snapPlayerToMeters)
      v.components.placer:OnUpdate(dt)
    end
  end
end

function ChoresPlugin:OnTaskLoseFocus()
  self:HidePlacer()
end

function ChoresPlugin:HidePlacer()
  if self.placers == nil then return end
  for ik, iv in pairs(self.placers) do
    iv:Remove()
  end
  self.placers = nil
  chores:IncUpdatingLv(-1)
end

function ChoresPlugin:OnOptClick(icon)
  -- 這個功能的選項是單選的
  local changed = {icon}
  for ik, iv in pairs(self.opt) do
    if iv then table.insert(changed, ik) end
  end
  -- 紀錄目前選了什麼
  self.seedPrefab = icon
  return changed
end

function ChoresPlugin:OnStartTask()
  self:OnStopTask()
  self.isTaskDoing = true
  self:SaveTaskPlacers()
end

function ChoresPlugin:ClearTaskPlacers()
  if self.taskPlacers == nil then return end
  for ik, iv in pairs(self.taskPlacers) do
    iv:Remove()
  end
  self.taskPlacers = nil
end

function ChoresPlugin:SaveTaskPlacers()
  self:ClearTaskPlacers()
  self.taskPlacers = self.placers
  self.placers = nil
end

function ChoresPlugin:OnStopTask()
  self.isTaskDoing = false
  self:ClearTaskPlacers()
end

function ChoresPlugin:OnForceStop()
  self:OnStopTask()
  self:HidePlacer()
end

choresplugin = ChoresPlugin()
