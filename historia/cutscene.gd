extends Control


@export var imagens_historia: Array[Texture2D]


@export var caminho_fase_jogo: String = "res://fases/Fase1.tscn" 

var quadro_atual: int = 0

@onready var imagem_tela = $TextureRect
@onready var som_efeito = $somEfeito

func _ready():

	if imagens_historia.size() > 0:
		imagem_tela.texture = imagens_historia[0]
		som_efeito.play()


func _on_button_pressed():
	# Avança para o próximo quadro
	quadro_atual += 1
	

	if quadro_atual < imagens_historia.size():
		imagem_tela.texture = imagens_historia[quadro_atual]
		som_efeito.play() # Toca o som a cada nova imagem
	else:

		get_tree().change_scene_to_file(caminho_fase_jogo)
