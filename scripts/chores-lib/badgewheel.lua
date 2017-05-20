local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"

local ATLAS = "images/avatars.xml"
local ATLASINV = "images/inventoryimages.xml"

local SMALLSCALE = 1.0
local LARGESCALE = 1.5
local BROWN = {80/255, 60/255, 30/255, 1}

Assets = {
  Asset("ATLAS", "images/avatars.xml"),
  Asset("IMAGE", "images/avatars.tex"),
}


local BadgeButton = Class(Button, function(self)
  Button._ctor(self)
  -- self:SetClickable(false) 

  -- self.root = self:AddChild(ImageButton(ATLAS, "avatar_bg.tex"))
  

  self.bg = self:AddChild(Image(ATLAS, "avatar_bg.tex"))  
  self.frame = self:AddChild(Image(ATLAS, "avatar_frame_white.tex"))  

  self.text = self.frame:AddChild( Text(BODYTEXTFONT, 24, "" ))
  -- self.text:SetColour(1,1,1,1)
  self.text:SetPosition(3, -20)
  self.text:Hide()
  self.scale_on_focus = true

  end)


function BadgeButton:InvIcon( name )
  local img = self.bg:AddChild(Image(ATLASINV, name .. ".tex"))    
  table.insert(self, img)
  return img
end
function BadgeButton:Icon( atlas, name)
  local img = self.bg:AddChild(Image(atlas, name))  
  table.insert(self, img)
  return img  
end
function BadgeButton:Text( text )
  if text then
    self.text:SetString(text)
    self.text:Show()
  else
    self.text:Hide()
  end
  return self.text
end

function BadgeButton:SetOnFocus( fn )
  self.onfocus = fn
end

function BadgeButton:OnGainFocus()
  Button._base.OnGainFocus(self)

  if self.image_focus == self.image_normal then
    if self.scale_on_focus then
      self:SetScale(1.1,1.1,1.1)
    end
  end
  if self.onfocus then
    self.onfocus(true)
  end
end

function BadgeButton:OnLoseFocus()
  Button._base.OnLoseFocus(self)
  if self.image_focus == self.image_normal then
    if self.scale_on_focus then
      self:SetScale(1,1,1)
    end
  end
  if self.onfocus then
    self.onfocus(false)
  end
end


local MAX_HUD_SCALE = 1.25
local BadgeWheel = Class(Widget, function(self)
  Widget._ctor(self, "BadgeWheel") 

  self:SetHAnchor(ANCHOR_MIDDLE)
  self:SetVAnchor(ANCHOR_MIDDLE)
  self:SetScaleMode(SCALEMODE_PROPORTIONAL) 
  self:SetMaxPropUpscale(MAX_HUD_SCALE)
  self.root = self:AddChild(Widget("root"))


  self.badge = {} 

  end)

function BadgeWheel:CreateBadges(count) 
  -- local dist = (65*count)/(math.pi)
  -- local delta = 2*math.pi/count
  local dist = ( 100 * count)/(math.pi)
  local delta = math.pi / (count)
  local theta = math.pi * 1.5 - (delta * count / 2 ) + delta / 2
  for inx = 1, count, 1 do 
    self.badge[inx] = self.root:AddChild(BadgeButton()) 
    self[inx] = self.badge[inx]
    self.badge[inx]:SetPosition(dist*math.cos(theta),dist*math.sin(theta), 0)
    theta = theta + delta
  end
end
function BadgeWheel:GetBadge(inx)
  return self.badge[inx]
end



function BadgeWheel:OnUpdate(dt) 
  print("onUpdate", dt)
end


return BadgeWheel