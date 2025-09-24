extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

# Displays a temporary message.
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
# What happens when the game ends - give player heads up that game is over, then return to start screen.
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	# $Message.text = "Dodge the Creeps!"
	# $Message.show()
	
	
	$Message.hide()
	$WarningLabel.hide()
	$Icon.visible = not $Icon.visible
	
	
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	$Instructions.show()
	$Icon.show()

func update_score(score):
	$ScoreLabel.text = str(score)

# Hide start button, then start the game.
func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$Instructions.hide()
	$SelectSFX.play()
	
	# Show the scorelabel the first time the button is pressed.
	$ScoreLabel.show()
	$WarningLabel.show()
	
	$Icon.visible = not $Icon.visible
	start_game.emit()


func _on_message_timer_timeout() -> void:
	$Message.hide()

func update_warning (threshold, diff_mult, timer_count) -> void:
	var barrier = str(threshold * diff_mult)
	$WarningLabel.text = "Difficulty: " + str(diff_mult) + " - Reach " + barrier + " Points - Time Left: " + str(int(timer_count))
