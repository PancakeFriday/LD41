local sti = require "sti"
local HC = require "hardoncollider"
local Gamera = require "gamera"
local Player = require "player"
local Enemyfactory = require "enemy"
local Dialogbox = require "dialogbox"

local STOPDIALOG = false

local Map = Object:extend()

local in_table = function(a,t)
	for i,v in pairs(t) do if a == v then return true end return false end
end

function Map:new()
	self.music = love.audio.newSource("wav/music.wav", "static")
	self.music:play()
	self.map = sti("map/level1.lua")
	self.player = Player
	self.collisions = {}
	self:loadCollisions()
	self.enemies = {}
	self:loadEnemies()
	self.camera = Gamera.new(0, 0, self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight)
	self.camera:setScale(4)

	self.dialogboxes = {}

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
	for i,v in ipairs(self.map.layers) do
		if v.type == "objectgroup" and v.name == "Enemies" then
			for j,k in pairs(v.objects) do
				local e = Enemyfactory:get(k.name,self.player,k.x,k.y)
				if e then
					table.insert(self.enemies, e)
				end
			end
		end
	end
end

function Map:loadCollisions()
	for i,v in pairs(self.map.layers) do
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
	return self.player.x-(w/2*Dialogbox.scale), self.player.y-h*Dialogbox.scale-16
end

function Map:getRandomText()
	self.randomtextit = (self.randomtextit)%(#self.randomtext)+1
	return self.randomtext[self.randomtextit]
end

function Map:update(dt)
	if math.floor(self.time) % 2 == 0 and not STOPDIALOG then
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
	if not dialogrunning or true then
		self.player:update(dt)
		if self.player.wasMoving then
			self.time = self.time + dt
		end
		for i,v in pairs(self.enemies) do
			v:update(dt)
		end
		self.map:update(dt)
	end
end

function Map:draw()
	self.camera:draw(function(l,t,w,h,par)
		for i,v in pairs(self.map.layers) do
			if v.type == "tilelayer" and v.name:starts("par-") then
				local num = tonumber(v.name:sub(5,5))
				love.graphics.push()
				love.graphics.translate(l/(num+1.5),0)
				self.map:drawTileLayer(i)
				love.graphics.pop()
			end
		end

		for i,v in pairs(self.dialogboxes) do
			v:draw()
		end

		for i,v in pairs(self.map.layers) do
			if v.type == "tilelayer" and v.name:starts("bac-") then
				self.map:drawTileLayer(i)
			end
		end

		self.player:draw(l,t,w,h)

		for i,v in pairs(self.enemies) do
			v:draw()
		end

		for i,v in pairs(self.map.layers) do
			if v.type == "tilelayer" and v.name:starts("for-") then
				if v.name == "for-secret" then
					love.graphics.stencil(function() self.player:getStencil() end, "replace", 1)
					love.graphics.setStencilTest("less", 1)
					self.map:drawTileLayer(i)
					love.graphics.setStencilTest()
				else
					self.map:drawTileLayer(i)
				end
			end
		end

		if STOPDIALOG then
			love.graphics.setColor(1,0.5,0.2)
			love.graphics.printUnscaled("No dialogs will spawn!",l,t)
			love.graphics.setColor(1,1,1)
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
	if key == "s" then
		STOPDIALOG = not STOPDIALOG
	end
end

return Map()
