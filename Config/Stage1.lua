local Stage1 = {}

--�趨��ʬ��ʼ������
Stage1.zombie = {
	x = 7,
	y = 5,
	life = 60,
	harm = 8,
	speed = 1.5,
	harmFar = 0,
	isHealthy = 0,
}

--�趨��ͨ�˵ĳ�ʼ������
Stage1.man = {
	life = 50,
	harm = 3,
	speed = 1.6,
	isHealthy = 3,
	attackSpeed = 1.8
}

--�趨�����ʼ������
Stage1.superman = {
	life = 50,
	harm = 5,
	harmFar = 2,
	speed = 1.6,
	isHealthy = 3,
	attackSpeed = 2
}

--�趨ʬ����
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
--�趨����
Stage1.manNum = 1
Stage1.supermanNum = 1

--�趨Ѳ��·��
Stage1.path = {
	{{11,6}, {12,6}, {13,6}},
	{{12,9}, {13,9}}
}

--�趨��ͼ
Stage1.map = "map/map1.tmx"
Stage1.mapHeight = 600
Stage1.mapWidth = 920
Stage1.tileSize = 40

return Stage1