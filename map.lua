local sti = require "sti"
local HC = require "hardoncollider"
local Gamera = require "gamera"
local Player = require "player"
local Dialogbox = require "dialogbox"

local Map = Object:extend()

function Map:new()
	self.map = sti("map/level1.lua")
	self.player = Player
	self.collisions = {}
	self:loadCollisions()
	self.camera = Gamera.new(0, 0, self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight)
	self.camera:setScale(4)

	self.dialogboxes = {}
	table.insert(self.dialogboxes, Dialogbox("Some rubbish, I don't really know what I'm talking about. THIS IS MADNESS! Hallelujah baby girl, every damn time! AND MORE TEXT, who had thought that! But really, isn't this too much? I don't know...",100,70))

	--table.insert(self.dialogboxes, Dialogbox("TEXT",0,100))
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
	local dialogrunning = false
	self.camera:setPosition(self.player:getPosition())
	for i,v in pairs(self.dialogboxes) do
		if not v.done then
			dialogrunning = true
		end
		v:update(dt)
	end
	self.player:update(dt)
	self.map:update(dt)
end

function Map:draw()
	self.camera:draw(function(l,t,w,h)
		for i,v in pairs(self.dialogboxes) do
			v:draw()
		end

		self.player:draw()

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
	end)
end

function Map:keypressed(key)
	self.player:keypressed(key)
end

return Map()
