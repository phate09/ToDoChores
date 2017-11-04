local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false

  -- options
  self.opt = {
    flint = true,
    cutgrass = true,
    twigs = true,
    berries = true,
    green_cap = true,
    carrot = true,
    petals = false,
    guano = true,
  }

  self.pickups = {
    flint = "flint",
    carrot = "carrot",
    petals = "petals",
    green_cap = "green_cap",
    red_cap = "green_cap",
    blue_cap = "green_cap",
    cutgrass = "cutgrass",
    twigs = "twigs",
    berries = "berries",
    berries_juicy = "berries",
    poop = "guano",
    guano = "guano",
    spoiled_food = "guano",
    rottenegg = "guano",
    fertilizer = "guano",
    glommerfuel = "guano",
  }

  self.picks = {
    carrot_planted = "carrot",
    flower = "petals",
    planted_flower = "petals",
    flower_rose = "petals",
    green_mushroom = "green_cap",
    red_mushroom = "green_cap",
    blue_mushroom = "green_cap",
    grass = "cutgrass",
    sapling = "twigs",
    berrybush = "berries",
    berrybush2 = "berries",
    berrybush_juicy = "berries",
  }
end)

function ChoresPlugin:GetAction()
  -- if holding dig tool, skip pick action that can be dig
  local tool = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
  self.isHoldingDigTool = tool and tool:HasTag("DIG_tool")

  -- find something can pick or pickup
  local target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, function(...) return self:CanPickOrPickup(...) end, nil, {"fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"}, {"pickable", "_inventoryitem"})
  if target == nil then return end

  return target:HasTag("pickable") and BufferedAction(ThePlayer, target, ACTIONS.PICK) or BufferedAction(ThePlayer, target, ACTIONS.PICKUP)
end

function ChoresPlugin:CanPickOrPickup(item)
  if item == nil or (self.isHoldingDigTool and item:HasTag('DIG_workable')) then return false end
  local result = nil
  if item:HasTag("pickable") then result = self.picks[item.prefab] else result = self.pickups[item.prefab] end
  -- ensure result to be false when nil
  if type(result) == "string" then return self.opt[result] else return result or false end
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
