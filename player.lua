local Player = Object:extend()

function Player:new()
	self.x = 0
	self.y = 0

	self.w = 16
	self.h = 16
	self.animations = {
		left = Animation("img/guy.png", 16, 16, 0, 4, 0.3)
	}
	self.currentAnim = self.animations["left"]

	self.speedx = 100
	self.speedy = 10
end

function Player:move(mx,my)
	self.x = self.x + mx
	self.y = self.y + my
end

function Player:update(dt)
	local mx, my = 0, 0
	if love.keyboard.isDown("right") then
		mx = mx + self.speedx*dt
	elseif love.keyboard.isDown("left") then
		mx = mx - self.speedx*dt
	end

	self:move(mx,my)
	self.currentAnim:update(dt)
end

function Player:draw()
	love.graphics.push()
	love.graphics.translate(self.x,self.y)
	self.currentAnim:draw()
	love.graphics.pop()
end

return Player()
