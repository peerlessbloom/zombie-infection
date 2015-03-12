---------------------------------------------
--                 人物sprite基类
--                 不持有资源，资源来自Res类
--					类似资源的执行类
---------------------------------------------
require "Res/GameRes"

CharacterSprite = class("CharacterSprite")

function CharacterSprite:init(characterRes)
	self.sprite = nil
end

-------------------对sprite的封装--------------
function CharacterSprite:setPosition(x, y)
	self.sprite:setPosition(x, y)
end

function CharacterSprite:getPosition()
	return self.sprite:getPosition()
end

function CharacterSprite:stopAllActions()
	self.sprite:stopAllActions()
	self.sprite:runAction(cc.FadeIn:create(0))
end

function CharacterSprite:reorder(other)
	local mapOrder = GameRes:getInstance().mapOrder
	
	if mapOrder[self.sprite] > mapOrder[other.sprite] then return end
	
	--将upperSprite.sprite先加入渲染树，self.sprite后加入渲染树
	cclog("reorder")
	local parent = self.sprite:getParent()
	parent:removeChild(self.sprite, false)
	parent:addChild(self.sprite, 1)
	
	mapOrder[self.sprite] = mapOrder["pos"]
	mapOrder["pos"] = mapOrder["pos"] + 1
end
------------------返回一段文字---------------

------------------运行动画--------------------