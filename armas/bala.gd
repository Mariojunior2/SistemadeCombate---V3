extends Node2D

const SPEED := 300
var shooter: CharacterBody2D = null  # variável para guardar quem atirou

func _ready():
	$DamageArea.connect("area_entered", Callable(self, "_on_area_entered"))
	print("Shooter da bala é: ", shooter)

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_owner()

	if enemy == null:
		return

	if enemy == self:
		return

	if enemy.is_in_group("enemy") and enemy.has_method("take_damage"):
		enemy.take_damage(shooter, self)  # Passa shooter explicitamente
		queue_free()
