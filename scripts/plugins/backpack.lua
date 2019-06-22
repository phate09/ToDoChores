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
      cutreeds = false,
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
      cutreeds = "cutreeds",
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
      berrybush_juicy = "berries",
      berrybush2 = "berries",
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
      reeds = "cutreeds",
      sapling = "twigs",
      wormlight_plant = "wormlight",
    }
  else
    self.opt = {
      berries = true,
      carrot = true,
      cutgrass = true,
      cutreeds = false,
      flint = true,
      green_cap = true,
      guano = true,
      kelp = true,
      petals = false,
      rock_avocado_fruit_rockhard = false,
      seeds = true,
      twigs = true,
    }

    self.pickups = {
      berries = "berries",
      berries_juicy = "berries",
      blue_cap = "green_cap",
      bullkelp_beachedroot = "kelp",
      carrot = "carrot",
      carrot_seeds = "seeds",
      corn_seeds = "seeds",
      cutgrass = "cutgrass",
      cutreeds = "cutreeds",
      dragonfruit_seeds = "seeds",
      durian_seeds = "seeds",
      eggplant_seeds = "seeds",
      fertilizer = "guano",
      flint = "flint",
      glommerfuel = "guano",
      green_cap = "green_cap",
      guano = "guano",
      petals = "petals",
      pomegranate_seeds = "seeds",
      poop = "guano",
      pumpkin_seeds = "seeds",
      red_cap = "green_cap",
      rock_avocado_fruit = "rock_avocado_fruit_rockhard",
      rottenegg = "guano",
      seeds = "seeds",
      spoiled_food = "guano",
      twigs = "twigs",
      watermelon_seeds = "seeds",
    }

    self.picks = {
      berrybush = "berries",
      berrybush_juicy = "berries",
      berrybush2 = "berries",
      blue_mushroom = "green_cap",
      bullkelp_plant = "kelp",
      carrot_planted = "carrot",
      flower = "petals",
      flower_rose = "petals",
      grass = "cutgrass",
      green_mushroom = "green_cap",
      planted_flower = "petals",
      red_mushroom = "green_cap",
      reeds = "cutreeds",
      rock_avocado_bush = "rock_avocado_fruit_rockhard",
      sapling = "twigs",
      sapling_moon = "twigs",
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

  if item:HasTag("pickable") then
    return CanBeAction(self.picks, self.opt, item)
  else
    return CanBeAction(self.pickups, self.opt, item)
  end
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
