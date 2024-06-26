extends Area2D

@onready var animation_sprite = get_node("WeaponShaft/Pistol")
@onready var audio = $AudioStreamPlayer

#Obtiene la velocidad de ataque que tiene el jugador.
func _ready():
	animation_sprite.speed_scale = get_parent().atk_speed

#Verifica si un enemigo entro en el rango del arma
func _physics_process(delta):
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		animation_sprite.play("shoot")
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)
		if cos(rotation) > 0:
			animation_sprite.flip_v = false
		else:
			animation_sprite.flip_v = true

#Dispara una bala
func shoot():
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.dmg = get_parent().DAMAGE_RATE
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	audio.play(0)
	%ShootingPoint.add_child(new_bullet)

#Ejecuta Shoot(), cada que la animacion del arma termina
func _on_pistol_animation_looped():
	shoot()
	pass
