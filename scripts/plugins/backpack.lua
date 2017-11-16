--- To Do Chores Backpack Plugin
-- @module choresPluginBackpack

local ChoresPlugin = Class(function(self)
  self.isTaskDoing = false
  self:InitWorld()
end)

function ChoresPlugin:InitWorld()
  if IS_CAVE then
    self.opt = {
      berries = true,
      carrot = true,
      cave_banana = true,
      cutgrass = true,
      cutlichen = true,
      flint = true,
      foliage = true,
      green_cap = true,
      guano = true,
      lightbulb = true,
      twigs = true,
      wormlight = true,
    }

    self.pickups = {
      berries = "berries",
      berries_juicy = "berries",
      blue_cap = "green_cap",
      carrot = "carrot",
      cave_banana = "cave_banana",
      cutgrass = "cutgrass",
      cutlichen = "cutlichen",
      fertilizer = "guano",
      flint = "flint",
      foliage = "foliage",
      glommerfuel = "guano",
      green_cap = "green_cap",
      guano = "guano",
      lightbulb = "lightbulb",
      poop = "guano",
      red_cap = "green_cap",
      rottenegg = "guano",
      spoiled_food = "guano",
      twigs = "twigs",
      wormlight = "wormlight",
      wormlight_lesser = "wormlight",
    }

    self.picks = {
      berrybush = "berries",
      berrybush2 = "berries",
      berrybush_juicy = "berries",
      blue_mushroom = "green_cap",
      carrot_planted = "carrot",
      cave_banana_tree = "cave_banana",
      cave_fern = "foliage",
      flower_cave = "lightbulb",
      flower_cave_double = "lightbulb",
      flower_cave_triple = "lightbulb",
      grass = "cutgrass",
      green_mushroom = "green_cap",
      lichen = "cutlichen",
      red_mushroom = "green_cap",
      sapling = "twigs",
      wormlight_plant = "wormlight",
    }
  else
    self.opt = {
      berries = true,
      carrot = true,
      cutgrass = true,
      flint = true,
      green_cap = true,
      guano = true,
      petals = false,
      twigs = true,
    }

    self.pickups = {
      berries = "berries",
      berries_juicy = "berries",
      blue_cap = "green_cap",
      carrot = "carrot",
      cutgrass = "cutgrass",
      fertilizer = "guano",
      flint = "flint",
      glommerfuel = "guano",
      green_cap = "green_cap",
      guano = "guano",
      petals = "petals",
      poop = "guano",
      red_cap = "green_cap",
      rottenegg = "guano",
      spoiled_food = "guano",
      twigs = "twigs",
    }

    self.picks = {
      berrybush = "berries",
      berrybush2 = "berries",
      berrybush_juicy = "berries",
      blue_mushroom = "green_cap",
      carrot_planted = "carrot",
      flower = "petals",
      flower_rose = "petals",
      grass = "cutgrass",
      green_mushroom = "green_cap",
      planted_flower = "petals",
      red_mushroom = "green_cap",
      sapling = "twigs",
    }
  end
end

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
