--- To Do Chores Axe Plugin
-- @module choresPluginAxe
-- @alias ChoresPlugin

local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false
  self:InitWorld()
end)

function ChoresPlugin:InitWorld()
  self.opt = {
    acorn = true,
    charcoal = false,
    driftwood_log = true,
    green_cap = false,
    moon_tree_blossom = false,
    pinecone = false,
    shovel = false,
    twiggy_nut = true,
  }

  self.pickups = {
    acorn = "acorn",
    blue_cap = "green_cap",
    charcoal = "charcoal",
    driftwood_log = "driftwood_log",
    green_cap = "green_cap",
    log = true,
    moon_tree_blossom = "moon_tree_blossom",
    pinecone = "pinecone",
    red_cap = "green_cap",
    twiggy_nut = "twiggy_nut",
    twigs = true,
  }

  self.chops = {
    deciduoustree = "acorn",
    driftwood_small1 = "driftwood_log",
    driftwood_small2 = "driftwood_log",
    driftwood_tall = "driftwood_log",
    evergreen = "pinecone",
    evergreen_sparse = "pinecone",
    marsh_tree = "twiggy_nut",
    moon_tree = "moon_tree_blossom",
    mushtree_medium = "green_cap",
    mushtree_small = "green_cap",
    mushtree_tall = "green_cap",
    mushtree_tall_webbed = "green_cap",
    twiggytree = "twiggy_nut",
  }

  self.adultTreeAnims = {
    "chop_tall",
    "idle_loop",
    "idle_tall",
    "idle",
    "sway1_loop_tall",
    "sway1_loop",
    "sway2_loop_tall",
    "sway2_loop",
    "sway3_loop",
    "sway4_loop",
  }
end

function ChoresPlugin:GetAction()
  local target = nil
  local tool = nil

  -- find something can pickup
  local act = GetClosestPickupAction(function(...) return self:CanBePickup(...) end)
  if act then return act end

  if self.opt['shovel'] then
    -- find stump
    target = FindEntity(ThePlayer, SEE_DIST_LOOT, nil, {"DIG_workable", "stump"}, {"withered", "diseased", "fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"})
  end

  if self.opt['shovel'] and target then
    -- now we have target, let's ensure tool
    tool, act = EnsureHandToolOrAction(function(item) return item and item:HasTag('DIG_tool') end)
    if act then return act end
    -- while tool not found, try to make one or return nil to stop task
    if tool == nil then act = CONFIG.use_gold_tools and GetMakeReciptAction("goldenshovel") or GetMakeReciptAction("shovel") or nil end
    if act then return act end
    -- if we have target and tool then dig
    if tool then return BufferedAction(ThePlayer, target, ACTIONS.DIG, tool) end
  end

  -- find something can chop
  target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, function(...) return self:CanBeChop(...) end, {"CHOP_workable"}, {"fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"})
  if target == nil then return end -- can not find target

  -- now we have target, let's ensure tool
  tool, act = EnsureHandToolOrAction(function(item) return item and item:HasTag('CHOP_tool') end)
  if act then return act end

  -- while tool not found, try to make one or return nil to stop task
  if tool == nil then return CONFIG.use_gold_tools and GetMakeReciptAction("goldenaxe") or GetMakeReciptAction("axe") or nil end

  return BufferedAction(ThePlayer, target, ACTIONS.CHOP, tool)
end

function ChoresPlugin:CanBePickup(item)
  return CanBeAction(self.pickups, self.opt, item)
end

function ChoresPlugin:CanBeChop(item) -- tags: CHOP_workable
  if item == nil or not item:HasTag("tree") then return false end
  if item:HasTag("burnt") then return self.opt["charcoal"] end

  -- adult tree
  if CONFIG.cut_adult_tree_only then
    if TheWorld.state.iswinter and item.prefab == "deciduoustree" then return false end
    for ik, iv in pairs(self.adultTreeAnims) do
      if item.AnimState:IsCurrentAnimation(iv) then return CanBeAction(self.chops, self.opt, item) end
    end
    return false
  end

  return CanBeAction(self.chops, self.opt, item)
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
