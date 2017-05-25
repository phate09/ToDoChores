name = "To Do Chores [Forked]"
description = "Automate gathering, chopping, digging and planting!"
author = "phate09"
version = "1.0.1"

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

local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
local keyslist = {} 
local Default_Key =  "V" 
for i = 1,#alpha do 
  keyslist[i] = {description = alpha[i],data = i + KEY_A - 1}
  if alpha[i] == Default_Key then
    Default_Key = keyslist[i].data
  end
end

local Default_planting_x = 4
local Default_planting_y = 5
local x_list = {}
local y_list = {}
for i = 1,9 do 
  x_list[i] = {description = i,data = i}
  y_list[i] = {description = i,data = i}
  if i == Default_planting_x then
    Default_planting_x = x_list[i].data
  end
  if i == Default_planting_y then
    Default_planting_y = y_list[i].data
  end
end

configuration_options =
{
  {
    name = "togglekey",
    label = "Open Chores Wheel",
    options = keyslist,
    default = Default_Key

  }, 
  {
    name = "planting_x",
    label = "How big is the planting square horizontally",
    options = x_list,
    default = Default_planting_x

  },
  {
    name = "planting_y",
    label = "How big is the planting square vertically",
    options = y_list,
    default = Default_planting_y

  } 
}

