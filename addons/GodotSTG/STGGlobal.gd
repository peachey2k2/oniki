extends Node
const POOL_CAP = 5000
var controller:Node

func repool(bullet:STGBullet):
	bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet.hide()
	bullet.get_parent().remove_child(bullet)
	controller.pools[bullet.index].append(bullet)
