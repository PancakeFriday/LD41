local sti = require "sti"

local Map = Object:extend()

function Map:new()
	self.map = sti("map/level1.lua")
end

function Map:update(dt)
	self.map:update(dt)
end

function Map:draw()
	for i,v in pairs(self.map.layers) do
		if v.type == "tilelayer" then
			self.map:drawTileLayer(i)
		end
	end
end

return Map()
