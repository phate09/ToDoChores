all = true
backtick_references = true
custom_tags = {{'helper', hidden = true}}
description = "這是一個 Don't Starve Together 的 To Do Chores 模組說明文件"
dir = "public"
ext = "html"
file = "."
format = "discount"
package = "."
prettify_files = "show"
project = "ToDoChores"
sort = true
title = "To Do Chores 文件"

-- show a label beside functions tagged with @callback.
custom_display_name_handler = function(item, default_handler)
  if item.type == 'function' and item.tags.helper then
    return item.name .. ' [helper]'
  end
  return default_handler(item)
end
