--添加一个可以拖动的图层
require "Scene/PauseScene"
require "Scene/SuccessScene"
require "Scene/FailureScene"
require "GameManager"

InteractLayer = class("InteractLayer")

function InteractLayer:create(mapNode, heroNode, pointerNode, manVec)
	local s = InteractLayer.new()
	s:init(mapNode, heroNode, pointerNode, manVec)
	return s
end

function InteractLayer:init(mapNode, heroNode, pointerNode, manVec)
	self.mapLayer = cc.Layer:create()
	self.blood = pointerNode
	
	--addChild
	mapNode:addChild(pointerNode, 1)
	mapNode:addChild(heroNode:sprite(), 1)
	self.mapLayer:addChild(mapNode.tiledMap)
	for i = 1, #(manVec) do 
		mapNode:addChild(manVec[i]:sprite(), 1) 
	end
	
	self.isTouching = false
	self:setTouchable(self.mapLayer)
	self:setKeyboard(self.mapLayer)
	
	--set manager
	self.god = GameManager:create(heroNode, manVec, mapNode)
	heroNode.askGod = self.god
	for i = 1, #(manVec) do 
		manVec[i].askGod = self.god
	end		
end

----------------------------监听各种事件----------------------------------
function InteractLayer:setKeyboard(layer)
	local function go(keyCode)	
		local curTime = os.time()
		local preDir = self.dir
        if keyCode == 28 then --up
            self.dir = "u"
        elseif keyCode == 29 then --down
            self.dir = "d"
		elseif keyCode == 26 then --left
            self.dir = "l"
		elseif keyCode == 27 then --right
            self.dir = "r"
		end
		if preDir == self.dir and self.t ~= nil and self.t[1] == "g" and curTime - self.t[2] < 1 then return end
		self.t = {"g", curTime}
		if self.dir ~= "touch" then
			self.god:zombieGoDir(self.dir)
		end
	end
	
	local function attack(keyCode)
		local curTime = os.time()
		if self.t ~= nil and self.t[1] == "a" and curTime - self.t[2] < 1 then return end
		self.t = {"a", curTime}
		if keyCode == 124 then --A
			if self.god:zombieAttack() == false then self.t = nil end
		elseif keyCode == 142 then --S
			self.god:zombieAttackFar()
		end
	end
	
	local function onKeyPressed(keyCode, event)
        if keyCode == 28 or keyCode == 29 or keyCode == 26 or keyCode == 27 then
            go(keyCode)
		elseif keyCode == 124 or keyCode == 142 then
			attack(keyCode)
		else
			cclog(keyCode)
			cc.Director:getInstance():pushScene(PauseScene:create())
		end
    end

    local function onKeyReleased(keyCode, event)
		if keyCode == 28 and self.dir == "u" or --up
           keyCode == 29 and self.dir == "d" or --down
           keyCode == 26 and self.dir == "l" or --left
           keyCode == 27 and self.dir == "r" then --right
			self.god:zombieStop()
			--self.dir = nil
		end
    end

    -- 注册键盘事件
    local eventDispatcher = layer:getEventDispatcher()
    local listener = cc.EventListenerKeyboard:create()

    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function InteractLayer:setTouchable(layer)
	--拖拽事件
    local function onTouchesMoved(touches, event )
		self.isTouching = false
        local diff = touches[1]:getDelta()
		self.god:dragMap(diff)
    end
	
	local function onTouchesBegan(touches, event )
        self.isTouching = true
    end
	
	--点击事件：自动寻路
	local function onTouchesEnded(touches, event )
		if self.isTouching then
			local location = touches[1]:getLocation()
			local deltaX, deltaY = self.god:getMapPosition()
			local touchpos = {location.x - deltaX, location.y - deltaY}
			self.dir = "touch"
			self.blood:setPosition(cc.p(touchpos[1], touchpos[2]))
			self.blood:runAction(cc.Sequence:create( cc.FadeIn:create(0.2), cc.FadeOut:create(2)))
			self.god:zombieGo(touchpos)
		end
		self.isTouching = false
    end
	--注册点击事件
	local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
	listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
	listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end