--- To Do Chores Modinfo
-- @module modinfo

name = "To Do Chores"
author = "phate09, taichunmin"
version = "2.2.1b2"
description = "version: "..version.."\n\nAutomate gathering, chopping, digging, planting, fertilizing, traping and drying!\n\n[Usage]\n* Press key V to toggle chores wheel (default)\n* Press O to open in-game settings (default)\n\nPlease report bug at: https://github.com/phate09/ToDoChores"

api_version = 10
priority = -10000

dont_starve_compatible = false
reign_of_giants_compatible = true
dst_compatible = true

all_clients_require_mod = false
client_only_mod = true

server_filter_tags = {"chores", "AI", "auto", "chop", "pickup", "plant", "mine", "fertilize", "dig", "dry", "trap"}

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

configuration_options =
{
  {
    name = "toggle_chores",
    label = "Toggle Chores Wheel",
    hover = "Which button do you want to toggle the working menu?",
    options = keyslist,
    default = "V",
  },
  {
    name = "open_settings",
    label = "Open In Game Settings",
    hover = "Which button do you want to open the settings of this mod in game?",
    options = keyslist,
    default = "O",
  },
  {
    name = "use_gold_tools",
    label = "Craft gold tools",
    hover = "Do you want to make gold tools when crafting?",
    options={
      {description="No", data=false},
      {description="Yes", data=true}
    },
    default=false,
  },
  {
    name = "cut_adult_tree_only",
    label = "Only cut adult trees",
    hover = "Do you want to only cut adult trees?",
    options={
      {description="No", data=false},
      {description="Yes", data=true}
    },
    default=true,
  },
  {
    name = "planting_x",
    label = "X-axis plant size",
    hover = "How big is the planting square on X axis?",
    options = numeric_list,
    default = 5
  },
  {
    name = "planting_y",
    label = "Y-axis plant size",
    hover = "How big is the planting square on Y axis?",
    options = numeric_list,
    default = 4
  },
  {
    name = "planting_margin",
    label = "Plantable extra margin",
    hover = "How many extra margin of planting plantable?",
    options = {
      {description = "0.1", data = 0.1},
      {description = "0.25", data = 0.25},
      {description = "0.5", data = 0.5},
      {description = "0.75", data = 0.75},
      {description = "1", data = 1},
      {description = "1.5", data = 1.5},
      {description = "2", data = 2},
    },
    default = 0.25
  },
  {
    name = "hint_start_stop",
    label = "Start and stop hint",
    hover = "Do you want mod to hint task start and stop?",
    options={
      {description="No", data=false},
      {description="Yes", data=true}
    },
    default=true,
  }
}
