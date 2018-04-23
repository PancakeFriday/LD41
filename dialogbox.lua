local HC = require "hardoncollider"

local Dialogbox = Object:extend()

local MAXWIDTH = 10
local TEXTSPEED = 0.03

Dialogbox.scale = 0.6

function Dialogbox.getDimensions(text)
	local textwidth, numlines = FONT[40]:getWrap(text, (MAXWIDTH*16 + 10)*4)
	numlines = #numlines
	local maxx = math.min(MAXWIDTH, math.floor(textwidth/(16*4)))
	local maxy = math.max(0,numlines - 2)
	return (maxx+2)*16, (maxy+2)*16
end

function Dialogbox:new(text,x,y)
	self.img = love.graphics.newImage("img/dialogbox.png")
	self.img:setFilter("nearest","nearest")
	self.quads = {}
	for y = 0,4 do
		self.quads[y] = {}
		for x = 0,4 do
			self.quads[y][x] = love.graphics.newQuad(x*16,y*16,16,16,self.img:getWidth(),self.img:getHeight())
		end
	end

	self.time = 0
	self.text = text
	self.x = x
	self.y = y

	self.w, self.h = Dialogbox.getDimensions(self.text)
	self.bboxes = {}
	for y=0,self.h-1,16 do
		local j = y/16
		self.bboxes[j] = {}
		for x=0,self.w-1,16 do
			local i = x/16
			self.bboxes[j][i] = HC.rectangle(self.x+x*self.scale, self.y+y*self.scale, 16*self.scale, 16*self.scale)
			self.bboxes[j][i].type = "dialogbox"
			self.bboxes[j][i].damaged = false
		end
	end

	self.done = false
	self.remove = false

	self.canvas = love.graphics.newCanvas(love.graphics.getDimensions())
end

function Dialogbox:update(dt)
	self.time = self.time + dt
	if self.time > 20 then
		self.remove = true
	end
	local numchars = math.floor((self.time)/TEXTSPEED)
	if numchars >= self.text:len() then
		self.done = true
	end
end

function Dialogbox:drawTile(x,y,qx,qy)
	local maxx, maxy = self.w/16, self.h/16
	if not self.bboxes[y][x].damaged then
		love.graphics.draw(self.img, self.quads[qy][qx],x*16,y*16)
	else
		if self.bboxes[y] and self.bboxes[y][x+1] and not self.bboxes[y][x+1].damaged then
			love.graphics.draw(self.img, self.quads[4][1], x*16, y*16)
		end
		if self.bboxes[y] and self.bboxes[y][x-1] and not self.bboxes[y][x-1].damaged then
			love.graphics.draw(self.img, self.quads[4][0], x*16, y*16)
		end
		if self.bboxes[y+1] and self.bboxes[y+1][x] and not self.bboxes[y+1][x].damaged then
			love.graphics.draw(self.img, self.quads[3][1], x*16, y*16)
		end
		if self.bboxes[y-1] and self.bboxes[y-1][x] and not self.bboxes[y-1][x].damaged then
			love.graphics.draw(self.img, self.quads[3][0], x*16, y*16)
		end
	end
end

function Dialogbox:stencilFun()
	for y=0,self.h-1,16 do
		local j = y/16
		for x=0,self.w-1,16 do
			local i = x/16
			love.graphics.setColor(1,1,1)
			if not self.bboxes[j][i].damaged then
				love.graphics.rectangle("fill",x,y,16,16)
			end
		end
	end
end

function Dialogbox:draw()
	local numchars = math.floor(self.time/TEXTSPEED)

	love.graphics.setFont(FONT[40])
	local textwidth, numlines = FONT[40]:getWrap(self.text, (MAXWIDTH*16 + 10)*4)
	local _, wrappedtext = FONT[40]:getWrap(self.text:sub(1,numchars), (MAXWIDTH*16 + 10)*4)
	numlines = #numlines

	local maxx = math.min(MAXWIDTH, math.floor(textwidth/(16*4)))
	local maxy = math.max(0,numlines - 2)

	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.scale(self.scale,self.scale)
	-- top left
	self:drawTile(0,0,0,0)
	-- top border
	for i=1,maxx do
		self:drawTile(i,0,1,0)
	end
	-- top right
	self:drawTile(maxx+1,0,2,0)

	if numlines > 2 then
		-- left border
		for i=1,maxy do
			self:drawTile(0,i,0,1)
		end
		-- right border
		for i=1,maxy do
			self:drawTile(maxx+1,i,2,1)
		end
	end

	-- center
	for y=1, maxy do
		for x=1, maxx do
			self:drawTile(x,y,1,1)
		end
	end

	-- bottom left
	self:drawTile(0,maxy+1,0,2)
	-- bottom right
	self:drawTile(maxx+1,maxy+1,2,2)
	-- bottom border
	for i=1,maxx do
		self:drawTile(i,maxy+1,1,2)
	end

	love.graphics.stencil(function() return self:stencilFun() end, "replace", 1)
	love.graphics.setStencilTest("greater", 0)

	love.graphics.setColor(0,0,0)
	for i,v in pairs(wrappedtext) do
		love.graphics.printUnscaled(v, 5, (i-1)*FONT[40]:getHeight()/4 + 4)
	end
	love.graphics.setColor(1,1,1)

	love.graphics.setStencilTest()
	love.graphics.pop()

	if DEBUG then
		love.graphics.setColor(1,0,0)
		for y,v in pairs(self.bboxes) do
			for x,k in pairs(v) do
				k:draw()
			end
		end
		love.graphics.setColor(1,1,1)
	end
end

return Dialogbox
