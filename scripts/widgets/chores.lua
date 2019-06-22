--- To Do Chores (a Don't Starve Together mod)
-- @classmod chores
-- @alias Chores

-- load dependencies
local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local Image = require("widgets/image")

-- Class Chores
Chores = Class(Widget, function (self)
  -- parents constructor
  Widget._ctor(self, "Chores")

  --- 所有插件的選項
  self.opts = {}
  --- 需要額外跳過幾次 `self:OnUpdatePC()`
  self.skipUpdatePC = 0
  --- StartUpdating 的深度, 由 `IncUpdatingLv()` 維護
  self.updatingLv = 0
  --- 目前正在進行中的工作, 由 `OnStartTask()`, `OnStopTask()` 維護
  self.doingTask = nil
  --- 是否需要等候工作開始，這個選項只有在沒有開啟預測模式才有效
  self.isWaitWorkStart = false
  --- 選項的除存路徑, 會因為是否有地穴而修改 `IS_CAVE`
  self.optsFile = modname .. (IS_CAVE and "_cave_opts" or "_opts")
  --- 指定動作的預設 RPC 模擬方式
  self.actionsToCtrl = {
    [ACTIONS.DEPLOY] = CONTROL_CONTROLLER_ACTION,
  }
  --- 提示開發者是否有動作發生錯誤的時候顯示用
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

--- A function to import a plugin, copy from `mods.lua:L294`
-- @local
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

--- Start to load all plugins
function Chores:InitPlugin ()
  self.plugins = {}

  local pluginNames = {"axe", "pickaxe", "backpack", "shovel", "book_gardening", "poop", "trap", "smallmeat_dried"}

  for _, pluginName in pairs(pluginNames) do
    DebugLog('loading ChoresPlugin: '..pluginName)
    choresplugin = nil
    PluginImport(pluginName)
    if choresplugin and choresplugin.GetOpt then
      local pluginOpts = choresplugin:GetOpt()
      if type(pluginOpts) == "table" and next(pluginOpts) ~= nil then
        self.plugins[pluginName] = choresplugin
        self.opts[pluginName] = pluginOpts
        DebugLog('loading ChoresPlugin: '..pluginName..' success!')
      else
        DebugLog('disabled ChoresPlugin: '..pluginName..' because no opts!')
      end
    end
  end
end

--- Render btns by opts of plugin
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

--- Creates a single button
function Chores:MakeBtn(task, icon, isTaskBtn)
  local me = self
  local image = icon .. ".tex"
  local btn = me.root:AddChild(ImageButton(GetInventoryItemAtlas(image), image))
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

--- On opts btn click function
function Chores:OnOptClick(task, icon)
  local plugin = self.plugins[task]
  if not plugin then return end
  local btnChanged = plugin.OnOptClick and plugin:OnOptClick(icon) or {icon}
  for _, iv in pairs(btnChanged) do
    self:SetBtnStatus(task, iv)
  end
end

--- Set opts btn status
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

--- Save opts on hide, copy from `modindex.lua:168`
function Chores:SaveOpts()
  local fastmode = true
  local data = DataDumper(self.opts, nil, fastmode)
  local insz, outsz = TheSim:SetPersistentString(self.optsFile, data, ENCODE_SAVES, function() DebugLog("Chores:SaveOpts() saved " .. self.optsFile) end)
end

--- Save opts on game start
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

--- Batch apply opts when load success
function Chores:ApplyOpts(newOpts)
  for task, iv in pairs(newOpts) do
    if self.plugins[task] then
      for icon, enable in pairs(iv) do
        if self.opts[task] ~= nil and self.opts[task][icon] ~= nil and enable ~= self.opts[task][icon] then self:OnOptClick(task, icon) end
      end
    end
  end
end

--- Toggle visibility of the widget
function Chores:Toggle()
  if self:IsVisible() then
    self:Hide()
    self:OnForceStop()
    self:SaveOpts()
    GaScreenView("Hide Widget", "end")
  else
    GaScreenView("Show Widget", "start")
    self:Show()
  end
end

--- Control the `self:StartUpdating()` and `self:StopUpdating()`
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

--- On start task
function Chores:OnStartTask(task)
  -- stop previous task
  self:OnStopTask()

  -- start new task
  if CONFIG.hint_start_stop then Say('Task "'..task..'" started.') end
  GaScreenView("Start Task: "..task)
  self.doingTask = task
  self.plugins[task]:OnStartTask()
  self:IncUpdatingLv(1)
end

--- On stop task
function Chores:OnStopTask()
  if self.doingTask == nil then return end

  if CONFIG.hint_start_stop then Say('Task "'..self.doingTask..'" stoped.') end
  GaScreenView("Stop Task: "..self.doingTask)

  self:IncUpdatingLv(-1)
  self.plugins[self.doingTask]:OnStopTask()
  self.doingTask = nil
  self.isWaitWorkStart = false
  self.skipUpdatePC = 0
end

--- On force stop
function Chores:OnForceStop()
  for _, plugin in pairs(self.plugins) do
    if plugin.OnForceStop then plugin:OnForceStop() end
  end
  self:OnStopTask()
  if ThePlayer.components.locomotor then
    ThePlayer.components.locomotor:Clear()
  end
end

--- On update, this function will call all `plugin:OnUpdate()` and `self:OnUpdatePC()`
function Chores:OnUpdate(dt)
  for _, plugin in pairs(self.plugins) do
    if plugin.OnUpdate then plugin:OnUpdate() end
  end
  self:OnUpdatePC(dt)
end

--- Check if player can do chores action or not
function Chores:OnUpdatePC(dt)
  -- no task
  if self.doingTask == nil then return end

  local pc = ThePlayer.components.playercontroller

  -- copy from PlayerController:OnControl
  if not pc:IsEnabled() or IsPaused() then return end

  -- DebugLogOnChange("locomotor = "..tostring(pc.locomotor ~= nil)..", IsDoingOrWorking = "..tostring(pc:IsDoingOrWorking())..", HasTag(idle) = "..tostring(ThePlayer:HasTag("idle"))..", HasTag(moving) = "..tostring(ThePlayer:HasTag("moving"))..", HasStateTag(idle) = "..tostring(ThePlayer.sg and ThePlayer.sg:HasStateTag("idle"))..", HasStateTag(moving) = "..tostring(ThePlayer.sg and ThePlayer.sg:HasStateTag("moving")))

  -- 等候上一個工作完成
  if pc.locomotor ~= nil then
    -- 有開啟預測模式下，需要確認主機的工作結束
    if ThePlayer.sg and (not ThePlayer.sg:HasStateTag("idle") or ThePlayer.sg:HasStateTag("moving")) then return end
  else
    -- 沒有開啟預測模式，需要先等工作開始
    if self.isWaitWorkStart and (not pc:IsDoingOrWorking() or ThePlayer:HasTag("idle") or ThePlayer:HasTag("moving")) then return end
  end
  self.isWaitWorkStart = false
  if pc:IsDoingOrWorking() or not ThePlayer:HasTag("idle") or ThePlayer:HasTag("moving") then return end

  -- 正在拿著很重的東西或是正在騎動物
  if ThePlayer.replica.inventory:IsHeavyLifting() and not (ThePlayer.replica.rider ~= nil and ThePlayer.replica.rider:IsRiding()) then return end

  -- 還沒辦法蓋東西 RpcMakeRecipeFromMenu() 會需要
  if ThePlayer.replica.builder:IsBusy() then return end

  if self.skipUpdatePC > 0 then
    self.skipUpdatePC = math.max(0, self.skipUpdatePC - 1)
    return
  end

  -- get plugin action
  local plugin = self.plugins[self.doingTask]
  self:DoAction(plugin:GetAction())
end

--- get the action, do extra RPC call, then call `pc:DoAction()`
function Chores:DoAction(buffaction)
  local pc = ThePlayer.components.playercontroller

  -- if no action then stop the task
  if not buffaction then return self:OnStopTask() end
  DebugLog(tostring(buffaction))

  -- if buffaction has skipUpdatePC, then save the max skipUpdatePC
  if buffaction.skipUpdatePC then
    self.skipUpdatePC = math.max(self.skipUpdatePC, buffaction.skipUpdatePC)
  end

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
    else -- default to CONTROL_PRIMARY
      buffaction.control = CONTROL_PRIMARY
    end
  end

  if buffaction.control then
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
  self.isWaitWorkStart = true
end

--- PRC call for PRIMARY
function Chores:RPC_PRIMARY(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:OnLeftClick
  if pc.ismastersim then
    ThePlayer.components.combat:SetTarget(nil)
  else
    local mouseover = act.action ~= ACTIONS.DROP and act.target or nil
    local position = act:GetActionPoint() or (mouseover and mouseover:GetPosition())
    local platform, pos_x, pos_z = pc:GetPlatformRelativePosition(position.x, position.z)

    local controlmods = pc:EncodeControlMods()
    if pc.locomotor == nil then
      pc.remote_controls[CONTROL_PRIMARY] = 0
      SendRPCToServer(RPC.LeftClick, act.action.code, pos_x, pos_z, mouseover, nil, controlmods, act.action.canforce, act.action.mod_name, platform, platform ~= nil)
    elseif act.action ~= ACTIONS.WALKTO and pc:CanLocomote() then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_PRIMARY] = 0
        local isreleased = not TheInput:IsControlPressed(CONTROL_PRIMARY)
        SendRPCToServer(RPC.LeftClick, act.action.code, pos_x, pos_z, mouseover, isreleased, controlmods, nil, act.action.mod_name, platform, platform ~= nil)
      end
    end
  end
  return act
end

--- PRC call for SECONDARY
function Chores:RPC_SECONDARY(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:OnRightClick
  if not pc.ismastersim then
    local position = act:GetActionPoint()
    local mouseover = FindEntityByPos(position, 0.1)
    local controlmods = pc:EncodeControlMods()
    local platform, pos_x, pos_z = pc:GetPlatformRelativePosition(position.x, position.z)
    if pc.locomotor == nil then
      pc.remote_controls[CONTROL_SECONDARY] = 0
      SendRPCToServer(RPC.RightClick, act.action.code, pos_x, pos_z, mouseover, act.rotation ~= 0 and act.rotation or nil, nil, controlmods, act.action.canforce, act.action.mod_name, platform, platform ~= nil)
    elseif act.action ~= ACTIONS.WALKTO and pc:CanLocomote() then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_SECONDARY] = 0
        local isreleased = not TheInput:IsControlPressed(CONTROL_SECONDARY)
        SendRPCToServer(RPC.RightClick, act.action.code, pos_x, pos_z, mouseover, act.rotation ~= 0 and act.rotation or nil, isreleased, controlmods, nil, act.action.mod_name, platform, platform ~= nil)
      end
    end
  end
  return act
end

--- PRC call for ACTION
function Chores:RPC_ACTION(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:DoActionButton
  if pc.ismastersim then
    pc.locomotor:PushAction(act, true)
    return
  elseif pc.locomotor == nil then
    pc:RemoteActionButton(act)
    return
  elseif pc:CanLocomote() then
    if act.action ~= ACTIONS.WALKTO then
      act.preview_cb = function()
        pc:RemoteActionButton(act, not TheInput:IsControlPressed(CONTROL_ACTION) or nil)
      end
    end
    pc.locomotor:PreviewAction(buffaction, true)
  end
end

--- PRC call for CONTROLLER_ALTACTION
function Chores:RPC_CONTROLLER_ALTACTION(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:DoControllerAltActionButton
  local obj = act.invobject
  local isspecial = nil

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
    SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, nil, act.action.canforce, isspecial, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
  elseif pc:CanLocomote() then
    act.preview_cb = function()
      pc.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
      local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)
      SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, isreleased, nil, isspecial, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
    end
  end
  return act
end

--- PRC call for CONTROLLER_ACTION
function Chores:RPC_CONTROLLER_ACTION(act)
  local pc = ThePlayer.components.playercontroller
  -- copy from playercontroller.lua:DoControllerActionButton
  local obj = act.invobject
  if pc.ismastersim then
    ThePlayer.components.combat:SetTarget(nil)
  elseif act.action == ACTIONS.DEPLOY then
    if pc.locomotor == nil then
      pc.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
      SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.local_pt.x, act.pos.local_pt.z, act.rotation ~= 0 and act.rotation or nil, nil, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
    elseif pc:CanLocomote() then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
        local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
        SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.local_pt.x, act.pos.local_pt.z, act.rotation ~= 0 and act.rotation or nil, isreleased, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
      end
    end
  elseif obj == nil then
    if pc.locomotor == nil then
      pc.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
      SendRPCToServer(RPC.ControllerActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, nil, act.action.canforce, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
    elseif pc:CanLocomote() then
      act.preview_cb = function()
        pc.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
        local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
        SendRPCToServer(RPC.ControllerActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, isreleased, nil, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
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

--- Because we want CHOP and MINE to do continuous, we need to deceive the CONTROL_ACTION key is pressed.
function Chores:InjectInput()
  local IsControlPressed_base = TheInput.IsControlPressed

  TheInput.IsControlPressed = function (self, control)
    if chores.doingTask and control == CONTROL_ACTION then return true end
    return IsControlPressed_base(self, control)
  end
end

--- Because we deceive the CONTROL_ACTION key is pressed, we need to prevent default ActionButtonAction from execute.
function Chores:InjectGetActionButtonAction()
  local pc = ThePlayer.components.playercontroller
  local GetActionButtonAction_base = pc.GetActionButtonAction

  pc.GetActionButtonAction = function (self, force_target)
    if chores.doingTask then return nil end
    return GetActionButtonAction_base(self, force_target)
  end
end
