--- To Do Chores Smallmeat Dried Plugin
-- @module choresPluginSmallmeatDried

local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false
  self:InitWorld()
end)

function ChoresPlugin:InitWorld()
  self.opt = {
    smallmeat = true,
    meat = true,
    monstermeat = false,
    froglegs = false,
    fish = false,
    drumstick = false,
    eel = false,
    batwing = false,
  }

  self.dries = {
    smallmeat = "smallmeat",
    drumstick = "drumstick",
    batwing = "batwing",
    fish = "fish",
    froglegs = "froglegs",
    eel = "eel",
    monstermeat = "monstermeat",
    meat = "meat",
  }
end

function ChoresPlugin:GetAction()
  local target

  -- 撿地板上可以曬的東西
  local act = GetClosestPickupAction(function(...) return self:isDryable(...) end)
  if act then return act end

  -- 尋找空的曬肉架
  target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, nil, {"candry"}, {"fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"})

  -- 如果找到東西可以曬
  if target then
    -- 找物品欄內可以曬的東西
    local invitem = EnsureActiveItem(function(...) return self:isDryable(...) end)
    if invitem then return GetLeftClickAction(target:GetPosition(), target) end
  end

  -- 找可以收成的曬肉架
  ReturnActiveItem() -- 把東西放回物品欄
  target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, nil, {"dried"}, {"fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"})
  if target then return GetLeftClickAction(target:GetPosition(), target) end
end

function ChoresPlugin:isDryable(item)
  local result = item and self.dries[item.prefab] or false
  if type(result) == "string" then return self.opt[result] else return result end
end

function ChoresPlugin:GetOpt()
  return self.opt
end

function ChoresPlugin:OnStartTask()
  self:OnStopTask()
  self.isTaskDoing = true
end

function ChoresPlugin:OnStopTask()
  self.isTaskDoing = false
end

function ChoresPlugin:OnForceStop()
  self:OnStopTask()
end

choresplugin = ChoresPlugin()
