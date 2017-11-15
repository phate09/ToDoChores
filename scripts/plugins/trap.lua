local triggeredTrapAnims = {
  "side",
  "trap_loop",
}

local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false
  self.trapOldPos = nil

  -- options
  self.opt = {
    rabbit = true,
    smallmeat = true,
    froglegs = true,
    silk = true,
    spidergland = true,
    monstermeat = true,
    spoiled_food = false,
  }

  self.pickups = {
    smallmeat = "smallmeat",
    froglegs = "froglegs",
    silk = "silk",
    spidergland = "spidergland",
    monstermeat = "monstermeat",
    spoiled_food = "spoiled_food",
  }

end)

local function isTrap(item)
  return item and item.prefab == "trap"
end

local function isTrapTriggered(item)
  if isTrap(item) then
    for ik, iv in pairs(triggeredTrapAnims) do
      if item.AnimState:IsCurrentAnimation(iv) then return true end
    end
  end
  return false
end

local function isNoTrapRabbithole(item)
  return item and item.prefab == "rabbithole" and FindEntity(item, 1, isTrap) == nil
end

function ChoresPlugin:GetAction()
  local act = nil

  -- let's try to drop trap if old trap position exists
  if self.trapOldPos then
    act = self:forceDropTrap(self.trapOldPos)
    self.trapOldPos = nil
    if act then return act end
  end

  -- find something can pickup
  act = GetClosestPickupAction(function(...) return self:CanPickup(...) end)
  if act then return act end

  -- check if we have trap or can make a trap
  local hasTrapOrCanMake = HasItemOrCanMake(isTrap, 'trap')

  -- find a cloest triggered trap or rabbit hole which is no trap
  local target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, function(item)
    if isTrapTriggered(item) then
      self.trapOldPos = item:GetPosition()
      return true
    end
    return hasTrapOrCanMake and self.opt["rabbit"] and isNoTrapRabbithole(item)
  end, nil, {"fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"})

  -- if the target is triggered trap
  if self.trapOldPos then
    ReturnActiveItem()
    chores.skipUpdatePC = 20
    return GetLeftClickAction(self.trapOldPos, target)
  end

  -- if the target is a rabbit hole which is no trap
  if target then
    act = self:forceDropTrap(target:GetPosition())
    if act then return act end
  end

  ReturnActiveItem()
end

function ChoresPlugin:forceDropTrap(pos)
  if FindEntityByPos(pos, 1, isTrap) ~= nil then return end
  chores.skipUpdatePC = 20

  return EnsureActiveItem(isTrap) and GetLeftClickAction(pos, nil) or GetMakeReciptAction("trap")
end

function ChoresPlugin:CanPickup(item)
  if item == nil then return false end
  local result = self.pickups[item.prefab] or false
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
