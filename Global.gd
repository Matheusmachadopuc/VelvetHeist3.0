extends Node

signal coins_changed(new_amount: int)
signal bullets_changed(new_amount: int)

const BULLET_PRICE: int = 3
const SAVE_PATH: String = "user://save.cfg"

# Valores usados apenas quando ainda não existe um save.
var _total_coins: int = 1
var _total_bullets: int = 1

var current_level: int = 1
var unlocked_level: int = 1

var _level_start_msec: int = 0

var last_reward: int = 0
var last_level_time: float = 0.0


func _ready() -> void:
	load_game()


func add_coins(amount: int) -> void:
	if amount <= 0:
		return

	_total_coins += amount
	coins_changed.emit(_total_coins)
	#save_game()


func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return false

	if _total_coins < amount:
		return false

	_total_coins -= amount
	coins_changed.emit(_total_coins)
	#save_game()

	return true


func get_coins() -> int:
	return _total_coins


func add_bullets(amount: int) -> void:
	if amount <= 0:
		return

	_total_bullets += amount
	bullets_changed.emit(_total_bullets)
	#save_game()


func get_bullets() -> int:
	return _total_bullets


func consume_bullet() -> bool:
	if _total_bullets <= 0:
		return false

	_total_bullets -= 1
	bullets_changed.emit(_total_bullets)
	##save_game()

	return true


func buy_bullet() -> bool:
	if _total_coins < BULLET_PRICE:
		return false

	_total_coins -= BULLET_PRICE
	_total_bullets += 1

	coins_changed.emit(_total_coins)
	bullets_changed.emit(_total_bullets)

	##save_game()

	return true


func start_level(level_number: int) -> void:
	current_level = level_number
	_level_start_msec = Time.get_ticks_msec()

	last_reward = 0
	last_level_time = 0.0

	if _total_bullets <= 0:
		_total_bullets=0
		bullets_changed.emit(get_bullets())
		#save_game()

func get_level_time() -> float:
	if _level_start_msec <= 0:
		return 0.0

	return (
		Time.get_ticks_msec() - _level_start_msec
	) / 1000.0


func finish_level() -> int:
	last_level_time = get_level_time()

	var reward: int = 0

	if last_level_time < 60.0:
		reward = 2
	elif last_level_time <= 90.0:
		reward = 1
	else:
		reward = 0

	last_reward = reward

	if reward > 0:
		_total_coins += reward
		coins_changed.emit(_total_coins)

	unlocked_level = max(
		unlocked_level,
		current_level + 1
	)

	#save_game()

	return reward


func get_next_level_path() -> String:
	var next_level: int = current_level + 1

	return "res://fases/fase%d.tscn" % next_level


#func #save_game() -> void:
	#var config := ConfigFile.new()
#
	#config.set_value(
		#"player",
		#"coins",
		#_total_coins
	#)
#
	#config.set_value(
		#"player",
		#"bullets",
		#_total_bullets
	#)
#
	#config.set_value(
		#"progress",
		#"current_level",
		#current_level
	#)
#
	#config.set_value(
		#"progress",
		#"unlocked_level",
		#unlocked_level
	#)
#
	#var error := config.save(SAVE_PATH)
#
	#if error != OK:
		#print("Erro ao salvar o jogo: ", error)


func load_game() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)

	# Primeiro início do jogo: usa uma moeda e uma bala.
	if error != OK:
		#save_game()
		return

	_total_coins = int(
		config.get_value(
			"player",
			"coins",
			1
		)
	)

	_total_bullets = int(
		config.get_value(
			"player",
			"bullets",
			1
		)
	)

	current_level = int(
		config.get_value(
			"progress",
			"current_level",
			1
		)
	)

	unlocked_level = int(
		config.get_value(
			"progress",
			"unlocked_level",
			1
		)
	)
