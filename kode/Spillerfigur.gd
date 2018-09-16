extends KinematicBody2D

var hastighet = 200
var hopp = 0
var hopphastighet = 400
var fallhastighet = 400
var fall = 0

var animasjon = 0
var animasjonshastighet = 200
var animasjonstid = 0
var animasjonsretning = 1
var bytt_bilde = false

var poeng = 0

onready var kamera = $'../Camera2D'
onready var poengtekst = $'../Info/Poengtekst'

onready var glittereffekt = preload('res://grafikk/Glitter.tscn')

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	var flytt = Vector2(0,0)
	if Input.is_key_pressed(KEY_LEFT):
		flytt.x = -1 * hastighet
		animasjonsretning = -1
	elif Input.is_key_pressed(KEY_RIGHT):
		flytt.x = 1 * hastighet
		animasjonsretning = 1
	
	if Input.is_key_pressed(KEY_Z) and is_on_floor():
		hopp = hopphastighet
	
	if hopp > 0:
		flytt.y = -1 * hopp
		hopp -= 1
	
	if not is_on_floor():
		fall += fallhastighet * delta
		flytt.y += fall
	
	var flyttresultat = move_and_slide(flytt, Vector2(0,-1))
	
	if is_on_ceiling():
		hopp = 0
	elif is_on_floor():
		fall = 0
		hopp = 0
	
	var tid = OS.get_ticks_msec()
	if tid >= animasjonstid + animasjonshastighet:
		bytt_bilde = not bytt_bilde
		animasjonstid = tid
	
	if floor(flyttresultat.x) == 0 and flyttresultat.y <= 20:
		animasjon = 0
	elif abs(flyttresultat.y) >= 20:
		animasjon = 1
	else:
		animasjon = 2
		if bytt_bilde:
			animasjon = 3
	
	$Sprite.frame = animasjon
	$Sprite.scale.x = animasjonsretning
	
	kamera.position = position + Vector2(200 * animasjonsretning,0)
	poengtekst.bbcode_text = '[color=red]Poeng: ' + str(poeng) + '[/color]'

func kollisjon_med_objekt(trigger):
	var objekt = trigger.get_parent()
	if objekt.name.begins_with('Diamant'):
		var glitter = glittereffekt.instance()
		glitter.position = Vector2(0,0)
		glitter.emitting = true
		add_child(glitter)
		objekt.queue_free()
		poeng += 20