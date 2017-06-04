local TUNING = GLOBAL.TUNING
--GLOBAL.CHEATS_ENABLED = true
--GLOBAL.require( 'debugkeys' )
local OptionScreen = GLOBAL.require("widgets/options")
local CONFIG={}
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
--Load In-game Settings
CONFIG.ac_planting_x=GetModConfigData("planting_x") or 4
CONFIG.ac_planting_y=GetModConfigData("planting_y") or 5
CONFIG.ac_cutadulttreeonly=GetModConfigData("cut_adult_tree_only") or 0
--Main
function OnActivated(player)
  GLOBAL.ThePlayer:AddComponent("auto_chores")--add auto_chores property(?) to ThePlayer (to be accessed in chores.lua)
  GLOBAL.ThePlayer.components.auto_chores:SetGlobal(GLOBAL)
  GLOBAL.ThePlayer.components.auto_chores:SetConfig(CONFIG)

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
  widget:SetConfig(CONFIG)
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
end  )

function UpdateSettings()
  CONFIG.ac_planting_x=GetModConfigData("planting_x") or 4
  CONFIG.ac_planting_y=GetModConfigData("planting_y") or 5
  CONFIG.ac_cutadulttreeonly=GetModConfigData("cut_adult_tree_only") or 0
--  GLOBAL.ThePlayer.components.auto_chores:SetConfig(CONFIG)
--  widget:SetConfig(CONFIG)
  --ae_ignoreRestrictions = GetModConfigData("autoequipignorerestrictions") or 1
  --	ae_weapons = GetModConfigData("autoequipweapon") or 1
  --	ae_huntwithboomerang = GetModConfigData("autoequipboomerang") or 0
  --	ae_givelight = GetModConfigData("autoequiplight") or 0
  --
  --	aa_canCraftToolsAutomatically = GetModConfigData("autoequipcraftornot") > 0 or false
  --	aa_useGoldenTools = GetModConfigData("autoequipgoldornot") > 0 or false
  --
  --	aa_ignoreTraps = false --GetModConfigData("autoequipignoretraps") and GetModConfigData("autoequipignoretraps") > 0 or false
  --	aa_reactiveTraps = false --GetModConfigData("autoequipreactivatetraps") and GetModConfigData("autoequipreactivatetraps") > 0 or false
  --	aa_replantTrees = GetModConfigData("autoequipreplanttrees") and GetModConfigData("autoequipreplanttrees") > 0 or false
  --
  --	aa_refuelfires = GetModConfigData("autoequiprefuelfires") or false
  --	aa_repairwalls = GetModConfigData("autoequiprepairwalls") and GetModConfigData("autoequiprepairwalls") > 0 or false
  --
  --	aa_completelyignore = GetModConfigData("autoequipignoresaplings") and GetModConfigData("autoequipignoresaplings") > 0 or false

  print("Settings have been updated!")
end
local function ShowOptionsScreen( controls )

  if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
  if not IsDefaultScreen() then return end

  GLOBAL.TheFrontEnd:PushScreen(OptionScreen(controls))
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
    if controls.updatesettings then
      controls.updatesettings = false
      UpdateSettings()
    end
  end
  controls.OnUpdate = OnUpdate

end



AddClassPostConstruct( "widgets/controls", AddOptionsScreen)
