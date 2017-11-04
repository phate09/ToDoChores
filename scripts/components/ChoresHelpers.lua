-- global require
require = GLOBAL.require
Inspect = require("components/inspect")

-- global alias
ACTIONS = GLOBAL.ACTIONS
AllRecipes = GLOBAL.AllRecipes
ANCHOR_BOTTOM = GLOBAL.ANCHOR_BOTTOM
ANCHOR_LEFT = GLOBAL.ANCHOR_LEFT
ANCHOR_MIDDLE = GLOBAL.ANCHOR_MIDDLE
ANCHOR_RIGHT = GLOBAL.ANCHOR_RIGHT
BufferedAction = GLOBAL.BufferedAction
BUTTONFONT = GLOBAL.BUTTONFONT
CONTROL_ACTION = GLOBAL.CONTROL_ACTION
CONTROL_ATTACK = GLOBAL.CONTROL_ATTACK
CONTROL_CANCEL = GLOBAL.CONTROL_CANCEL
CONTROL_CONTROLLER_ACTION = GLOBAL.CONTROL_CONTROLLER_ACTION
CONTROL_MAP = GLOBAL.CONTROL_MAP
CONTROL_MOVE_DOWN = GLOBAL.CONTROL_MOVE_DOWN
CONTROL_MOVE_LEFT = GLOBAL.CONTROL_MOVE_LEFT
CONTROL_MOVE_RIGHT = GLOBAL.CONTROL_MOVE_RIGHT
CONTROL_MOVE_UP = GLOBAL.CONTROL_MOVE_UP
CONTROL_PAUSE = GLOBAL.CONTROL_PAUSE
CONTROL_PRIMARY = GLOBAL.CONTROL_PRIMARY
CONTROL_SECONDARY = GLOBAL.CONTROL_SECONDARY
DataDumper = GLOBAL.DataDumper
DEGREES = GLOBAL.DEGREES
ENCODE_SAVES = GLOBAL.ENCODE_SAVES
EQUIPSLOTS = GLOBAL.EQUIPSLOTS
error = GLOBAL.error
FindEntity = GLOBAL.FindEntity
IsPaused = GLOBAL.IsPaused
KEY_ALT = GLOBAL.KEY_ALT
kleiloadlua = GLOBAL.kleiloadlua
KnownModIndex = GLOBAL.KnownModIndex
MAX_HUD_SCALE = GLOBAL.MAX_HUD_SCALE
ModInfoname = GLOBAL.ModInfoname
NEWFONT = GLOBAL.NEWFONT
PI = GLOBAL.PI
RADIANS = GLOBAL.RADIANS
RPC = GLOBAL.RPC
RunInSandboxSafe = GLOBAL.RunInSandboxSafe
SavePersistentString = GLOBAL.SavePersistentString
SCALEMODE_FILLSCREEN = GLOBAL.SCALEMODE_FILLSCREEN
SCALEMODE_PROPORTIONAL = GLOBAL.SCALEMODE_PROPORTIONAL
SendRPCToServer = GLOBAL.SendRPCToServer
setfenv = GLOBAL.setfenv
SpawnPrefab = GLOBAL.SpawnPrefab
STRINGS = GLOBAL.STRINGS
TheCamera = GLOBAL.TheCamera
TheFrontEnd = GLOBAL.TheFrontEnd
TheInput = GLOBAL.TheInput
ThePlayer = GLOBAL.ThePlayer
TheSim = GLOBAL.TheSim
UIFONT = GLOBAL.UIFONT
Vector3 = GLOBAL.Vector3

-- global variables
BUTTON_REPEAT_COOLDOWN = 0.5
SEE_DIST_LOOT = 5
SEE_DIST_WORK_TARGET = 25
DEBUG = false

function ToLowerCase(str)
  if type(str) == "string" then
    str = str:lower():byte()
  end
  return str
end

function IsWorkshopMod()
  local workshop_prefix = "workshop-"
  return modname:sub( 1, workshop_prefix:len() ) == workshop_prefix
end

function IsDefaultScreen()
  local active_screen = TheFrontEnd:GetActiveScreen()
  return active_screen ~= nil and active_screen.name:find("HUD") ~= nil
end

function UpdateSettings()
  local config = KnownModIndex:GetModConfigurationOptions_Internal(modname, false)
  env.CONFIG = {}
  for i, v in pairs(config) do
    if v.saved ~= nil then
      env.CONFIG[v.name] = v.saved
    else
      env.CONFIG[v.name] = v.default
    end
  end
  env.CONFIG.togglekey = ToLowerCase(env.CONFIG.togglekey)
end

function GetPlayerActiveItem()
  return ThePlayer.replica.inventory:GetActiveItem()
end

function GetAllInventoryItems()
  return ThePlayer.replica.inventory:GetItems()
end

function GetAllInventoryEquips()
  return ThePlayer.replica.inventory:GetEquips()
end

function GetInventoryOverflowContainer()
  return ThePlayer.replica.inventory:GetOverflowContainer()
end

function GetAllPlayerItems()
  local items = {}
  local activeItem = GetPlayerActiveItem()
  if activeItem then table.insert(items, activeItem) end
  for k,v in pairs(GetAllInventoryItems()) do table.insert(items, v) end
  for k,v in pairs(GetAllInventoryEquips()) do table.insert(items, v) end

  local overflow = GetInventoryOverflowContainer()
  if overflow then
    local overflowItems = overflow.GetItems and overflow.GetItems() or overflow.slots or nil
    if overflowItems then
      for k, v in pairs(overflowItems) do
        table.insert(items, v)
      end
    end
  end
  return items
end

function FindOnePlayerInvItem(fn)
  for k, v in pairs(GetAllInventoryItems()) do
    if fn(v) then return v end
  end
end

function FindOnePlayerItem(fn)
  local activeItem = GetPlayerActiveItem()
  if fn(activeItem) then return activeItem end

  local invItem = FindOnePlayerInvItem(fn)
  if invItem then return invItem end

  for k, v in pairs(GetAllInventoryEquips()) do
    if fn(v) then return v end
  end

  local overflow = GetInventoryOverflowContainer()
  if overflow then
    local overflowItems = overflow.GetItems and overflow.GetItems() or overflow.slots or nil
    if overflowItems then
      for k, v in pairs(overflowItems) do
        if fn(v) then return v end
      end
    end
  end
  return nil
end

function GetClosestPickupAction(fn)
  local tmp = FindEntity(ThePlayer, SEE_DIST_LOOT, fn, {"_inventoryitem"}, {"fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK"})
  -- DebugLog('GetClosestPickupAction:', tmp)
  if tmp then return BufferedAction(ThePlayer, tmp, ACTIONS.PICKUP) end
end

function EnsureEquipToolOrAction(fn)
  local playerInv = ThePlayer.replica.inventory
  local tmp = nil

  -- equipped
  tmp = playerInv:GetEquippedItem(EQUIPSLOTS.HANDS)
  if fn(tmp) then return tmp, nil end

  -- item in inventory
  tmp = FindOnePlayerInvItem(fn)
  if tmp then return nil, BufferedAction(ThePlayer, nil, ACTIONS.EQUIP, tmp) end

  -- item need pickup
  tmp = GetClosestPickupAction(fn)
  if tmp then return nil, tmp end

  -- need make recipe
  return nil, nil
end

function ReturnActiveItem()
  ThePlayer.replica.inventory:ReturnActiveItem()
end

function EnsureActiveItem(fn)
  local playerInv = ThePlayer.replica.inventory

  -- active item
  local tmp = GetPlayerActiveItem()
  if fn(tmp) then return tmp else ReturnActiveItem() end

  -- item in inventory
  for k, v in pairs(GetAllInventoryItems()) do
    if fn(v) then
      playerInv:TakeActiveItemFromAllOfSlot(k)
      return v
    end
  end

  for k, v in pairs(GetAllInventoryEquips()) do
    if fn(v) then
      playerInv:TakeActiveItemFromAllOfSlot(k)
      return v
    end
  end

  local overflow = GetInventoryOverflowContainer()
  if overflow then
    local overflowItems = overflow.GetItems and overflow.GetItems() or overflow.slots or nil
    if overflowItems then
      for k, v in pairs(overflowItems) do
        if fn(v) then
          overflow:TakeActiveItemFromAllOfSlot(k)
          return v
        end
      end
    end
  end
  return nil -- need make recipe
end

-- get offset position corresponding the current position and rotation of ThePlayer
function GetPositionByPlayerDirection(xdir, ydir)
  return ThePlayer:GetPosition() + (TheCamera:GetRightVec() * xdir - TheCamera:GetDownVec() * ydir)
end

function FindEntityByPos(pos, radius, fn, musttags, canttags, mustoneoftags)
  local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, radius, musttags, canttags, mustoneoftags)
  for i, v in ipairs(ents) do
    if v.entity:IsVisible() and (fn == nil or fn(v)) then
      return v
    end
  end
end

function GetDeployActionByDeployPlacer(deployplacer)
  local act = nil
  if deployplacer
    and deployplacer.components.placer
    and deployplacer.components.placer.can_build
    then
    act = deployplacer.components.placer:GetDeployAction()
    if act ~= nil then
      act.distance = 1
      act.control = CONTROL_CONTROLLER_ACTION
    end
  end
  return act
end

function CanMakeRecipt(recipeName)
  local recipe = AllRecipes[recipeName]
  local builder = ThePlayer.replica.builder
  return recipe and builder:KnowsRecipe(recipe.name) and builder:CanBuild(recipe.name) and recipe
end

function GetMakeReciptAction(recipeName)
  local recipe = CanMakeRecipt(recipeName)
  return recipe and BufferedAction(ThePlayer, nil, ACTIONS.BUILD, nil, nil, recipe.name, 1)
end

function RpcMakeRecipeFromMenu(recipeName)
  local recipe = CanMakeRecipt(recipeName)
  local builder = ThePlayer.replica.builder
  -- need to check if builder is busy
  if recipe and not builder:IsBusy() then builder:MakeRecipeFromMenu(recipe) end
end

function RpcUseItemFromInvTile(item)
  if item and ThePlayer.replica.inventory then
    ThePlayer.replica.inventory:UseItemFromInvTile(item)
  end
end

function HasItemOrCanMake(fn, recipeName)
  return (FindOnePlayerItem(fn) or CanMakeRecipt(recipeName)) and true or false
end

function GetLeftClickAction(pos, target)
  return ThePlayer.components.playeractionpicker:GetLeftClickActions(pos, target)[1]
end

function GetRightClickAction(pos, target)
  return ThePlayer.components.playeractionpicker:GetRightClickActions(pos, target)[1]
end

function DebugLog(...)
  if not DEBUG then return end

  local args = {...}
  local logstr = ''
  for ik, iv in pairs(args) do
    logstr = logstr .. '\n' .. DataDumper(self.opts, nil, fastmode)
  end
  print(logstr)
end

local DiffPrintCache = {}
function DiffPrint(key, val)
  if not DEBUG then return end

  if type(key) == "string" and type(val) == "string" then
    if DiffPrintCache[key] ~= val then print(key .. " = " .. val) end
    DiffPrintCache[key] = val
  end
end

function Vector3RotateDeg(p, deg)
  return Vector3(
    p.x * math.cos(deg) - p.z * math.sin(deg),
    0,
    p.x * math.sin(deg) + p.z * math.cos(deg)
  )
end

function Fcmp(fa, fb)
  local delta = 0.000001
  local diff = fa - fb
  if diff < -delta then return -1 else return diff > delta and 1 or 0 end
end

UpdateSettings() -- init setting

if not IsWorkshopMod() then DEBUG = true end -- if not workshop mod then turn on DebugLog()

-- local debug = {}
-- for ik, iv in pairs(env) do
--   if type(iv) == "function" then
--     debug[ik] = "function"
--   elseif type(iv) == "table" then
--     debug[ik] = "table"
--   elseif type(iv) == "userdata" then
--     debug[ik] = "userdata"
--   elseif type(iv) == "thread" then
--     debug[ik] = "thread"
--   else
--     debug[ik] = iv
--   end
-- end
-- print(Inspect(debug))
