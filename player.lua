local HC = require "hardoncollider"

local Health = Object:extend()

function Health:new(num)
	self.img = love.graphics.newImage("img/hearts.png")
	self.img:setFilter("nearest","nearest")
	self.num_hearts = num
	self.health = num
	self.quads = {}
	local w,h = self.img:getDimensions()
	for i=0,2 do
		table.insert(self.quads, love.graphics.newQuad(i*w/3,0,w/3,h,w,h))
	end
end

function Health:draw(l,t,w,h)
	love.graphics.push()
	love.graphics.translate(l,t)
	for i=1,self.num_hearts do
		local q
		if self.health-i >= 0 then
			q = 1
		elseif self.health-i >= -0.5 then
			q = 2
		else
			q = 3
		end
		love.graphics.draw(self.img, self.quads[q], (i-1)*13+2, 2)
	end
	love.graphics.pop()
end

function Health:subtract(x)
	self.health = math.max(0, self.health-x)
end

local Player = Object:extend()

function Player:new()
	self.x = 50
	self.y = 170
	self.floaty = 0

	self.w = 16
	self.h = 16
	self.animations = {
		left = Animation("img/guy.png", 16, 16, 0, 2, 0.3),
		jumpduring = Animation("img/guy.png", 16, 16, 1, 4, 0.2)
	}

	self.animations["jumpduring"]:setDone(function()
		if not self.falling and not self.jumping then
			self.currentAnim = self.animations["left"]
		end
	end)

	self.currentAnim = self.animations["left"]
	self.currentAnim:play()

	self.speedx = 100
	self.speedy = 50
	self.accely = 200

	self.bbox = HC.rectangle(3,3,10,13)
	self.bbox:moveTo(self.x, self.y+1)
	self.bbox.type = "player"

	self.jumping = false
	self.falling = false

	self.time = 0

	self.health = Health(3)
	self.hurtTime = -100
end

function Player:getPosition()
	return self.x, self.y
end

function Player:move(mx,my)
	self.bbox:move(0,my)
	for i,v in pairs(HC.collisions(self.bbox)) do
		if i.type == "map" then
			self.bbox:move(0,-my)
			my = 0
			break
		end
	end
	self.falling, self.jumping = false,false
	self.y = self.y + my
	if my > 0 then
		self.falling = true
	elseif my < 0 then
		self.jumping = true
	else
		self.speedy = 0
	end

	self.bbox:move(mx,0)
	for i,v in pairs(HC.collisions(self.bbox)) do
		if i.type == "map" then
			self.bbox:move(-mx,0)
			mx = 0
			break
		end
	end
	self.x = self.x + mx

	if mx ~= 0 then
		self.currentAnim:play()
	elseif not self.jumping and not self.falling then
		self.currentAnim:stop()
		self.currentAnim:reset()
	end

	if mx ~= 0 or my ~= 0 then
		self.wasMoving = true
	else
		self.wasMoving = false
	end
end

function Player:hurt(x)
	self.health:subtract(x)
	self.hurtTime = self.time
end

function Player:update(dt)
	self.time = self.time + dt

	local mx, my = 0, 0
	if love.keyboard.isDown("right") then
		mx = mx + self.speedx*dt
	elseif love.keyboard.isDown("left") then
		mx = mx - self.speedx*dt
	end

	self.speedy = self.speedy + self.accely * dt
	my = my + self.speedy * dt

	if not self.jumping and not self.falling then
		if mx < 0 then
			self.currentAnim:setMirror(-1)
		elseif mx > 0 then
			self.currentAnim:setMirror(1)
		end
	end

	self.floaty = (math.sin(self.time*4)-1.8)*1

	self:move(mx,my)
	self.currentAnim:update(dt)
end

function Player:draw(l,t,w,h)
	love.graphics.push()
	love.graphics.translate(self.x,self.y+self.floaty)
	self.currentAnim:draw()
	love.graphics.pop()

	self.health:draw(l,t,w,h)

	if DEBUG then
		love.graphics.setColor(1,0,0)
		self.bbox:draw()
		love.graphics.setColor(1,1,1)
	end

	local alpha = (1-(self.time - self.hurtTime)/1)/4
	love.graphics.setColor(1,0.1,0.1,alpha)
	love.graphics.rectangle("fill",l,t,w,h)
	love.graphics.setColor(1,1,1)
end

function Player:keypressed(key)
	if (key == "space" or key == "up") and not self.falling and not self.jumping then
		self.speedy = -140
		self.currentAnim = self.animations["jumpduring"]
		self.currentAnim:reset()
		self.currentAnim:play()
	end
	if key == "k" then
		self.health:subtract(0.5)
	end
end

return Player()
