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

function Player:new(collectibles)
	self.collectibles = collectibles

	self.audio_hurt = love.audio.newSource("wav/hurt.wav", "static")
	self.audio_hurt:setVolume(0.3)

	self.audio_pickup = love.audio.newSource("wav/pickup.wav", "static")
	self.audio_pickup:setVolume(0.3)

	self.audio_explode = love.audio.newSource("wav/explode.wav", "static")
	self.audio_explode:setVolume(0.3)

	self.audio_dash = love.audio.newSource("wav/dash.wav", "static")
	self.audio_dash:setVolume(0.3)

	self.falltime = 0

	self.x = 5831--20
	self.y = 160--140
	self.floaty = 0

	self.w = 16
	self.h = 16
	self.animations = {
		left = Animation("img/guy.png", 16, 16, 0, 2, 0.3),
		jumpduring = Animation("img/guy.png", 16, 16, 1, 4, 0.2),
		dead = Animation("img/guy.png",16,16,2,2,0.3),
		dash = Animation("img/guy.png",16,16,3,4,0.3)
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
	self.accely = 400

	self.momentumx = 0

	self.bbox = HC.rectangle(3,3,10,13)
	self.bbox:moveTo(self.x, self.y+1)
	self.bbox.type = "player"

	self.jumpheight = 0
	self.jumping = false
	self.falling = false
	self.dashing = false

	self.time = 0

	self.health = Health(3)
	self.hurtTime = -100

	self.gameover_img = love.graphics.newImage("img/gameover.png")
	self.gameover_img:setFilter("nearest","nearest")
	self.gameover = false
end

function Player:reset(x,y)
	self.x = x
	self.y = y
	self.bbox:moveTo(x,y)
	self.health = Health(3)
	self.warplevel = nil
end

function Player:getStencil()
	love.graphics.setColor(1,1,1)
	love.graphics.circle("fill",self.x,self.y,16)
end

function Player:getPosition()
	return self.x, self.y
end

function Player:move(mx,my,dt)
	self.bbox:move(mx,my)
	self.bbox:move(-mx,-my)
	for i,v in pairs(HC.collisions(self.bbox)) do
		if i.type == "collectible" and not i.object.collected then
			i.object.collected = true
			self.audio_pickup:play()
		elseif i.type == "ending" then
			self.triggerending = true
		elseif i.type == "warp" then
			self.warplevel = i
		end
	end

	print("---")
	self.bbox:move(0,my)
	for i,v in pairs(HC.collisions(self.bbox)) do
		if i.type == "map" or (i.type == "dialogbox" and my > 0 and i.damaged ~= true) then
			print("yes")
			self.bbox:move(0,-my)
			my = 0
			break
		elseif i.type == "dialogbox" and self.jumping then
			i.damaged = true
			self.audio_explode:play()
		elseif i.type == "enemy" then
			self.bbox:move(0,-my)
			my = -lume.sign(my)*100*dt
			self.bbox:move(0,my)
			self.speedy = my/dt
			self:hurt(0.5)
		end
	end
	local newfalling, newjumping = false, false
	self.y = self.y + my
	if my > 0 then
		newfalling = true
	elseif my < 0 and not newfalling then
		newjumping = true
	else
		self.speedy = 0
	end
	if newfalling ~= self.falling and newfalling == true then
		self.falltime = 0
	end
	if newfalling == true and newjumping == false and self.jumping == true then
		self.falltime = 100
	end
	self.falling, self.jumping = newfalling, newjumping

	self.bbox:move(mx,0)
	for i,v in pairs(HC.collisions(self.bbox)) do
		if i.type == "map" or (i.type == "dialogbox" and i.damaged ~= true and not self.dashing) then
			self.bbox:move(-mx,0)
			mx = 0
			break
		elseif i.type == "dialogbox" and self.dashing then
			i.damaged = true
			self.audio_explode:play()
		elseif i.type == "enemy" then
			self.bbox:move(-mx,0)
			mx = -lume.sign(mx)*400*dt
			self.bbox:move(mx,0)
			self.momentumx = mx/dt
			if self.dashing then
				if i.object then
					i.object:hurt(0.5)
				end
			else
				self:hurt(0.5)
			end
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
	if self.time - self.hurtTime > 0.8 then
		self.health:subtract(x)
		self.hurtTime = self.time
		self.audio_hurt:play()
	end
	if self.health.health <= 0 then
		self.gameover = true
		self.hurtTime = -100
		self.currentAnim = self.animations["dead"]
		self.currentAnim:reset()
		self.currentAnim:play()
	end
end

function Player:sparseUpdate(dt)
	self.time = self.time + dt*3
	local mx, my = 0, 0

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

	my = math.min(my,3)

	self:move(mx+self.momentumx*dt,my,dt)
	self.currentAnim:update(dt)
end

function Player:update(dt)
	if not self.gameover then
		self.time = self.time + dt*3
		if self.falling then
			self.falltime = self.falltime + dt
		end

		if self.dashing and math.abs(self.momentumx) < 10 then
			self.dashing = false
			self.currentAnim = self.animations["left"]
		end

		if self.momentumx > 0 then
			self.momentumx = math.max(self.momentumx - dt*700)
		else
			self.momentumx = math.min(0,self.momentumx + dt*700)
		end

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

		my = math.min(my,3)

		self:move(mx+self.momentumx*dt,my,dt)
		self.currentAnim:update(dt)
	end
end

function Player:draw(l,t,w,h)
	love.graphics.push()
	love.graphics.translate(self.x,self.y+self.floaty)
	self.currentAnim:draw()
	love.graphics.pop()

	self.health:draw(l,t,w,h)
	local winw, winh = love.graphics.getDimensions()
	for i,v in pairs(self.collectibles) do
		v:draw_ui(winw/4+l-(i-1)*16,t,w,h)
	end

	if DEBUG then
		love.graphics.setColor(1,0,0)
		self.bbox:draw()
		love.graphics.setColor(1,1,1)
	end

	local alpha = (1-(self.time - self.hurtTime)/1)/4
	love.graphics.setColor(1,0.1,0.1,alpha)
	love.graphics.rectangle("fill",l,t,w,h)
	love.graphics.setColor(1,1,1)

	if self.gameover then
		local winw, winh = love.graphics.getDimensions()
		local imgw, imgh = self.gameover_img:getWidth(), self.gameover_img:getHeight()
		love.graphics.draw(self.gameover_img, l+winw/8-imgw/2, t+winh/8 - 50)
	end
end

function Player:keypressed(key)
	if self.gameover then
		love.load()
	end

	if (key == "c" or key == "up") and (not self.falling or self.falltime < 0.08) and not self.jumping then
		self.speedy = -230
		self.currentAnim = self.animations["jumpduring"]
		self.currentAnim:reset()
		self.currentAnim:play()
		self.jumpheight = 0
	end
	if key == "x" then
		local dir = self.currentAnim.mirror
		if love.keyboard.isDown("left") then dir = -1
		elseif love.keyboard.isDown("right") then dir = 1 end
		if math.abs(self.momentumx) < 10 then
			self.currentAnim = self.animations["dash"]
			self.currentAnim:setMirror(dir)
			self.audio_dash:play()
			self.dashing = true
			self.momentumx = dir * 400
		end
	end
	if key == "k" then
		self.health:subtract(0.5)
	end
end

return Player
