extends Node2D

var duck_row = 0
var duck_column = 0
var goose_row = 0
var goose_column =0

var duck_steps_remaining = 0  # Number of steps left to move
var goose_steps_remaining = 0

var dice_result = 0  # Stores dice roll result
var is_moving = false
var is_duck_turn = true

@onready var move_timer = $MoveTimer
@onready var dice_timer = $DiceTimer
@onready var DiceRolledTimer = $DiceRolledTimer

func roll_dice() -> int:
	return randi_range(1, 6)
	
func move_character_x_animated(animal: Node2D,amount: float, duration: float = 0.5) -> void:
	var current_pos = animal.position
	var target_pos = current_pos + Vector2(amount,0)
	var tween = create_tween()
	tween.tween_property(animal,"position",target_pos,duration)
	
func move_character_y_animated(animal: Node2D,amount: float, duration: float = 0.5) -> void:
	var current_pos = animal.position
	var target_pos = current_pos + Vector2(0,-amount)
	var tween = create_tween()
	tween.tween_property(animal,"position",target_pos,duration)


func update_character_position(animal: Node2D, steps_remaining: int, row: int, column: int) -> Dictionary:
	if steps_remaining > 0:
		if row < 9 && column%2 ==0:
			if column %2 != 0:
				move_character_y_animated(animal,71,0.5)
				column+=1
			else:
				move_character_x_animated(animal,71,0.5)
				row += 1
			
		else:
			if column %2 == 0 && row == 9:
				move_character_y_animated(animal,71,0.5)
				column +=1
			elif column%2 != 0 && row ==0:
				move_character_y_animated(animal,71,0.5)
				column +=1
			else:
				move_character_x_animated(animal,-71,0.5)
				row -=1
		steps_remaining -=1
		move_timer.start()
		return {"steps_remaining": steps_remaining, "row": row, "column": column}
	else:
		move_timer.stop()
		is_moving = false
		switch_turns()
		return {"steps_remaining": steps_remaining, "row": row, "column": column}
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
		start_turn()
		$Dice/Dice1.hide()
		$Dice/Dice2.hide()
		$Dice/Dice3.hide()
		$Dice/Dice4.hide()
		$Dice/Dice5.hide()
		$Dice/Dice6.hide()
		
func start_turn():
	
		is_moving = true
		dice_result = roll_dice()
		if is_duck_turn:
			duck_steps_remaining = dice_result
			$Dice.show()
			$Dice/DiceAnimation.play("DiceRoll")
			dice_timer.start()
		else:
			goose_steps_remaining = dice_result
			$Dice.show()
			$Dice/DiceAnimation.play("DiceRoll")
			dice_timer.start()

func switch_turns():
	is_duck_turn = !is_duck_turn
	
func _ready():

	$Dice.hide()
	$Win.hide()
	$Duck/DuckAnimation.play("WalkRight")
	$Goose/GooseAnimation.play("WalkRight")
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_move_timer_timeout() -> void:
	if is_duck_turn:
		var result = update_character_position($Duck, duck_steps_remaining, duck_row, duck_column)
		duck_steps_remaining = result["steps_remaining"]
		duck_row = result["row"]
		duck_column = result["column"]
	else:
		var result = update_character_position($Goose, goose_steps_remaining, goose_row, goose_column)
		goose_steps_remaining = result["steps_remaining"]
		goose_row = result["row"]
		goose_column = result["column"]




func _on_dice_timer_timeout() -> void:
	 # Display the dice result
	$Dice/DiceAnimation.stop()
	show_dice_roll_result()
	DiceRolledTimer.start()
	if is_duck_turn:
		var result = update_character_position($Duck, duck_steps_remaining, duck_row, duck_column)
		duck_steps_remaining = result["steps_remaining"]
		duck_row = result["row"]
		duck_column = result["column"]
	else:
		var result = update_character_position($Goose, goose_steps_remaining, goose_row, goose_column)
		goose_steps_remaining = result["steps_remaining"]
		goose_row = result["row"]
		goose_column = result["column"]
	dice_timer.stop()


func _on_dice_rolled_timer_timeout() -> void:
	$Dice.hide()
	DiceRolledTimer.stop()


func _on_movement_finished() -> void:
	if is_duck_turn:
		if duck_steps_remaining ==0:
			is_moving = false
	else:
		if goose_steps_remaining == 0:
			is_moving = false
			
func _on_winning_block_body_entered(body: Node2D) -> void:
	if body == $Duck or body == $Goose:
		print("Duck has reached goal!")
		$Win.show()
