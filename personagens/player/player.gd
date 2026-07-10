extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var tempo_lanterna_desligada: float = 5.0

@export var normal_speed: float = 300.0
@export var boost_speed: float = 450.0

@export var intensidade_oscilacao: float = 0.05 # teste
@export var velocidade_oscilacao: float = 5.0 # teste

@export_range(0.0, 1.0) var chance_falha_por_segundo: float = 0.05

var energia_original_lanterna: float
var falha_ativa: bool = false
var multiplicador_falha: float = 1.0

var inimigos_no_cone: Array = []

var current_speed: float
var can_dash: bool = true
var municao: int = 1

var ultima_direcao: String = "down"

@onready var point_light: PointLight2D = $origemTiro/PointLight2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var origem_tiro: Node2D = $origemTiro
@onready var raycast: RayCast2D = $origemTiro/RayCast2D
@onready var laser_line: Line2D = $origemTiro/RayCast2D/Line2D
@onready var som_tiro: AudioStreamPlayer = $SomTiro



func _ready():
	current_speed = normal_speed
	energia_original_lanterna = point_light.energy #teste

	for inimigo in get_tree().get_nodes_in_group("enemy"):
		print("Nome:", inimigo.name)


		if inimigo.has_node("Polygon2D"):
			inimigo.get_node("Polygon2D").visible = false
		else:
			print("NÃO TEM Polygon2D!")

		if inimigo.has_node("PointLight2D"):
			inimigo.get_node("PointLight2D").visible = false


func _physics_process(_delta):
	get_8way_input()

	# Primeiro gira a arma, o RayCast e a lanterna.
	origem_tiro.look_at(get_global_mouse_position())

	# Depois escolhe a animação pela direção da mira.
	animate()

	move_and_slide()

	verificar_inimigos_visiveis()

	if Input.is_action_just_pressed("shoot"):
		shoot()

	if Input.is_action_just_pressed("rolar") and can_dash:
		dash()

	check_door_collision()


func move_8way():
	get_8way_input()
	animate()
	move_and_slide()


func get_8way_input():
	var input_direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = input_direction * current_speed


func animate():
	var direcao_mira: Vector2 = (
		get_global_mouse_position() - global_position
	).normalized()

	var nova_animacao: String

	if abs(direcao_mira.x) > abs(direcao_mira.y):
		if direcao_mira.x > 0:
			nova_animacao = "right"
		else:
			nova_animacao = "left"
	else:
		if direcao_mira.y > 0:
			nova_animacao = "down"
		else:
			nova_animacao = "up"

	ultima_direcao = nova_animacao

	if velocity == Vector2.ZERO:
		sprite.animation = ultima_direcao
		sprite.stop()
	else:
		if sprite.animation != ultima_direcao:
			sprite.play(ultima_direcao)
		elif not sprite.is_playing():
			sprite.play(ultima_direcao)


func verificar_inimigos_visiveis():
	for inimigo in inimigos_no_cone.duplicate():
		if not is_instance_valid(inimigo):
			inimigos_no_cone.erase(inimigo)
			continue

		var detectado: bool = pode_ver(inimigo)

		inimigo.set_meta("detectado", detectado)

		var cone = inimigo.get_node_or_null("Polygon2D")
		var luz = inimigo.get_node_or_null("PointLight2D")

		if cone:
			cone.visible = detectado

		if luz:
			luz.visible = detectado


func shoot():
	if bullet_scene == null:
		print("ERRO: bullet_scene não foi configurada.")
		return

	if not Global.consume_bullet():
		print("SEM MUNIÇÃO!")
		return
		
	$AudioStreamPlayer2.play()

	var bullet = bullet_scene.instantiate()

	get_parent().add_child(bullet)

	bullet.global_transform = origem_tiro.global_transform

	print("ATIROU")
	print("Balas restantes:", Global.get_bullets())


func dash():
	can_dash = false
	current_speed = boost_speed

	await get_tree().create_timer(0.3).timeout

	if not is_inside_tree():
		return

	current_speed = normal_speed

	await get_tree().create_timer(2.0).timeout

	if not is_inside_tree():
		return

	can_dash = true


func check_door_collision():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if is_instance_valid(collider) and collider.is_in_group("door"):
			call_deferred("win_game")
			return


var vitoria_processada: bool = false


func win_game():
	if vitoria_processada:
		return

	vitoria_processada = true

	var recompensa: int = Global.finish_level()

	print("Você venceu!")
	print("Tempo:", Global.last_level_time)
	print("Moedas recebidas:", recompensa)
	print("Total de moedas:", Global.get_coins())

	get_tree().change_scene_to_file(
		"res://gameHubEEtc/Menu/vitoria.tscn"
	)

func die():
	get_tree().reload_current_scene()


func _on_area_2d_body_entered(body):
	print("ENTROU:", body.name)

	if body.is_in_group("enemy"):
		print("ADICIONADO!")

		if not inimigos_no_cone.has(body):
			inimigos_no_cone.append(body)


func _on_area_2d_body_exited(body):
	print("SAIU:", body.name)

	if body.is_in_group("enemy"):
		inimigos_no_cone.erase(body)

		if body.has_node("Polygon2D"):
			body.get_node("Polygon2D").visible = false

		if body.has_node("PointLight2D"):
			body.get_node("PointLight2D").visible = false


func pode_ver(inimigo) -> bool:
	if not is_instance_valid(inimigo):
		return false

	var space = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		inimigo.global_position
	)

	query.exclude = [self]

	var resultado = space.intersect_ray(query)

	print("Resultado:", resultado)

	if resultado.is_empty():
		return true

	var collider = resultado.get("collider")

	if not is_instance_valid(collider):
		return false

	print("Colidiu com:", collider.name)

	return collider == inimigo

func _process(delta: float) -> void:
	var tempo := Time.get_ticks_msec() / 1000.0
	var oscilacao := sin(tempo * velocidade_oscilacao)

	var energia_com_oscilacao := energia_original_lanterna + (
		oscilacao * intensidade_oscilacao
	)

	point_light.energy = max(
		0.0,
		energia_com_oscilacao * multiplicador_falha
	)

	# A multiplicação por delta deixa a chance independente do FPS.
	if not falha_ativa:
		if randf() < chance_falha_por_segundo * delta:
			iniciar_falha_lanterna()



func iniciar_falha_lanterna() -> void:
	if falha_ativa:
		return

	falha_ativa = true

	# Pisca antes de apagar.
	var piscadas_antes := randi_range(3, 6)

	for i in range(piscadas_antes):
		# Lanterna fica fraca.
		multiplicador_falha = randf_range(0.05, 0.25)

		await get_tree().create_timer(
			randf_range(0.04, 0.10)
		).timeout

		if not is_inside_tree():
			return

		# Lanterna volta por um instante.
		multiplicador_falha = 1.0

		await get_tree().create_timer(
			randf_range(0.04, 0.15)
		).timeout

		if not is_inside_tree():
			return

	# Apaga completamente.
	multiplicador_falha = 0.0
	point_light.enabled = false

	# Fica apagada por 5 segundos.
	await get_tree().create_timer(
		tempo_lanterna_desligada
	).timeout

	if not is_inside_tree():
		return

	# Liga o PointLight, mas ainda sem intensidade.
	point_light.enabled = true
	multiplicador_falha = 0.0

	# Pisca várias vezes ao voltar.
	var piscadas_volta := randi_range(4, 7)

	for i in range(piscadas_volta):
		# Acende com intensidade irregular.
		multiplicador_falha = randf_range(0.15, 1.0)

		await get_tree().create_timer(
			randf_range(0.04, 0.12)
		).timeout

		if not is_inside_tree():
			return

		# Apaga novamente.
		multiplicador_falha = 0.0

		await get_tree().create_timer(
			randf_range(0.04, 0.16)
		).timeout

		if not is_inside_tree():
			return

	# Volta definitivamente ao normal.
	multiplicador_falha = 1.0
	point_light.enabled = true
	falha_ativa = false


func _on_animated_sprite_2d_frame_changed():
	if velocity == Vector2.ZERO:
		return     
	var animacoes_de_movimento: Array = ["up", "down", "left", "right"]  
	if sprite.animation in animacoes_de_movimento:       
		if sprite.frame in [1, 2, 4]:
			if has_node("AudioStreamPlayer"):
				$AudioStreamPlayer.pitch_scale = randf_range(0.8, 1.2)
				$AudioStreamPlayer.play()
