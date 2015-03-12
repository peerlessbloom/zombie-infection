require "Util/LogUtil"
require "Util/FindPathUtil"
require "Util/MapUtil"
require "Res/GameRes"
--村庄地图

MapLayer = class("MapLayer")

function MapLayer:create(path)
	local s = MapLayer.new()
	s:init(path)
	return s
end

function MapLayer:init(path)
	self.tiledMap = cc.TMXTiledMap:create(path)	
	
	
	local buildingLayer = self.tiledMap:getLayer("building")
	local layerS = buildingLayer:getLayerSize()
	local map = {}
	for i = 0, layerS.width - 1 do
		map[i + 1] = {}
		for j = 0, layerS.height - 1 do
			map[i + 1][j + 1] = buildingLayer:getTileGIDAt(cc.p(i, j))
		end
	end
	self:setPosition(0, 0)
	self.astar = AStarMap.new(layerS.width, layerS.height, map)--用于寻路的类
end

-----------------------tiledMap部分-----------------------
function MapLayer:addChild(layer, i)
	local mapOrder = GameRes:getInstance().mapOrder
	mapOrder[layer] = mapOrder["pos"]
	mapOrder["pos"] = mapOrder["pos"] + 1
	self.tiledMap:addChild(layer, i)
end

function MapLayer:setPosition(x, y)
	self.tiledMap:setPosition(cc.p(x, y))
end

function MapLayer:getPosition()
	return self.tiledMap:getPosition()
end

function MapLayer:move(x, y, t)
	t = t or 1
	self.tiledMap:runAction( cc.Sequence:create( cc.MoveTo:create(t , cc.p(x, y))))
end

--------------------A*部分-----------------------------
function MapLayer:isValid(x, y)
	return self.astar:isValid(x, y)
end

function MapLayer:findPath(from, to)
	self.astar:setStart(from[1], from[2])
	self.astar:setEnd(to[1], to[2])
	return self.astar:findPath()
end