local _G = GLOBAL
local TUNING = _G.TUNING
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' )

local is_dst
function IsDST()
  if is_dst == nil then
    is_dst = GLOBAL.kleifileexists("scripts/networking.lua") and true or false
  end
  return is_dst
end
_G.IsDST = IsDST

function SetTheWorld()
  if IsDST() == false then 
    local TheWorld = _G.GetWorld()
    _G.rawset(_G, "TheWorld", TheWorld)
    -- _G.TheWorld = TheWorld
  end
end
function SetThePlayer(player)
  if IsDST() == false then  
    _G.rawset(_G, "ThePlayer", player)
    -- _G.TheWorld = TheWorld
  end
end 


-------------
-- Wdiget 
local ToggleButton = GetModConfigData("togglekey")





function OnActivated(player)
  -- local player = playercontroller.inst  
  -- print("OnActivated prefabs", _G.ThePlayer)
  _G.ThePlayer:AddComponent("auto_chores")
end

function SimPostInit(player)
  -- example of modifying the player charater
  -- player.components.health:SetMaxHealth(50)

  print("SimPostInit")
  if IsDST() then
    _G.TheWorld:ListenForEvent("playeractivated", OnActivated)

  else 
    -- local TheWorld = _G.TheWorld and _G.TheWorld or _G.GetWorld()
    SetTheWorld()
    SetThePlayer(player)
    OnActivated(player) 
  end

end

AddSimPostInit(SimPostInit)





-- function AddController(controls)

-- 	-- for some reason, without this the game would crash without an error when calling controls.topright_root:AddChild
-- 	-- too lazy to track down the cause, so just using this workaround
-- 	controls.inst:DoTaskInTime( 1, function()

-- 		-- add the minimap widget and set its position
-- 		local ControlWidget = require "widgets/chore"

-- 		controls:AddChild(ControlWidget()) 
-- 	end)

-- end 

-- AddClassPostConstruct( "widgets/controls", AddController )



local function IsDefaultScreen()
  return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
end

local function AddWidget(parent)

  local ControlWidget = _G.require "widgets/chores"

  local widget = parent:AddChild(ControlWidget())   
  widget:Hide()

  -- local keydown = false
  -- GLOBAL.TheInput:AddKeyDownHandler(ToggleButton, function()
  --   if not IsDefaultScreen() then return end 
  --   widget:Show()
  --   end)
  GLOBAL.TheInput:AddKeyUpHandler(ToggleButton, function()
    if not IsDefaultScreen() then return end 
    widget:Toggle()
    end)
end


Assets = { 
  Asset("ATLAS", "images/fepanels.xml"),
  Asset("IMAGE", "images/fepanels.tex"), 
}


if IsDST() then
  AddClassPostConstruct( "widgets/controls", function (controls)
    AddWidget(controls)
    end  )
else 
  table.insert(Assets, Asset("ATLAS", "images/avatars.xml"))
    
  table.insert(Assets, Asset("IMAGE", "images/avatars.tex"))

  AddSimPostInit(function()
    local controls = _G.ThePlayer.HUD
    AddWidget(controls)
    end)

end