local sti = require "sti"
local HC = require "hardoncollider"
local Gamera = require "gamera"
local Player = require "player"
local Enemyfactory = require "enemy"
local Dialogbox = require "dialogbox"
local Collectible = require "collectible"

local STOPDIALOG = false

local Map = Object:extend()

local in_table = function(a,t)
	for i,v in pairs(t) do if a == v then return true end return false end
end

love.graphics.setBackgroundColor(35/255,17/255,43/255)

function Map:new()
	self.music = love.audio.newSource("wav/music.wav", "static")
	self.music:setLooping(true)
	self.loaded = false

	self.camera = Gamera.new(0, 0, 1,1)
	self.camera:setScale(4)

	self.img_win = love.graphics.newImage("img/win.png")
	self.img_win:setFilter("nearest","nearest")
	self.img_lose = love.graphics.newImage("img/lose.png")
	self.img_lose:setFilter("nearest","nearest")
end

function Map:loadLevel(n,player,x,y)
	self.curlevel = n
	if player then
		for i,v in pairs(self.collisions) do
			HC.remove(v)
		end
	end
	self.loaded = true
	self.music:play()
	self.map = sti(n)
	self.collisions = {}
	self.collectibles = {}
	self:loadCollisions()
	if player then
		self.player = player
		self.player:reset(x,y)
	else
		self.player = Player(self.collectibles)
	end
	self.camera:setWorld(0,0,self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight)
	self.enemies = {}
	self:loadEnemies()

	self.dialogboxes = {}

	self.time = 0
	self.endingtime = 0
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
	for i,v in ipairs(self.map.layers) do
		if v.type == "objectgroup" and v.name == "Collisions" then
			for j,k in pairs(v.objects) do
				local x,y = k.rectangle[1].x, k.rectangle[1].y
				local w,h = k.rectangle[3].x-x, k.rectangle[3].y-y
				table.insert(self.collisions, HC.rectangle(x,y,w,h))
				if k.properties.type then
					for p,q in pairs(k.properties) do
						self.collisions[#self.collisions][p] = q
					end
				else
					self.collisions[#self.collisions].type = "map"
				end
			end
		elseif v.type == "objectgroup" and v.name == "Pain-in-the-ass" then
			for j,k in pairs(v.objects) do
				local x,y = k.rectangle[1].x, k.rectangle[1].y
				local w,h = k.rectangle[3].x-x, k.rectangle[3].y-y
				table.insert(self.collisions, HC.rectangle(x,y,w,h))
				self.collisions[#self.collisions].type = "enemy"
			end
		elseif v.type == "objectgroup" and v.name == "Collectibles" then
			for j,k in pairs(v.objects) do
				table.insert(self.collectibles, Collectible(k.name, k.x, k.y))
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
	if self.curlevel == "map/level1.lua" and self.time == 0 then
		table.insert(self.dialogboxes, Dialogbox("Darn, my cat named turtle went missing. You gotta help my find her! Just... don't stop walking...", 20, 120))
	end
	if self.player.warplevel then
		local w = self.player.warplevel
		self:loadLevel("map/".. w.warpto ..".lua",self.player,w.x,w.y)
	end
	if not self.player.gameover and self.player.y > self.map.height*self.map.tileheight+10 then
		self.player:hurt(100)
	end
	if not self.player.triggerending and not self.player.gameover then
		if math.floor(self.time) % 3 == 0 and not STOPDIALOG then
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
		for i,v in lume.ripairs(self.dialogboxes) do
			if not v.done then
				dialogrunning = true
			end
			if v.remove == true then
				table.remove(self.dialogboxes, i)
			else
				v:update(dt)
			end
		end
		if not dialogrunning or true then
			self.player:update(dt)
			self.time = self.time + dt
			for i,v in pairs(self.enemies) do
				v:update(dt)
			end
			for i,v in pairs(self.collectibles) do
				v:update(dt)
			end
			self.map:update(dt)
		end
	end
	if self.player.triggerending then
		for i,v in pairs(self.dialogboxes) do
			v:update(dt)
		end
		local cat = nil
		for i,v in pairs(self.enemies) do
			if v.iscat then
				cat = v
			end
		end
		cat:update(dt)

		self.player.currentAnim = self.player.animations["left"]
		self.player:sparseUpdate(dt)

		if self.endingtime == 0 then
			local catx, caty = 0, 0
			for i,v in pairs(self.enemies) do
				if v.iscat then
					catx, caty = v.x, v.y
					break
				end
			end
			lume.clear(self.dialogboxes)
			local t = "test"
			local numc = 0
			for i,v in pairs(self.player.collectibles) do
				if v.collected then numc = numc + 1 end
			end
			if numc >= 6 then
				t = "Hey, you found all my stuff! Guess I'll come back with you!"
				cat.walkdir = -1
				cat.currentAnimation = cat.animations["walk"]
				cat.currentAnimation:play()
				cat.currentAnimation:setMirror(1)
				self.win = true
				self.endtimer = 0
			else
				t = "Too bad you didn't find all my toys. See ya some other time, maybe you'll manage then..."
				cat.walkdir = 1
				cat.currentAnimation = cat.animations["walk"]
				cat.currentAnimation:play()
				cat.currentAnimation:setMirror(-1)
				self.lose = true
				self.endtimer = 0
			end
			table.insert(self.dialogboxes, Dialogbox(t, catx-100, caty-40))
		end
		self.endtimer = self.endtimer + dt
		self.endingtime = self.endingtime + dt
	end
end

function Map:stencilfun()
	love.graphics.setColor(1,1,1)
	love.graphics.circle("fill", self.player.x, self.player.y, self.time*400)
end

function Map:draw()
	self.camera:draw(function(l,t,w,h,par)
		--self:stencilfun()
		love.graphics.stencil(function() return self:stencilfun() end, "replace", 1)
		love.graphics.setStencilTest("greater", 0)

		if self.win then
			local winw, winh = love.graphics.getDimensions()
			local imgw = self.img_win:getWidth()
			love.graphics.draw(self.img_win, l+winw/8-imgw/2,t+30)
		end
		if self.lose then
			local winw, winh = love.graphics.getDimensions()
			local imgw = self.img_win:getWidth()
			love.graphics.draw(self.img_lose, l+winw/8-imgw/2,t+30)
		end

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
		for i,v in pairs(self.collectibles) do
			v:draw()
		end

		for i,v in pairs(self.map.layers) do
			if v.type == "tilelayer" and v.name:starts("for-") then
				if v.name == "for-secret" then
					love.graphics.stencil(function() self.player:getStencil() end, "replace", 1)
					love.graphics.setStencilTest("less", 1)
					self.map:drawTileLayer(i)
					love.graphics.stencil(function() return self:stencilfun() end, "replace", 1)
					love.graphics.setStencilTest("greater", 0)
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
	if (self.win or self.lose) and self.endtimer > 3 then
		self.win = nil
		self.lose = nil
		love.load()
	end
	if not self.player.triggerending then
		self.player:keypressed(key)
	end
	--if key == "s" then
		--STOPDIALOG = not STOPDIALOG
	--end
end

return Map()
