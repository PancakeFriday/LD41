local HC = require "hardoncollider"

local Projectile = Object:extend()
Projectile.idgen = 0

function Projectile:new(img, start, dir, vel, done)
	self.id = Projectile.idgen
	Projectile.idgen = Projectile.idgen + 1
	self.img = love.graphics.newImage(img)
	self.pos = start
	self.dir = dir
	self.vel = vel
	self.done = done

	local r = self.img:getWidth()/2
	self.bbox = HC.circle(self.pos.x+r, self.pos.y+r, r)
	self.bbox.type = "projectile"

	self.time = 0
end

function Projectile:update(dt)
	self.time = self.time + dt

	local mby = self.dir*self.vel*dt
	self.pos = self.pos + mby
	self.bbox:move(mby.x, mby.y)

	local called_done = false
	for i,v in pairs(HC.collisions(self.bbox)) do
		self.done(self, i)
		called_done = true
		break
	end

	if not called_done then
		if self.time > 4 then
			self.done(self,{})
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
	math.randomseed(os.time())
	self.player = player
	self.x = x
	self.y = y
	self.time = math.random()*2*math.pi
	self.rottime = math.random()*2*math.pi

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
	local distToPlayer = Vector().dist(Vector(self.player.x, self.player.y), Vector(self.x, self.y))
	if math.floor(self.time*2) % 2 == 0 and distToPlayer < 140 then
		self.attacking = true
	else
		if self.attacking then
			local start = Vector(self.x+self.xoff, self.y+self.yoff)-Vector(3,5)
			local dir = Vector(self.player.x, self.player.y) - start

			local p = Projectile("img/dragon_proj.png", start, dir:normalized(), 70, function(s, other)
				for i,v in pairs(self.projectiles) do
					if v.id == s.id then
						table.remove(self.projectiles, i)
						break
					end
				end
				if other.type == "player" then
					self.player:hurt(0.5)
				end
			end)

			self.attacking = false
			table.insert(self.projectiles, p)
		end
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

	self.animation:setMirror(lume.sign(self.x - self.player.x))
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
