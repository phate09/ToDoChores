--- To Do Chores Modinfo Traditional Chinese Version
-- @module modinfoCht

name = "家務小助手"
author = "phate09, taichunmin"
version = "2.2.0"
description = "版本: "..version.."\n\n自動採集、砍樹、挖掘、種樹、施肥、放陷阱、曬肉乾！\n\n[預設使用方法]\n* 預設使用 V 來開啟工作面板\n* 預設使用 O 來開啟遊戲內設定\n\n如果模組有任何 bug 請回報到：https://github.com/phate09/ToDoChores"

api_version = 10

dont_starve_compatible = false
reign_of_giants_compatible = true
dst_compatible = true

all_clients_require_mod = false
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
  numeric_list[i] = {description = i, data = i}
end

configuration_options =
{
  {
    name = "toggle_chores",
    label = "開關工作面板",
    hover = "想要使用什麼按鍵來開關家務小助手的工作面板？",
    options = keyslist,
    default = "V",
  },
  {
    name = "open_settings",
    label = "遊戲內打開設定",
    hover = "想要在遊戲內使用什麼按鍵來開關家務小助手的設定面板？",
    options = keyslist,
    default = "O",
  },
  {
    name = "use_gold_tools",
    label = "製作黃金工具",
    hover = "是否自動嘗試製作黃金工具？",
    options={
      {description="否", data=false},
      {description="是", data=true}
    },
    default=false,
  },
  {
    name = "cut_adult_tree_only",
    label = "只砍大樹",
    hover = "是否只自動砍大樹來最大化種子的掉落？",
    options={
      {description="否", data=false},
      {description="是", data=true}
    },
    default=true,
  },
  {
    name = "planting_x",
    label = "X 軸種植數量",
    hover = "在 X 軸方向自動種植的數量？",
    options = numeric_list,
    default = 5
  },
  {
    name = "planting_y",
    label = "Y 軸種植數量",
    hover = "在 Y 軸方向自動種植的數量？",
    options = numeric_list,
    default = 4
  },
  {
    name = "planting_margin",
    label = "額外種植間距",
    hover = "在種植種子或樹苗時需要多少額外的間距呢？",
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
    label = "開始結束提示",
    hover = "您希望模組提示您任務的開始和結束嗎？",
    options={
      {description="否", data=false},
      {description="是", data=true}
    },
    default=true,
  }
}
