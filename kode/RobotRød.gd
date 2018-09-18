extends KinematicBody2D

var liv = 5
var hastighet = 100
var siste_retning = Vector2(-1,0)
var fallhastighet = 400
var fall = 0

var aktiv = false
var usaarbar = false

onready var eksplosjon_effekt = preload('res://grafikk/Eksplosjon.tscn')

func _ready():
	randomize()

func _process(delta):
	if aktiv:
		var flytt = siste_retning * hastighet
		
		if not is_on_floor():
			fall += fallhastighet * delta
			flytt.y += fall
		
		var flyttresultat = move_and_slide(flytt, Vector2(0, -1))
		
		if flyttresultat.x == 0:
			siste_retning.x *= -1
		
		if is_on_floor():
			fall = 0
		
		if usaarbar:
			$Sprite.modulate = Color(1, 1-$Skadetid.time_left, 1-$Skadetid.time_left)
	
		$Sprite.flip_h = siste_retning.x == -1
		if liv <= 0:
			$Doedtid.start()
			$Skadetrigger/CollisionShape2D2.disabled = true
			$Eksplosjonstid.start()
			aktiv = false
	elif $Eksplosjonstid.time_left > 0:
		$Sprite.modulate = Color(1,1,1,1-($Eksplosjonstid.time_left * 3))
	
func skade():
	if not usaarbar:
		liv -=1
		$Skadetid.start()
		usaarbar = true

func skade_stopp():
	$Sprite.modulate = Color(1, 1, 1)
	usaarbar = false

func eksploder():
	var eksplosjon = eksplosjon_effekt.instance()
	get_parent().add_child(eksplosjon)
	eksplosjon.global_position = Vector2(global_position.x + rand_range(-40, 40), global_position.y + rand_range(-40,40))
	eksplosjon.playing = true
	$Eksplosjonstid.start()
	
func forsvinn():
	$'../Nøkkel'.visible = true
	$'../Nøkkel/CollisionShape2D'.disabled = false
	queue_free()