local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false

  -- options
  self.opt = {
    nitre = false,
    goldnugget = true,
    rocks = false,
    ice = false,
    moonrocknugget = false,
    marble = false,
  }

  self.pickups = {
    flint = true,
    rocks = true,
    nitre = "nitre",
    goldnugget = "goldnugget",
    ice = "ice",
    moonrocknugget = "moonrocknugget",
    marble = "marble",
    marblebean = "marble",
  }

  self.mines = {
    rock1 = "nitre",
    rock_petrified_tree = "nitre",
    rock2 = "goldnugget",
    rock_ice = "ice",
    rock_moon = "moonrocknugget",
    rock_flintless = "rocks",
    marblepillar = "marble",
    marbletree = "marble",
    statueharp = "marble",
    statue_marble = "marble",
    sculpture_rookbody = "marble",
    sculpture_bishopbody = "marble",
    sculpture_knightbody = "marble",
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
end)

function ChoresPlugin:GetAction()
  -- find something can pickup
  local act = GetClosestPickupAction(function(...) return self:CanPickup(...) end)
  if act then return act end

  -- find something to mine
  local target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, function(...) return self:CanMine(...) end, {"MINE_workable"})
  if target == nil then return end -- can not find target

  -- now we have target, let's ensure tool
  local tool = nil
  tool, act = EnsureEquipToolOrAction(function(item) return item and item:HasTag('MINE_tool') end)
  if act then return act end

  -- while tool not found, try to make one or return nil to stop task
  if tool == nil then return CONFIG.use_gold_tools and GetMakeReciptAction("goldenpickaxe") or GetMakeReciptAction("pickaxe") or nil end

  return BufferedAction(ThePlayer, target, ACTIONS.MINE, tool)
end

function ChoresPlugin:CanPickup(item)
  if item == nil then return false end
  local result = self.pickups[item.prefab] or false
  if type(result) == "string" then return self.opt[result] else return result end
end

function ChoresPlugin:CanMine(item) -- tags: Mine_workable
  if item == nil then return false end

  -- if is empty or not worth to mine
  for ik, iv in pairs(self.emptyAnims) do
    if item.AnimState:IsCurrentAnimation(iv) then return false end
  end

  local result = self.mines[item.prefab] or false
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
