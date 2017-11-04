-- global variable
chores = nil

-- local variable
local addChoresControls = nil

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

-- mod main function
function modmain()
  -- ensure ThePlayer and widgets/controls exists
  if GLOBAL.ThePlayer and addChoresControls and chores == nil then
    modimport("scripts/components/ChoresHelpers")
    modimport("scripts/widgets/chores")
    chores = addChoresControls:AddChild(Chores())
    modimport("scripts/widgets/optionscreen")

    -- key handler
    local keyHandler = TheInput:AddKeyHandler(function(key, down)
      -- only handle key up event
      if down or not IsDefaultScreen() then return end
      if key == CONFIG.togglekey then
        if TheInput:IsKeyDown(KEY_ALT) then TheFrontEnd:PushScreen(OptionScreen(addChoresControls)) else chores:Toggle() end
      end
    end)
  end
end
