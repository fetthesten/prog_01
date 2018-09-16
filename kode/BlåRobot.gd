extends KinematicBody2D

var liv = 1
var hastighet = 200
var siste_retning = Vector2(-1,0)
var fallhastighet = 400
var fall = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	var flytt = siste_retning * hastighet
	
	if not is_on_floor():
		fall += fallhastighet * delta
		flytt.y += fall
	
	var flyttresultat = move_and_slide(flytt, Vector2(0, -1))
	
	if flyttresultat.x == 0:
		siste_retning.x *= -1
	
	if is_on_floor():
		fall = 0

	$Sprite.flip_h = siste_retning.x == -1