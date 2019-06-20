--- To Do Chores Helper Functions and Variables
-- @module ChoresHelpers

-- global require
require = GLOBAL.require
Inspect = require("components/inspect")
ModConfigurationScreen = require "screens/redux/modconfigurationscreen"

-- global alias
ACTIONS = GLOBAL.ACTIONS
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
GetCurrentLocale = GLOBAL.GetCurrentLocale
GetValidRecipe = GLOBAL.GetValidRecipe
IsPaused = GLOBAL.IsPaused
KEY_ALT = GLOBAL.KEY_ALT
kleiloadlua = GLOBAL.kleiloadlua
KnownModIndex = GLOBAL.KnownModIndex
MAX_HUD_SCALE = GLOBAL.MAX_HUD_SCALE
ModInfoname = GLOBAL.ModInfoname
NEWFONT = GLOBAL.NEWFONT
next = GLOBAL.next
PI = GLOBAL.PI
RADIANS = GLOBAL.RADIANS
rawget = GLOBAL.rawget
RoundBiasedUp = GLOBAL.RoundBiasedUp
RPC = GLOBAL.RPC
RunInEnvironment = GLOBAL.RunInEnvironment
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
TheNet = GLOBAL.TheNet
ThePlayer = GLOBAL.ThePlayer
TheSim = GLOBAL.TheSim
TheWorld = GLOBAL.TheWorld
UIFONT = GLOBAL.UIFONT
Vector3 = GLOBAL.Vector3

-- global variables
BUTTON_REPEAT_COOLDOWN = 0.5
SEE_DIST_LOOT = 5
SEE_DIST_WORK_TARGET = 25
DEBUG = false
IS_CAVE = TheWorld ~= nil and TheWorld:HasTag("cave")
IS_PLAYING_NOW = TheNet:GetIsClient() or TheNet:GetIsServer()
I18N_CODE = nil

--- Transform togglekey from char to key code
-- @helper
-- @param ch the char string
-- @return (integer) key code (lowercase alphabet)
function CharToKeyCode(ch)
  if type(ch) == "string" then
    return ch:lower():byte()
  end
end

--- is the mod downloaded from workshop?
-- This func can determine open DebugLog or not.
-- @helper
-- @return (boolean)
function IsWorkshopMod()
  local workshop_prefix = "workshop-"
  return modname:sub( 1, workshop_prefix:len() ) == workshop_prefix
end

--- Is the current screen default screen?
-- This function is prevent togglekey to be trigger on non-default screen.
-- @helper
-- @return (boolean)
function IsDefaultScreen()
  local active_screen = TheFrontEnd:GetActiveScreen()
  return active_screen and active_screen.name and active_screen.name.find and active_screen.name:find("HUD") ~= nil
end

--- Reload setting.
-- On game start or in game setting save will reload.
-- Game setting will be save to `CONFIG` variable.
-- @helper
-- @return (nil)
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
  env.CONFIG.toggle_chores = CharToKeyCode(env.CONFIG.toggle_chores) or CharToKeyCode('V')
  env.CONFIG.open_settings = CharToKeyCode(env.CONFIG.open_settings) or CharToKeyCode('O')
end

--- Get player's active item.
-- @helper
-- @return (table) inventory active item, or (nil)
function GetPlayerActiveItem()
  return ThePlayer.replica.inventory:GetActiveItem()
end

--- Get player's overflow container.
-- @helper
-- @return (table) overflow container, or (nil)
function GetPlayerOverflowContainer()
  return ThePlayer.replica.inventory:GetOverflowContainer()
end

--- Get player's all invitems. (not include active, equip, overflow)
-- @helper
-- @return (table) inventory items, or (nil)
function GetAllPlayerInvItems()
  return ThePlayer.replica.inventory:GetItems()
end

--- Get player's all equip items.
-- @helper
-- @return (table) equip items, or (nil)
function GetAllPlayerEquips()
  return ThePlayer.replica.inventory:GetEquips()
end

--- Get player's all overflow items.
-- @helper
-- @return (table) overflow items
function GetAllPlayerOverflowItems()
  local overflow = GetPlayerOverflowContainer()
  if not overflow then return {} end
  return overflow.GetItems and overflow:GetItems() or overflow.slots or {}
end

--- Get player's all items. (invitems, actives, equips, overflow items)
-- @helper
-- @return (table) overflow container, or (nil)
function GetAllPlayerItems()
  local items = {}
  local activeItem = GetPlayerActiveItem()
  if activeItem then table.insert(items, activeItem) end
  for k,v in pairs(GetAllPlayerInvItems()) do table.insert(items, v) end
  for k,v in pairs(GetAllPlayerEquips()) do table.insert(items, v) end
  for k,v in pairs(GetAllPlayerOverflowItems()) do table.insert(items, v) end
  return items
end

--- Find player's one invitem. (not include active, equip, overflow)
-- @helper
-- @param fn A judging function to return boolean represent the item you need or not
function FindOnePlayerInvItem(fn)
  for k, v in pairs(GetAllPlayerInvItems()) do
    if fn(v) then return v end
  end
end

--- Find player's one overflow item. (not include active, equip, invitem)
-- @helper
-- @param fn A judging function to return boolean represent the item you need or not
function FindOnePlayerOverflowItem(fn)
  for k, v in pairs(GetAllPlayerOverflowItems()) do
    if fn(v) then return v end
  end
end

--- Find player's one item.
-- @helper
-- @param fn A judging function to return boolean represent the item you need or not
function FindOnePlayerItem(fn)
  local activeItem = GetPlayerActiveItem()
  if fn(activeItem) then return activeItem end

  local invItem = FindOnePlayerInvItem(fn)
  if invItem then return invItem end

  for k, v in pairs(GetAllPlayerEquips()) do
    if fn(v) then return v end
  end

  for k, v in pairs(GetAllPlayerOverflowItems()) do
    if fn(v) then return v end
  end

  return nil
end

--- Find one item to pickup.
-- This function use `SEE_DIST_LOOT` as pickup range.
-- @helper
-- @param fn A judging function to return boolean represent the item you need or not
-- @return (bufferedaction) action need to do, or (nil)
function GetClosestPickupAction(fn)
  local tmp = FindEntity(ThePlayer, SEE_DIST_LOOT, fn, {"_inventoryitem"}, {"fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK", "mineactive", "minesprung"})
  -- DebugLog('GetClosestPickupAction:', tmp)
  if tmp then
    local act = BufferedAction(ThePlayer, tmp, ACTIONS.PICKUP)
    act.skipUpdatePC = 1
    return act
  end
end

--- Ensure player's hand tool is what you need.
-- @helper
-- @param fn A judging function to return boolean represent the tool you need or not
-- @return (handitem) if the current hand is what you need, or (nil)
-- @return (bufferedaction) action need to do, or (nil)
function EnsureHandToolOrAction(fn)
  local playerInv = ThePlayer.replica.inventory
  local tmp = nil

  -- equipped
  tmp = playerInv:GetEquippedItem(EQUIPSLOTS.HANDS)
  if fn(tmp) then return tmp, nil end

  -- item in inventory
  tmp = FindOnePlayerInvItem(fn)
  if tmp then return nil, BufferedAction(ThePlayer, nil, ACTIONS.EQUIP, tmp) end

  -- item in overflow container
  tmp = FindOnePlayerOverflowItem(fn)
  if tmp then return nil, BufferedAction(ThePlayer, nil, ACTIONS.EQUIP, tmp) end

  -- item need pickup
  tmp = GetClosestPickupAction(fn)
  if tmp then return nil, tmp end

  -- need make recipe
  return nil, nil
end

--- Return player's active item to original place
-- @helper
function ReturnActiveItem()
  ThePlayer.replica.inventory:ReturnActiveItem()
end

--- Ensure player's activeitem is what you need.
-- @helper
-- @param fn A judging function to return boolean represent the item you need or not
-- @return (activeitem) if the current activeitem is what you need, or (nil)
-- @return (bufferedaction) action need to do, or (nil)
function EnsureActiveItem(fn)
  local playerInv = ThePlayer.replica.inventory

  -- active item
  local tmp = GetPlayerActiveItem()
  if fn(tmp) then return tmp else ReturnActiveItem() end

  -- item in inventory
  for k, v in pairs(GetAllPlayerInvItems()) do
    if fn(v) then
      playerInv:TakeActiveItemFromAllOfSlot(k)
      return v
    end
  end

  for k, v in pairs(GetAllPlayerEquips()) do
    if fn(v) then
      playerInv:TakeActiveItemFromAllOfSlot(k)
      return v
    end
  end

  local overflow = GetPlayerOverflowContainer()
  for k, v in pairs(GetAllPlayerOverflowItems()) do
    if fn(v) then
      overflow:TakeActiveItemFromAllOfSlot(k)
      return v
    end
  end

  return nil -- need make recipe
end

--- Get offset position corresponding the position of player on screen.
-- @helper
-- @param xdir x direction amount
-- @param ydir y direction amount
-- @return (position) position
function GetPositionByPlayerDirection(xdir, ydir)
  return ThePlayer:GetPosition() + (TheCamera:GetRightVec() * xdir - TheCamera:GetDownVec() * ydir)
end

--- Any position version of FindEntity().
-- @helper
-- @param pos (Vector3) Center of the circle to find
-- @param radius (number) Radius of the circle to find
-- @param fn A judging function to return boolean represent the item you need or not, or (nil)
-- @param musttags (table) entity must have these tags, or (nil)
-- @param canttags (table) entity cannot have these tags, or (nil)
-- @param mustoneoftags (table) entity must have one of these tags, or (nil)
function FindEntityByPos(pos, radius, fn, musttags, canttags, mustoneoftags)
  local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, radius, musttags, canttags, mustoneoftags)
  for i, v in pairs(ents) do
    if v.entity:IsVisible() and (fn == nil or fn(v)) then
      return v
    end
  end
end

--- Get Deploy Action By DeployPlacer
-- @helper
-- @param deployplacer deployplacer
-- @return (bufferedaction) action need to do, or (nil)
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

--- Check if player knows recipe and resource enough
-- @helper
-- @param recipeName
-- @return (boolean) can make recipe or not
function CanMakeRecipt(recipeName)
  local recipe = GetValidRecipe(recipeName)
  local builder = ThePlayer.replica.builder
  return recipe and builder:KnowsRecipe(recipe.name) and builder:CanBuild(recipe.name) and recipe
end

function BuilderIsFreeBuildMode()
  local builder = ThePlayer.components.builder or nil
  local classified = ThePlayer.replica and ThePlayer.replica.builder and ThePlayer.replica.builder.classified or nil
  if builder then return builder.freebuildmode else return classified.isfreebuildmode:value() end
end

--- Make Recipt
-- @helper
-- @param recipeName
-- @return (bufferedaction) action need to do, or (nil)
function GetMakeReciptAction(recipeName)
  local recipe = CanMakeRecipt(recipeName)
  return recipe and BufferedAction(ThePlayer, nil, ACTIONS.BUILD, nil, nil, recipe.name, 1) or nil
end

--- 回傳玩家目前是否有指定數量的物品，以及回傳玩家目前有幾個物品
function HasInvItem(prefab, amount)
  return ThePlayer.replica.inventory:Has(prefab, amount)
end

--- Check if player knows recipe and resource enough (deep version)
-- debug: print(ThePlayer.chores.CanDeepMakeRecipt('trap_teeth', 2))
-- @helper
-- @param recipeName
-- @param amount
-- @return (boolean) can make recipe or not
function CanDeepMakeRecipt(recipeName, amount)
  if amount == nil then amount = 1 end
  local recipe = GetValidRecipe(recipeName)
  local builderReplica = ThePlayer.replica.builder
  if not (recipe and builderReplica:KnowsRecipe(recipe.name)) then return end
  if ThePlayer.components.builder == nil and builderReplica.classified == nil then return end
  if not BuilderIsFreeBuildMode() then
    for i, v in pairs(recipe.ingredients) do
      local requiredCnt = amount * math.max(1, RoundBiasedUp(v.amount * builderReplica:IngredientMod()))
      hasEnoughIngredients, ownedCnt = HasInvItem(v.type, requiredCnt)
      -- DebugLog(v.type .. ': need=' .. requiredCnt .. ', owned=' .. ownedCnt)
      if not (hasEnoughIngredients or CanDeepMakeRecipt(v.type, requiredCnt - ownedCnt)) then return end
    end
  end
  for i, v in pairs(recipe.character_ingredients) do
    if not builderReplica:HasCharacterIngredient(v) then return end
  end
  for i, v in pairs(recipe.tech_ingredients) do
    if not builderReplica:HasTechIngredient(v) then return end
  end
  return recipe
end

--- Make Recipt (deep version)
-- debug: print(ThePlayer.chores.GetDeepMakeReciptAction('trap_teeth'))
-- @helper
-- @param recipeName
-- @return (bufferedaction) action need to do, or (nil)
function GetDeepMakeReciptAction(recipeName)
  local recipe = CanDeepMakeRecipt(recipeName)
  local builderReplica = ThePlayer.replica.builder
  if not recipe then return end
  if not BuilderIsFreeBuildMode() then
    for i, v in pairs(recipe.ingredients) do
      local requiredCnt = math.max(1, RoundBiasedUp(v.amount * builderReplica:IngredientMod()))
      if not HasInvItem(v.type, requiredCnt) then return GetDeepMakeReciptAction(v.type) end
    end
  end
  return BufferedAction(ThePlayer, nil, ACTIONS.BUILD, nil, nil, recipe.name, 1)
end

--- RPC: Additional RPC for make recipt
-- @helper
-- @param recipeName
function RpcMakeRecipeFromMenu(recipeName)
  local recipe = CanMakeRecipt(recipeName)
  local builder = ThePlayer.replica.builder
  -- need to check if builder is busy
  if recipe and not builder:IsBusy() then builder:MakeRecipeFromMenu(recipe) end
end

--- RPC: Additional RPC for Use Item From InvTile
-- @helper
-- @param item invitem
function RpcUseItemFromInvTile(item)
  if item and ThePlayer.replica.inventory then
    ThePlayer.replica.inventory:UseItemFromInvTile(item)
  end
end

--- Check if player has item or can make recipe
-- @helper
-- @param fn A judging function to return boolean represent the item you need or not, or (nil)
-- @param recipeName
-- @return (boolean) can make recipe or not
function HasItemOrCanMake(fn, recipeName)
  return (FindOnePlayerItem(fn) or CanMakeRecipt(recipeName)) and true or false
end

--- Get Left Click Action.
-- @helper
-- @param pos
-- @param target
-- @return (bufferedaction) action need to do, or (nil)
function GetLeftClickAction(pos, target)
  return ThePlayer.components.playeractionpicker:GetLeftClickActions(pos, target)[1]
end

--- Get Right Click Action.
-- @helper
-- @param pos
-- @param target
-- @return (bufferedaction) action need to do, or (nil)
function GetRightClickAction(pos, target)
  return ThePlayer.components.playeractionpicker:GetRightClickActions(pos, target)[1]
end

--- Debug Log, only print on `DEBUG = true`.
-- @helper
-- @param ... any data
function DebugLog(...)
  if not DEBUG then return end

  local args = {...}
  local str = ""
  for ik, iv in pairs(args) do
    if ik > 1 then str = str .. " " end
    if type(iv) == "table" then
      local debug = {}
      for jk, jv in pairs(iv) do
        if type(jv) == "function" then
          debug[jk] = "function"
        elseif type(jv) == "table" then
          debug[jk] = "table"
        elseif type(jv) == "userdata" then
          debug[jk] = "userdata"
        elseif type(jv) == "thread" then
          debug[jk] = "thread"
        else
          debug[jk] = jv
        end
      end
      str = str .. Inspect(debug)
    else
      str = str .. tostring(iv)
    end
  end
  print(str)
end

local DebugLogOnChangePrev = ''
function DebugLogOnChange(...)
  if not DEBUG then return end

  local args = {...}
  local str = ""
  for ik, iv in pairs(args) do
    if ik > 1 then str = str .. " " end
    if type(iv) == "table" then
      local debug = {}
      for jk, jv in pairs(iv) do
        if type(jv) == "function" then
          debug[jk] = "function"
        elseif type(jv) == "table" then
          debug[jk] = "table"
        elseif type(jv) == "userdata" then
          debug[jk] = "userdata"
        elseif type(jv) == "thread" then
          debug[jk] = "thread"
        else
          debug[jk] = jv
        end
      end
      str = str .. Inspect(debug)
    else
      str = str .. tostring(iv)
    end
  end

  if str ~= DebugLogOnChangePrev then print(str) end
  DebugLogOnChangePrev = str
end

local DiffPrintCache = {}
--- DiffPrint only print if data changed
-- @helper
-- @param key a key to distinguish value
-- @param val a string value to diff print
function DiffPrint(key, val)
  if not DEBUG then return end

  key = tostring(key)
  val = tostring(val)

  if DiffPrintCache[key] ~= val then print(key .. " = " .. val) end
  DiffPrintCache[key] = val
end

--- Postion rotate.
-- @helper
-- @param p (Vector3) postion
-- @param deg degree
-- @return (Vector3) Rotated postion
function Vector3RotateDeg(p, deg)
  return Vector3(
    p.x * math.cos(deg) - p.z * math.sin(deg),
    0,
    p.x * math.sin(deg) + p.z * math.cos(deg)
  )
end

--- float compare with a deviation `delta`
-- @helper
-- @param fa (float) a
-- @param fb (float) b
-- @return `-1` on `fa < fb`, `0` on `fa == fb`, `1` on `fa > fb`
function Fcmp(fa, fb)
  local delta = 0.000001
  local diff = fa - fb
  if diff < -delta then return -1 else return diff > delta and 1 or 0 end
end

function Say(str)
  if not (ThePlayer.components.talker and ThePlayer.components.talker.Say) then return end
  ThePlayer.components.talker:Say(tostring(str))
end

--- Save current language code to `I18N_CODE`
-- @helper
function InitI18nCode()
  local languagemap = {
    chs = "chs", 
    cht = "cht", 
    zh_CN = "chs", 
    cn = "chs", 
    TW = "cht",
    zh = "chs",
    schinese = "chs", 
    tchinese = "cht",
  }
  local lang = nil
  -- Because GLOBAL has "strict.lua"
  -- Need to use rawget to prevent game crash!
  if rawget(GLOBAL, "LanguageTranslator") then
    lang = GLOBAL.LanguageTranslator.defaultlang
  else
    lang = TheNet:GetLanguageCode()
  end
  if lang and languagemap[lang] then I18N_CODE = languagemap[lang] end
end
InitI18nCode()

function TranslateModInfo ()
  if I18N_CODE == nil then return end
  modinfofiles = {
    'modinfo.lua',
    'modinfo_chs.lua',
    'modinfo_cht.lua'
  }
  local modinfofile = env.MODROOT..'modinfo_'..I18N_CODE..'.lua'
  local modinfoenv = {}
  print("Chores TranslateModInfo: " .. modinfofile)

  local modinfofn = kleiloadlua(modinfofile)
  if type(modinfofn) == "string" then
    print("Error TranslateModInfo: "..modinfofile.."!\n "..fn.."\n")
    return
  elseif modinfofn then
    local status, r = RunInEnvironment(modinfofn, modinfoenv)
    -- override
    local baseLoadModConfigurationOptions = KnownModIndex.LoadModConfigurationOptions
    KnownModIndex.LoadModConfigurationOptions = function (self, _modname, _client_config)
      local config_options = baseLoadModConfigurationOptions(self, _modname, _client_config)
      if _modname == modname then
        for i,v in pairs(modinfoenv.configuration_options) do
          for j,k in pairs(config_options) do
            if v.name == k.name then
              k.label = v.label
              k.hover = v.hover
            end
          end
        end
      end
      return config_options
    end
  end
end

function fprint(filename, data)
  local fastmode = true
  filename = modname .. "_DEBUG_" .. filename
  data = DataDumper(data, nil, fastmode)
  TheSim:SetPersistentString(filename, data, false, function()
    print("Saved to " .. filename)
  end)
end

function DebugAllWorkable(filename)
  local CachePrefab = {}
  local function UniquePrefab(key, item)
    if item == nil then return end
    if CachePrefab[key] == nil then CachePrefab[key] = {} end
    CachePrefab[key][item.prefab] = 1
  end

  local tags = {"_inventoryitem", "CHOP_workable", "pickable", "DIG_workable", "MINE_workable"}
  for ik, tag in pairs(tags) do
    FindEntity(ThePlayer, SEE_DIST_WORK_TARGET, function(...) UniquePrefab(tag, ...) end, {tag})
  end

  fprint(filename, CachePrefab)
end

function encodeURI(str)
  if (str) then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w ])", function (c) return string.format("%%%02X", string.byte(c)) end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

function decodeURI(str)
  if(str) then
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function (hex) return string.char(tonumber(hex, 16)) end )
  end
  return str
end

function GaScreenView(screen_name, session_control)
  local userid = TheNet:GetUserID()
  local version = KnownModIndex:GetModInfo(modname).version
  local locale = GetCurrentLocale()
  local url = "https://www.google-analytics.com/collect?v=1&tid=UA-142147160-1&t=screenview&an=ToDoChores&av="..version.."&cid="..userid.."&cd="..encodeURI(screen_name)
  if session_control == "start" or session_control == "end" then
    url = url .. "&sc=" .. session_control
  end
  if locale ~= nil and locale.code ~= nil then
    url = url .. "&ul=" .. locale.code
  end
  -- DebugLog(url)
  TheSim:QueryServer(url, function(result, isSuccessful, resultCode) end, "GET")
end

UpdateSettings() -- init setting

if not IsWorkshopMod() then DEBUG = true end -- if not workshop mod then turn on DebugLog()
