require "Util/LogUtil"
--´å×¯µØÍ¼

VillageMap = class("VillageMap", function()
	local tiledMap = cc.TMXTiledMap:create("map/map.tmx")
	
	local s = tiledMap:getContentSize()
    cclog("ContentSize: %f, %f", s.width,s.height)
	return tiledMap
end)