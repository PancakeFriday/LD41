local Player = Object:extend()
local HC = require "hardoncollider"

function Player:new()
	self.x = 0
	self.y = 0
	self.floaty = 0

	self.w = 16
	self.h = 16
	self.animations = {
		left = Animation("img/guy.png", 16, 16, 0, 4, 0.3)
	}
	self.currentAnim = self.animations["left"]
	self.currentAnim:play()

	self.speedx = 100
	self.speedy = 0
	self.accely = 200

	self.bbox = HC.rectangle(3,3,10,13)
	self.bbox:moveTo(self.x, self.y+1)

	self.jumping = false
	self.falling = false

	self.time = 0
end

function Player:move(mx,my)
	self.bbox:move(0,my)
	for i,v in pairs(HC.collisions(self.bbox)) do
		self.bbox:move(0,-my)
		my = 0
		break
	end
	self.y = self.y + my
	if my > 0 then
		self.falling = true
	end

	self.bbox:move(mx,0)
	for i,v in pairs(HC.collisions(self.bbox)) do
		self.bbox:move(-mx,0)
		mx = 0
		break
	end
	self.x = self.x + mx
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

	if mx < 0 then
		self.currentAnim:setMirror(-1)
	elseif mx > 0 then
		self.currentAnim:setMirror(1)
	end

	self.floaty = (math.sin(self.time*4)-1)*1

	self:move(mx,my)
	self.currentAnim:update(dt)
end

function Player:draw()
	love.graphics.push()
	love.graphics.translate(self.x,self.y+self.floaty)
	self.currentAnim:draw()
	love.graphics.pop()

	if DEBUG then
		love.graphics.setColor(1,0,0)
		self.bbox:draw()
		love.graphics.setColor(1,1,1)
	end
end

function Player:keypressed(key)
	if key == "space" then
		print("ay")
	end
end

return Player()
