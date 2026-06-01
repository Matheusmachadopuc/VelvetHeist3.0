extends CharacterBody2D

@export var bullet_scene: PackedScene 

var normal_speed = 300.0
var boost_speed = 600.0

var current_speed = normal_speed
var can_dash = true

var municao = 1;

@onready var raycast = $origemTiro/RayCast2D
@onready var laser_line = $origemTiro/RayCast2D/Line2D

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = direction * current_speed
	move_and_slide()
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		if municao > 0:
			shoot()
		
	# Rolagem / Dash
	if Input.is_action_just_pressed("rolar") and can_dash:
		dash()
		
	# Atualiza o laser
	update_laser()

	# 🔥 DETECÇÃO DA PORTA (NOVO)
	check_door_collision()


# 🔥 FUNÇÃO NOVA: detecta encostar na porta
func check_door_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("door"):
			call_deferred("win_game")


# 🔥 FUNÇÃO DE VITÓRIA
func win_game():
	print("Você venceu!")
	if get_tree():
		get_tree().change_scene_to_file("res://gameHubEEtc/Menu/vitoria.tscn")
func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $origemTiro.global_position
	bullet.global_rotation = global_rotation
	get_parent().add_child(bullet)
	municao = municao - 1


func update_laser():
	laser_line.clear_points()
	laser_line.add_point(Vector2.ZERO)
	
	if raycast.is_colliding():
		var collision_point = raycast.to_local(raycast.get_collision_point())
		laser_line.add_point(collision_point)
	else:
		laser_line.add_point(raycast.target_position)


func dash():
	can_dash = false
	
	current_speed = boost_speed
	
	await get_tree().create_timer(0.3).timeout
	
	current_speed = normal_speed
	
	await get_tree().create_timer(2.0).timeout
	
	can_dash = true


func die():
	get_tree().reload_current_scene()
