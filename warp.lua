local Warp = Object:extend()

function Warp:new(to, tox, toy,x,y,w,h)
	self.bbox = HC.rectangle(x,y,w,h)
	self.bbox.type = "warp"
	self.bbox.to = to
	self.bbox.tox = tox
	self.bbox.toy = toy
end
