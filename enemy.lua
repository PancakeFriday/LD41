local Dragon = Object:extend()

function Dragon:new(x,y)
	self.x = x
	self.y = y

	self.animation = Animation("img/dragon.png", 16, 16, 0, 2, 0.3)
	self.animation:play()
end

function Dragon:update(dt)
	self.animation:update(dt)
end

function Dragon:draw()
	love.graphics.push()
	love.graphics.translate(self.x,self.y)
	self.animation:draw()
	love.graphics.pop()
end

local Enemyfactory = Object:extend()

function Enemyfactory:new()

end

function Enemyfactory:get(name,x,y)
	if name == "dragon" then
		return Dragon(x,y)
	end
end

return Enemyfactory()
