local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false

  -- options
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
end)

function ChoresPlugin:GetAction()
  -- find something can pickup
  local act = GetClosestPickupAction(function(...) return self:isDryable(...) end)
  if act then return act end

  -- find some item dryable
  local invitem = EnsureActiveItem(function(...) return self:isDryable(...) end)

  local target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, function(item)
    if item == nil then return false end
    return item:HasTag("dried") or (invitem)
  end, nil, {"fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"}, {"candry", "dried"})

  if target then
    if invitem and target:HasTag("candry") then
      return GetLeftClickAction(target:GetPosition(), target)
    else
      return BufferedAction(self.inst, target, ACTIONS.HARVEST)
    end
  end
  ReturnActiveItem()
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
