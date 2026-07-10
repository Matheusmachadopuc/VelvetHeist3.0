extends StaticBody2D


func hit():
	queue_free()


func _ready():
	# Cone e luz começam escondidos.
	$Polygon2D.visible = false
	$PointLight2D.visible = false

	# O Sprite2D deve continuar visível.
	# O material Light Only controlará quais pixels aparecem.
	if has_node("Sprite2D"):
		$Sprite2D.visible = true


func _physics_process(_delta: float) -> void:
	var vision_area = get_node_or_null("VisionArea")
	if is_instance_valid(vision_area):
		for body in vision_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				if has_line_of_sight(body):
					player_caught(body)

func has_line_of_sight(target: Node2D) -> bool:
	if not is_instance_valid(target):
		return false
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.exclude = [self]
	var result := space.intersect_ray(query)
	if result.is_empty():
		return true
	return result.get("collider") == target

func _on_vision_area_body_entered(body):
	pass


func player_caught(player):
	player.die()


func check_line_of_sight(player):
	$RayCast2D.target_position = to_local(player.global_position)
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()

		if collider == player:
			player_caught(player)
			
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Make sure this matches your node's name
  
func update_animation(movimento: Vector2) -> void:
	if not is_instance_valid(animated_sprite):
		return

	# Keep the sprite upright relative to the screen
	animated_sprite.global_rotation = 0.0

	if movimento.length_squared() < 0.001:
		animated_sprite.stop()
		return
	
	var nova_animacao: String
	var deve_reverter: bool = false
	
	if abs(movimento.x) > abs(movimento.y):
		if movimento.x > 0:
			nova_animacao = "right"
			deve_reverter = true # Set flag to play backwards
		else:
			nova_animacao = "left"
	else:	
		if movimento.y > 0:
			nova_animacao = "down"
		else:
			nova_animacao = "up"
	
	# Update the animation and play direction
	if animated_sprite.animation != nova_animacao or not animated_sprite.is_playing():
		if deve_reverter:
			animated_sprite.play_backwards(nova_animacao)
		else:
			animated_sprite.play(nova_animacao)
