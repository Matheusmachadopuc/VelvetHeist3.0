extends Node2D
extends Global

var time_elapsed := 0.0
var tempo_segundo

func _process(delta: float) -> void:
	# Increment time by the seconds passed since the last frame
	time_elapsed += delta
	tempo_segundo = int(time_elapsed)


	print(tempo_segundo)

Global.moedas = 
