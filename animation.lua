local Animation = Object:extend()

function Animation:new(spritesheet,w,h,row,numFrames,tbf)
	self.spritesheet = love.graphics.newImage(spritesheet)
	self.numFrames = numFrames
	self.quads = {}
	for i=0,self.spritesheet:getWidth()-1,w do
		table.insert(self.quads, love.graphics.newQuad(i,
			row*h,
			w,
			h,
			self.spritesheet:getWidth(),
			self.spritesheet:getHeight()
		))
	end
	self.time = 0

	-- time between frames
	self.tbf = tbf or 0.3
	self.stopped = true
end

function Animation:update(dt)
	if not self.stopped then
		self.time = self.time + dt
	end
end

function Animation:draw()
	local i = math.floor(self.time/self.tbf)%self.numFrames+1
	love.graphics.draw(self.spritesheet, self.quads[i])
end

function Animation:stop()
	self.stopped = true
end

function Animation:play()
	self.stopped = false
end

function Animation:reset()
	self.time = 0
end

return Animation
