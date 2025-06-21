extends Node2D

const bala = preload("res://armas/bala.tscn")
var pode_atacar = true
var cooldown = 0.25

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

	if visible and Input.is_action_just_pressed("Attack_arm"):
		atirar()

func atirar():
	if not pode_atacar:
		return

	pode_atacar = false

	var bala_instancia = bala.instantiate()
	bala_instancia.shooter = get_parent() 
	bala_instancia.global_position = global_position
	bala_instancia.rotation = rotation
	get_tree().root.add_child(bala_instancia)


	iniciar_cooldown()

func iniciar_cooldown():
	await get_tree().create_timer(cooldown).timeout
	pode_atacar = true
