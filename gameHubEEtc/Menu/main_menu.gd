extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://historia/cutscene.tscn"
	)


func _on_button_2_pressed() -> void:
	Global.save_game()
	get_tree().quit()
