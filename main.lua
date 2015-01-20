cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
require "cocos.init"
require "Role/Zombie"
require "Scene/Village"
require "Scene/DragLayer"
require "Util/LogUtil"

local function initGLView()
    local director = cc.Director:getInstance()
    local glView = director:getOpenGLView()
    if nil == glView then
        glView = cc.GLViewImpl:create("Zombie infection")
        director:setOpenGLView(glView)
    end

    director:setOpenGLView(glView)
    glView:setDesignResolutionSize(900, 600, cc.ResolutionPolicy.NO_BORDER)

    --turn on display FPS
    director:setDisplayStats(true)
	--director:setProjection(cc.DIRECTOR_PROJECTION2_D )

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
end

local function main()
	 -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    initGLView()
	
	-- load scene
	local sceneGame = cc.Scene:create()
	
	--load map
	local map = VillageMap.new()
	
	-- load zombie
	local zombieSprite = Zombie.new()
	map:addChild(zombieSprite, 1)
	zombieSprite:retain()
	--test run
	--[[
	local  move = cc.MoveBy:create(10, cc.p(400,450))
    local  back = move:reverse()
    local  seq = cc.Sequence:create(move, back)
    zombieSprite:runAction( cc.RepeatForever:create(seq))
	]]

	--load blood
	local blood = cc.Sprite:create("effect/blood.png")
	blood:setOpacity(0)
	
	--add to container
	local container = DragLayer:new(map, zombieSprite, blood)
	
	map:addChild(blood, 1)
	container:addChild(map)
	sceneGame:addChild(container)
	
    cc.Director:getInstance():runWithScene(sceneGame)
end

xpcall(main, __G__TRACKBACK__)