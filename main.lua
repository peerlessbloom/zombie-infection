cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
require "cocos.init"
require "Scene/LoadScene"
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
    --director:setDisplayStats(true)
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
	local s = LoadScene:create()
	
    cc.Director:getInstance():runWithScene(s)
end

xpcall(main, __G__TRACKBACK__)