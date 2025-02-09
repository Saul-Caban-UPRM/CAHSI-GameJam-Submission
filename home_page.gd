extends Control

@onready var start_button = $TextureRect/StartGame
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func StopPlayingMusic() -> void:
	$TextureRect/AudioStreamPlayer2D.stop()

func ExplosionSounds() -> void:
	$TextureRect/AudioStreamPlayer2D2.play(4)
func homePageReset() -> void:
	$TextureRect/AudioStreamPlayer2D.stop()
	$TextureRect.show()
	$TextureRect/StartGame.show()
	$TextureRect/Label.show()

func _on_start_game_pressed() -> void:
	$TextureRect/AudioStreamPlayer2D.play()
	$TextureRect.hide()
	$TextureRect/StartGame.hide()
	$TextureRect/Label.hide()
