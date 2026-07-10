extends Control

var can_skip = false

func _ready():
	await get_tree().create_timer(1.5).timeout
	can_skip = true

func _input(event):
	if not can_skip:
		return
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			get_tree().change_scene_to_file("res://gameHubEEtc/Menu/vitoria.tscn")
