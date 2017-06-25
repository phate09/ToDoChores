local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Inst = require "chores-lib.instance"
local Inspect = require "inspect"
local modname = KnownModIndex:GetModActualName("To Do Chores [Forked]")
local CONFIG

CW = nil

local PLACER_GAP = {
  pinecone = 2,
  acorn = 2,
  twiggy_nut=2,
  marblebean=2,
  dug_grass = 1,
  dug_berrybush = 2,
  dug_sapling = 1
}
local ATLASINV = "images/inventoryimages.xml"
local MAX_HUD_SCALE = 1.25
local ChoresWheel = Class(Widget, function(self)
  Widget._ctor(self, "Chores")

  self:SetHAnchor(ANCHOR_LEFT)
  self:SetVAnchor(ANCHOR_BOTTOM)
  self:SetScaleMode(SCALEMODE_PROPORTIONAL)
  self:SetMaxPropUpscale(MAX_HUD_SCALE)

  self.root = self:AddChild(Image("images/fepanels.xml","panel_mod1.tex"))
  self.root:SetTint(1,1,1,0.5)

  ThePlayer.Inspect = Inspect

  CW = self.root

  self.flag ={
    axe = {pinecone=true},
    pickaxe = {goldnugget=true},
    shovel = {dug_grass=true, dug_berrybush=true, dug_sapling=true},
    backpack = {cutgrass=true, berries=true, twigs=true, flint=true, green_cap=true, carrot=true, guano=true},
    book_gardening = {dug_grass=true},
    guano = {fertilizer=true},
    trap = {rabbit=true, smallmeat=true, froglegs=true, silk=true, spidergland=true, monstermeat=true},
    smallmeat_dried = {smallmeat=true, meat=true}
  }

  self.layout ={
    {"axe", "pinecone", "charcoal", "shovel"},
    {"pickaxe", "nitre","goldnugget","rocks","ice","moonrocknugget","marble"},
    {"backpack", "flint", "cutgrass", "twigs", "berries","green_cap", "carrot", "petals", "guano"},
    {"shovel", "dug_grass", "dug_berrybush", "dug_sapling"},
    {"book_gardening", "dug_grass", "dug_berrybush", "dug_sapling", "pinecone","acorn","twiggy_nut", "marblebean"},
    {"guano", "poop", "spoiled_food", "rottenegg", "fertilizer", "glommerfuel"},
    {"trap", "rabbit", "smallmeat", "froglegs", "silk", "spidergland", "monstermeat", "spoiled_food"},
    {"smallmeat_dried", "smallmeat", "meat", "monstermeat", "froglegs", "fish", "drumstick", "eel", "batwing"}
  }

  self.root.btns = {}

  local x,y,rowcnt,colcnt = 0, 0, 0, 0
  for i, row in pairs(self.layout) do
    if i > rowcnt then rowcnt = i end
    local task = row[1]
    self.root.btns[task] = {}
    for inx, icon in pairs(row) do
      if inx > colcnt then colcnt = inx end
      local btn = self:MakeBtn(task, icon, inx==1)
      btn:SetPosition( x, y)
      x = x + 45
      if inx == 1 then x = x + 25 end
    end
    y = y - 50
    x = 0
  end

  self.root:SetPosition(125, 100 + 50 * rowcnt)
  self.root:SetSize(25 + 45 * colcnt, 50 * rowcnt)

end)
function ChoresWheel:SetEnv(newEnv)
  self.env = newEnv
  self:UpdateSettings()
end
function ChoresWheel:UpdateSettings()
  local config = KnownModIndex:GetModConfigurationOptions_Internal(self.env.modname, false)
  CONFIG = {}
  for i, v in pairs(config) do
    if v.saved ~= nil then
      CONFIG[v.name] = v.saved
    else
      CONFIG[v.name] = v.default
    end
  end
  -- print('AutoChores CONFIG: '..Inspect(CONFIG))
end
function ChoresWheel:Toggle()--toggle visibility of the widget
  if self.shown then
    self:Hide()

    ThePlayer.components.auto_chores:ForceStop()
  else
    self:Show()
  end
  print("TheNet:GetIsServer():"..tostring(TheNet:GetIsServer()))
  print("TheNet:GetIsClient():"..tostring(TheNet:GetIsClient()))
end

function ChoresWheel:SetBtnValue(task, icon, value)
  local btn = self.root.btns[task][icon]
  if value == nil then value = (not self.flag[task][icon]) end
  self.flag[task][icon] = value
  if value then
    btn.image:SetTint(1, 1, 1, 1)
  else
    btn.image:SetTint(.2, .2, .2, 1)
  end
end

function ChoresWheel:MakeBtn(task, icon, isTaskBtn)--creates a button
  local btn = self.root:AddChild(ImageButton(ATLASINV, icon .. ".tex"))
  local widget = self
  widget.root.btns[task][icon] = btn
  btn:SetNormalScale(0.67, 0.67, 0.67) -- 63 * 0.67 = 42
  btn:SetFocusScale(0.76, 0.76, 0.76) -- 63 * 0.76 = 48

  if isTaskBtn then -- task btn
    if task == "book_gardening" then
      local _OnGainFocus = btn.OnGainFocus
      btn.OnGainFocus = function(...)
        _OnGainFocus(...)
        widget:showPlacer()
      end
      local _OnLoseFocus = btn.OnLoseFocus
      btn.OnLoseFocus = function(...)
        _OnLoseFocus(...)
        widget:hidePlacer()
      end
    end
    btn:SetOnClick(function()
      widget:DoTask(task)
    end)
    btn.image:SetTint(1, 1, 1, 1)
  else -- flag btn
    btn:SetOnClick(function()
      if task == "book_gardening" then -- radio btn
        for ik, iv in pairs(widget.flag[task]) do
          if iv then widget:SetBtnValue(task, ik, false) end
        end
      end
      widget:SetBtnValue(task, icon)
    end)
    widget:SetBtnValue(task, icon, widget.flag[task][icon] == true)
  end

  return btn
end

function ChoresWheel:showPlacer() --on the focus of planting displays the placers
  if self.placers ~= nil then return end
  self.placers = {}

  local prefab_name = nil
  for prefab, flag in pairs(self.flag["book_gardening"]) do
    if flag then prefab_name = prefab end
  end
  if prefab_name == nil then return end

  local placerGap = PLACER_GAP[prefab_name]

  local function _find_placer (item) --finds the icon to use as marker to show where things will be planted
    if item == nil then return false end
    if prefab_name == "dug_berrybush" and (item.prefab == "dug_berrybush2" or item.prefab == "dug_berrybush_juicy") then
      return true
    end
    return item.prefab == prefab_name
  end

  local placer_item = Inst(ThePlayer):inventory_FindItems(_find_placer)[1]

  -- local placer_item = SpawnPrefab(prefab_name)

  --print(placer_item)
  if placer_item == nil then
    -- 심을것 없음 에러
    --No planting error
    return
  end


  if Inst(placer_item):inventoryitem() == nil then
    -- 심을것 없음 에러
    --No planting error
    return
  end

  local placer_name = Inst(placer_item):inventoryitem_GetDeployPlacerName()

  self:StartUpdating()

  local planting_x = CONFIG.planting_x
  local planting_y = CONFIG.planting_y
	print("showing "..planting_x.."x"..planting_y.." grid")
  for xOff = 0, planting_x-1, 1 do
    for zOff = 0, planting_y-1, 1 do
      local deployplacer = SpawnPrefab(placer_name)
      table.insert( self.placers, deployplacer)
      deployplacer.components.placer:SetBuilder(ThePlayer, nil, placer_item)

      local function _testfn(pt)
        local test_item = Inst(ThePlayer):inventory_GetActiveItem()

        if _find_placer(test_item) == false then
          test_item = Inst(ThePlayer):inventory_FindItems(_find_placer)[1]
        end
        return test_item ~= nil and Inst(test_item):inventoryitem_CanDeploy(pt)
      end

      deployplacer.components.placer.testfn = _testfn

      -- deployplacer:RemoveComponent("placer")
      -- deployplacer:AddComponent("placer_orig")
      -- deployplacer.components.placer = deployplacer.components.placer_orig

      local function _replace(self, dt)

        self.can_build = self.testfn == nil or self.testfn(self.inst:GetPosition())
        local color = self.can_build and Vector3(.25,.75,.25) or Vector3(.75,.25,.25)
        -- debug('SetAddColour', color.x , color.y , self.can_build, self.testfn)
        self.inst.AnimState:SetAddColour(color.x, color.y, color.z ,0)

      end
      deployplacer.components.placer.OnUpdate = _replace

      local function _reposition(self)
        local pos = Vector3(ThePlayer.Transform:GetWorldPosition())
        pos = Vector3( math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
        self.Transform:SetPosition((pos + self.offset ):Get())
      end
      deployplacer.offset = Vector3( (xOff -1) * placerGap  , 0, (zOff-1) * placerGap)
      deployplacer.reposition = _reposition
      deployplacer:reposition()
      deployplacer.components.placer:OnUpdate(0)

    end
  end
end

function ChoresWheel:hidePlacer()--remove placers on lose focus of planting
  if self.placers == nil then return end
  for k, v in pairs(self.placers) do
    v:Remove()
  end
  self:StopUpdating()
  self.placers = nil
end


function ChoresWheel:DoTask(task)
--	print("do task"..task)
  --saves self.flags into flags
  local flags = {}
  for key, flag in pairs(self.flag[task]) do
    flags[key] = flag
  end

  ThePlayer.components.auto_chores:SetTask(task, flags, self.placers)
  self.placers = nil
end


function ChoresWheel:OnUpdate(dt)
  if self.placers == nil then return end
  for k, v in pairs(self.placers) do
    v:reposition()
    v.components.placer:OnUpdate(dt)
  end
end

return ChoresWheel
