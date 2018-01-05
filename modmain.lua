--- To Do Chores (a Don't Starve Together mod)
-- @module modmain

-- global variable
chores = nil
IS_PLAYING_NOW = GLOBAL.TheNet:GetIsClient() or GLOBAL.TheNet:GetIsServer()

-- local variable
local addChoresControls = nil

if IS_PLAYING_NOW then
  -- Main: add listener to init Chores
  AddPrefabPostInitAny( function(inst)
    if GLOBAL.ThePlayer and inst == GLOBAL.ThePlayer then
      print("Chores: ThePlayer Ready.")
      modmain()
    end
  end )

  AddClassPostConstruct( "widgets/controls", function (controls)
    print("Chores: controls Ready.")
    addChoresControls = controls
    modmain()
  end)

  --- mod main function
  -- modmain need after PostConstruct of `widgets/controls` and after ThePlayer PostInit
  function modmain()
    -- ensure ThePlayer and widgets/controls exists
    if GLOBAL.ThePlayer and addChoresControls and chores == nil then
      modimport("scripts/components/ChoresHelpers")
      modimport("scripts/widgets/chores")
      TranslateModInfo()
      chores = addChoresControls:AddChild(Chores())

      -- key handler
      local keyHandler = TheInput:AddKeyHandler(function(key, down)
        -- only handle key up event
        if down or not IsDefaultScreen() then return end
        if key == CONFIG.open_settings then
          -- inject UpdateSettings() to TheFrontEnd.PopScreen once
          local basePopScreen = TheFrontEnd.PopScreen
          TheFrontEnd.PopScreen = function (...) 
            TheFrontEnd.PopScreen = basePopScreen
            UpdateSettings()
            basePopScreen(...)
          end
          TheFrontEnd:PushScreen(ModConfigurationScreen(modname, false))
        elseif key == CONFIG.toggle_chores then
          chores:Toggle()
        end
      end)
    end
  end
end
