require "Res/GameRes"

IntroScene = class("IntroScene")

function IntroScene:create()
	local s = IntroScene.new()
	s:init()
	return s.scene
end


function IntroScene:init()
	self.scene = cc.Scene:create()
	local bg = GameRes:getInstance().bgGray
	bg:setAnchorPoint( 0, 0 )
	self.scene:addChild(bg, 0)
	local tt = GameRes:getInstance().title1
	tt:setPosition(200, 500)
	tt:setAnchorPoint( 0, 0 )
	self.scene:addChild(tt, 1)
	
	local people = GameRes:getInstance().cvsts
	local conversation = {"啊。。。好饿", "你是新僵尸吗？第一次见到你\n前面不远处有个村落，里面有不少人可以作为食物那",
						  "可是我害怕\n那么多人，如果发现我了就惨了", "普通村民看见你也会害怕的\n他们会逃跑，直到无路可逃时才会拼死一搏",
						  "真的吗？那不普通的村民是什么样的？", "你的视角真独特。。。\n不普通的村民会穿绿色的制服，别让他们看见，否则会吃子弹的",
						  "如何不被发现那？", "躲在树后面，树会遮挡村民的视野\n另外，里村民太远或者躲在他们后面都不会被发现",
						  "太棒了，那我真的要去饱餐一顿了", "还有一件事要告诉你\n选择吃掉村民，你可以变得更强；\n你也可以选择感染他们，这样你就有并肩作战的小伙伴啦",
						  "唔。。。那我得好好想想", "享受你的第二个人生吧！"}
	local index = 1
	local size = #(conversation)
	local msg = nil
	local p = nil
	
	local function getNext()
		if msg ~= nil then
			msg:getParent():removeChild(msg)
			p:getParent():removeChild(p)
			msg = nil
			p = nil
		end
		if index > size then
			return false
		end
				
		if index%2 == 1 then
			p = people[1]
			p:setAnchorPoint(0,0)
			p:setPosition(0,0)
			msg = GameRes:getInstance():getTalkBox(conversation[index], 200)
		else
			p = people[2]
			p:setAnchorPoint(0,0)
			p:setPosition(700,0)
			msg = GameRes:getInstance():getTalkBox(conversation[index])
		end
		msg:setAnchorPoint( 0, 0 )
		
		self.scene:addChild(msg, 1)
		self.scene:addChild(p, 2)
		index = index + 1
		return true
	end	

	local function goHome()
		cc.Director:getInstance():popScene()
	end
	
	local function onContinue()
		local res = getNext()
		if res == false then goHome() end
	end
	
	-- 注册键盘事件
    local eventDispatcher = self.scene:getEventDispatcher()
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onContinue, cc.Handler.EVENT_KEYBOARD_PRESSED)

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.scene)
	getNext()
		
	GameRes:getInstance():registerHomeFun(goHome)
	local home = GameRes:getInstance():getHomeMenu()
	home:setPosition(850, 550)
	self.scene:addChild(home)	
end
	