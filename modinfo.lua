name = "To Do Chores [Forked]"
description = "Automate gathering, chopping, digging and planting!\n v1.2"
author = "phate09"
version = "1.2"

forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Can specify a custom icon for this mod!
-- icon_atlas = "ExtendedIndicators.xml"
-- icon = "ExtendedIndicators.tex"

-- Specify compatibility with the game!
dont_starve_compatible = false
reign_of_giants_compatible = true
dst_compatible = true

all_clients_require_mod = false
--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = true

server_filter_tags = {"chores", "geometry", "mine", "wood","chop", "AI", "auto"}


icon_atlas = "modicon.xml"
icon = "to-do-chores.tex"

local KEY_A = 65
local keyslist = {}
local string = ""
for i = 1, 26 do
	local ch = string.char(KEY_A + i - 1)
	keyslist[i] = {description = ch, data = ch}
end

local numeric_list={}
for i = 1,9 do
	numeric_list[i] = {description = i,data = i}
end
local Default_planting_x = 4
local Default_planting_y = 5

configuration_options =
{
  {
    name = "togglekey",
    label = "Open Chores Wheel",
    longlabel="Which button should open the in-game settings menu?",
    options = keyslist,
    default = "V",
    hover="Changing this from in-game won't work. Sorry.",
  }, 
  {
    name = "use_gold_tools",
    label = "Use gold tools",
    longlabel="When crafting new tools prefer tools made of gold",
    options={
      {description="No", data=0},
      {description="Yes", data=1}
    },
   default=0,
--   hover="It will only work if you are the host of the server",
  },
  {
    name = "cut_adult_tree_only",
    label = "Cut only adult trees",
    longlabel="Cut only adult trees to maximise cones yeld",
    options={
			{description="No", data=0},
			{description="Yes", data=1}
		},
	 default=0,
--   hover="It will only work if you are the host of the server",
  }, 
  {
    name = "planting_x",
    label = "How big is the planting square horizontally",
    options = numeric_list,
    default = 4

  },
  {
    name = "planting_y",
    label = "How big is the planting square vertically",
    options = numeric_list,
    default = 5

  } 
}

