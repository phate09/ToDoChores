Inst = Class(function(self, inst)--store inst variable
  self.inst = inst
  end)

function Inst:builder_IsBusy()
    return self.inst.replica.builder:IsBusy()
end

function Inst:builder_KnowsRecipe(recipename)
  if recipename == nil then return false end
  return self.inst.replica.builder:KnowsRecipe(recipename)
end
function Inst:builder_CanBuild(recipename)
  if recipename == nil then return false end
  return self.inst.replica.builder:CanBuild(recipename)
end
function Inst:CanBuild(recipename)
    return self:builder_KnowsRecipe(recipename) and self:builder_CanBuild(recipename)
end
function Inst:builder_MakeRecipeBy(recipename)
  local recipe = AllRecipes[recipename]
    self.inst.replica.builder:MakeRecipeFromMenu(recipe)
end

function Inst:combat()
    return self.inst.replica.combat
end

function Inst:combat_GetTarget()
    return self.inst.replica.combat:GetTarget()
end

function Inst:combat_GetAttackRangeWithWeapon()
    return self.inst.replica.combat:GetAttackRangeWithWeapon()
end

function Inst:equippable()
    return self.inst.replica.equippable
end
function Inst:equippable_EquipSlot()
    return self.inst.replica.equippable:EquipSlot()
end

function Inst:health_Max()
    return self.inst.replica.health:Max()
end
function Inst:health_Current()
    return self.inst.replica.health.classified.currenthealth:value()
end

function Inst:inventory_GetEquippedItem(slot)
    return self.inst.replica.inventory:GetEquippedItem(slot)
end
function Inst:inventory_GetAllItems()
  local items = {}
  for k,v in pairs(self:inventory_GetItems()) do table.insert(items, v) end
  for k,v in pairs(self:inventory_GetEquips()) do table.insert(items, v) end

  local overflow = self:inventory_GetOverflowContainer()
  if overflow ~= nil then
    if overflow.slots then
      for k,v in pairs(overflow.slots) do table.insert(items, v) end
    else
      for k,v in pairs(overflow:GetItems()) do table.insert(items, v) end
    end
  end
  return items
end
function Inst:inventory_FindItems(fn)
    local items = self:inventory_GetAllItems()
    local result = {}
    for k,v in pairs(items) do
      if fn(v) then
        table.insert(result, v)
      end
    end
    return result
end
function Inst:hasItem(fn)
  if fn == nil then return false end
  for k,v in pairs(self:inventory_GetAllItems()) do
    if fn(v) then
      return true
    end
  end
  for k,v in pairs(self:inventory_GetEquips()) do
    if fn(v) then
      return true
    end
  end
  local overflow = self:inventory_GetOverflowContainer()
  if overflow ~= nil then
    local items = nil
    if overflow.slots ~= nil then
      items = overflow.slots
    else
      items = overflow:GetItems()
    end

    for k,v in pairs(items) do
      if fn(v) then
        return true
      end
    end
  end
  return false
end
function Inst:hasItemOrCanBuild(fn, recipename)
  return self:hasItem(fn) or self:CanBuild(recipename)
end

function Inst:inventory_GetActiveItem()
  return self.inst.replica.inventory:GetActiveItem()
end

function Inst:inventory_ReturnActiveItem()
  return self.inst.replica.inventory:ReturnActiveItem()
end

function Inst:inventory_TakeActiveItemFromAllOfSlot(fn)
  for k,v in pairs(self:inventory_GetItems()) do
    if fn(v) then
      self.inst.replica.inventory:TakeActiveItemFromAllOfSlot(k)
      return
    end
  end
  for k,v in pairs(self:inventory_GetEquips()) do
    if fn(v) then
      self.inst.replica.inventory:TakeActiveItemFromAllOfSlot(k)
      return
    end
  end

  local overflow = self:inventory_GetOverflowContainer()
  if overflow ~= nil then
    local items = nil
    if overflow.slots ~= nil then
      items = overflow.slots
    else
      items = overflow:GetItems()
    end

    for k,v in pairs(items) do
      if fn(v) then
        overflow:TakeActiveItemFromAllOfSlot(k)
        return
      end
    end
  end
end

function Inst:inventory_UseItemFromInvTile(item)
    return self.inst.replica.inventory:UseItemFromInvTile(item)
end
function Inst:inventory_GetItems()
    return self.inst.replica.inventory:GetItems()
end
function Inst:inventory_GetEquips()
    return self.inst.replica.inventory:GetEquips()
end
function Inst:inventory_GetOverflowContainer()
    return self.inst.replica.inventory:GetOverflowContainer()
end

function Inst:inventoryitem()
    return self.inst.replica.inventoryitem
end
function Inst:inventoryitem_PercentUsed()
    return self.inst.replica.inventoryitem.classified.percentused:value()
end
function Inst:inventoryitem_CanDeploy(pos)
    return self.inst.replica.inventoryitem:CanDeploy(pos)
end
function Inst:inventoryitem_GetDeployPlacerName()
    return self.inst.replica.inventoryitem:GetDeployPlacerName()
end

function Inst:GetLeftClickAction(position, target)
    return self.inst.components.playeractionpicker:GetLeftClickActions(position, target)[1]
end
function Inst:GetRightClickAction(position, target)
    return self.inst.components.playeractionpicker:GetRightClickActions(position, target)[1]
end

return Inst
