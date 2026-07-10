extends CanvasLayer

@export var phase_time_limit: float = 90.0 # Time limit for the phase in seconds

@onready var coins_label: Label = $Control/MarginContainer/HBoxContainer/CoinsContainer/CoinsLabel
@onready var timer_label: Label = $Control/MarginContainer/HBoxContainer/TimerContainer/TimerLabel

var timer_expired: bool = false

func _ready() -> void:
	# Connect to the global coins signal
	Global.coins_changed.connect(_on_coins_changed)
	
	# Check if current level has a custom time limit
	var level_root = get_tree().current_scene
	if level_root and "time_limit" in level_root:
		phase_time_limit = level_root.time_limit
	
	# Initial update
	_update_coins_display(Global.get_coins())

func _process(delta: float) -> void:
	if timer_expired:
		return
		
	# Calculate remaining time
	var elapsed_time = Global.get_level_time()
	var remaining_time = max(0.0, phase_time_limit - elapsed_time)
	
	_update_timer_display(remaining_time)
	
	if remaining_time <= 0.0:
		_on_timer_expired()

func _on_coins_changed(new_amount: int) -> void:
	_update_coins_display(new_amount)

func _update_coins_display(amount: int) -> void:
	if coins_label:
		coins_label.text = "Moedas: %d" % amount

func _update_timer_display(time_left: float) -> void:
	if timer_label:
		var minutes := int(time_left) / 60
		var seconds := int(time_left) % 60
		timer_label.text = "Tempo: %02d:%02d" % [minutes, seconds]
		
		# Optional visual alert if time is running out (e.g. less than 15 seconds)
		if time_left < 15.0:
			timer_label.modulate = Color.RED
		else:
			timer_label.modulate = Color.WHITE

func _on_timer_expired() -> void:
	timer_expired = true
	print("Tempo esgotado!")
	
	# Call die() on the player if present, or reload the scene
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		if player.has_method("die"):
			player.die()
		else:
			get_tree().reload_current_scene()
	else:
		get_tree().reload_current_scene()
