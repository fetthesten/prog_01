extends KinematicBody2D

var hastighet = 200
var hopp = 0
var hopphastighet = 400
var fallhastighet = 400
var skuddhastighet = 600
var fall = 0
var skaderetning = Vector2(0,0)

var animasjon = 0
var animasjonshastighet = 200
var animasjonstid = 0
var animasjonsretning = 1
var bytt_bilde = false

var poeng = 0
var liv = 3
var usaarbar = false
var spill_slutt = false

var skuddsperre = false
var bosstrigger = false
var noekkeltrigger = false

onready var kamera = $'../Camera2D'
onready var poengtekst = $'../Info/Poengtekst'
onready var livmaaler = $'../Info/Livmåler'
onready var spill_slutt_tekst = $'../Info/SpillSluttTekst'

onready var glittereffekt = preload('res://grafikk/Glitter.tscn')
onready var spillerskudd = preload('res://objekter/Spillerskudd.tscn')

func _process(delta):
	var flytt = Vector2(0,0)
	
	if spill_slutt:
		flytt.x = animasjonsretning * -1 * hastighet
		hopp = hopphastighet * $Skadetid.time_left
		if Input.is_key_pressed(KEY_Z) and $Skadetid.time_left <= 0:
			get_tree().reload_current_scene()
	else:
		if Input.is_key_pressed(KEY_LEFT):
			flytt.x = -1 * hastighet
			animasjonsretning = -1
		elif Input.is_key_pressed(KEY_RIGHT):
			flytt.x = 1 * hastighet
			animasjonsretning = 1
		
		if Input.is_key_pressed(KEY_Z) and is_on_floor():
			hopp = hopphastighet
		
		if Input.is_key_pressed(KEY_X) and not skuddsperre:
			skuddsperre = true
			$Skuddtid.start()
			var skudd = spillerskudd.instance()
			get_parent().add_child(skudd)
			skudd.global_position = global_position
			skudd.linear_velocity = Vector2(animasjonsretning * skuddhastighet, 0)
	
	if Input.is_key_pressed(KEY_ESCAPE):
			get_tree().quit()
				
	if usaarbar:
		var skadefarge = Color(1,1-$Skadetid.time_left,1-$Skadetid.time_left)
		$Sprite.modulate = skadefarge
	
	if hopp > 0:
		flytt.y = -1 * hopp
		hopp -= 1
	
	if not is_on_floor():
		fall += fallhastighet * delta
		flytt.y += fall
	

	var flyttresultat = move_and_slide(flytt, Vector2(0,-1))
	if skaderetning != Vector2(0,0):
		flyttresultat = move_and_slide(skaderetning * (hastighet * $Skadetid.time_left), Vector2(0,-1))

	if is_on_ceiling():
		hopp = 0
	elif is_on_floor():
		fall = 0
		hopp = 0

	if not spill_slutt:	
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
	
		kamera.position = position + Vector2(200 * animasjonsretning,-100)
		poengtekst.bbcode_text = '[color=red]Poeng: ' + str(poeng) + '[/color]'
	else:
		$Sprite.frame = 0
		$Sprite.rotate(delta * -animasjonsretning)
		
	if liv <= 0:
		avslutt_spill()		

func kollisjon_med_objekt(trigger):
	if trigger.name.begins_with('Bosstrigger') and not bosstrigger:
		$'../Bossrom/Bossvegg'.visible = true
		$'../Bossrom/Bossvegg/Sperre'.disabled = false
		$'../Bossrom/RobotRød'.aktiv = true
		bosstrigger = true
	elif trigger.name.begins_with('Nøkkel'):
		trigger.queue_free()
		noekkeltrigger = true
		$'../Bossrom/Utgangsdør/Sprite'.region_rect.position.x = 320
	elif trigger.name.begins_with('Utgangsdør') and noekkeltrigger:
		vinn_spill()
	else:
		var objekt = trigger.get_parent()
		if objekt.name.begins_with('Diamant'):
			var glitter = glittereffekt.instance()
			glitter.position = Vector2(0,0)
			glitter.emitting = true
			add_child(glitter)
			objekt.queue_free()
			poeng += 20
		elif objekt.name.begins_with('Robot'):
			if not usaarbar:
				start_skade()
				skaderetning = (global_position - objekt.global_position).normalized()
				
func start_skade():
	usaarbar = true
	$Skadetid.start()
	liv -= 1
	livmaaler.value = liv

func fjern_skadeindikator():
	usaarbar = false
	$Sprite.modulate = Color(1,1,1)
	skaderetning = Vector2(0,0)

func avslutt_spill():
	spill_slutt = true
	spill_slutt_tekst.bbcode_text = '[color=#ff8833]Du dævva!\nDu fikk ' + str(poeng) + ' poeng![/color]\n\nTrykk Z for å prøve igjen!'
	$Kollisjon.disabled = true
	fjern_skadeindikator()

func vinn_spill():
	var livbonus = liv * 100
	var tidsbonus = $'../Info/Bonusstripe'.value
	spill_slutt_tekst.bbcode_text = '[color=#66ff33]Gratulerer! Du vant spillet!\n\nPoeng: ' + str(poeng) + '\nLivbonus: ' + str(livbonus) + '\nTidsbonus: ' + str(tidsbonus) + '\nTotalt ' + str(poeng + livbonus + tidsbonus) + ' poeng![/color]\n\nTrykk Z for å spille igjen!'
	spill_slutt = true
	$Sprite.visible = false
	
func kan_skyte():
	skuddsperre = false

func reduser_bonus():
	if $'../Info/Bonusstripe'.value > 0:
		$'../Info/Bonusstripe'.value -= 1
		$Bonustid.start()
	
