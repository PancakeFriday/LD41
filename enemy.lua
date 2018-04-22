local HC = require "hardoncollider"

local Projectile = Object:extend()

function Projectile:new(img, start, dir, vel, done)
	self.img = love.graphics.newImage(img)
	self.pos = start
	self.dir = dir
	self.vel = vel
	self.done = done

	local r = self.img:getWidth()/2
	self.bbox = HC.circle(self.pos.x+r, self.pos.y+r, r)
	self.bbox.type = "projectile"
end

function Projectile:update(dt)
	local mby = self.dir*self.vel*dt
	self.pos = self.pos + mby
	self.bbox:move(mby.x, mby.y)
	for i,v in pairs(HC.collisions(self.bbox)) do
		if i.type == "player" then

			self.done(self)
		elseif i.type == "map" then

			self.done(self)
		end
	end
end

function Projectile:draw()
	love.graphics.draw(self.img, self.pos.x, self.pos.y, angle)

	if DEBUG then
		love.graphics.setColor(1,0,0)
		self.bbox:draw()
		love.graphics.setColor(1,1,1)
	end
end

local Dragon = Object:extend()

function Dragon:new(player,x,y)
	self.player = player
	self.x = x
	self.y = y
	self.time = 0
	self.rottime = 0

	self.radius = 10
	self.speed = 2

	self.xoff = math.sin(self.rottime*self.speed)*self.radius
	self.yoff = math.cos(self.rottime*self.speed)*self.radius

	self.animation = Animation("img/dragon.png", 16, 16, 0, 2, 0.3)
	self.animation:play()

	self.attacking = false

	self.projectiles = {}
end

function Dragon:update(dt)
	self.time = self.time + dt
	if math.floor(self.time) % 2 == 0 then
		self.attacking = true
	else
		if self.attacking then
			local dir = Vector(self.player.x, self.player.y) - Vector(self.x+self.xoff, self.y+self.yoff)
			local p = Projectile("img/dragon_proj.png", Vector(self.x+self.xoff, self.y+self.yoff), dir:normalized(), 30, function(s)
				local t = lume.find(self.projectiles, s)
				table.remove(self.projectiles, t)
			end)
			table.insert(self.projectiles, p)
		end
		self.attacking = false
		self.rottime = self.rottime + dt
	end
	for i,v in pairs(self.projectiles) do
		v:update(dt)
	end
	self.animation:update(dt)
end

function Dragon:draw()
	local xoff, yoff
	if not self.attacking then
		self.xoff = math.sin(self.rottime*self.speed)*self.radius
		self.yoff = math.cos(self.rottime*self.speed)*self.radius
		xoff, yoff = self.xoff, self.yoff
	else
		xoff = self.xoff
		yoff = math.random(0,0.4) + self.yoff
	end

	love.graphics.push()
	love.graphics.translate(self.x+xoff,self.y+yoff)
	self.animation:draw()
	love.graphics.pop()

	for i,v in pairs(self.projectiles) do
		v:draw()
	end
end

local Enemyfactory = Object:extend()

function Enemyfactory:new()

end

function Enemyfactory:get(name,player,x,y)
	if name == "dragon" then
		return Dragon(player,x,y)
	end
end

return Enemyfactory()
