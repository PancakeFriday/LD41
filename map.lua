local sti = require "sti"
local HC = require "hardoncollider"

local Map = Object:extend()

function Map:new()
	self.map = sti("map/level1.lua")
	self.collisions = {}
	self:loadCollisions()
end

function Map:loadCollisions()
	for i,v in pairs(self.map.layers) do
		if v.type == "objectgroup" then
			for j,k in pairs(v.objects) do
				local x,y = k.rectangle[1].x, k.rectangle[1].y
				local w,h = k.rectangle[3].x-x, k.rectangle[3].y-y
				table.insert(self.collisions, HC.rectangle(x,y,w,h))
			end
		end
	end
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

	if DEBUG then
		love.graphics.setColor(1,0,0)
		for i,v in pairs(self.collisions) do
			v:draw()
		end
		love.graphics.setColor(1,1,1)
	end
end

return Map()
