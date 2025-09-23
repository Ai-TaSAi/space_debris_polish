extends Area2D
signal hit
signal nuke

@export var speed = 400 # How fast the player moves, px/s
var screen_size # Size of game window

# New variables for the ship to use for rotational and speed. Speed can now be independently adjusted.
var facing_degrees = 0
var ship_speed = 0.8

var on_screen

func _ready(): # Used when the player enters the scene tree.
	screen_size = get_viewport_rect().size
	facing_degrees = 270
	hide() # Hides the player upon the start of the game.
	
	on_screen = false
	
func _process(delta): # Runs the whole time.
	var velocity = Vector2.ZERO # Defines player's movement vector, add and subtract to modify the velocity based on player movement direction.
	
	# OLD TUTORIAL CODE. NOT USED.
	#if Input.is_action_pressed("move_right"):
		#velocity.x += 1
	#if Input.is_action_pressed("move_left"):
		#velocity.x -= 1
	#if Input.is_action_pressed("move_down"):
		#velocity.y += 1
	#if Input.is_action_pressed("move_up"):
		#velocity.y -= 1
		
	if on_screen:
		# Left and Right now rotate the ship instead of making it go up and down.
		if Input.is_action_pressed("move_right"):
			facing_degrees += 5
			if (facing_degrees > 360):
				facing_degrees = 0
		if Input.is_action_pressed("move_left"):
			facing_degrees -= 5
			if (facing_degrees < 0):
				facing_degrees = 360
		# Fly ship forward or reverse it (though realistically, you're not able to reverse a ship in such manners)
		if Input.is_action_pressed("move_up"):
			velocity.x += cos(facing_degrees * PI / 180) * ship_speed
			velocity.y += sin(facing_degrees * PI / 180) * ship_speed
		if Input.is_action_pressed("move_down"):
			velocity.x -= cos(facing_degrees * PI / 180) * ship_speed
			velocity.y -= sin(facing_degrees * PI / 180) * ship_speed
			
		if Input.is_action_just_pressed("nuke"):
			nuke.emit()
			$ParticleBurst.restart()
			print("NUKED!")
		
	$AnimatedSprite2D.rotation = (facing_degrees * PI / 180)
		
	# Update code to only use fly animation, when ship is in motion.
	if velocity.length() > 0: # Moving @ (1,1) = SQRT(2) is faster than simply moving cardinal. Normalizing prevents that.
		velocity = velocity.normalized() * speed
		# Play sprite if moving. Else don't.
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.animation = "fly"
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta # Modify character position based on the velocity, by the system FPS.
	position = position.clamp(Vector2.ZERO, screen_size) # Clamp prevents the character from leaving the screen.
	
	# Choosing animation files to play based on direction of sprite - OLD CODE, NOT USED ANYMORE.
	#if velocity.x != 0:
		#$AnimatedSprite2D.animation = "walk"
		#$AnimatedSprite2D.flip_v = false
		#$AnimatedSprite2D.flip_h = velocity.x < 0
	#elif velocity.y != 0:
		#$AnimatedSprite2D.animation = "up"
		#$AnimatedSprite2D.flip_v = velocity.y > 0

func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	on_screen = false
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback. Makes it so that object collision disappears once it's safe to do so.
	$CollisionShape2D.set_deferred("disabled", true)
	
func _on_failure() -> void:
	hide()
	on_screen = false
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback. Makes it so that object collision disappears once it's safe to do so.
	$CollisionShape2D.set_deferred("disabled", true)

# Function resets the player when starting a new game.
func start(pos):
	position = pos
	facing_degrees = 270
	show()
	on_screen = true
	$ParticleBurst.emitting = false
	$CollisionShape2D.disabled = false
