-- local is_dst
-- function IsDST()
--   if is_dst == nil then
--     is_dst = kleifileexists("scripts/networking.lua") and true or false
--   end
--   return is_dst
-- end

local PrefabLibrary = Class( function(self, fn)
	self.stats = {}
	self.fn = fn

  -- self:DieTest()
  end)
function PrefabLibrary:DieTest()
  local prefab = "butterfly"
  local data = nil
  if self.stats[prefab] == nil then
    local realMaster =  TheWorld.ismastersim
    TheWorld.ismastersim = true
    local _assert = assert
    assert = function (a,b,c) end
    local proto = SpawnPrefab(prefab)
    assert = _assert 

    proto = SpawnPrefab(prefab)
    -- self.stats[prefab] = self.fn(proto, data)
    proto:Remove()
    TheWorld.ismastersim = realMaster
  end  
  return self.stats[prefab]
end


function PrefabLibrary:Get(item, data)
  if item == nil or item.prefab == nil then
    print("=================================== PrefabLibrary GOT NIL")

    print(item, item.prefab)
    -- item.test.aaa()
    return nil
  end

  if IsDST() == false then 
    return self.fn(item, data)
  end

  local prefab = item.prefab
  -- print("copy", proto)
  -- print("components-----------")
  -- for k, v in pairs(copy.components) do
  --   print("copy comp = ", k, v)
  -- end
  -- print("replica-----------")
  -- for k, v in pairs(copy.replica._ ) do
  --   print("copy replica = ", k, v)
  -- end
  if self.stats[prefab] == nil then
  	local realMaster =  TheWorld.ismastersim
  	TheWorld.ismastersim = true

    local _assert = assert
    assert = function (a,b,c) end
    local proto = SpawnPrefab(prefab)
    assert = _assert 
    
  	self.stats[prefab] = self.fn(proto, data)
  	proto:Remove()
  	TheWorld.ismastersim = realMaster
  end  
  return self.stats[prefab]
end

return PrefabLibrary