--添加一个可以拖动的图层

DragLayer = class("DragLayer")

DragLayer.isTouching = false
 

function DragLayer:new(mapNode, heroNode, pointerNode)
	local mapLayer = cc.Layer:create()
	DragLayer.map = mapNode
	DragLayer.zombie = heroNode
	DragLayer.blood = pointerNode
	DragLayer:setTouchable(mapLayer)
	return mapLayer
end

function DragLayer.setTouchable(self, layer)

    local function onTouchesMoved(touches, event )
		DragLayer.isTouching = false
        local diff = touches[1]:getDelta()
        if DragLayer.map ~= nil then	
			local currentPosX, currentPosY= DragLayer.map:getPosition()
			DragLayer.map:setPosition(cc.p(currentPosX + diff.x, currentPosY + diff.y))
		end
    end
	
	local function onTouchesBegan(touches, event )
        DragLayer.isTouching = true
    end
	
	local function onTouchesEnded(touches, event )
		if DragLayer.isTouching and DragLayer.zombie ~= nil and DragLayer.blood ~= nil then
			local location = touches[1]:getLocation()
			local deltaX, deltaY = DragLayer.map:getPosition()
			--走到点击的位置
			--动画
			DragLayer.blood:setPosition(cc.p(location.x - deltaX, location.y - deltaY))
			DragLayer.blood:runAction(cc.Sequence:create( cc.FadeIn:create(0.2), cc.FadeOut:create(2)))
			DragLayer.zombie:setPosition(cc.p(location.x - deltaX, location.y - deltaY))
		end
		DragLayer.isTouching = false
    end
	
	local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
	listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
	listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    return layer
end