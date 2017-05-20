

local Inst = require "chores-lib.instance" 
local PrefabLibary = require("chores-lib.prefablibrary")  



local ChoreLib = PrefabLibary(function (proto)
  local stat = {} 
  if proto.components.tool ~= nil then
    stat.tool = {}
    stat.tool.CHOP = proto.components.tool:CanDoAction(ACTIONS.CHOP)
    stat.tool.DIG = proto.components.tool:CanDoAction(ACTIONS.DIG)
    stat.tool.MINE = proto.components.tool:CanDoAction(ACTIONS.MINE)
  end
  return stat
  end)

local function _isChopper(item) --check if the object can chop
  if item == nil then return false end
  local stat = ChoreLib:Get(item)
  if stat == nil then return false end
  if stat.tool == nil then return false end
  return stat.tool.CHOP
end

local function _isDigger(item) --check if the object can dig
  if item == nil then return false end
  local stat = ChoreLib:Get(item)
  if stat == nil then return false end
  if stat.tool == nil then return false end
  return stat.tool.DIG
end
local function _isMiner(item) --check if the object can mine
  if item == nil then return false end
  local stat = ChoreLib:Get(item)
  if stat == nil then return false end
  if stat.tool == nil then return false end
  return stat.tool.MINE
end


local AutoChores = Class(function(self, inst)
  self.inst = inst
  self.INST = Inst(inst)  

  print("AutoChores") 
  self.inst:ListenForEvent("actionfailed", function(inst) inst.components.auto_chores:StopLoop() end)--when an action has failed stops the loop

  
  self.ActionButtonDown = true
  self:OverridePC()
  self:OverrideInput()

  end,
  nil,
  { })

function AutoChores:SetTask(task, flag, placer)   
  self:ClearPlacer()
  self.task = task -- "LumberJack"
  self.task_flag = flag
  self.task_placer = placer
  print("SetTask", task, flag, placer) 
end 
function AutoChores:ForceStop()
  -- body
  self.inst.components.locomotor:Clear()
  self:StopLoop()
end

function AutoChores:ClearPlacer()

  if self.task_placer == nil then return end 
  for k, v in pairs(self.task_placer) do
    v:Remove()
  end
  self.task_placer = nil
end


function AutoChores:StopLoop() 
  print("StopLoop")
  if self.task ~= nil then  
    self.task = nil 
    self:ClearPlacer()
  end
end
function AutoChores:GetAction()
  if self.task == "axe" then
    return self:GetLumberJackAction() 
  elseif self.task == "pickaxe" then
    return self:GetMinerAction()
  elseif self.task == "backpack" then
    return self:GetCollectorAction()
  elseif self.task == "shovel" then
    return self:GetDiggerAction()
  elseif self.task == "book_gardening" then
    return self:GetPlanterAction() 
  end
end

function AutoChores:OverrideInput()
  local auto_chores = self
  local _fnOrig = TheInput.IsControlPressed
  local function _fnOver(self, control)
    if auto_chores.task ~= nil then
      if control == CONTROL_ACTION then return auto_chores.ActionButtonDown end
    end
    return _fnOrig(self, control)
  end
  TheInput.IsControlPressed = _fnOver
end

function AutoChores:OverridePC()--player controller
  local auto_chores = self
  local PLAYER = Inst(self.inst)
  local pc = self.inst.components.playercontroller



  local _fnOrig =  pc.GetActionButtonAction
  local function _fnOver(self, force_target)

    if auto_chores.task == nil then return _fnOrig(self, force_target) end

    --Don't want to spam the action button before the server actually starts the buffered action
    if not self.ismastersim and (self.remote_controls[CONTROL_ACTION] or 0) > 0 then
      return
    end
    if not self:IsEnabled() then
      return
    end


    local isdoing, isworking
    if self.inst.sg == nil then
      isdoing = self.inst:HasTag("doing")
      isworking = self.inst:HasTag("working")
    elseif not self.ismastersim and self.inst:HasTag("autopredict") then
      isdoing = self.inst.sg:HasStateTag("doing")
      isworking = self.inst.sg:HasStateTag("working")
    else
      isdoing = self.inst.sg:HasStateTag("doing") or self.inst:HasTag("doing")
      isworking = self.inst.sg:HasStateTag("working") or self.inst:HasTag("working")
    end

    if (isdoing or isworking) then return end 

    if self.passtime ~= nil and self.passtime > 0 then --delay
      self.passtime = self.passtime - 1
      return
    end

    local bufaction = auto_chores:GetAction()

    print("auto_chores", bufaction)
    if bufaction == nil then 
      auto_chores:StopLoop() 
    else
      if bufaction.action == ACTIONS.BUILD  then
        if not PLAYER:builder_IsBusy() then
          self.passtime = 20 -- 20 * 0.03초 => 0.6초
          PLAYER:builder_MakeRecipeBy(bufaction.recipe)
        end 
      elseif bufaction.action == ACTIONS.EQUIP then
        PLAYER:inventory_UseItemFromInvTile(bufaction.invobject)
          self.passtime = 10 -- 10 * 0.03초 => 0.3초
          return
        elseif bufaction.action == ACTIONS.DEPLOY then 
        -- TODO 디플로이 기능 구현 하기
        -- local act = BufferedAction(self.builder, nil, ACTIONS.DEPLOY, act.invobject, Vector3(self.inst.Transform:GetWorldPosition()))  
        local act = bufaction
        
       local pos = bufaction.pos
       print("Position:",pos)
       local seed = act.invobject
       print("Item:",seed)
				--if( self.ismastersim ) then
--				print("ismaster")
--					local act = BufferedAction( self.inst, nil, ACTIONS.DEPLOY, seed, pos, nil )
--					self.inst.components.locomotor:PushAction(act,true)
--				else
--				print("isnotmaster")
--					local act = BufferedAction( self.inst, nil, ACTIONS.DEPLOY, seed, pos, nil )
--					act.preview_cb = function()
--					local RPC = GLOBAL.RPC
--					local SendRPCToServer = GLOBAL.SendRPCToServer
						--SendRPCToServer(RPC.RightClick, act.action.code, pos.x, pos.z, act.target, false, controlmods, nil, act.action.mod_name)
						if( _G.TheWorld.Map:CanDeployPlantAtPoint(pos, seed) ) then
						self.passtime = 20
						_G.SendRPCToServer(_G.RPC.ControllerActionButtonDeploy, seed, pos.x, pos.z)
						end
--					end
--					self:DoAction(act)
--				end
        --if not self.ismastersim then  
--          print("not master")
--          local position = bufaction.pos
--          local mouseover = false -- TheInput:GetWorldEntityUnderMouse()
--          local controlmods = nil
--
--          local function _cb() 
--            self.remote_controls[CONTROL_SECONDARY] = 0
--            local isreleased = true
--            SendRPCToServer(RPC.RightClick, act.action.code, position.x, position.z, mouseover, isreleased, controlmods, nil, act.action.mod_name)
--            -- print("PLAYER:inventory_ReturnActiveItem()")
--            -- PLAYER:inventory_ReturnActiveItem()              
--          end
--          act.preview_cb = _cb
--        end

--        self:DoAction(act)
--        return
      end
    end
    return bufaction 
  end

  pc.GetActionButtonAction = _fnOver

end

function AutoChores:GetItem(fn)
  local hands = self.INST:inventory_GetEquippedItem(EQUIPSLOTS.HANDS)
  if fn(hands) then
    return hands
  end 
  local items = self.INST:inventory_FindItems(fn)
  return items[1]
end 
function AutoChores:CustomFindItems( inst, inv, check )
	if not inst or not inv or not check or ( ( not inv.GetItems or not inv:GetItems() ) and not inv.itemslots ) then print("Something went wrong with the inventory...") return nil end
	local items = inv.GetItems and inv:GetItems() or inv.itemslots
	local zeItem = {}
	
	for k,v in pairs(items) do
		if check(v) then
			table.insert(zeItem,v)
		end
	end
	
	if inv and inv.GetOverflowContainer then
		items = ( inv:GetOverflowContainer() and inv:GetOverflowContainer().GetItems and inv:GetOverflowContainer():GetItems() ) or ( inv:GetOverflowContainer() and inv:GetOverflowContainer().slots ) or nil
		if items then
			for k,v in pairs(items) do
				if check(v) then
					table.insert(zeItem,v)
				end
			end
		end
	end
	
	return zeItem
end
function AutoChores:GetInventory( inst )
	return ( inst.components and inst.components.playercontroller and inst.components.inventory ) or ( inst.replica and inst.replica.inventory )
end

function AutoChores:TestHandAction(fn)
  local hands = self.INST:inventory_GetEquippedItem(EQUIPSLOTS.HANDS) 
  return fn(hands) 
end 

function AutoChores:TryActiveItem(fn)
  local activeItem = self.INST:inventory_GetActiveItem()
  if activeItem ~= nil and  fn(activeItem) then
    return activeItem
  end
  local item = self:GetItem(fn) 
  if item ~=nil then
    self.INST:inventory_TakeActiveItemFromAllOfSlot(fn)
    return item
  end
end


SEE_DIST_WORK_TARGET = 25
SEE_DIST_LOOT = 5



function AutoChores:GetLumberJackAction()
  -- print('GetLumberJackAction')

  local item = nil 

  item = self:GetItem(_isChopper)
  if item == nil then
    local target = FindEntity(self.inst, SEE_DIST_LOOT, _isChopper)
    if target then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    end 
    
    local recipe = "axe"
    if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
      return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
    end
    return nil
  end
  local chopper = item 



  item = self:GetItem(_isDigger)

  -- print("finded digger = ", item)

  if item == nil then 
    local target = FindEntity(self.inst, SEE_DIST_LOOT, _isDigger)
    if target then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    end 

    local recipe = "shovel"
    if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
      return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
    end
  end

  local digger = item 
  
  local target = FindEntity(self.inst, SEE_DIST_LOOT, function (item)
    if item == nil then return false end
    if item.prefab == "log" then return true end 
    if self.task_flag["charcoal"] == true and item.prefab == "charcoal" then return true end 
    if self.task_flag["pinecone"] == true and (item.prefab == "pinecone" or item.prefab == "acorn")  then return true end --and item.issapling:value() == false
    --if item.prefab == "acorn" then return true end -- this is Birchnut
    return false
    end)
  if target then
    return BufferedAction(self.inst, target, ACTIONS.PICKUP )
  end 


  if digger then
    local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item)
      return item ~= nil and item:HasTag("stump") 
      end)
    if target then
      if self:TestHandAction(_isDigger) == false then
        -- print("do Equip digger", digger)
        return BufferedAction(self.inst, nil, ACTIONS.EQUIP, digger)
      end
      return BufferedAction(self.inst, target, ACTIONS.DIG, digger )
    end 
  end 


  local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item)
    if item == nil then return false end
    if item:HasTag("stump") then return false end
    if self.task_flag["charcoal"] == false and item:HasTag("burnt") then return false end 
    return item:HasTag("tree") 
    end)
  if target then
    if self:TestHandAction(_isChopper) == false then
      -- print("do Equip chopper", chopper)
      return BufferedAction(self.inst, nil, ACTIONS.EQUIP, chopper)
    end
    return BufferedAction(self.inst, target, ACTIONS.CHOP, chopper )
  end 

  -- -- print("target = ",  target)
  -- if target then
  --   local bufaction = BufferedAction(inst, target, ACTIONS.CHOP) 

end 


function AutoChores:GetMinerAction()
  -- print('GetLumberJackAction')

  local item = nil 

  item = self:GetItem(_isMiner)
  if item == nil then
    local target = FindEntity(self.inst, SEE_DIST_LOOT, _isMiner)
    if target then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    end 
    
    local recipe = "pickaxe"
    if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
      return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
    end
    return nil
  end
  local minner = item 


--pickup target
  local target = FindEntity(self.inst, SEE_DIST_LOOT, function (item) 
    if item == nil then return false end
    if self.task_flag["nitre"] == true and item.prefab == "nitre" then return true end 
    if self.task_flag["goldnugget"] == true and item.prefab == "goldnugget" then return true end 
    if item.prefab == "flint" then return true end 
    if item.prefab == "rocks" then return true end   
    return false 
    end)
  if target then
    return BufferedAction(self.inst, target, ACTIONS.PICKUP )
  end 
  


--miner target
  if minner then 
    local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item) 
      if item == nil then return false end
      if self.task_flag["nitre"] == true and item.prefab == "rock1" then return true end 
      if self.task_flag["goldnugget"] == true and item.prefab == "rock2" then return true end 
      if item.prefab == "rock_flintless" then return true end 
      return false

      end)
    if target then
      if self:TestHandAction(_isMiner) == false then
        -- print("do Equip digger", digger)
        return BufferedAction(self.inst, nil, ACTIONS.EQUIP, minner)
      end
      return BufferedAction(self.inst, target, ACTIONS.MINE, minner)
    end 
  end 
  

end 

function AutoChores:GetCollectorAction()  
  local target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item) 
    if item == nil then return false end
    if self.task_flag["flint"] == true and item.prefab == "flint" then return true end 
    if self.task_flag["carrot"] == true and (item.prefab == "carrot" or item.prefab == "carrot_planted") then return true end 
    if self.task_flag["petals"] == true and (item.prefab == "flower" or item.prefab == "petals" or item.prefab == "planted_flower") then return true end
    if self.task_flag["green_cap"] == true and (
    		(
    			(item.prefab == "green_mushroom" or item.prefab == "red_mushroom" or item.prefab == "blue_mushroom") and item:HasTag("pickable") 
    		) or (
    			item.prefab == "green_cap" or item.prefab == "red_cap" or item.prefab == "blue_cap"
    		)
    	) then return true end  
    if self.task_flag["cutgrass"] == true and item.prefab == "grass" and item:HasTag("pickable") then return true end   
    if self.task_flag["twigs"] == true and item.prefab == "sapling" and item:HasTag("pickable") then return true end   
    if self.task_flag["berries"] == true and (item.prefab == "berrybush" or item.prefab == "berrybush2" or item.prefab == "berrybush_juicy") and item:HasTag("pickable") then return true end   
    return false 
    end)
  if target then
    if target.prefab == "flint" or target.prefab == "berries_juicy" or target.prefab == "berries" or target.prefab == "carrot" or target.prefab == "green_cap" or target.prefab == "red_cap" or target.prefab == "blue_cap" then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    else
      return BufferedAction(self.inst, target, ACTIONS.PICK )
    end
  end 
end


function AutoChores:GetDiggerAction()  
  local target = FindEntity(self.inst, SEE_DIST_LOOT, function (item)  
    if item == nil then return false end 
    if self.task_flag["dug_grass"] == true and item.prefab == "cutgrass" then return true end 
    if self.task_flag["dug_grass"] == true and item.prefab == "dug_grass" then return true end 
    if self.task_flag["dug_berrybush"] == true and (item.prefab == "berries" or item.prefab == "berries_juicy") then return true end   
    if self.task_flag["dug_berrybush"] == true and ( item.prefab == "dug_berrybush" or item.prefab == "dug_berrybush2" or item.prefab == "dug_berrybush_juicy") then return true end   
    if self.task_flag["dug_sapling"] == true and item.prefab == "twigs" then return true end    
    if self.task_flag["dug_sapling"] == true and item.prefab == "dug_sapling" then return true end    
    return false 
    end)
  if target then 
    return BufferedAction(self.inst, target, ACTIONS.PICKUP )  
  end 


  local item = self:GetItem(_isDigger) 
  if item == nil then 
    local target = FindEntity(self.inst, SEE_DIST_LOOT, _isDigger)
    if target then
      return BufferedAction(self.inst, target, ACTIONS.PICKUP )
    end 

    local recipe = "shovel"
    if self.INST:builder_KnowsRecipe(recipe) and self.INST:builder_CanBuild(recipe) then
      return BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe, 1)
    end
  end

  local digger = item 
  -- print("digger = ", digger)

  if digger then 
    target = FindEntity(self.inst, SEE_DIST_WORK_TARGET, function (item)   
      if item == nil then return false end
      if item:HasTag("barren") then return false end
      if self.task_flag["dug_grass"] == true and item.prefab == "grass" then return true end 
      if self.task_flag["dug_berrybush"] == true and ( item.prefab == "berrybush" or item.prefab == "berrybush2" or item.prefab == "berrybush_juicy") then return true end   
      if self.task_flag["dug_sapling"] == true and item.prefab == "sapling" then return true end   
      return false 
      end)

    -- print("target = ", target)
    if target then
      if self:TestHandAction(_isDigger) == false then
        print("do Equip digger", digger)
        return BufferedAction(self.inst, nil, ACTIONS.EQUIP, digger)
      end
      return BufferedAction(self.inst, target, ACTIONS.DIG, digger )
    end 
  end 

end

function AutoChores:GetPlanterAction()

	local seed = self:GetItem(--self:CustomFindItems(self.inst, self:GetInventory(self.inst), 
	function (item) 
    if item == nil then return false end
    if self.task_flag["dug_grass"] == true and item.prefab == "dug_grass" then return true end 
    if self.task_flag["dug_berrybush"] == true and ( item.prefab == "dug_berrybush" or item.prefab == "dug_berrybush2" or item.prefab == "dug_berrybush_juicy") then return true end 
    if self.task_flag["dug_sapling"] == true and item.prefab == "dug_sapling" then return true end 
    if self.task_flag["pinecone"] == true and item.prefab == "pinecone" then return true end 
    if self.task_flag["acorn"] == true and item.prefab == "acorn" then return true end 
    return false
    end) 
  if seed ~= nil then
    if self.task_placer ~= nil then
      for k, placer in pairs(self.task_placer) do
        local pos = placer:GetPosition()
        if Inst(seed):inventoryitem_CanDeploy(pos) then
        	print("can deploy")
        	local act = BufferedAction( self.inst, nil, ACTIONS.DEPLOY, seed, pos, nil )
            return act --BufferedAction(self.inst, nil, ACTIONS.DEPLOY, item, pos)
        end
      end
    end 
  end

--  Inst(self.inst):inventory_ReturnActiveItem()
end



return AutoChores