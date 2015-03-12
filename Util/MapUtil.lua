--地图的相关计算

MapUtil = class("MapUtil")
--将地图中像素的点对应到地图上
function MapUtil:convert(x, y)
	return math.floor(x / self.tileSize) + 1, math.floor((self.mapHeight - y) / self.tileSize) + 1
end

--将地图中位置对应到像素
function MapUtil:convertBack(x, y)
	return (x - 1) * self.tileSize, self.mapHeight - (y - 1) * self.tileSize
end

function MapUtil:setConfig(config)
	self.tileSize = config.tileSize
	self.mapHeight = config.mapHeight
	self.mapWidth = config.mapWidth
end