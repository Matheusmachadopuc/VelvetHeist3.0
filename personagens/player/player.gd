extends CharacterBody2D

@export var bullet_scene: PackedScene 

var normal_speed = 300.0
var boost_speed = 600.0

var current_speed = normal_speed
var can_dash = true

var municao = 1;

# O @onready avisa o Godot para carregar esses nós assim que o jogo começar
@onready var raycast = $origemTiro/RayCast2D
@onready var laser_line = $origemTiro/RayCast2D/Line2D

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = direction * current_speed
	move_and_slide()
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		if(municao > 0):
			shoot()
		
		
	# Rolagem / Dash
	if Input.is_action_just_pressed("rolar") and can_dash:
		dash()
		
	# Atualiza o laser
	update_laser()

# Função que criamos para organizar o tiro
func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $origemTiro.global_position
	bullet.global_rotation = global_rotation
	get_parent().add_child(bullet)
	municao = municao - 1
	
	

# Função nova para desenhar o laser
func update_laser():
	# Limpa a linha antiga e define que o ponto inicial é o zero (no cano da arma)
	laser_line.clear_points()
	laser_line.add_point(Vector2.ZERO)
	
	# Se o raio invisível bater em uma parede...
	if raycast.is_colliding():
		# Pegamos a posição exata da batida e adicionamos como o fim da linha
		var collision_point = raycast.to_local(raycast.get_collision_point())
		laser_line.add_point(collision_point)
	else:
		# Se não bater em nada, a linha vai até o final
		laser_line.add_point(raycast.target_position)

# Função da rolagem
func dash():
	can_dash = false
	
	current_speed = boost_speed
	
	# Tempo da rolagem
	await get_tree().create_timer(0.3).timeout
	
	current_speed = normal_speed
	
	# Cooldown da rolagem
	await get_tree().create_timer(2.0).timeout
	
	can_dash = true
func die():
	get_tree().reload_current_scene()
