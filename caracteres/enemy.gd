extends CharacterBody2D

@export var max_health := 10
@export var normal_speed := 30.0
@export var alert_speed := 60.0
@export var enraged_speed := 100.0
@export var attack_range := 40.0
@export var damage_amount := 1

var current_health: int
var is_alert := false
var is_enraged := false
var attack_timer := 0.0
var direction := 1
var player: CharacterBody2D = null

var is_attacking := false
var attack_stage := 1  # 1 = primeiro ataque (0.6s), 2 = demais (0.3s)

func _ready():
	current_health = max_health
	$Hurtbox.connect("area_entered", Callable(self, "_on_Hurtbox_area_entered"))
	$HitBoxDamage.connect("body_entered", Callable(self, "_on_HitBoxDamage_body_entered"))
	$HitBoxDamage.connect("body_exited", Callable(self, "_on_HitBoxDamage_body_exited"))

func _physics_process(delta):
	if current_health <= 0:
		return

	velocity = Vector2.ZERO

	if is_alert and player and is_instance_valid(player):
		var dir_vector = (player.global_position - global_position).normalized()
		var distance = global_position.distance_to(player.global_position)

		var speed = normal_speed
		if is_enraged:
			speed = enraged_speed
		elif is_alert:
			speed = alert_speed

		velocity = dir_vector * speed

		if abs(dir_vector.x) > 0.1:
			$AnimatedSprite2D.flip_h = dir_vector.x < 0

		if distance <= attack_range and not is_attacking:
			start_attack_sequence()
	else:
		patrol()

	move_and_slide()

func patrol():
	velocity.x = normal_speed * direction
	velocity.y = 0
	$AnimatedSprite2D.play("walk")
	$AnimatedSprite2D.flip_h = direction < 0

	if is_on_wall():
		direction *= -1

func start_attack_sequence():
	is_attacking = true
	attack_timer = 0.6 if attack_stage == 1 else 0.3
	$AnimatedSprite2D.play("attack")

	if player and is_instance_valid(player) and player.has_method("take_damage"):
		await get_tree().create_timer(0.2).timeout
		player.take_damage(damage_amount)
		print("Inimigo causou dano ao player!")

	await get_tree().create_timer(attack_timer).timeout

	if is_alert and is_instance_valid(player):
		is_attacking = false
		attack_stage = 2
	else:
		is_attacking = false
		attack_stage = 1
		$AnimatedSprite2D.play("idle")

func take_damage(source = null, area = null):
	current_health -= 1
	print("Inimigo recebeu dano! HP: ", current_health)
	print("Source:", source, "Area:", area)

	if source and source.is_in_group("player") and source is CharacterBody2D:
		player = source
		is_alert = true
		print("Player definido por dano recebido direto do source!")

	elif area and area.has_method("get_owner"):
		var area_owner = area.get_owner()
		if area_owner and area_owner.is_in_group("player") and area_owner is CharacterBody2D:
			player = area_owner
			is_alert = true
			print("Player definido por dano recebido do owner da area!")

	if not player or not is_instance_valid(player):
		player = null
		is_alert = false

	if area and area.is_in_group("bullet"):
		is_enraged = true
		print("Inimigo enfurecido por bala!")

	if current_health <= 0:
		die()


func die():
	print("Inimigo derrotado.")
	queue_free()

func _on_Hurtbox_area_entered(area):
	var source = null
	if area.has_method("get_owner"):
		source = area.get_owner()
	take_damage(source, area)

func _on_HitBoxDamage_body_entered(body):
	if body.is_in_group("player"):
		var current = body
		while current and not current is CharacterBody2D:
			current = current.get_parent()

		if current and current.has_method("take_damage"):
			player = current
			is_alert = true
			print("DEBUG: player entrou na área, inimigo está alerta:", player.name)

func _on_HitBoxDamage_body_exited(body):
	# Não cancelamos alerta ou perseguição ao sair da área
	pass
