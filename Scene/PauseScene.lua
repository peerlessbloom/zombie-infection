require "Res/GameRes"

PauseScene = class("PauseScene")

function PauseScene:create()
	local s = PauseScene.new()
	s:init()
	return s.scene
end


function PauseScene:init()
	self.scene = cc.Scene:create()
	local bg = GameRes:getInstance().bgGray
	bg:setAnchorPoint( 0, 0 )
	self.scene:addChild(bg, 0)
	local tt = GameRes:getInstance().title1
	tt:setPosition(200, 500)
	tt:setAnchorPoint( 0, 0 )
	self.scene:addChild(tt, 1)
	
	local function goHome()
		cc.Director:getInstance():popScene()
		cc.Director:getInstance():popScene()
	end
	
	GameRes:getInstance():registerHomeFun(goHome)
	local home = GameRes:getInstance():getHomeMenu()
	home:setPosition(850, 550)
	self.scene:addChild(home)	
	
	local messageBox = GameRes:getInstance():getMessageBox("按任何按键继续游戏...")
	messageBox:setAnchorPoint( 0.5, 1 )
	messageBox:setPosition( 450, 450 )
	self.scene:addChild(messageBox, 1)
	messageBox:setOpacity(0)
	messageBox:runAction(cc.Sequence:create( cc.FadeIn:create(0.5), 
											 cc.RotateBy:create(1, 10),
											 cc.RotateBy:create(0.5, -5),
											 cc.RotateBy:create(0.5, 3)
					 )
				)

	local function onContinue()
		cc.Director:getInstance():popScene()
	end
	
	-- 注册键盘事件
    local eventDispatcher = self.scene:getEventDispatcher()
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onContinue, cc.Handler.EVENT_KEYBOARD_PRESSED)

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.scene)
end


	