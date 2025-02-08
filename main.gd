extends Node2D

var row = 0
var column = 0
var steps_remaining = 0  # Number of steps left to move
var dice_result = 0  # Stores dice roll result
@onready var move_timer = $MoveTimer
@onready var dice_timer = $DiceTimer
@onready var DiceRolledTimer = $DiceRolledTimer

func roll_dice() -> int:
	return randi_range(1, 6)
	
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

func move_character_up_animated(amount: float, duration: float = 0.5) -> void:
	var current_pos = $Duck.position
	var target_pos = current_pos + Vector2(0,-amount)
	var tween = create_tween()
	tween.tween_property($Duck,"position",target_pos,duration)

func move_character_down_animated(amount: float, duration: float = 0.5) -> void:
	var current_pos = $Duck.position
	var target_pos = current_pos + Vector2(0,-amount)
	var tween = create_tween()
	tween.tween_property($Duck,"position",target_pos,duration)

func update_character_position():
	if steps_remaining > 0:
		if row < 9 && column%2 ==0:
			if column %2 != 0:
				move_character_up_animated(71,0.5)
				column+=1
			else:
				move_character_right_animated(71,0.5)
				row += 1
			
		else:
			if column %2 == 0 && row == 9:
				move_character_up_animated(71,0.5)
				column +=1
			elif column%2 != 0 && row ==0:
				move_character_up_animated(71,0.5)
				column +=1
			else:
				move_character_left_animated(-71,0.5)
				row -=1
		steps_remaining -=1
		move_timer.start()
	else:
		move_timer.stop()
		
func show_dice_roll_result() -> void:
	$Dice/Dice1.hide()
	$Dice/Dice2.hide()
	$Dice/Dice3.hide()
	$Dice/Dice4.hide()
	$Dice/Dice5.hide()
	$Dice/Dice6.hide()
	# Show the corresponding dice face based on the roll result
	match dice_result:
		1:
			$Dice/Dice1.show()
		2:
			$Dice/Dice2.show()
		3:
			$Dice/Dice3.show()
		4:
			$Dice/Dice4.show()
		5:
			$Dice/Dice5.show()
		6:
			$Dice/Dice6.show()
	

func _input(event):
	if event.is_action_pressed("move_right"):
		dice_result = roll_dice()
		steps_remaining= dice_result
		$Dice.show()
		$Dice/Dice1.hide()
		$Dice/Dice2.hide()
		$Dice/Dice3.hide()
		$Dice/Dice4.hide()
		$Dice/Dice5.hide()
		$Dice/Dice6.hide()
		$Dice/DiceAnimation.play("DiceRoll")  # Show the dice on the screen
		dice_timer.start()  # Start the dice animation timer
		
		
func _ready():
	$Dice.hide()
	$Duck/DuckAnimation.play("idle")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_move_timer_timeout() -> void:
	update_character_position()





func _on_dice_timer_timeout() -> void:
	 # Display the dice result
	$Dice/DiceAnimation.stop()
	show_dice_roll_result()
	DiceRolledTimer.start()
	update_character_position()
	dice_timer.stop()


func _on_dice_rolled_timer_timeout() -> void:
	$Dice.hide()
	DiceRolledTimer.stop()
