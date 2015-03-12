local Stage1 = {}

--设定僵尸初始化参数
Stage1.zombie = {
	x = 7,
	y = 5,
	life = 60,
	harm = 8,
	speed = 1.5,
	harmFar = 0,
	isHealthy = 0,
}

--设定普通人的初始化参数
Stage1.man = {
	life = 50,
	harm = 3,
	speed = 1.6,
	isHealthy = 3,
	attackSpeed = 1.8
}

--设定警察初始化参数
Stage1.superman = {
	life = 50,
	harm = 5,
	harmFar = 2,
	speed = 1.6,
	isHealthy = 3,
	attackSpeed = 2
}

--设定尸化人
Stage1.infectedman = {
	life = 30,
	harm = 5,
	speed = 1.6,
	isHealthy = 0,
}

Stage1.infectedsuperman = {
	life = 30,
	harm = 5,
	speed = 1.8,
	isHealthy = 0,
}
--设定个数
Stage1.manNum = 1
Stage1.supermanNum = 1

--设定巡逻路径
Stage1.path = {
	{{11,6}, {12,6}, {13,6}},
	{{12,9}, {13,9}}
}

--设定地图
Stage1.map = "map/map1.tmx"
Stage1.mapHeight = 600
Stage1.mapWidth = 920
Stage1.tileSize = 40

return Stage1