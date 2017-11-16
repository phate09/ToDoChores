-- load dependencies
local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local Image = require("widgets/image")

-- Class Chores
Chores = Class(Widget, function (self)
  -- parents constructor
  Widget._ctor(self, "Chores")

  self.opts = {}
  self.skipUpdatePC = 0
  self.updatingLv = 0 -- level of StartUpdating, maintained by IncUpdatingLv()
  self.doingTask = nil -- maintained by OnStartTask(), OnStopTask()
  self.optsFile = modname .. "_opts"
  self.skipChoresOnControl = {
    CONTROL_ACTION,
    CONTROL_ATTACK,
    CONTROL_PRIMARY,
    CONTROL_SECONDARY,
  }
  self.actionsToCtrl = {
    [ACTIONS.CHECKTRAP] = CONTROL_PRIMARY,
    [ACTIONS.DEPLOY] = CONTROL_CONTROLLER_ACTION,
    [ACTIONS.DROP] = CONTROL_PRIMARY,
    [ACTIONS.DRY] = CONTROL_PRIMARY,
    [ACTIONS.FERTILIZE] = CONTROL_PRIMARY,
  }
  -- hint devloper that action is not suitable for some control rpc
  self.controlToStr = {
    CONTROL_PRIMARY = "CONTROL_PRIMARY",
    CONTROL_SECONDARY = "CONTROL_SECONDARY",
    CONTROL_ACTION = "CONTROL_ACTION",
    CONTROL_CONTROLLER_ALTACTION = "CONTROL_CONTROLLER_ALTACTION",
    CONTROL_CONTROLLER_ACTION = "CONTROL_CONTROLLER_ACTION",
  }

  self:InitPlugin()
  self:InjectInput()
  self:InjectGetActionButtonAction()
  self:Render()
  self:LoadOpts()

  self:Hide()

  DebugLog('Chores Inited')
end)

local function PluginImport(pluginName)
  pluginName = "scripts/plugins/"..pluginName
  DebugLog("PluginImport: "..env.MODROOT..pluginName)
  if string.sub(pluginName, #pluginName-3,#pluginName) ~= ".lua" then
    pluginName = pluginName..".lua"
  end
  local result = kleiloadlua(env.MODROOT..pluginName)
  if result == nil then
    error("Error in PluginImport: "..pluginName.." not found!")
  elseif type(result) == "string" then
    error("Error in PluginImport: "..ModInfoname(modname).." importing "..pluginName.."!\n"..result)
  else
    setfenv(result, env.env)
    result()
  end
end

function Chores:InitPlugin ()
  self.plugins = {}

  local pluginNames = {"axe", "pickaxe", "backpack", "shovel", "book_gardening", "poop", "trap", "smallmeat_dried"}

  for _, pluginName in pairs(pluginNames) do
    DebugLog('loading ChoresPlugin:'..pluginName)
    choresplugin = nil
    PluginImport(pluginName)
    if choresplugin then
      self.plugins[pluginName] = choresplugin
      self.opts[pluginName] = choresplugin:GetOpt()
      DebugLog('loading ChoresPlugin:'..pluginName..' success!')
    end
  end
end

function Chores:Render()
  self:SetHAnchor(ANCHOR_LEFT)
  self:SetVAnchor(ANCHOR_BOTTOM)
  self:SetScaleMode(SCALEMODE_PROPORTIONAL)
  self:SetMaxPropUpscale(MAX_HUD_SCALE)

  self.root = self:AddChild( Image("images/fepanels.xml", "panel_mod1.tex") )
  self.root:SetTint(1, 1, 1, 0.5)

  self.root.btns = {}

  local x,y,rowcnt,colcnt = 70, 0, 0, 0
  for task, pluginCfg in pairs(self.opts) do
    self.root.btns[task] = {}
    local btnTask = self:MakeBtn(task, task, true)
    btnTask:SetPosition(0, y)
    local inx = 0
    for icon, enable in pairs(pluginCfg) do
      local btn = self:MakeBtn(task, icon, false)
      btn:SetPosition(x, y)
      x = x + 45
      inx = inx + 1
    end
    y = y - 50
    x = 70
    colcnt = math.max(colcnt, inx)
    rowcnt = rowcnt + 1
  end

  self.root:SetPosition(125, 100 + 50 * rowcnt)
  self.root:SetSize(25 + 45 * colcnt, 50 * rowcnt)
end

-- creates a button
function Chores:MakeBtn(task, icon, isTaskBtn)
  local me = self
  local btn = me.root:AddChild(ImageButton("images/inventoryimages.xml", icon .. ".tex"))
  local plugin = me.plugins[task]

  me.root.btns[task][icon] = btn
  btn:SetNormalScale(0.67, 0.67, 0.67) -- 63 * 0.67 = 42
  btn:SetFocusScale(0.76, 0.76, 0.76) -- 63 * 0.76 = 48

  if isTaskBtn then -- Task Button
    btn.image:SetTint(1, 1, 1, 1)
    if plugin.OnTaskGainFocus then
      local originalFn = btn.OnGainFocus
      btn.OnGainFocus = function(...)
        originalFn(...)
        plugin:OnTaskGainFocus()
      end
    end
    if plugin.OnTaskLoseFocus then
      local originalFn = btn.OnLoseFocus
      btn.OnLoseFocus = function(...)
        originalFn(...)
        plugin:OnTaskLoseFocus()
      end
    end
    if plugin.OnStartTask then
      btn:SetOnClick(function()
        me:OnStartTask(task)
      end)
    end
  else -- Option Button
    me:SetBtnStatus(task, icon, me.opts[task][icon])
    me.root.btns[task][icon] = btn
    btn:SetOnClick(function() me:OnOptClick(task, icon) end)
  end

  return btn
end

function Chores:OnOptClick(task, icon)
  local plugin = self.plugins[task]
  if not plugin then return end
  local btnChanged = plugin.OnOptClick and plugin:OnOptClick(icon) or {icon}
  for _, iv in pairs(btnChanged) do
    self:SetBtnStatus(task, iv)
  end
end

function Chores:SetBtnStatus(task, icon, status)
  if status == nil then status = (not self.opts[task][icon]) end

  local btn = self.root.btns[task][icon]
  self.opts[task][icon] = status
  if status then
    btn.image:SetTint(1, 1, 1, 1)
  else
    btn.image:SetTint(.2, .2, .2, 1)
  end
end

-- save opts on hide
function Chores:SaveOpts()
  -- copy from modindex.lua:168
  local fastmode = true
  local data = DataDumper(self.opts, nil, fastmode)
  local insz, outsz = TheSim:SetPersistentString(self.optsFile, data, ENCODE_SAVES, function() DebugLog("Chores:SaveOpts() saved " .. self.optsFile) end)
end

-- save opts on game start
function Chores:LoadOpts()
  TheSim:GetPersistentString(self.optsFile, function (load_success, str)
    if load_success == true then
      local success, savedata = RunInSandboxSafe(str)
      if success and string.len(str) > 0 and savedata ~= nil then
        self:ApplyOpts(savedata)
        DebugLog ("Chores:LoadOpts() loaded "..self.optsFile)
      else
        DebugLog ("Chores:LoadOpts() Parse Error "..self.optsFile)
        if string.len(str) > 0 then
          DebugLog("File str is ["..str.."]")
        end
      end
    else
      DebugLog ("Chores:LoadOpts() Could not load "..self.optsFile)
    end
  end)
end

-- batch apply opts when load success
function Chores:ApplyOpts(newOpts)
  for task, iv in pairs(newOpts) do
    if self.plugins[task] then
      for icon, enable in pairs(iv) do
        if self.opts[task] ~= nil and self.opts[task][icon] ~= nil and enable ~= self.opts[task][icon] then self:OnOptClick(task, icon) end
      end
    end
  end
end

-- toggle visibility of the widget
function Chores:Toggle()
  if self:IsVisible() then
    self:Hide()
    self:OnForceStop()
    self:SaveOpts()
  else
    self:Show()
  end
end

function Chores:IncUpdatingLv(inc)
  if inc then
    local newUpdatingLv = self.updatingLv + inc
    if self.updatingLv < 1 and newUpdatingLv > 0 then
      self:StartUpdating()
    elseif self.updatingLv > 0 and newUpdatingLv < 1 then
      self:StopUpdating()
    end
    modassert(newUpdatingLv > -1, "newUpdatingLv must larger then -1, cur = " .. newUpdatingLv)
    self.updatingLv = math.max(0, newUpdatingLv)
  end
  return self.updatingLv
end

function Chores:OnStartTask(task)
  DebugLog('start task: '..task)

  -- stop previous task
  self:OnStopTask()

  -- start new task
  self.doingTask = task
  self.plugins[task]:OnStartTask()
  self:IncUpdatingLv(1)
end

function Chores:OnStopTask()
  if self.doingTask == nil then return end

  DebugLog('stop task: '..self.doingTask)

  self:IncUpdatingLv(-1)
  self.plugins[self.doingTask]:OnStopTask()
  self.doingTask = nil
end

function Chores:OnForceStop()
  for _, plugin in pairs(self.plugins) do
    if plugin.OnForceStop then plugin:OnForceStop() end
  end
  self:OnStopTask()
  if ThePlayer.components.locomotor then
    ThePlayer.components.locomotor:Clear()
  end
end

function Chores:OnUpdate(dt)
  for _, plugin in pairs(self.plugins) do
    if plugin.OnUpdate then plugin:OnUpdate() end
  end
  self:OnUpdatePC(dt)
end

function Chores:OnUpdatePC(dt)
  -- no task
  if self.doingTask == nil then return end

  local pc = ThePlayer.components.playercontroller

  -- Don't want to spam the action button before the server actually starts the buffered action
  -- Also check if playercontroller is enabled
  if (not pc.ismastersim and (pc.remote_controls[CONTROL_ACTION] or 0) > 0) or not pc:IsEnabled() then return end

  -- copy from playercontroller.lua:369
  if not pc:IsEnabled() or IsPaused() or pc:IsBusy() then return end

  -- hands are full!
  if ThePlayer.replica.inventory:IsHeavyLifting() and not (ThePlayer.replica.rider ~= nil and ThePlayer.replica.rider:IsRiding()) then return end

  -- copy from playercontroller.lua:369
  if pc:IsDoingOrWorking() then return end

  -- copy from playercontroller.lua:1771
  local isidle = ThePlayer:HasTag("idle")
  if ThePlayer.sg ~= nil then
    isidle = ThePlayer.sg:HasStateTag("idle") or (isidle and ThePlayer:HasTag("nopredict"))
  end
  if not isidle then return end

  if self.skipUpdatePC > 0 then
    self.skipUpdatePC = math.max(0, self.skipUpdatePC - 1)
    return
  end

  -- get plugin action
  local plugin = self.plugins[self.doingTask]
  local buffaction = plugin:GetAction()
  DebugLog(tostring(buffaction))

  -- if no action then stop the task
  if not buffaction then self:OnStopTask() end
  self:DoAction(buffaction)
end

function Chores:DoAction(buffaction)
  local pc = ThePlayer.components.playercontroller
  if not buffaction then return end

  -- when an action has failed stops the loop
  buffaction:AddFailAction(function()
    local msg = "buffaction failed: "..tostring(buffaction)
    if buffaction.control and self.controlToStr[buffaction.control] then
      msg = msg .. "\nIf this action never success, maybe this action not suitable for " .. self.controlToStr[buffaction.control] .. " RPC."
    end
    DebugLog(msg)
    -- self:OnStopTask()
  end)

  if buffaction.control == nil then
    -- some special RPC actions
    if buffaction.action == ACTIONS.BUILD then -- build recipe
      buffaction.distance = 1
      RpcMakeRecipeFromMenu(buffaction.recipe)
    elseif buffaction.action == ACTIONS.EQUIP then -- equip invobject
      RpcUseItemFromInvTile(buffaction.invobject)
      return -- equip don't need to do action, so return directly
    elseif self.actionsToCtrl[buffaction.action] then -- ACTIONS to Ctrl
      buffaction.control = self.actionsToCtrl[buffaction.action]
    else -- default to CONTROL_ACTION
      buffaction.control = CONTROL_ACTION
    end
  end

  if buffaction and buffaction.control then
    local ctrl = buffaction.control
    if ctrl == CONTROL_PRIMARY then
      buffaction = self:RPC_PRIMARY(buffaction)
    elseif ctrl == CONTROL_SECONDARY then
      buffaction = self:RPC_SECONDARY(buffaction)
    elseif ctrl == CONTROL_ACTION then
      buffaction = self:RPC_ACTION(buffaction)
    elseif ctrl == CONTROL_CONTROLLER_ALTACTION then
      buffaction = self:RPC_CONTROLLER_ALTACTION(buffaction)
    elseif ctrl == CONTROL_CONTROLLER_ACTION then
      buffaction = self:RPC_CONTROLLER_ACTION(buffaction)
    end
  end

  pc:DoAction(buffaction)
end

function Chores:RPC_PRIMARY(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:2596
  if pc.ismastersim then
    ThePlayer.components.combat:SetTarget(nil)
  else
    local position = act.pos or act.target:GetPosition()
    local mouseover = (act.action ~= ACTIONS.DROP and position) and FindEntityByPos(position, 0.1) or nil
    local controlmods = pc:EncodeControlMods()
    if pc.locomotor == nil then
      pc.remote_controls[CONTROL_PRIMARY] = 0
      SendRPCToServer(RPC.LeftClick, act.action.code, position.x, position.z, mouseover, nil, controlmods, act.action.canforce, act.action.mod_name)
    elseif act.action ~= ACTIONS.WALKTO and pc:CanLocomote() then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_PRIMARY] = 0
        local isreleased = not TheInput:IsControlPressed(CONTROL_PRIMARY)
        SendRPCToServer(RPC.LeftClick, act.action.code, position.x, position.z, mouseover, isreleased, controlmods, nil, act.action.mod_name)
      end
    end
  end
  return act
end

function Chores:RPC_SECONDARY(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:2684
  if not pc.ismastersim then
    local position = act.pos
    local mouseover = FindEntityByPos(position, 0.1)
    local controlmods = pc:EncodeControlMods()
    if pc.locomotor == nil then
      pc.remote_controls[CONTROL_SECONDARY] = 0
      SendRPCToServer(RPC.RightClick, act.action.code, position.x, position.z, mouseover, act.rotation ~= 0 and act.rotation or nil, nil, controlmods, act.action.canforce, act.action.mod_name)
    elseif act.action ~= ACTIONS.WALKTO and pc:CanLocomote() then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_SECONDARY] = 0
        local isreleased = not TheInput:IsControlPressed(CONTROL_SECONDARY)
        SendRPCToServer(RPC.RightClick, act.action.code, position.x, position.z, mouseover, act.rotation ~= 0 and act.rotation or nil, isreleased, controlmods, nil, act.action.mod_name)
      end
    end
  end
  return act
end

function Chores:RPC_ACTION(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:1328
  if pc.locomotor == nil then
    pc.remote_controls[CONTROL_ACTION] = BUTTON_REPEAT_COOLDOWN
    SendRPCToServer(RPC.ActionButton, act.action.code, act.target, nil, act.action.canforce, act.action.mod_name)
  elseif pc:CanLocomote() then
    if act.action ~= ACTIONS.WALKTO then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_ACTION] = BUTTON_REPEAT_COOLDOWN
        local isreleased = not TheInput:IsControlPressed(CONTROL_ACTION)
        SendRPCToServer(RPC.ActionButton, act.action.code, act.target, isreleased, nil, act.action.mod_name)
      end
    end
    return act
  end
  return act
end

function Chores:RPC_CONTROLLER_ALTACTION(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:630
  local obj = act.invobject
  if pc.ismastersim then
    ThePlayer.components.combat:SetTarget(nil)
  elseif obj ~= nil then
    if pc.locomotor == nil then
      pc.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
      SendRPCToServer(RPC.ControllerAltActionButton, act.action.code, obj, nil, act.action.canforce, act.action.mod_name)
    elseif pc:CanLocomote() then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
        local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)
        SendRPCToServer(RPC.ControllerAltActionButton, act.action.code, obj, isreleased, nil, act.action.mod_name)
      end
    end
  elseif pc.locomotor == nil then
    pc.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
    SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.x, act.pos.z, nil, act.action.canforce, act.action.mod_name)
  elseif pc:CanLocomote() then
    act.preview_cb = function()
      pc.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
      local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)
      SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.x, act.pos.z, isreleased, nil, act.action.mod_name)
    end
  end
  return act
end

function Chores:RPC_CONTROLLER_ACTION(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:523
  local obj = act.invobject
  if pc.ismastersim then
    ThePlayer.components.combat:SetTarget(nil)
  elseif act.action == ACTIONS.DEPLOY then
    if pc.locomotor == nil then
      pc.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
      SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.x, act.pos.z, act.rotation ~= 0 and act.rotation or nil)
    elseif pc:CanLocomote() then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
        local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
        DebugLog(RPC.ControllerActionButtonDeploy, obj, act.pos.x, act.pos.z, act.rotation ~= 0 and act.rotation or nil, isreleased)
        SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.x, act.pos.z, act.rotation ~= 0 and act.rotation or nil, isreleased)
      end
    end
  elseif pc.locomotor == nil then
    pc.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
    SendRPCToServer(RPC.ControllerActionButton, act.action.code, obj, nil, act.action.canforce, act.action.mod_name)
  elseif pc:CanLocomote() then
    act.preview_cb = function()
      pc.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
      local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
      SendRPCToServer(RPC.ControllerActionButton, act.action.code, obj, isreleased, nil, act.action.mod_name)
    end
  end
  return act
end

function Chores:InjectInput()
  local IsControlPressed_base = TheInput.IsControlPressed

  TheInput.IsControlPressed = function (self, control)
    if chores.doingTask and control == CONTROL_ACTION then return true end
    return IsControlPressed_base(self, control)
  end
end

function Chores:InjectGetActionButtonAction()
  local pc = ThePlayer.components.playercontroller
  local GetActionButtonAction_base = pc.GetActionButtonAction

  pc.GetActionButtonAction = function (self)
    if chores.doingTask then return nil end
    return GetActionButtonAction_base(self)
  end
end
