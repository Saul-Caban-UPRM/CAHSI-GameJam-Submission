extends Node2D
@onready var EggHatchTimer = $CharacterBody2D/EggHatch
@onready var ExplosionTimer = $CharacterBody2D/ExplosionTimer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharacterBody2D/Egg.show()
	$CharacterBody2D/Explosion.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func explode() -> void:
	$CharacterBody2D/Egg/EggAnimation.play("EggHatching")
	EggHatchTimer.start()
	
	

func _on_egg_hatch_timeout() -> void:
	$CharacterBody2D/Explosion.show()
	$CharacterBody2D/Egg.hide()
	$CharacterBody2D/Explosion/ExplosionAnimation.play("Explosion")
	EggHatchTimer.stop()
	ExplosionTimer.start()


func _on_explosion_timer_timeout() -> void:
	$CharacterBody2D/Explosion.hide()
	ExplosionTimer.stop()
