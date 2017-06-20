local TUNING = GLOBAL.TUNING
--GLOBAL.CHEATS_ENABLED = true
--GLOBAL.require( 'debugkeys' )
local OptionScreen = GLOBAL.require("widgets/options")
local widget

-------------
-- Wdiget
local ToggleButton = GetModConfigData("togglekey")
if type(ToggleButton) == "string" then
  ToggleButton = ToggleButton:lower():byte()
end

--In-Game settings
local KEYBOARDTOGGLEKEY = GetModConfigData("autochoresopeningamesettings") or "O"
if type(KEYBOARDTOGGLEKEY) == "string" then
  KEYBOARDTOGGLEKEY = KEYBOARDTOGGLEKEY:lower():byte()
end
--Main
function OnActivated(player)
  GLOBAL.ThePlayer:AddComponent("auto_chores")--add auto_chores property(?) to ThePlayer (to be accessed in chores.lua)
  GLOBAL.ThePlayer.components.auto_chores:SetGlobal(GLOBAL)
  GLOBAL.ThePlayer.components.auto_chores:SetEnv(env)
end

function SimPostInit(player)--after the world is initialised
  print("SimPostInit")
  GLOBAL.TheWorld:ListenForEvent("playeractivated", OnActivated)--waits for the player to be active
end

AddSimPostInit(SimPostInit)

local function IsDefaultScreen()
  return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
end
local function IsMapScreen()
  return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("MapScreen") ~= nil
end

local function AddWidget(parent)
  local ControlWidget = GLOBAL.require "widgets/chores" --load the widget chores class instance
  widget = parent:AddChild(ControlWidget())
  widget:Hide()--widget starts hidden

  GLOBAL.TheInput:AddKeyUpHandler(ToggleButton, function()--adds the eventhandler to the keyboard when pressing the button
    if not IsDefaultScreen() then return end--and not IsMapScreen()
    widget:Toggle()
  end)
end

Assets = {
  Asset("ATLAS", "images/fepanels.xml"),
  Asset("IMAGE", "images/fepanels.tex"),
}
AddClassPostConstruct( "widgets/controls", function (controls)
  AddWidget(controls)--adds the widget to the controls collection
end)

local function UpdateSettings()
  GLOBAL.ThePlayer.components.auto_chores:UpdateSettings()
end

local function ShowOptionsScreen( controls )

  if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
  if not IsDefaultScreen() then return end

  GLOBAL.TheFrontEnd:PushScreen(OptionScreen(controls, env))
end

local function HideOptionsScreen(delay_focus_loss)
  if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end

  if delay_focus_loss and controls.OptionScreen.activegesture then
    --delay a little on controllers to prevent canceling the emote by moving
    GLOBAL.ThePlayer:DoTaskInTime(0.5, function() SetModHUDFocus("OptionScreen", false) end)
  else
    SetModHUDFocus("OptionScreen", false)
  end

  controls.OptionScreen:Hide()
  controls.OptionScreen.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)

  if not IsDefaultScreen() then return end

  if controls.OptionScreen.activegesture then
    GLOBAL.TheNet:SendSlashCmdToServer(controls.OptionScreen.activegesture, true)
  end
end

local function AddOptionsScreen( self )
  controls = self -- this just makes controls available in the rest of the modmain's functions
  inst = GLOBAL.ThePlayer
  if not handlers_applied then
    -- Keyboard controls
    GLOBAL.TheInput:AddKeyDownHandler(KEYBOARDTOGGLEKEY, function()
      ShowOptionsScreen(controls)
    end)

    handlers_applied = true
  end

  local OldOnUpdate = controls.OnUpdate
  local function OnUpdate(...)
    OldOnUpdate(...)
    if env.updatesettings then
      env.updatesettings = false
      UpdateSettings()
    end
  end
  controls.OnUpdate = OnUpdate
end

AddClassPostConstruct( "widgets/controls", AddOptionsScreen)
