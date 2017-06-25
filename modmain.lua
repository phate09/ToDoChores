local _G = GLOBAL
local TUNING = _G.TUNING
--_G.CHEATS_ENABLED = true
--_G.require( 'debugkeys' )
local OptionScreen = _G.require("widgets/options")
local Inspect = _G.require("components/inspect")
local ControlWidget = _G.require("widgets/chores")
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
  _G.ThePlayer:AddComponent("auto_chores")--add auto_chores property(?) to ThePlayer (to be accessed in chores.lua)
  _G.ThePlayer.components.auto_chores:SetGlobal(GLOBAL)
  _G.ThePlayer.components.auto_chores:SetEnv(env)
end

function SimPostInit(player)--after the world is initialised
  print("SimPostInit")
  _G.TheWorld:ListenForEvent("playeractivated", OnActivated)--waits for the player to be active
end

AddSimPostInit(SimPostInit)

local function IsDefaultScreen()
  return _G.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
end
local function IsMapScreen()
  return _G.TheFrontEnd:GetActiveScreen().name:find("MapScreen") ~= nil
end

local function AddWidget(parent)
  ControlWidget:SetEnv(env)
  widget = parent:AddChild(ControlWidget())
  widget:Hide()--widget starts hidden

  _G.TheInput:AddKeyUpHandler(ToggleButton, function()--adds the eventhandler to the keyboard when pressing the button
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
  _G.ThePlayer.components.auto_chores:UpdateSettings()
  ControlWidget:UpdateSettings()
end

local function ShowOptionsScreen( controls )

  if type(_G.ThePlayer) ~= "table" or type(_G.ThePlayer.HUD) ~= "table" then return end
  if not IsDefaultScreen() then return end

  _G.TheFrontEnd:PushScreen(OptionScreen(controls, env))
end

local function HideOptionsScreen(delay_focus_loss)
  if type(_G.ThePlayer) ~= "table" or type(_G.ThePlayer.HUD) ~= "table" then return end

  if delay_focus_loss and controls.OptionScreen.activegesture then
    --delay a little on controllers to prevent canceling the emote by moving
    _G.ThePlayer:DoTaskInTime(0.5, function() SetModHUDFocus("OptionScreen", false) end)
  else
    SetModHUDFocus("OptionScreen", false)
  end

  controls.OptionScreen:Hide()
  controls.OptionScreen.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)

  if not IsDefaultScreen() then return end

  if controls.OptionScreen.activegesture then
    _G.TheNet:SendSlashCmdToServer(controls.OptionScreen.activegesture, true)
  end
end

local function AddOptionsScreen( self )
  controls = self -- this just makes controls available in the rest of the modmain's functions
  inst = _G.ThePlayer
  if not handlers_applied then
    -- Keyboard controls
    _G.TheInput:AddKeyDownHandler(KEYBOARDTOGGLEKEY, function()
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
