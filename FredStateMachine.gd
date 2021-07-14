extends StateMachine

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("climb")
	add_state("flip_right")
	add_state("flip_left")
	add_state("jump_on_right")
	add_state("jump_on_left")
	add_state("jump_off_right")
	add_state("jump_off_left")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	#parent.velocity = Vector2.ZERO
	parent._get_input()
	parent._move(delta)
	#match state:
	#	states.idle:
	#		pass
	#	states.walk:
	#		if Input.is_action_pressed("left") and !Input.is_action_pressed("right") and !Input.is_action_just_pressed("left"):
	#			parent.velocity.x -= 1
	#			#if !parent.sprite.flip_h:
				#	parent.sprite.flip_h = true
	#			parent.sprite.play("walk")
	#		elif Input.is_action_pressed("right") and !Input.is_action_pressed("left") and !Input.is_action_just_pressed("right"):
	#			parent.velocity.x += 1
	#			#if parent.sprite.flip_h:
				#	parent.sprite.flip_h = false
	#			parent.sprite.play("walk")
	#		parent.move(delta, parent.velocity)
	#	states.jump:
	#		if Input.is_action_just_pressed("jump"):
	#			parent.position.y = parent.position.y + parent.SIMPLE_JUMP_INPX
				#var climbing = parent.isNearLineVicinity()
				#if (climbing):
				#	var newPosX = parent.calculateCorrectedVerticalPosition()
				#	parent.position.x = newPosX
	#			parent.sprite.play("jump")
	#			parent.jumpTimer.start()

func _get_transition(delta):
	match state:
		states.idle:
			if parent.velocity.x != 0:
				return states.walk
			if parent.potentialMoves["jumping"]:
				return states.jump
			if parent.potentialMoves["climbing"]:
				return states.jump
		states.walk:
			if parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.jumpTimer.is_stopped() and parent.potentialMoves["jumping"]:
				return states.idle
			if parent.jumpTimer.is_stopped() and parent.potentialMoves["climbing"]:
				return states.climb
		states.flip_right:
			if parent.flipTimer.is_stopped():
				return states.climb
		states.flip_left:
			if parent.flipTimer.is_stopped():
				return states.climb
		states.jump_off_right:
			if parent.jumpTimer.is_stopped():
				return states.idle
		states.jump_off_left:
			if parent.jumpTimer.is_stopped():
				return states.idle
	return null
		
	
func _enter_state(new_state, old_state):
	match new_state:
		states.walk:
			if parent.velocity.x < 0:
				if !parent.sprite.flip_h:
					parent.sprite.flip_h = true
			if parent.velocity.x > 0:
				if parent.sprite.flip_h:
					parent.sprite.flip_h = false
			parent.sprite.play("walk")
		states.idle:
			if old_state == states.jump:
				parent.position.y = parent.position.y - parent.SIMPLE_JUMP_INPX
			parent.sprite.play("idle")
		states.jump:
			parent.sprite.play("jump")
			parent.position.y = parent.position.y + parent.SIMPLE_JUMP_INPX
			parent.jumpTimer.start()
		states.climb:
			parent.sprite.play("climb")
		states.flip_right:
			if parent.sprite.flip_h:
				parent.sprite.flip_h = true
			else:
				parent.sprite.flip_h = true
			parent.flipTimer.start()
		states.flip_left:
			if parent.sprite.flip_h:
				parent.sprite.flip_h = false
			else:
				parent.sprite.flip_h = false
			parent.flipTimer.start()
		states.jump_off_right:
			if old_state == states.flip_right:
				pass
			parent.sprite.play("jump")
			parent.sprite.flip_h = false
			parent.previousRopeCollider = parent.currentRopeCollider
			parent.jumpTo = 1
			var distanceX = Vector2(parent.previousRopeCollider.position.x, 0).distance_to(Vector2(parent.position.x, 0))
			if not distanceX > parent.DISTANCE_OF_THE_JUMP_OFF:
				parent.velocity.x += parent.jumpTo
			if parent.jumpTimer.is_stopped():
				parent.jumpTimer.start()
		states.jump_off_left:
			if old_state == states.flip_left:
				pass
			parent.sprite.play("jump")
			parent.sprite.flip_h = true
			parent.previousRopeCollider = parent.currentRopeCollider
			parent.jumpTo = -1
			var distanceX = Vector2(parent.previousRopeCollider.position.x, 0).distance_to(Vector2(parent.position.x, 0))
			if not distanceX > parent.DISTANCE_OF_THE_JUMP_OFF:
				parent.velocity.x += parent.jumpTo
			if parent.jumpTimer.is_stopped():
				parent.jumpTimer.start()
	
func _exit_state(old_state, new_state):
	match new_state:
		states.idle:
			if old_state == states.jump_off_right or old_state == states.jump_off_left:
				parent.jumpTo = 0
				parent.sprite.play("idle")
				parent.position.y = parent.position.y - parent.SIMPLE_JUMP_INPX
			parent.potentialMoves["jumping"] = false
		states.climb:
			parent.potentialMoves["climbing"] = false
		states.jump:
			if parent.potentialMoves["climbing"]:
				var newPosX = parent.calculateCorrectedVerticalPosition()
				parent.position.x = newPosX
			#pass
			#parent.potentialMoves["jumping"] = false
