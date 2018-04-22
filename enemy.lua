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
			self.done(self,{type="map"})
		end
	end
end

function Projectile:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.img, self.pos.x, self.pos.y, angle)

	if DEBUG then
		love.graphics.setColor(1,0,0)
		self.bbox:draw()
		love.graphics.setColor(1,1,1)
	end
end

local Dragon = Object:extend()

function Dragon:new(player,x,y)
	self.dead = false

	self.audio_shoot = love.audio.newSource("wav/shoot.wav", "static")
	self.audio_shoot:setLooping(false)
	self.audio_shoot:setVolume(0.3)

	self.audio_dead = love.audio.newSource("wav/endead.wav", "static")
	self.audio_dead:setLooping(false)
	self.audio_dead:setVolume(0.3)

	self.audio_hit = love.audio.newSource("wav/enhit.wav", "static")
	self.audio_hit:setLooping(false)
	self.audio_hit:setVolume(0.3)


	self.health = 1

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

	self.bbox = HC.rectangle(self.x+3, self.y+3, 10, 10)
	self.bbox.type = "enemy"
	self.bbox.object = self
end

function Dragon:hurt(n)
	self.health = self.health - n
	if self.health <= 0 then
		self.dead = true
		HC.remove(self.bbox)
		self.audio_dead:play()
	else
		self.audio_hit:play()
	end
end

function Dragon:update(dt)
	if not self.dead then
		self.time = self.time + dt
		local distToPlayer = Vector().dist(Vector(self.player.x, self.player.y), Vector(self.x, self.y))
		if math.floor(self.time*2) % 2 == 0 and distToPlayer < 140 then
			self.attacking = true
		else
			if self.attacking then
				local start = Vector(self.x+self.xoff, self.y+self.yoff)-Vector(3,5)
				local dir = Vector(self.player.x, self.player.y) - start

				local p = Projectile("img/dragon_proj.png", start, dir:normalized(), 70, function(s, other)
					if other.type == "player" or other.type == "map" then
						for i,v in pairs(self.projectiles) do
							if v.id == s.id then
								table.remove(self.projectiles, i)
								break
							end
						end
						if other.type == "player" then
							self.player:hurt(0.5)
						end
					end
				end)

				self.audio_shoot:play()
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
end

function Dragon:draw()
	if not self.dead then
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
		self.bbox:moveTo(self.x+xoff, self.y+yoff)
		self.animation:draw()
		love.graphics.pop()

		for i,v in pairs(self.projectiles) do
			love.graphics.setColor(1,0,0)
			v:draw()
			love.graphics.setColor(1,1,1)
		end

		if DEBUG then
			self.bbox:draw()
		end
	end
end

local Snake = Object:extend()

function Snake:new(player,x,y)
	self.player = player
	self.x = x
	self.xoff = 0
	self.y = y

	self.health = 1

	self.audio_dead = love.audio.newSource("wav/endead.wav", "static")
	self.audio_dead:setLooping(false)
	self.audio_dead:setVolume(0.3)

	self.audio_hit = love.audio.newSource("wav/enhit.wav", "static")
	self.audio_hit:setLooping(false)
	self.audio_hit:setVolume(0.3)

	self.animations = {
		walk = Animation("img/snake.png", 16, 16, 0, 2, 0.3),
		attack = Animation("img/snake.png", 16, 16, 0, 2, 0.8),
	}
	self.animations["walk"]:play()

	self.bbox = HC.rectangle(self.x, self.y+8, 16, 6)
	self.bbox.type = "enemy"
	self.bbox.object = self

	self.gprobel = HC.rectangle(self.x-1,self.y+16,1,1)
	self.gprober = HC.rectangle(self.x+16,self.y+16,1,1)

	self.attacking = false
	self.time = 0

	self.dir = -1

	self.dead = false
end

function Snake:hurt(n)
	self.health = self.health - n
	if self.health <= 0 then
		self.dead = true
		HC.remove(self.bbox)
		self.audio_dead:play()
	else
		self.audio_hit:play()
	end
end

function Snake:update(dt)
	if not self.dead then
		self.time = self.time + dt
		self.xoff = math.sin(self.time/0.3*math.pi/2)^2
		self.animations["walk"]:update(dt)
		self.animations["attack"]:update(dt)
		self:move(dt)
	end
end

function Snake:move(dt)
	local mx = self.dir * 20*dt
	self.x = self.x + mx
	self.bbox:move(mx,0)
	self.gprobel:move(mx,0)
	self.gprober:move(mx,0)

	self.animations["walk"]:setMirror(-self.dir)
	local foundcol = false
	for i,v in pairs(HC.collisions(self.gprobel)) do
		if i.type == "map" then
			foundcol = true
			break
		end
	end
	if not foundcol then self.dir = 1 end
	local foundcol = false
	for i,v in pairs(HC.collisions(self.gprober)) do
		if i.type == "map" then
			foundcol = true
			break
		end
	end
	if not foundcol then self.dir = -1 end
	local foundcol = false
	for i,v in pairs(HC.collisions(self.bbox)) do
		if i.type == "map" then
			foundcol = true
		end
	end
	if foundcol then self.dir = -self.dir end
end

function Snake:draw()
	if not self.dead then
		if not self.attacking then
			love.graphics.push()
			love.graphics.translate(self.x+8+self.xoff, self.y+8)
			self.animations["walk"]:draw()
			love.graphics.pop()
		end

		if DEBUG then
			self.bbox:draw()
			self.gprobel:draw()
			self.gprober:draw()
		end
	end
end

local Enemyfactory = Object:extend()

function Enemyfactory:new()

end

function Enemyfactory:get(name,player,x,y)
	if name == "dragon" then
		return Dragon(player,x,y)
	elseif name == "snake" then
		return Snake(player,x,y)
	end
end

return Enemyfactory()
