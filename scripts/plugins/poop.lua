--- To Do Chores Poop Plugin
-- @module choresPluginPoop

local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false
  self:InitWorld()
end)

function ChoresPlugin:InitWorld()
  self.opt = {
    poop = false,
    spoiled_food = true,
    fertilizer = true,
    guano = true,
    rottenegg = false,
    glommerfuel = false,
  }

  self.fertilizes = {
    poop = "poop",
    guano = "guano",
    spoiled_food = "spoiled_food",
    rottenegg = "rottenegg",
    fertilizer = "fertilizer",
    glommerfuel = "glommerfuel",
  }

  self.recipes = {
    fertilizer = "fertilizer",
  }
end

function ChoresPlugin:GetAction()
  -- find something can pickup
  local act = GetClosestPickupAction(function(...) return self:isFertilizer(...) end)
  if act then return act end

  -- find something can fertilize
  local target = FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, nil, nil, {"tree", "fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"}, {"withered", "barren"})
  -- 找不到任何可施肥的目標，把手上的東西放回物品欄
  if target == nil then return ReturnActiveItem() end

  -- now we have target, let's find fertilizer
  local item = EnsureActiveItem(function(...) return self:isFertilizer(...) end)
  if item == nil then
    for recipeName, icon in pairs(self.recipes) do
      if self.opt[icon] then
        act = GetMakeReciptAction(recipeName)
        if act then return act end
      end
    end
    -- no fertilizer, so stop the task
    return
  end

  return BufferedAction(ThePlayer, target, ACTIONS.FERTILIZE, item, target:GetPosition())
end

function ChoresPlugin:isFertilizer(item)
  return CanBeAction(self.fertilizes, self.opt, item)
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
