--����һ����ʬ�࣬Ҳ���û����Ƶ�Ӣ��
--����һ��sprite

Zombie = class("Zombie", function()
	local sprite = cc.Sprite:create("sprite/zombie.png")
	sprite:setAnchorPoint(0, 0)
	local viewWindowOrigin = cc.Director:getInstance():getVisibleOrigin()
	local viewWindowSize = cc.Director:getInstance():getVisibleSize()
	sprite:setPosition(viewWindowOrigin.x, viewWindowOrigin.y + viewWindowSize.height / 4)
	return sprite
end)

Zombie.life = 100
Zombie.harm = 5
Zombie.speed = 10
