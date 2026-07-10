extends PathFollow2D

@export var speed: float = 150.0

# Velocidade máxima da rotação, em graus por segundo
@export var velocidade_giro_maxima: float = 220.0

# Quanto tempo o inimigo demora para ganhar/perder velocidade de giro
@export var aceleracao_giro: float = 700.0

# Define o quanto ele tenta acompanhar rapidamente a direção
@export var resposta_giro: float = 6.0

# Correção da direção do desenho do inimigo
@export var ajuste_sprite: float = -90.0

@onready var inimigo: Node2D = $inimigo

var velocidade_angular: float = 0.0


func _ready():
	# Impede o PathFollow2D de girar instantaneamente
	rotates = false


func _process(delta: float) -> void:
	if not is_instance_valid(inimigo):
		set_process(false)
		return

	# Normalize the enemy global scale to match fase1 size (approx 0.48)
	inimigo.global_scale = Vector2(0.48, 0.48)

	# Guarda a posição antes de andar
	var posicao_anterior = global_position

	# Calculate speed compensation factor based on parent's scale
	var parent_scale = get_parent().scale
	var scale_factor = (parent_scale.x + parent_scale.y) / 2.0
	if scale_factor <= 0.0:
		scale_factor = 1.0

	# Move pelo caminho (compensated speed)
	progress += (speed / scale_factor) * delta

	# Descobre para qual direção o inimigo está andando
	var movimento = global_position - posicao_anterior
	
	if inimigo.has_method("update_animation"):
		inimigo.update_animation(movimento)                                                                                                                                            
		if movimento.length_squared() < 0.001:
			return

	if movimento.length_squared() < 0.001:
		return

	var angulo_alvo = movimento.angle() + deg_to_rad(ajuste_sprite)

	# Menor distância entre o ângulo atual e o ângulo desejado
	var diferenca_angulo = wrapf(
		angulo_alvo - inimigo.global_rotation,
		-PI,
		PI
	)

	var giro_maximo = deg_to_rad(velocidade_giro_maxima)
	var aceleracao = deg_to_rad(aceleracao_giro)

	# Quanto ele deveria estar girando neste momento
	var velocidade_desejada = clamp(
		diferenca_angulo * resposta_giro,
		-giro_maximo,
		giro_maximo
	)

	# Acelera ou desacelera gradualmente
	velocidade_angular = move_toward(
		velocidade_angular,
		velocidade_desejada,
		aceleracao * delta
	)

	# Evita ultrapassar o ângulo desejado
	var passo_giro = min(
		abs(velocidade_angular) * delta,
		abs(diferenca_angulo)
	)

	inimigo.global_rotation = rotate_toward(
		inimigo.global_rotation,
		angulo_alvo,
		passo_giro
	)
