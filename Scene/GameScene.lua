require "Role/Zombie"
require "Role/Man"
require "Role/SuperMan"
require "Layer/MapLayer"
require "Layer/InteractLayer"
require "Res/GameRes"
require "Util/MapUtil"
	
GameScene = class("GameScene")

function GameScene:create(level)
	local s = GameScene.new()
	s:init(level)
	return s.scene
end

function GameScene:init(level)
	self.scene = cc.Scene:create()
	
	--读入config
	local levelStageMapping = {"Config/Stage1", "Config/Stage2"}
	cclog("stage:"..levelStageMapping[level])
	local stageConfig = require(levelStageMapping[level])
	
	--load map
	MapUtil:setConfig(stageConfig)
	local map = MapLayer:create(stageConfig.map)
	
	-- load zombie
	local zombieRes = ZombieRes:create()
	local zombie = Zombie:create(zombieRes, stageConfig.zombie)
	
	-- load man
	local manRes = ManRes:create(stageConfig.manNum)
	local superManRes = SuperManRes:create(stageConfig.supermanNum)
	
	local path = stageConfig.path
	local manVec = {}
	index = 1
	for i = 1, stageConfig.manNum do
		local man = Man:create(manRes, path[index], stageConfig.man, stageConfig.infectedman)
		index = index + 1
		table.insert(manVec, man)
	end
	
	for i = 1, stageConfig.supermanNum do
		local superman = SuperMan:create(superManRes, path[index], stageConfig.superman, stageConfig.infectedsuperman)
		index = index + 1
		table.insert(manVec, superman)
	end

	--register res
	GameRes:getInstance():addRes(manRes)
	GameRes:getInstance():addRes(zombieRes)
	GameRes:getInstance():addRes(superManRes)
	
	--load blood
	local blood = GameRes:getInstance().blood
	
	--add to container
	local container = InteractLayer:create(map, zombie, blood, manVec)
	
	self.scene:addChild(container.mapLayer)
	
	for i = 1, #(manVec) do
		manVec[i]:patroll()
	end
	
	if level == 1 then self:runIntro() end
end

function GameScene:runIntro()
	local intro = { "这个丛林深处的村庄，由于饱受僵尸的骚扰，现在已经没有几个村民了",
					"活着的人在村庄外围建立了围墙，妄图守护最后的安宁",
					"多么可笑是不是，现在你可以来一个瓮中捉鳖了", 
					"村里现在只有两个村民，都按照固定的线路巡逻着\n上面这个是普通村民，下面的是警察\n\n蓝色的点是他们视野范围，树会遮挡视野",
					"普通村民看你会逃跑，直到无路可逃时才会拼死一搏\n警察看见你会进行远程攻击",
					"现在，你可以通过键盘的[上][下][左][右]键在地图上走动\n还可以点击地图的某一点，自动走过去",
					"你有两种攻击方式:\n\n[A]是进程攻击，可以伤害和你距离1以内的敌人\n[S]是远程感染，敌人被感染三次后就会变成僵尸",
					"你可以点击村民，当他头上有一双红眼睛的时候，就代表他是你的攻击目标了\n如果你没有指定，那就会攻击离你最近的村民",
					"当你吃掉村民后，自己的实力也会有提升",
					"当村庄中没有活人时，你就赢了\n加油！"
				}
	local times = {1, 1, 1, 2, 1, 2, 3, 3, 1, 1}
	local p = GameRes:getInstance().cvsts[2]
	p:setPosition(700,0)
	p:setAnchorPoint(0,0)
	self.scene:addChild(p, 2)
	
	local index = 1
	local size = #(intro)
	local msg = nil
	local isContinue = true
	
	local function getNext()
		if msg ~= nil then
			msg:getParent():removeChild(msg)
			msg = nil
		end
		if index > size then
			isContinue = false
		end
						
		if isContinue then
			msg = GameRes:getInstance():getTalkBox(intro[index])
			msg:setAnchorPoint( 0, 0 )
			msg:setOpacity(0)
			self.scene:addChild(msg, 1)
			index = index + 1
			msg:runAction( cc.Sequence:create( cc.FadeIn:create(1),
											   cc.FadeOut:create(times[index - 1]),
											   cc.CallFunc:create(getNext)
						 )
			  )
		else
			p:getParent():removeChild(p)
		end
	end
	getNext()
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	