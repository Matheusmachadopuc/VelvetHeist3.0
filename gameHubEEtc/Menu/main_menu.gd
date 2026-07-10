extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://fases/fase1.tscn"
	)


func _on_button_2_pressed() -> void:
	#Global.save_game()
	get_tree().quit()
