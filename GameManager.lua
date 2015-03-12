require "Util/MapUtil"
require "Util/CollideUtil"

GameManager = class("GameManager")

--����ģʽ
function GameManager:create(zombie, manVec, map)
	local s = GameManager.new()
	s:init(zombie, manVec, map)
	return s
end

function GameManager:init(zombie, manVec, map)
	self.map = map
	self.zombie = zombie
	self.manVec = manVec					--�洢����������man, superMan
	self.infectedmanVec = {self.zombie}		--�洢���и�Ⱦ��man, superMan	
end

--�������ǵľ���
function GameManager:lookingForZombie(x, y)
	local zombiepos = self.zombie:getMapPosition()
	local dist = CollideUtil:getMapDist(x, y, zombiepos[1], zombiepos[2])
	if dist > 3 then return nil end
	local dir = {zombiepos[1] - x, zombiepos[2] - y}
	return dir
end


--����Ƿ������
--����ֵ��
--			1 ��ǽ
--			2 ������
--			3 �ǽ�ʬ
--			0 ������û��
function GameManager:isValid(x, y, zombie)
	--�Ƿ����ڵ�
	if self.map:isValid(x, y) == false then return 1 end --��ǽ
	if zombie == nil or zombie == false then --Ѱ������,����û��ָ��������
		for i = 1, #(self.manVec) do
			local manpos = self.manVec[i]:getMapPosition()
			if manpos[1] == x and manpos[2] == y then return 2,self.manVec[i] end --������
		end
	end
	if zombie == nil or zombie == true then --Ѱ�ҽ�ʬ,����û��ָ��������
		for i = 1, #(self.infectedmanVec) do
			local manpos = self.infectedmanVec[i]:getMapPosition()
			--cclog("zombie pos:(%d, %d), check pos:(%d, %d)", manpos[1], manpos[2], x, y)
			if manpos[1] == x and manpos[2] == y then return 3,self.infectedmanVec[i] end --������
		end
	end
	return 0
end

--Ѱ��NPC�����Ƿ��е���...
--zombie:���������ǽ�ʬ/����
--dir��С�˵�����λ�ã���������Ұ
--����ֵ�����˵��������
-- ��ƽ���Ϊ����8������
-- �ֲ���ڶ���ļ��ÿ�����֣�����Ӧ�ڵ������
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
	--�˴���Ҫ��������Ϻ��£��Ա㴦���ڵ�
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
	
	--�ڵ����������
	--��i��Ե�i+1���Ӱ��
	--�˴�delta����>=0�ģ�����ֻ��Ҫ��ͼ��4 5 6���ڵ�������Ϳ����Դ����Ƴ�����5����������
	--key:{deltaX, deltaY}=>{{deltaX1, deltaY1},{deltaX2, deltaY2}...}
	--��һ�㣺
	--{0,1} = {{0,2}}
	--{1,1} = {{1,2},{2,2},{2,2}}
	--{1,0} = {{2,0}}
	--�ڶ��㣺
	--{0,2} = {{0,3}}
	--{1,2} = {{1,3}}
	--{2,2} = {{2,3},{3,3},{3,2}}
	--{2,1} = {{3,1}}
	--{2,0} = {{3,0}}
	--�����㣺
	--{0,3} = {{0,4}}
	--{1,3} = {{1,4}}
	--{2,3} = {{2,4}}
	--{3,3} = {{3,4}, {4,4}, {4,3}}
	--{3,2} = {{4,2}}
	--{3,1} = {{4,1}}
	--{3,0} = {{4,0}}
	--ͬʱ����key > 0, ����{0,i} {i,0}����������ܵ���������ֻ����key > 0���ڵ����
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
	 for layer = 1, maxLayer do --�ӵ�һ�㿪ʼ�����������
		for i = s, e do --��鵱ǰ��
			local delta = checkDelta[i]			
			local isvalid, target = self:isValid(x + delta[1], y + delta[2], zombie)
			--cclog("layer:%d delta(%d,%d) isvalid=%d", layer, delta[1], delta[2], isvalid)
			if isvalid ~= 1 and isvalid ~= 0 then --��Ŷ���е���
					return delta,target
			end
			if isvalid == 0 then --����û�б��ڵ�����Ҫ�����һ�������
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
				--ȡ�� {i,j}�ķ��ţ����Ҹ���i,j��ѯocclude��
				else
					--����
					local signX = (((delta[1] > 0) and 1) or -1)
					local signY = (((delta[2] > 0) and 1) or -1)
					delta[1] = signX * delta[1]
					delta[2] = signY * delta[2]
					--��ǰ�����
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
	 
	 --û�ҵ�
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

---------------------------������Ϸ���-------------------------------
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

--------------------------��ʬ�¼�------------------------------------
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
		--�����һ��δ��Ⱦ�Ĵ�����ʾ�����־
		if tag == 2 then
			self.zombie:setEnemy(target)
			return
		elseif tag == 1 then
			return
		end
		--�ߵ������λ��
		local curMappos = self.zombie:getMapPosition()
		local path = self:findPath(curMappos, touchMapPos)
		self.zombie:goPath(path)
	end
end

function GameManager:zombieStop()
	self.zombie:resetPosition()
end
-------------------------�϶���ͼ-------------------------------------
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











