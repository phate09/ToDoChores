
local CountDown = Class( function(self, initcount, fn)

	self.initcount = initcount
	self.start = false
	self.count = initcount
	self.fn = fn
	end)

function CountDown:ReStart()
	if self.start then 
		self.count = self.initcount + 1
	else 

		self.start = true
		self.count = self.initcount
		self.fn(self)
		EntityScript.DoTaskInTime(self, 1, function() self:Down() end )
	end 
end
function CountDown:Down()
	if self.start == false then return end 
	self.count = self.count - 1

	self.fn(self)
	if self.count > 0 then 
		EntityScript.DoTaskInTime(self, 1, function() self:Down() end )
	else 
		self.start = false
	end
end  

function CountDown:Turnoff()
	self.count = self.initcount 
	self.start = false
end


CountDown.TEST = "CHORES"
return CountDown