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
    axe = {pinecone=true, charcoal=false, shovel=false},
    pickaxe={ nitre=false, goldnugget=true, rocks=false, ice=false, moonrocknugget=false, marble=false},
    shovel={ dug_grass=true, dug_berrybush=true, dug_sapling=true},
    backpack={ cutgrass=true, berries=true, twigs=true, flint=true, green_cap=false, carrot=true, petals=false, guano=true},
    book_gardening={ dug_grass=true, dug_berrybush=false, dug_sapling=false, pinecone=false, acorn=false, twiggy_nut=false, marblebean=false},
    guano={poop=false, guano=false, spoiled_food=false, rottenegg=false, fertilizer=true, glommerfuel=false},
    trap={rabbit=true, smallmeat=true, froglegs=true, silk=true, spidergland=true, monstermeat=true, spoiled_food=false}
  }

  self.layout ={
    {"axe", "pinecone", "charcoal", "shovel"},
    {"pickaxe", "nitre","goldnugget","rocks","ice","moonrocknugget","marble"},
    {"backpack", "flint", "cutgrass", "twigs", "berries","green_cap", "carrot", "petals", "guano"},
    {"shovel", "dug_grass", "dug_berrybush", "dug_sapling"},
    {"book_gardening", "dug_grass", "dug_berrybush", "dug_sapling", "pinecone","acorn","twiggy_nut", "marblebean"},
    {"guano", "poop", "spoiled_food", "rottenegg", "fertilizer", "glommerfuel"},
    {"trap", "rabbit", "smallmeat", "froglegs", "silk", "spidergland", "monstermeat", "spoiled_food"}
  }

  self.root.btns = {}

  local x,y,rowcnt,colcnt = 0, 0, 0, 0
  for i, row in pairs(self.layout) do
    if i > rowcnt then rowcnt = i end
    local task = row[1]
    self.root.btns[task] = {}
    for inx, icon in pairs(row) do
      if inx > colcnt then colcnt = inx end
      local btn = self:MakeBtn(task, icon)
      btn:SetPosition( x, y)
      x = x + 45
      if inx == 1 then x = x + 25 end
    end
    y = y - 60
    x = 0
  end

  self.root:SetPosition(125, 100 + 60 * rowcnt)
  self.root:SetSize(25 + 45 * colcnt, 60 * rowcnt)

end)
function ChoresWheel:SetConfig(config)
	CONFIG=config
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
function ChoresWheel:MakeBtn(task, icon)--creates a button
  local btn = self.root:AddChild(ImageButton(ATLASINV, icon .. ".tex"))
  local widget = self
  btn:SetNormalScale(0.67, 0.67, 0.67) -- 63 * 0.67 = 42
  btn:SetFocusScale(0.76, 0.76, 0.76) -- 63 * 0.76 = 48

  self.root.btns[task][icon] = btn
  local function updateTint()
    if self.flag[task][icon] == false then
      btn.image:SetTint(.2,.2,.2,1)
    else
      btn.image:SetTint(1,1,1,1)
    end
  end

  --print("ti ", task, icon)
  if task ~= icon then updateTint() end

  btn.updateTint = updateTint
  btn:SetOnClick(function(self)

    widget:BtnClick(task, icon)
  end)--assign the handler of the OnClick event

  local _OnGainFocus = btn.OnGainFocus
  btn.OnGainFocus = function (self)
    _OnGainFocus(self)
    widget:BtnGainFocus(task,icon)
  end

  local _OnLoseFocus = btn.OnLoseFocus
  btn.OnLoseFocus = function (self)
    _OnLoseFocus(self)
    widget:BtnLoseFocus(task, icon)
  end

  return btn
end

function ChoresWheel:BtnClick(task, icon)
  if task == icon then
    self:DoTask(icon)
  elseif task == "book_gardening" then
    for k,v in pairs(self.flag[task]) do self.flag[task][k] = false end
    self.flag[task][icon] = true
    for k,v in pairs(self.root.btns[task]) do self.root.btns[task][k].updateTint() end
  else
    self.flag[task][icon] = not self.flag[task][icon]
    self.root.btns[task][icon].updateTint()
  end
end

function ChoresWheel:BtnGainFocus(task, icon) --on the focus of planting displays the placers
  if task == "book_gardening" and icon == "book_gardening" then

    if self.placers ~= nil then return end
    self.placers = {}

    local prefab_name = nil
    for prefab, flag in pairs(self.flag[task]) do
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

    local planting_x=GetModConfigData("planting_x",modname)
    local planting_y=GetModConfigData("planting_y",modname)
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
end

function ChoresWheel:BtnLoseFocus(task, icon)--remove placers on lose focus of planting
  if task == "book_gardening" and icon == "book_gardening" then
    if self.placers == nil then return end
    for k, v in pairs(self.placers) do
      v:Remove()
    end
    self:StopUpdating()
    self.placers = nil
  end
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


function ChoresWheel:OnUpdate(dt )
  if self.placers == nil then return end
  for k, v in pairs(self.placers) do
    v:reposition()
    v.components.placer:OnUpdate(dt)
  end
end

return ChoresWheel
