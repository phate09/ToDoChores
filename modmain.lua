local TUNING = GLOBAL.TUNING
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' )

-------------
-- Wdiget 
local ToggleButton = GetModConfigData("togglekey")
function OnActivated(player)
  GLOBAL.ThePlayer:AddComponent("auto_chores")--add auto_chores property(?) to ThePlayer (to be accessed in chores.lua)
  GLOBAL.ThePlayer.components.auto_chores:SetGlobal(GLOBAL)
end

function SimPostInit(player)--after the world is initialised
  print("SimPostInit")
    GLOBAL.TheWorld:ListenForEvent("playeractivated", OnActivated)--waits for the player to be active
end

AddSimPostInit(SimPostInit)

local function IsDefaultScreen()
  return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
end

local function AddWidget(parent)
  local ControlWidget = GLOBAL.require "widgets/chores" --load the widget chores class instance
  local widget = parent:AddChild(ControlWidget())   
  widget:Hide()--widget starts hidden

  GLOBAL.TheInput:AddKeyUpHandler(ToggleButton, function()--adds the eventhandler to the keyboard when pressing the button
    if not IsDefaultScreen() then return end 
    widget:Toggle()
    end)
end

Assets = { 
  Asset("ATLAS", "images/fepanels.xml"),
  Asset("IMAGE", "images/fepanels.tex"), 
}
AddClassPostConstruct( "widgets/controls", function (controls)
    AddWidget(controls)--adds the widget to the controls collection
end  )