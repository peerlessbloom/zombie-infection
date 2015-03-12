require "Util/LogUtil"


AStarMap = class("AStarMap")
function AStarMap:ctor(width, height, map)
	self.visited = {} --存放当前点的父亲结点，内容为x,y,以及对应的G值
	self.map = {}
	self.width = width
	self.height = height
	for i = 1,width do
		self.map[i] = {}
		self.visited[i] = {}
		for j = 1,height do
			self.map[i][j] = map[i][j]
		end
	end
	self:reset()
end

function AStarMap:reset()
	for i = 1,self.width do
		for j = 1,self.height do
			self.visited[i][j] = {}
		end
	end
	self.open = {count = 0}
	self.G = 0
end

function AStarMap:isValid(x, y)
	if x <= 0 or y <= 0 or x > self.width or y > self.height then return false end
	return self.map[x][y] == 0
end

function AStarMap:setStart(x, y)
	--x, y = MapUtil:convert(x, y)
	--cclog("start:%f, %f", x, y)
	self.startX = x
	self.startY = y
end

function AStarMap:setEnd(x, y)
	--x, y = MapUtil:convert(x, y)
	--cclog("end:%f, %f", x, y)
	self.endX = x
	self.endY = y
end



--开始A*寻路
function AStarMap:findPath()
	self:reset()
	self.visited[self.startX][self.startY] = {x=0, y=0, G=0}
	--cclog("[findPath start]\n visited(%d, %d) = (%d, %d)", self.startX, self.startY, self.visited[self.startX][self.startY]["x"], self.visited[self.startX][self.startY]["y"])
	return self:findPathRecur()
end

--DFS A*寻路
function AStarMap:findPathRecur()
	self.G = self.G + 1
	
	if self.startX == self.endX and self.startY == self.endY then
		--cclog("Find")
		return self:getPath()
	end
	--map index
	local i = self.startX
	local j = self.startY
	--上
	if i >= 1 and j-1 >= 1 and 
	i <= self.width and j <= self.height and 
	self.map[i][j-1] == 0 and 
	( self.visited[i][j-1]["G"] == nil or self.visited[i][j-1]["G"] > self.G )then
		self.visited[i][j-1] = {x=i, y=j, G = self.G}
		self:addToOpen(i, j - 1)
		--cclog("visited(%d, %d) = (%d, %d)", i, j-1, self.visited[i][j-1]["x"], self.visited[i][j-1]["y"])
	end
	--左
	if i-1 >= 1 and j >= 1 and 
	i <= self.width and j <= self.height and 
	self.map[i-1][j] == 0 and 
	( self.visited[i-1][j]["G"] == nil or self.visited[i-1][j]["G"] > self.G ) then
		self.visited[i-1][j] = {x=i, y=j, G = self.G}
		self:addToOpen(i - 1, j)
		--cclog("visited(%d, %d) = (%d, %d)", i-1, j, self.visited[i-1][j]["x"], self.visited[i-1][j]["y"])
	end
	--下
	if i >= 1 and j >= 1 and 
	i <= self.width and j + 1 <= self.height and 
	self.map[i][j+1] == 0 and 
	( self.visited[i][j+1]["G"] == nil or self.visited[i][j+1]["G"] > self.G ) then
		self.visited[i][j+1] = {x=i, y=j, G = self.G}
		self:addToOpen(i, j + 1)
		--cclog("visited(%d, %d) = (%d, %d)", i, j+1, self.visited[i][j+1]["x"], self.visited[i][j+1]["y"])
	end
	--右
	if i >= 1 and j >= 1 and 
	i + 1 <= self.width and j <= self.height and 
	self.map[i+1][j] == 0 and 
	( self.visited[i+1][j]["G"] == nil or self.visited[i+1][j]["G"] > self.G ) then
		self.visited[i+1][j] = {x=i, y=j, G = self.G}
		self:addToOpen(i + 1, j)
		--cclog("visited(%d, %d) = (%d, %d)", i+1, j, self.visited[i+1][j]["x"], self.visited[i+1][j]["y"])
	end
	
	--重置当前位置为open中最小的F对应的位置
	local minK = 1000
	for k in pairs(self.open) do
		if type(k) == "number" and minK > k then
			minK = k 
		end
	end
	local v = self.open[minK];
	if v == nil then return nil end
	vlast = table.getn(v)

	self.startX = v[vlast][1]
	self.startY = v[vlast][2]
	if table.getn(v) == 1 then
		self.open[minK] = nil
		self.open["count"] = self.open["count"] - 1
	else
		table.remove(v)
	end
	return self:findPathRecur()
end

--将当前点加入open列表，以<F,{x,y}>的键值对形式插入
function AStarMap:addToOpen(x, y)
	local curF = self:getF(x, y)
	if self.open[curF] == nil then
		self.open[curF] = {}
		self.open["count"] = self.open["count"] + 1
	end
	table.insert( self.open[curF], {x, y})--向open[F]中添加{x, y}
end

--获取某个点的F值
function AStarMap:getF(curX, curY)
	return math.abs(curX - self.endX) + math.abs(curY - self.endY) + self.G
end

--回溯寻路
function AStarMap:getPath()
	self.path = {}
	reversePath = {}
	local i = self.endX
	local j = self.endY
	while self.visited[i][j]["G"] ~= nil and self.visited[i][j]["G"] ~= 0 do
		--cclog("(%d, %d)", i, j)
		table.insert(reversePath, {i, j}) 
		local nexti = self.visited[i][j]["x"]
		local nextj = self.visited[i][j]["y"]
		i = nexti
		j = nextj
	end
	table.insert(reversePath, {i, j})
	--cclog("(%d, %d)", i, j)
	--旧的方法转置，同时得到方向
	--[[
	local size = #(reversePath)
	if size <= 1 then
		return reversePath
	end
	local prei = reversePath[size][1]
	local prej = reversePath[size][2]
	local preo = MapUtil:getDir(prei, prej, reversePath[size - 1][1], reversePath[size - 1][2])
	for index = size - 1,1,-1 do
		--cclog("(%d, %d)", reversePath[index][1], reversePath[index][2])
		o = MapUtil:getDir(prei, prej, reversePath[index][1], reversePath[index][2])
		if preo ~= o then 
			cclog("insert in table")
			table.insert(self.path, {prei, prej, preo})
		end
		prei = reversePath[index][1]
		prej = reversePath[index][2]
		preo = o
	end
	table.insert(self.path, {prei, prej, preo})--插入终点
	]]
	for index = #(reversePath),1,-1 do
		table.insert(self.path, reversePath[index])
	end
	return self.path
end

