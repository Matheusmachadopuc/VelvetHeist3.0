extends StaticBody2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Você venceu!")

		# Troca para tela de vitória
		if Global.current_level == 4:
			get_tree().change_scene_to_file("res://historia/vitoria_tela.tscn")
		else:
			get_tree().change_scene_to_file("res://gameHubEEtc/Menu/vitoria.tscn")
