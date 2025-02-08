extends Node2D


# Called when the node enters the scene tree for the first time.
func move_character_right_animated(amount: float, duration: float = 0.5) -> void:
	var current_pos = $Duck.position
	var target_pos = current_pos + Vector2(amount,0)
	var tween = create_tween()
	tween.tween_property($Duck,"position",target_pos,duration)
func move_character_left_animated(amount: float, duration: float = 0.5) -> void:
	var current_pos = $Duck.position
	var target_pos = current_pos + Vector2(amount,0)
	var tween = create_tween()
	tween.tween_property($Duck,"position",target_pos,duration)

	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.is_action_pressed("move_right"):
			move_character_right_animated(71,0.5)
func _ready():
	$Duck/DuckAnimation.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
