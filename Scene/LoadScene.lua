require "Scene/MainScene"
require "Res/GameRes"

LoadScene = class("LoadScene")

function LoadScene:create()
	local s = LoadScene.new()
	s:init()
	return s.scene
end


function LoadScene:init()
	local function showMessageBox(sprite)
		self.messageBox = GameRes:getInstance():getMessageBox("按任何按键进入游戏...")
		self.messageBox:setAnchorPoint( 0.5, 1 )
		self.messageBox:setPosition( 450, 450 )
		self.scene:addChild(self.messageBox, 1)
		self.messageBox:setOpacity(0)
		self.messageBox:runAction(cc.Sequence:create( cc.FadeIn:create(1), 
											     cc.RotateBy:create(1, 10),
												 cc.RotateBy:create(0.5, -5),
												 cc.RotateBy:create(0.5, 3)
						 )
					)
	
	end
	
	self.scene = cc.Scene:create()
	local bg = GameRes:getInstance().bg
	self.title = GameRes:getInstance().title
	bg:setAnchorPoint( 0, 0 )
	self.title:setAnchorPoint(0,0)
	self.title:setPosition(0, 700)
	self.scene:addChild(bg, 0)
	self.scene:addChild(self.title, 0)
	self.title:runAction(cc.Sequence:create( cc.MoveBy:create(2, cc.p(0, -700)),
										cc.CallFunc:create(showMessageBox)
						 )
					)
	
	local function replaceScene()
		cc.Director:getInstance():replaceScene(MainScene:create())
	end
	
	local function onContinue()
		self.title:runAction(cc.Sequence:create( cc.MoveBy:create(2, cc.p(0, 150))))
		self.messageBox:runAction(cc.Sequence:create( cc.MoveBy:create(2, cc.p(0, -700)), 
												 cc.CallFunc:create(replaceScene)
						 )
					)
	end
	
	-- 注册键盘事件
    local eventDispatcher = self.scene:getEventDispatcher()
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onContinue, cc.Handler.EVENT_KEYBOARD_PRESSED)

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.scene)
end


	