extends Node2D                                                                      
																					
var time_limit: float = 120.0 # Time limit in seconds (2 minutes) for Level 4       
																					
func _ready() -> void:                                                              
	Global.start_level(4)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
