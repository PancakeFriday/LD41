local sti = require "sti"

local Map = Object:extend()

function Map:new()
	self.map = sti("map/level1.lua")
end

function Map:update(dt)
	self.map:update(dt)
end

function Map:draw()
	self.map:draw()
end

return Map()
