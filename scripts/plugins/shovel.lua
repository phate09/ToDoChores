--- To Do Chores Shovel Plugin
-- @module choresPluginShovel

local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false
  self:InitWorld()
end)

function ChoresPlugin:InitWorld()
  self.opt = {
    dug_grass = true,
    dug_berrybush = true,
    dug_berrybush_juicy = true,
    dug_sapling = true,
    log = false,
  }

  self.pickups = {
    berries = "dug_berrybush",
    berries_juicy = "dug_berrybush",
    cutgrass = "dug_grass",
    dug_berrybush = "dug_berrybush",
    dug_berrybush2 = "dug_berrybush",
    dug_berrybush_juicy = "dug_berrybush_juicy",
    dug_grass = "dug_grass",
    dug_sapling = "dug_sapling",
    log = "log",
    twigs = "dug_sapling",
  }

  self.digs = {
    grass = "dug_grass",
    berrybush = "dug_berrybush",
    berrybush2 = "dug_berrybush",
    berrybush_juicy = "dug_berrybush_juicy",
    sapling = "dug_sapling",
  }
end

function ChoresPlugin:GetAction(item)
  -- find something can pickup
  local act = GetClosestPickupAction(function(...) return self:CanPickup(...) end)
  if act then return act end

  -- find something can dig
  local target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, function(...) return self:CanDig(...) end, {"DIG_workable"}, {"withered", "diseased", "fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"})
  if target == nil then return end -- can not find target

  -- now we have target, let's ensure tool
  local tool = nil
  tool, act = EnsureHandToolOrAction(function(item) return item and item:HasTag('DIG_tool') end)
  if act then return act end

  -- while tool not found, try to make one or return nil to stop task
  if tool == nil then return CONFIG.use_gold_tools and GetMakeReciptAction("goldenshovel") or GetMakeReciptAction("shovel") or nil end

  return BufferedAction(ThePlayer, target, ACTIONS.DIG, tool)
end

function ChoresPlugin:CanPickup(item)
  if item == nil then return false end
  local result = self.pickups[item.prefab] or false
  if type(result) == "string" then return self.opt[result] else return result end
end

function ChoresPlugin:CanDig(item) -- tag: DIG_workable
  if item == nil then return false end
  -- dig stump
  if item:HasTag("stump") then return self.opt["log"] end
  local result = self.digs[item.prefab] or false
  if type(result) == "string" then return self.opt[result] else return result end
end

local function isDigTool(item)
  if item == nil then return false end
  return item:HasTag('DIG_tool')
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
