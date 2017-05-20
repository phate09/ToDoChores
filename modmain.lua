local _G = GLOBAL
local TUNING = _G.TUNING
_G.CHEATS_ENABLED = true
_G.require( 'debugkeys' )

--local is_dst
--function IsDST()
--  if is_dst == nil then
--    is_dst = GLOBAL.kleifileexists("scripts/networking.lua") and true or false
--  end
--  return is_dst
--end
--_G.IsDST = IsDST

-------------
-- Wdiget 
local ToggleButton = GetModConfigData("togglekey")





function OnActivated(player)
  -- local player = playercontroller.inst  
  -- print("OnActivated prefabs", _G.ThePlayer)
  _G.ThePlayer:AddComponent("auto_chores")
end

function SimPostInit(player)--after the world is initialised
  -- example of modifying the player charater
  -- player.components.health:SetMaxHealth(50)

  print("SimPostInit")
    _G.TheWorld:ListenForEvent("playeractivated", OnActivated)--waits for the player to be active

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

  local ControlWidget = _G.require "widgets/chores" --load the widget chores class instance

  local widget = parent:AddChild(ControlWidget())   
  widget:Hide()

  GLOBAL.TheInput:AddKeyUpHandler(ToggleButton, function()--adds the eventhandler to the keyboard when pressing the button
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
    AddWidget(controls)--adds the widget to the controls collection
    end  )
else 
  table.insert(Assets, Asset("ATLAS", "images/avatars.xml"))
    
  table.insert(Assets, Asset("IMAGE", "images/avatars.tex"))

  AddSimPostInit(function()
    local controls = _G.ThePlayer.HUD
    AddWidget(controls)
    end)

end