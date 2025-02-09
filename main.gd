extends Node2D

var ORIGINAL_DUCK_POSITION = Vector2()
var ORIGINAL_GOOSE_POSITION = Vector2()

var duck_row = 0
var duck_column = 0
var goose_row = 0
var goose_column =0

var duck_is_moving = false
var goose_is_moving = false

var duck_steps_remaining = 0  # Number of steps left to move
var goose_steps_remaining = 0

var dice_result = 0  # Stores dice roll result
var is_moving = false
var is_duck_turn = true
var exploded_eggs = {}
var foward = true
var is_bot_turn = false
@onready var move_timer = $MoveTimer
@onready var dice_timer = $DiceTimer
@onready var DiceRolledTimer = $DiceRolledTimer
@onready var BackwardsTimer = $BackWardsTimer

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
		duck_is_moving = true
		goose_is_moving = true
		if not foward:
			if row ==9 && column%2 != 0:
				move_character_y_animated(animal, -71, 0.5)
				column -=1
			elif row==0 && column%2 == 0: 
				move_character_y_animated(animal, -71, 0.5)
				column -=1
			elif column % 2 == 0:  # Going left
				move_character_x_animated(animal, -71, 0.5)
				row -= 1
			else:  # Going right
				move_character_x_animated(animal, 71, 0.5)
				row += 1
		if foward:
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
		duck_is_moving = false
		goose_is_moving = false
		foward = true
		
		
		
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
		set_process_input(false) 
		is_moving = true
		dice_result = roll_dice()
		if is_duck_turn:
			duck_steps_remaining = dice_result
			$Dice.show()
			$Dice/DiceAnimation.play("DiceRoll")
			dice_timer.start()
		elif is_bot_turn:
			goose_steps_remaining = dice_result
			$Dice.show()
			$Dice/DiceAnimation.play("DiceRoll")
			dice_timer.start()
		
func switch_turns():
	is_duck_turn = !is_duck_turn
	if not is_duck_turn:
		bot_turn()
	elif is_duck_turn:
		set_process_input(true)
	
		
func _ready():
	ORIGINAL_DUCK_POSITION = $Duck.position
	ORIGINAL_GOOSE_POSITION = $Goose.position
	$Dice.hide()
	$Win.hide()
	$Loose.hide()
	$Duck/DuckAnimation.play("WalkRight")
	$Goose/GooseAnimation.play("WalkRight")

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
	
	if duck_steps_remaining == 0 or goose_steps_remaining == 0:
		_on_movement_finished()
	
func ExplodeOnTile()-> void:
# Define the egg positions
	
	var egg_positions = {"egg1": Vector2(1, 8),"egg2": Vector2(8, 7),"egg3": Vector2(3, 5),"egg4": Vector2(7, 3),"egg5": Vector2(1, 2),"egg6": Vector2(5, 1)}
	
	# Mapping for the corresponding egg nodes
	var egg_nodes = {"egg1": $EggContainer/ExplosiveEgg5,"egg2": $EggContainer/ExplosiveEgg6,"egg3": $EggContainer/ExplosiveEgg4,"egg4": $EggContainer/ExplosiveEgg3,"egg5": $EggContainer/ExplosiveEgg2,"egg6": $EggContainer/ExplosiveEgg1}
	
	for egg_name in egg_positions.keys():
		var pos = egg_positions[egg_name]

		
		if (duck_row == pos.x and duck_column == pos.y and not duck_is_moving) or (goose_row == pos.x and goose_column == pos.y and not goose_is_moving):
			if not exploded_eggs.get(egg_name, false):  
				egg_nodes[egg_name].explode()
				$HomePage.ExplosionSounds()
				exploded_eggs[egg_name] = true  
				
				# Stop forward movement completely
				move_timer.stop()
				is_moving = true  

				# Move character back 3 steps
				foward = false
				
				
				if duck_row == pos.x and duck_column == pos.y:
					duck_steps_remaining = randi_range(3, 6)  # Set the number of backward steps
					_on_back_wards_timer_timeout()
				elif goose_row == pos.x and goose_column == pos.y:
					goose_steps_remaining = randi_range(3, 6)
					_on_back_wards_timer_timeout()

		
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
		
	elif is_bot_turn:
		var result = update_character_position($Goose, goose_steps_remaining, goose_row, goose_column)
		goose_steps_remaining = result["steps_remaining"]
		goose_row = result["row"]
		goose_column = result["column"]
	dice_timer.stop()
	move_timer.start()
	



func _on_dice_rolled_timer_timeout() -> void:
	$Dice.hide()
	DiceRolledTimer.stop()


func _on_movement_finished() -> void:
	if is_duck_turn and duck_steps_remaining == 0:
		ExplodeOnTile()  # Check for explosions first
	elif not is_duck_turn and goose_steps_remaining == 0:
		ExplodeOnTile()  # Check for explosions first
	if not is_moving:
		switch_turns()
		
		
			
func _on_winning_block_body_entered(body: Node2D) -> void:
	print(body)
	if body == $Duck:
		print("Duck has reached goal!")
		$Win.show()
		$HomePage.StopPlayingMusic()
		stop_game()
		
	elif body == $Goose:
		$Loose.show()
		$HomePage.StopPlayingMusic()
		stop_game()
	
func _on_back_wards_timer_timeout() -> void:
	# Handle backward movement for the duck
	
	if is_duck_turn:
		var result = update_character_position($Duck, duck_steps_remaining, duck_row, duck_column)
		duck_steps_remaining = result["steps_remaining"]
		duck_row = result["row"]
		duck_column = result["column"]

	# Handle backward movement for the goose
	elif not is_duck_turn:
		
		var result = update_character_position($Goose, goose_steps_remaining, goose_row, goose_column)
		goose_steps_remaining = result["steps_remaining"]
		goose_row = result["row"]
		goose_column = result["column"]
		
func bot_turn()->void:
	set_process_input(false) 
	is_bot_turn = true
	start_turn()
	$Dice/Dice1.hide()
	$Dice/Dice2.hide()
	$Dice/Dice3.hide()
	$Dice/Dice4.hide()
	$Dice/Dice5.hide()
	$Dice/Dice6.hide()
	# Implement the bot's move automatically after the turn is started
	
	is_bot_turn = false 
	
func stop_game() -> void:
	# Stop all movement and timers
	move_timer.stop()
	dice_timer.stop()
	DiceRolledTimer.stop()	 
	BackwardsTimer.stop()
	set_process_input(true)
	$EndDelay.start()

func _on_end_delay_timeout() -> void:
	reset_game()
	

func reset_game() -> void:
	duck_row = 0
	duck_column = 0
	goose_row = 0
	goose_column = 0
	duck_steps_remaining = 0
	goose_steps_remaining = 0
	
	is_duck_turn = true
	is_bot_turn = false
	foward = true
	is_moving = false
	$EggContainer/ExplosiveEgg1.EggRespawn()
	$EggContainer/ExplosiveEgg2.EggRespawn()
	$EggContainer/ExplosiveEgg3.EggRespawn()
	$EggContainer/ExplosiveEgg4.EggRespawn()
	$EggContainer/ExplosiveEgg5.EggRespawn()
	$EggContainer/ExplosiveEgg6.EggRespawn()
	$HomePage.homePageReset()
	$Win.hide()
	$Loose.hide()
	$Duck.position = ORIGINAL_DUCK_POSITION
	
	$Goose.position = ORIGINAL_GOOSE_POSITION
	
