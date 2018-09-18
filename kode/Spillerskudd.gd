extends RigidBody2D

func kollisjon_med_objekt(body):
	if body.name.begins_with('Robot'):
		body.skade()
	queue_free()
