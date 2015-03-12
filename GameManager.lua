require "Util/MapUtil"
require "Util/CollideUtil"

GameManager = class("GameManager")

--单例模式
function GameManager:create(zombie, manVec, map)
	local s = GameManager.new()
	s:init(zombie, manVec, map)
	return s
end

function GameManager:init(zombie, manVec, map)
	self.map = map
	self.zombie = zombie
	self.manVec = manVec					--存储所有正常的man, superMan
	self.infectedmanVec = {self.zombie}		--存储所有感染的man, superMan	
end

--检查和主角的距离
function GameManager:lookingForZombie(x, y)
	local zombiepos = self.zombie:getMapPosition()
	local dist = CollideUtil:getMapDist(x, y, zombiepos[1], zombiepos[2])
	if dist > 3 then return nil end
	local dir = {zombiepos[1] - x, zombiepos[2] - y}
	return dir
end


--检查是否可以走
--返回值：
--			1 有墙
--			2 是人类
--			3 是僵尸
--			0 生命都没有
function GameManager:isValid(x, y, zombie)
	--是否有遮挡
	if self.map:isValid(x, y) == false then return 1 end --有墙
	if zombie == nil or zombie == false then --寻找人类,或者没有指定的类型
		for i = 1, #(self.manVec) do
			local manpos = self.manVec[i]:getMapPosition()
			if manpos[1] == x and manpos[2] == y then return 2,self.manVec[i] end --有人类
		end
	end
	if zombie == nil or zombie == true then --寻找僵尸,或者没有指定的类型
		for i = 1, #(self.infectedmanVec) do
			local manpos = self.infectedmanVec[i]:getMapPosition()
			--cclog("zombie pos:(%d, %d), check pos:(%d, %d)", manpos[1], manpos[2], x, y)
			if manpos[1] == x and manpos[2] == y then return 3,self.infectedmanVec[i] end --有人类
		end
	end
	return 0
end

--寻找NPC附近是否有敌人...
--zombie:敌人类型是僵尸/人类
--dir：小人的面向位置，用于做视野
--返回值：敌人的相对坐标
-- 将平面分为以下8个部分
-- 分层从内而外的检查每个部分，以适应遮挡的情况
--	  1   2   3
--    8 (x,y) 4 
--    7   6   5
function GameManager:checkSurrounding(curRes, x, y, dir, zombie, animateFun, maxLayer)
	local function initCheckDelta()
		 local checkDelta = {}
		 if dir ~= "d" and dir ~= "r" then 	table.insert(checkDelta, {-1, -1}) end --1
		 if dir ~= "d" then					table.insert(checkDelta, {0, -1}) end  --2
		 if dir ~= "d" and dir ~= "l" then 	table.insert(checkDelta, {1, -1}) end  --3
		 if dir ~= "l" then					table.insert(checkDelta, {1, 0}) end   --4
		 if dir ~= "u" and dir ~= "l" then 	table.insert(checkDelta, {1, 1}) end   --5
		 if dir ~= "u" then					table.insert(checkDelta, {0, 1}) end   --6
		 if dir ~= "u" and dir ~= "r" then 	table.insert(checkDelta, {-1, 1}) end  --7
		 if dir ~= "r" then					table.insert(checkDelta, {-1 ,0}) end  --8
		 return checkDelta
	end
	
	local function checkReorder()
	--此处需要单独检查上和下，以便处理遮挡
		for targetX = x - 1, x + 1 do
			local isvalid, target = self:isValid(targetX, y + 1)
			if isvalid == 2 or isvalid == 3 then
				target.res:reorder(curRes)
			end
			isvalid, target = self:isValid(targetX, y - 1)
			if isvalid == 2 or isvalid == 3 then
				curRes:reorder(target.res)
			end
		end
	end
	
	checkReorder()	
	
	--遮挡的相对坐标
	--第i层对第i+1层的影响
	--此处delta均是>=0的，这样只需要存图中4 5 6的遮挡情况，就可以以此类推出其余5个区域的情况
	--key:{deltaX, deltaY}=>{{deltaX1, deltaY1},{deltaX2, deltaY2}...}
	--第一层：
	--{0,1} = {{0,2}}
	--{1,1} = {{1,2},{2,2},{2,2}}
	--{1,0} = {{2,0}}
	--第二层：
	--{0,2} = {{0,3}}
	--{1,2} = {{1,3}}
	--{2,2} = {{2,3},{3,3},{3,2}}
	--{2,1} = {{3,1}}
	--{2,0} = {{3,0}}
	--第三层：
	--{0,3} = {{0,4}}
	--{1,3} = {{1,4}}
	--{2,3} = {{2,4}}
	--{3,3} = {{3,4}, {4,4}, {4,3}}
	--{3,2} = {{4,2}}
	--{3,1} = {{4,1}}
	--{3,0} = {{4,0}}
	--同时由于key > 0, 而且{0,i} {i,0}的两种情况很单纯，所以只存了key > 0的遮挡情况
	local occlude = {	{ 	{{1,2},{2,2},{2,1}}, 	--[1][1]
							{{1,3}},				--[1][2]
							{{1,4}}					--[1][3]
						},
						{	{{3,1}},				--[2][1]
							{{2,3},{3,3},{3,2}},	--[2][2]
							{{2,4}}					--[2][3]
						},
						{	{{4,1}},				--[3][1]
							{{4,2}},				--[3][2]
							{{3,4},{4,4},{4,3}}		--[3][3]
						}
					}
	
	 maxLayer = maxLayer or 3
	 local checkDelta = initCheckDelta()
	 local s = 1
	 local e = #(checkDelta)
	 for layer = 1, maxLayer do --从第一层开始到第三层结束
		for i = s, e do --检查当前层
			local delta = checkDelta[i]			
			local isvalid, target = self:isValid(x + delta[1], y + delta[2], zombie)
			--cclog("layer:%d delta(%d,%d) isvalid=%d", layer, delta[1], delta[2], isvalid)
			if isvalid ~= 1 and isvalid ~= 0 then --啊哦，有敌人
					return delta,target
			end
			if isvalid == 0 then --视线没有被遮挡，需要添加下一层的内容
				if animateFun ~= nil then
					animateFun(delta[1] * 40, -delta[2] * 40)
				end
				--{i,0}
				if delta[2] == 0 then
					if delta[1] > 0 then table.insert(checkDelta, {delta[1] + 1, 0})
					else				 table.insert(checkDelta, {delta[1] - 1, 0}) end
					--cclog("(%d,%d)=>(%d,%d)", delta[1], delta[2], checkDelta[#(checkDelta)][1], checkDelta[#(checkDelta)][2])
				--{0,i}
				elseif delta[1] == 0 then
					if delta[2] > 0 then table.insert(checkDelta, {0, delta[2] + 1})
					else				 table.insert(checkDelta, {0, delta[2] - 1}) end
					--cclog("(%d,%d)=>(%d,%d)", delta[1], delta[2], checkDelta[#(checkDelta)][1], checkDelta[#(checkDelta)][2])
				--取得 {i,j}的符号，并且根据i,j查询occlude表
				else
					--符号
					local signX = (((delta[1] > 0) and 1) or -1)
					local signY = (((delta[2] > 0) and 1) or -1)
					delta[1] = signX * delta[1]
					delta[2] = signY * delta[2]
					--当前在里层
					if layer < maxLayer then 
						--local nextDelta = {}
						local nextDeltaInOcc = occlude[delta[1]][delta[2]]
						for index = 1, #(nextDeltaInOcc) do
							local item = nextDeltaInOcc[index]
							table.insert(checkDelta, {signX * item[1], signY *item[2]})
							--cclog("(%d,%d)=>(%d,%d)", delta[1], delta[2], checkDelta[#(checkDelta)][1], checkDelta[#(checkDelta)][2])
						end	
						--table.insert(checkDelta, nextDelta)
					end
				end
			end--end of if isvalid == 0 
		end--end of for
		s = e + 1
		e = #(checkDelta)
	 end
	 
	 --没找到
	 return nil	 
end

function GameManager:findPath(from, to)
	cclog("to(%d,%d)", to[1], to[2])
	local path = self.map:findPath(from, to)
	return path
end

function GameManager:addToMap(node, i)
	self.map:addChild(node, i)
end

function GameManager:manDied(node)
	if #(self.manVec) == 1 and self.manVec[1] == node then self:zombieWin() end
	for i = 1, #(self.manVec) do
		if self.manVec[i] == node then 
			table.remove(self.manVec, i)
			return
		end
	end
	for i = 1, #(self.infectedmanVec) do
		if self.infectedmanVec[i] == node then 
			table.remove(self.infectedmanVec, i)
			return
		end
	end
end

function GameManager:manInfected(node)
	if #(self.manVec) == 1 and self.manVec[1] == node then self:zombieWin() end
	for i = 1, #(self.manVec) do
		if self.manVec[i] == node then 
			table.remove(self.manVec, i)
			break
		end
	end
	table.insert(self.infectedmanVec, node)
end

---------------------------宣布游戏结果-------------------------------
function GameManager:manWin()
	self.gameover = true
	cc.Director:getInstance():replaceScene(FailureScene:create())
	GameRes:getInstance():deleteOtherRes()
end

function GameManager:zombieWin()
	self.gameover = true
	cc.Director:getInstance():replaceScene(SuccessScene:create())
	GameRes:getInstance():deleteOtherRes()
end

--------------------------僵尸事件------------------------------------
function GameManager:zombieAttack()
	return self.zombie:attack()
end

function GameManager:zombieAttackFar()
	self.zombie:attackFar()
end

function GameManager:zombieGoDir(dir)
	self.zombie:goDir(dir)
end

function GameManager:zombieAddDir(dir)
	self.zombie:addDir(dir)
end

function GameManager:zombieGo(touchpos)
	if self.zombie ~= nil then
		local touchMapPos = {MapUtil:convert(touchpos[1], touchpos[2])}
		local tag, target = self:isValid(touchMapPos[1], touchMapPos[2], false)
		--如果是一个未感染的村民，显示警戒标志
		if tag == 2 then
			self.zombie:setEnemy(target)
			return
		elseif tag == 1 then
			return
		end
		--走到点击的位置
		local curMappos = self.zombie:getMapPosition()
		local path = self:findPath(curMappos, touchMapPos)
		self.zombie:goPath(path)
	end
end

function GameManager:zombieStop()
	self.zombie:resetPosition()
end
-------------------------拖动地图-------------------------------------
function GameManager:dragMap(diff)
	if self.map ~= nil then	
		local currentPosX, currentPosY= self.map:getPosition()
		currentPosX = currentPosX + diff.x
		currentPosY = currentPosY + diff.y
		currentPosX, currentPosY = self:calculateMapPosition(currentPosX, currentPosY)
		self.map:setPosition(currentPosX, currentPosY)
	end
end

function GameManager:mapMoveTo(x, y, t)
	x, y = self:calculateMapPosition(x, y)
	self.map:move(x, y, t)
end

function GameManager:calculateMapPosition(x,y)
	if self.map ~= nil then	
		x = ((x > 0) and 0) or x
		x = ((x <= (900-MapUtil.mapWidth)) and (900-MapUtil.mapWidth+1)) or x
		y = ((y > 0) and 0) or y
		y = ((y <= (600-MapUtil.mapHeight)) and (600-MapUtil.mapHeight+1)) or y
		return x, y
	end
end

function GameManager:getMapPosition()
	return self.map:getPosition()
end











