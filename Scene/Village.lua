require "Util/LogUtil"
--��ׯ��ͼ

VillageMap = class("VillageMap", function()
	local tiledMap = cc.TMXTiledMap:create("map/map.tmx")
	
	local s = tiledMap:getContentSize()
    cclog("ContentSize: %f, %f", s.width,s.height)
	return tiledMap
end)