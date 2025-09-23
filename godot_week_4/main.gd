extends Node

@export var mob_scene: PackedScene # Allows us to choose the Mob scene we want to instance.
var score
var diff_mult

var threshold = 20

func _ready() -> void:
	pass

# Upon a game over, pause the mob and score timers.
func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$FilterTimer.stop()
	$HUD.show_game_over()
	
	# Upon death, stop BGM, play death sound.
	$Music.stop()
	$DeathSound.play()
	$GameOverSound.play()

# Upon starting a new game, reset score, and start player at specified position.
func new_game():
	score = 0
	diff_mult = 1
	
	$HUD.update_warning(threshold, diff_mult, round($FilterTimer.time_left))
	
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	
	# Calls the named function on every node in a group -- tell every mob to delete itself.
	get_tree().call_group("mobs", "queue_free")
	
	# Play music upon game start.
	$Music.play()


func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_warning(threshold, diff_mult, round($FilterTimer.time_left))
	$HUD.update_score(score)
	

func _on_filter_timer_timeout() -> void:
	if (score >= (threshold * diff_mult)):
		diff_mult += 1
		$MobTimer.wait_time = 1.0 / diff_mult
		$MobTimer.start()  
		$UpdateSound.play()
		print("New wait time:", $MobTimer.wait_time)
	else:
		$Player._on_failure()


func _on_start_timer_timeout() -> void:
	$MobTimer.wait_time = 1 / diff_mult
	
	$MobTimer.start()
	$ScoreTimer.start()
	$FilterTimer.start()
	

func _on_player_nuke() -> void:
	print("Seismic Charge.")
	$DeathSound.play()
	$ChargeSound.play()
	get_tree().call_group("mobs", "kill_self")
	score -= 3
	if (score < 0) :
		score = 0
	$HUD.update_score(score)
