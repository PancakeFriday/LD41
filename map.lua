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
	self:loadEnemies()
	self.camera = Gamera.new(0, 0, self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight)
	self.camera:setScale(4)

	self.dialogboxes = {}
	self.enemies = {}

	self.time = 0
	self.insertDialog = false

	self.randomtext = lume.split(love.filesystem.read("text/garbage"), "\n")
	for i,v in lume.ripairs(self.randomtext) do
		if v == "" then
			table.remove(self.randomtext, i)
		end
	end
	self.randomtext = lume.shuffle(self.randomtext)
	self.randomtextit = 1
end

function Map:loadEnemies()
	for i,v in pairs(self.map.layers) do
		if v.type == "objectgroup" and v.name == "Enemies" then
			for j,k in pairs(v.objects) do
			end
		end
	end
end

function Map:loadCollisions()
	for i,v in pairs(self.map.layers) do
		print(v.name)
		if v.type == "objectgroup" and v.name == "Collisions" then
			for j,k in pairs(v.objects) do
				local x,y = k.rectangle[1].x, k.rectangle[1].y
				local w,h = k.rectangle[3].x-x, k.rectangle[3].y-y
				table.insert(self.collisions, HC.rectangle(x,y,w,h))
				self.collisions[#self.collisions].type = "map"
			end
		end
	end
end

function Map:findDialogPosition(text)
	local w,h = Dialogbox.getDimensions(text)
	return self.player.x-w/2, self.player.y-h-16
end

function Map:getRandomText()
	self.randomtextit = self.randomtextit + 1
	return self.randomtext[self.randomtextit-1]
end

function Map:update(dt)
	if math.floor(self.time) % 2 == 0 then
		if self.insertDialog then
			local t = self:getRandomText()
			local x,y = self:findDialogPosition(t)
			table.insert(self.dialogboxes, Dialogbox(t, x,y))
			self.insertDialog = false
		end
	else
		self.insertDialog = true
	end

	local dialogrunning = false
	self.camera:setPosition(self.player:getPosition())
	for i,v in pairs(self.dialogboxes) do
		if not v.done then
			dialogrunning = true
		end
		v:update(dt)
	end
	if not dialogrunning then

		self.player:update(dt)
		if self.player.wasMoving then
			self.time = self.time + dt
		end
		self.map:update(dt)
	end
end

function Map:draw()
	self.camera:draw(function(l,t,w,h)
		for i,v in pairs(self.dialogboxes) do
			v:draw()
		end

		for i,v in pairs(self.map.layers) do
			if v.type == "tilelayer" and not v.name:starts("for-") then
				self.map:drawTileLayer(i)
			end
		end

		self.player:draw()

		for i,v in pairs(self.map.layers) do
			if v.type == "tilelayer" and v.name:starts("for-") then
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
