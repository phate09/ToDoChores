--- To Do Chores Pickaxe Plugin
-- @module choresPluginPickaxe

local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false
  self:InitWorld()
end)

function ChoresPlugin:InitWorld()
  self.opt = {
    fossil_piece = false,
    goldnugget = true,
    ice = false,
    marble = false,
    moonglass = false,
    moonrocknugget = false,
    nitre = false,
    redgem = true,
    rock_avocado_fruit_rockhard = false,
    rocks = false,
  }

  self.pickups = {
    bluegem = "redgem",
    flint = true,
    fossil_piece = "fossil_piece",
    goldnugget = "goldnugget",
    greengem = "redgem",
    ice = "ice",
    marble = "marble",
    marblebean = "marble",
    moonglass = "moonglass",
    moonrocknugget = "moonrocknugget",
    nitre = "nitre",
    opalpreciousgem = "redgem",
    orangegem = "redgem",
    purplegem = "redgem",
    redgem = "redgem",
    rock_avocado_fruit_ripe = "rock_avocado_fruit_rockhard",
    rock_avocado_fruit_sprout = "rock_avocado_fruit_rockhard",
    rocks = true,
    yellowgem = "redgem",
  }

  -- see rocks.lua
  self.mines = {
    cavein_boulder = "rocks",
    gargoyle_houndatk = "moonrocknugget",
    gargoyle_hounddeath = "moonrocknugget",
    gargoyle_werepigatk = "moonrocknugget",
    gargoyle_werepigdeath = "moonrocknugget",
    gargoyle_werepighowl = "moonrocknugget",
    hotspring = "moonglass",
    marblepillar = "marble",
    marbleshrub = "marble",
    marbletree = "marble",
    moonglass_rock = "moonglass",
    rock_avocado_fruit = "rock_avocado_fruit_rockhard",
    rock_flintless = "rocks",
    rock_flintless_low = "rocks",
    rock_flintless_med = "rocks",
    rock_ice = "ice",
    rock_moon = "moonrocknugget",
    rock_moon_shell = "moonrocknugget",
    rock_petrified_tree = "nitre",
    rock_petrified_tree_med = "nitre",
    rock_petrified_tree_old = "nitre",
    rock_petrified_tree_short = "nitre",
    rock_petrified_tree_tall = "nitre",
    rock1 = "nitre",
    rock2 = "goldnugget",
    sculpture_bishopbody = "marble",
    sculpture_knightbody = "marble",
    sculpture_rookbody = "marble",
    stalagmite = "goldnugget",
    stalagmite_full = "goldnugget",
    stalagmite_low = "goldnugget",
    stalagmite_med = "goldnugget",
    stalagmite_tall = "goldnugget",
    stalagmite_tall_full = "goldnugget",
    stalagmite_tall_low = "goldnugget",
    stalagmite_tall_med = "goldnugget",
    statue_marble = "marble",
    statueharp = "marble",
  }

  self.emptyAnims = {
    -- rock_ice
    "melted",
    "dryup",
    -- marbleshrub
    "idle_short",
    "hit_short",
    "mined_short",
    "grow_tall_to_short",
    "idle_normal",
    "hit_normal",
    "mined_normal",
    "grow_short_to_normal",
    "grow_normal_to_tall",
  }
end

function ChoresPlugin:GetAction()
  -- find something can pickup
  local act = GetClosestPickupAction(function(...) return self:CanPickup(...) end)
  if act then return act end

  -- find something to mine
  local target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, function(...) return self:CanMine(...) end, {"MINE_workable"})
  if target == nil then return end -- can not find target

  -- now we have target, let's ensure tool
  local tool = nil
  tool, act = EnsureHandToolOrAction(function(item) return item and item:HasTag('MINE_tool') end)
  if act then return act end

  -- while tool not found, try to make one or return nil to stop task
  if tool == nil then return CONFIG.use_gold_tools and GetMakeReciptAction("goldenpickaxe") or GetMakeReciptAction("pickaxe") or nil end

  return BufferedAction(ThePlayer, target, ACTIONS.MINE, tool)
end

function ChoresPlugin:CanPickup(item)
  return CanBeAction(self.pickups, self.opt, item)
end

function ChoresPlugin:CanMine(item) -- tags: Mine_workable
  if item == nil then return false end

  -- if is empty or not worth to mine
  for ik, iv in pairs(self.emptyAnims) do
    if item.AnimState:IsCurrentAnimation(iv) then return false end
  end

  return CanBeAction(self.mines, self.opt, item)
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
