extends Node2D

@onready var vitoria_label: Label = $vitoria
@onready var moedas_label: Label = $MoedasLabel
@onready var balas_label: Label = $BalasLabel
@onready var comprar_bala_button: Button = $ComprarBalaButton
@onready var mensagem_loja: Label = $MensagemLoja
@onready var proxima_fase_button: Button = $ProximaFaseButton
@onready var sair_button: Button = $SairButton


func _ready() -> void:
	conectar_sinais()

	Global.coins_changed.connect(atualizar_moedas)
	Global.bullets_changed.connect(atualizar_balas)

	atualizar_moedas(Global.get_coins())
	atualizar_balas(Global.get_bullets())

	mensagem_loja.text = ""

	var segundos: int = int(Global.last_level_time)

	vitoria_label.text = (
		"Você venceu!\n"
		+ "Tempo: "
		+ str(segundos)
		+ " segundos\n"
		+ "Moedas recebidas: "
		+ str(Global.last_reward)
	)

	verificar_proxima_fase()


func conectar_sinais() -> void:
	if not comprar_bala_button.pressed.is_connected(
		_on_comprar_bala_button_pressed
	):
		comprar_bala_button.pressed.connect(
			_on_comprar_bala_button_pressed
		)

	if not proxima_fase_button.pressed.is_connected(
		_on_proxima_fase_button_pressed
	):
		proxima_fase_button.pressed.connect(
			_on_proxima_fase_button_pressed
		)

	if not sair_button.pressed.is_connected(
		_on_sair_button_pressed
	):
		sair_button.pressed.connect(
			_on_sair_button_pressed
		)


func atualizar_moedas(quantidade: int) -> void:
	moedas_label.text = (
		"Moedas: " + str(quantidade)
	)

	comprar_bala_button.disabled = (
		quantidade < Global.BULLET_PRICE
	)


func atualizar_balas(quantidade: int) -> void:
	balas_label.text = (
		"Balas: " + str(quantidade)
	)


func _on_comprar_bala_button_pressed() -> void:
	if Global.buy_bullet():
		mensagem_loja.text = (
			"Uma bala foi comprada!"
		)
	else:
		mensagem_loja.text = (
			"Você precisa de 3 moedas."
		)


func verificar_proxima_fase() -> void:
	var caminho := Global.get_next_level_path()

	if ResourceLoader.exists(caminho):
		proxima_fase_button.disabled = false
	else:
		proxima_fase_button.disabled = true
		proxima_fase_button.text = (
			"Próxima fase indisponível"
		)


func _on_proxima_fase_button_pressed() -> void:
	var caminho := Global.get_next_level_path()

	if not ResourceLoader.exists(caminho):
		mensagem_loja.text = (
			"A próxima fase ainda não existe."
		)
		return

	Global.save_game()

	get_tree().change_scene_to_file(caminho)


func _on_sair_button_pressed() -> void:
	Global.save_game()
	get_tree().quit()
