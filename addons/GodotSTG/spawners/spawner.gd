@tool
# DEPRECATED!!! DO NOT USE LOOOOOOOOOOOOOOOOOOOOOOOOOOOL
class_name STGSpawnerNode extends Node2D

var index:int
var tex:Texture2D
var data:STGSpawner:
	set(val):
		data = val
		index = data.bullet.index
		tex = STGGlobal.textures[data.bullet.id]

func spawn_bullet(pos, vel, acc):
	var _data = STGGlobal.bdata[index].duplicate()
	_data.position = pos
	_data.velocity = vel
	_data.acceleration = acc
	_data.lifespan = -1
	_data.texture = tex
	STGGlobal.create_bullet(_data)
