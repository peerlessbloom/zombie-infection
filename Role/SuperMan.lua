--��������

require "Sprite/SuperManSprite"
require "Ai/SuperManState"
require "Role/Man"

SuperMan = class("SuperMan", function() return Man.new() end)
function SuperMan:create(manRes, patrollPath, config, infectedConfig)
	local m = SuperMan.new()
	m:init(manRes, patrollPath, config, infectedConfig)
	return m
end

function SuperMan:init(manRes, patrollPath, config, infectedConfig)
	self.path = patrollPath				--��ǰ·��,�ڳ�ʼ���׶�=Ѳ��·��
	self.pathIndex = 1
	self.mapPos = self.path[self.pathIndex]
	self.patrollPath = patrollPath		--Ѳ��·��
	self.patrollDir = 1					--Ѳ�߷���
	self.patrollPathIndex = 1			--��ǰѲ�ߵ�λ��
	self.isPatroll = "patroll"			--�Ƿ���Ѳ��"patroll"/ȥѲ�߿�ʼλ�õ�·��"return"/����"escape"
	self.dir = "d"
	
	self.life = config["life"]
	self.harm = config["harm"]						--���̹���
	self.harmFar = config["harmFar"]				--Զ�̹���
	self.speed = config["speed"]
	self.leftfoot = true
	self.enemy = nil
	self.isHealthy = config["isHealthy"]			--�Ƿ񱻸�Ⱦ,������ʬԶ�̹�����ʱ��isHealthy--��ֱ��=0ʱ����Ⱦ
	self.attackSpeed = config["attackSpeed"]		--ÿ�빥����
	self.infectedConfig = infectedConfig
	
	self.aiState = SuperManPatrollState:create() --AI״̬
	self.state = "alive"				--����״̬
	
	self.askGod = nil
	
	self.res = SuperManSprite:create(manRes, self.speed, self.life)
	self.res:setPosition(MapUtil:convertBack(self.mapPos[1], self.mapPos[2]))
end

--------------------����--------------------

-------------------����---------------------
local function selfCheck(sprite, man)
	cclog("superman self check")
	--�Զ�������
	man[1]:update()
end

-----------------ֹͣ-------------------------

-----------------״̬-------------------------

-----------------��������---------------------

-----------------����-------------------------
function SuperMan:attackFar()
	if self:isAttackable(3) == false then
		local dist, dir, enemy = self:checkView()
		if self:isAttackable(3) == false then 
			self:update()
			return 
		end
		self.dir = CollideUtil:convertDir(dir[1], dir[2])
	end
	
	local pos = self:getMapPosition()
	local attack = Attack:create(1, self.enemy, self.harmFar, self:getMapPosition(), self.askGod)
	--AI
	self.res:runDelayFunction(1/self.attackSpeed, selfCheck, {self})
	attack:go()
end

-----------------����---------------------

-----------------����---------------------

-----------------��Ⱦ---------------------
function SuperMan:infect()
	--�Ѿ���Ⱦ������Ҫ�ٴθ�Ⱦ
	if self.state == "infected" or  self.state == "dead" then return end
	--����ʬ���˵�����
	self.isHealthy = self.infectedConfig["isHealthy"]
	self.life = self.infectedConfig["life"]
	self.harm = self.infectedConfig["harm"]
	self.speed = self.infectedConfig["speed"]
	self:setEnemy(nil)
	pos = self:getPosition()
	self.res:setSprite(true, pos, self.life)
	self.res:updateState(self.life)
	--self:patroll()
	self.askGod:manInfected(self)
	self.state = "infected"
	self:update()
end