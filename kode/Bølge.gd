extends Node2D

var opprinnelig_y

func _ready():
	opprinnelig_y = position.y

func _physics_process(delta):
	var sw = sin(OS.get_ticks_msec() * 0.01 + position.x)
	position.y = opprinnelig_y + 2 * sw