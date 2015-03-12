--------------------------------------------------
--              ���ࣺ������һ����ɫ
--              ���ࣺZombie Man
--							 SuperMan
--------------------------------------------------

require "Util/MapUtil"
require "Util/logUtil"
require "Util/CollideUtil"

Character = class("Character")

-------------------��Ա------------------
function Character:init()
	self.res = nil 			--��Դ
	self.mapPos = nil		--�ڵ�ͼ�е�λ��
	self.path = nil			--·������
	self.pathIndex = nil	--��·���е��±�
	self.isPathEnd = false	--�Ƿ�����Ҫ���ߵ�·�������¼��У�
	self.dir = nil			--����
	
	self.life = nil			--����
	self.harm = nil			--������
	self.speed = nil		--�ٶ�
	self.leftfoot = nil 	--�Ƿ������
	self.enemy = nil 		--�����ĵ���
	
	self.aiState = nil		--����״̬��
	
	self.askGod = nil		--�ϵۣ�InteractLayer��
end

function Character:sprite()
	return self.res.sprite
end
------------------����--------------------
function Character:getPosition()
	return {self.res:getPosition()}
end

function Character:getMapPosition(dir)
	return CollideUtil:getNextMapPos(self.mapPos[1], self.mapPos[2], dir)
end

-----------------����---------------------
function Character:resetPathIndex()
	self.pathIndex = 1
	self.isPathEnd = false
end

--��path�������
function Character:addDir(dir)
	self.isGoDir = "dir"
	if self.isPathEnd then --�Ѿ�����·�̣���������
		self:goDir(dir)
		return
	end
	local lastpos = self.path[#(self.path)]
	local newpos = CollideUtil:getNextMapPos(lastpos[1], lastpos[2], dir)
	table.insert(self.path, {newpos[1],newpos[2]})
	--[[
	cclog("ADD_DIR(%d,%d)=>(%d,%d) [%d]| cur:%d (%d,%d)", 
		lastpos[1], lastpos[2], newpos[1], newpos[2], #(self.path), self.pathIndex, 
		self.path[self.pathIndex][1], self.pathIndex, self.path[self.pathIndex][2])
	for i = 1, #(self.path) do 
		cclog("\t(%d,%d)", self.path[i][1], self.path[i][2])
	end
	]]
end

--����
function Character:goDir(dir)
	self.isGoDir = "dir"
	local nextPos = self:getMapPosition(dir)
	self.path = {{self.mapPos[1],self.mapPos[2]}, {nextPos[1],nextPos[2]}}
	--[[
	cclog("GO_DIR(%d,%d)=>(%d,%d)", self.mapPos[1], self.mapPos[2], nextPos[1], nextPos[2])
	for i = 1, #(self.path) do 
		cclog("\t(%d,%d)", self.path[i][1], self.path[i][2])
	end
	]]
	self:resetPathIndex()
	self:go()
end

--·��
function Character:goPath(path)
	self.isGoDir = "path"
	self.path = path
	self.pathIndex = 1
	self:go()
end

function Character:go()
	self:stop()
	--����������
	if self.path == nil then 
		self.update()
		return 
	end
	if self.pathIndex >= #(self.path) then 
		self.isPathEnd = true
		self.update()
		return 
	end
	--��ײ���
	local curpos = self.path[self.pathIndex]
	local nextpos = self.path[self.pathIndex + 1]
	self.dir = CollideUtil:getMapDir(curpos[1], curpos[2], nextpos[1], nextpos[2])
	self.mapPos = {curpos[1], curpos[2]}
	local state = self:collideCheck(nextpos)
	if state == "stop" then
		--������Զ�Ѱ·�������ܻ������������
		--����Ǽ��̣�����뽫self.path��գ���Ϊ�����·������Ч��
		self.path = {curpos}
		self.pathIndex = 1
		self.isPathEnd = true
		self:stopStub(curpos)
		return
	elseif state == "wait" then
		--ԭ�صȴ�
		curpos = {MapUtil:convertBack(curpos[1], curpos[2])}
		self:waitStub(curpos)
		return
	end
	--update״̬
	self.pathIndex = self.pathIndex + 1
	self.mapPos = {nextpos[1], nextpos[2]}
	if self.leftfoot then self.leftfoot = false else self.leftfoot = true end
	--cclog("(%d,%d)=>(%d,%d)", curpos[1], curpos[2], nextpos[1], nextpos[2])
	curpos = {MapUtil:convertBack(curpos[1], curpos[2])}
	nextpos = {MapUtil:convertBack(nextpos[1], nextpos[2])}
	----cclog("(%f,%f)=>(%f,%f)", curpos[1], curpos[2], nextpos[1], nextpos[2])
	
	--stub����
	self:goStub(curpos, nextpos, self.dir)
end

--overwrite
function Character:goStub(curpos, nextpos, dir)
end

--overwrite
function Character:waitStub(curpos)
end

function Character:stopStub(curpos)
end

--��ײ���
function Character:collideCheck(pos)
	local tag = self.askGod:isValid(pos[1], pos[2])
	--cclog("%d, %d", pos[1], pos[2])
	--cclog(tag)
	if tag == 1 then return "stop"
	elseif tag == 2 or tag == 3 then return "wait", tag
	else	return "go"
	end
end

-----------------ֹͣ-------------------------
function Character:stop()
	self.res:stopAllActions()
end

------------------״̬-----------------------
function Character:update()
	if self.aiState == nil or self.askGod.gameover then 
		cclog("no ai")
		return 
	end
	self.aiState:handle(self)
end

function Character:changeAIState(s)
	self.aiState = s
end

---------------��������---------------------
function Character:setEnemy(e)
end

function Character:lookingForZombie()
	return self.askGod:lookingForZombie(self.mapPos[1], self.mapPos[2])
end

--�����Ұ���������õ���
function Character:checkView(checkScope, showAnimate)
	return self:checkAround(checkScope, self.dir, showAnimate)
end

--�������
function Character:checkAround(checkScope, dir, showAnimate)
	if dir == nil then dir = "a" end
	if showAnimate == nil then showAnimate = true end
	--cclog("check around:(%d, %d)", self.mapPos[1], self.mapPos[2])
	local findZombie = true
	if self:isInfected() then findZombie = false end
	
	local function fun(x, y)
		if showAnimate then self.res:runCheckAnimate(x, y) end
	end
	
	local dir, enemy = self.askGod:checkSurrounding(self.res, self.mapPos[1], self.mapPos[2], dir, findZombie, fun, checkScope)
	--û�ҵ�
	if enemy == nil then 
		self:setEnemy(nil)
		return nil 
	end
	local dist = CollideUtil:getMapDist(dir[1], dir[2], 0, 0)
	self:setEnemy(enemy) --�����ĵ������õ���
	return dist, dir, enemy
end

----------------����------------------------
function Character:isAttackable(dist) --�ܷ񹥻�
	if self.enemy == nil or self:isDied() == true or
		(self.enemy ~= nil and self.enemy:isDied()) or
		(self.enemy ~= nil and self.enemy:isInfected() == self:isInfected())
		then return false end
	if dist ~= nil then
		local eMapPos = self.enemy:getMapPosition()
		if CollideUtil:getMapDist(eMapPos[1], eMapPos[2], self.mapPos[1], self.mapPos[2]) > dist then 
			return false end
	end
	return true
end

function Character:attack()
	self:stop()
	if self:isAttackable(1) == false then
		local dist, dir, enemy = self:checkView(nil, false)
		if self:isAttackable(1) == false then 
			self:update() --����״̬
			self:attackFailStub()
			return false
		end
	end
	local eMapPos = self.enemy:getMapPosition()
	local dir = CollideUtil:getMapDir(self.mapPos[1], self.mapPos[2], eMapPos[1], eMapPos[2])
	local goDir = self.dir
	self.dir = dir
	--2.���Ŷ���
	self:attackStub(eMapPos, goDir)
	--3.����Ѫ����
	self.enemy:hurt(self.harm, false)
	if self.enemy:isDied() then
		self:upgrade()
	end
	return true
end

--�ȴ�overwrite
function Character:attackStub(eMapPos)
end

--�ȴ�overwrite
function Character:attackFailStub()
end

--�����Ƿ��������
function Character:searchStub()
	--self:checkView()
	--return self:isAttackable()
	return false
end


function Character:attackFar()
end

----------------����----------------------
function Character:upgrade()
end

-----------------����---------------------
function Character:hurt(value)
end

-----------------����---------------------
function Character:die()
end

function Character:isDied()
	return self.life <= 0
end

function Character:isInfected()
	return false
end