extends RigidBody2D

# When mob is placed into the scene:
func _ready():
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names()) # Pick random mob type and change its animations accordingly.
	mob_types.erase("explode")
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	
# When mob has left the screen, eject it from the game.
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	# print("Killed self")
	

func kill_self ():
	$PointLight2D.show()
	$AnimatedSprite2D.play("explode")
	$DeathExplode.restart()
	$CollisionShape2D.disabled = true
	await $DeathExplode.finished
	
	$PointLight2D.hide()
	print("Killed Self")
	queue_free()
