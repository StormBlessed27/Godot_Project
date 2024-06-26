extends Node2D

@export var mobs_max = 100
@export var bajas_objeto :=10

@onready var timer_mobs = $Player/Path2D/Timer


var cant_mobs :=0
var jefes_muertos := 0
var bajas_totales:=0
var racha_bajas:=0

var jefe

var pause_menu

var paused := false

#Carga el personaje seleccionado
func  _ready():
	%Player.char_name = GLOBAL.character[GLOBAL.selected_char]
	match GLOBAL.character[GLOBAL.selected_char]:
		"rolo":
			%Player.health = 5
			%Player.speed = 300
		"paisa":
			%Player.health = 3
			%Player.speed = 350
		"costeno":
			%Player.health = 7
			%Player.speed = 250
	GLOBAL.maxHealth = %Player.health
	%Player.emit_signal("player_ready")

func _process(delta):
	if jefes_muertos == 5:
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
	if Input.is_action_just_pressed("pause"):
		paused_menu()

#Genera un mob aleatorio para spawnear
func random_mob():
	var new_zombie= preload("res://scenes/zombie.tscn").instantiate()
	var new_esqueleto= preload("res://scenes/esqueleto.tscn").instantiate()
	const Gameover=preload("res://scenes/game_over.tscn")
	var rand = randi_range(1,2)
	if	rand == 1:
		return new_esqueleto
	else:
		return new_zombie

#Spawnea un mob
func spawn_mobs():
	
		var new_mob = random_mob()
		%PathFollow2D.progress_ratio=randf()
		new_mob.global_position = %PathFollow2D.global_position
		new_mob.mob_dead.connect(_on_mob_dead)
		add_child(new_mob)
		cant_mobs +=1

#Spawnea jefe
func spawn_jefe():
	if jefe == null:
		var new_jefe= preload("res://scenes/jefe.tscn").instantiate()
		%PathFollow2D.progress_ratio=randf()
		new_jefe.global_position = %PathFollow2D.global_position
		jefe=new_jefe
		jefe.jefe_dead.connect(_on_jefe_dead)
		add_child(jefe)
	else:
		pass

#Spawnea uno de 2 objetos defensivos
func spawn_defensive_object(mob):
	var rng = randi_range(1,2)
	match rng:
		1:
			var shield = preload("res://scenes/shield.tscn").instantiate()
			shield.global_position = mob.global_position
			add_child(shield)
			pass
		2:
			var boots = preload("res://scenes/boots.tscn").instantiate()
			boots.global_position = mob.global_position
			add_child(boots)
			pass
	pass

#Spawnea uno de 3 objetos ofensivos
func spawn_ofensive_object(mob):
	var rng = randi_range(1,3)
	match rng:
		1:
			var atk_speed = preload("res://scenes/attack_speed.tscn").instantiate()
			atk_speed.global_position = mob.global_position
			add_child(atk_speed)
			pass
		2:
			var dmg_up = preload("res://scenes/damage_up.tscn").instantiate()
			dmg_up.global_position = mob.global_position
			add_child(dmg_up)
			pass
		3:
			var add_gun = preload("res://scenes/add_gun.tscn").instantiate()
			add_gun.global_position = mob.global_position
			add_child(add_gun)
			pass
	pass

#Spawnea un objeto defensivo o uno objeto ofensivo
func spawn_object(mob):
	var objeto = randi_range(1,2)
	match objeto:
		1:
			spawn_defensive_object(mob)
		2:
			spawn_ofensive_object(mob)
	pass

#Pausa el juego y despliega el menu de pausa
func paused_menu():
	if paused:
		pause_menu.queue_free()
		get_tree().paused = false
	else:
		pause_menu = preload("res://scenes/pause_scene.tscn").instantiate()
		pause_menu.resume.connect(_on_resume)
		pause_menu.exit.connect(_on_exit)
		add_child(pause_menu)
		get_tree().paused = true
		pass
	paused = !paused

#Llama la funcion spawn_mobs() cada cierto tiempo
func _on_timer_timeout():
	spawn_mobs()
	pass

#Se ejecuta cuando el jugador muere.
func _on_player_death():
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

#Se ejecuta cada que el jugador acaba con un jefe
func _on_jefe_dead():
	jefes_muertos+=1
	pass

#Aumenta la velocidad de los mobs hasta un limite
func increase_mobs_speed():
	if GLOBAL.mobs_speed < 250:
		GLOBAL.mobs_speed += 10
	elif GLOBAL.mobs_speed > 250:
		GLOBAL.mobs_speed = 250

func increase_mobs():
	if $Player/Path2D/Timer.wait_time <=0.2:
		$Player/Path2D/Timer.wait_time = 0.2
	else:
		$Player/Path2D/Timer.wait_time -=0.2

#Se ejecuta cada que un mob es derrotado
func _on_mob_dead(mob):
	cant_mobs -=1
	bajas_totales +=1
	racha_bajas +=1
	if racha_bajas == bajas_objeto:
		increase_mobs_speed()
		racha_bajas = 0
		bajas_objeto += 5
		spawn_object(mob)

#Llama a la funcion spawn_jefe() cada cierto tiempo
func _on_spawn_jefe_timeout():
	spawn_jefe()

#Reanuda el juego
func _on_resume():
	paused_menu()
#Regresa a la pantalla principal
func _on_exit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_player_new_gun():
	increase_mobs()
	pass # Replace with function body.
