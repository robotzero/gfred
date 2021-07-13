extends StateMachine

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("climb")
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
		states.walk:
			if parent.velocity.x == 0:
				return states.idle
		states.jump:
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
	
func _exit_state(old_state, new_state):
	match new_state:
		states.idle:
			parent.potentialMoves["jumping"] = false
		states.climb:
			parent.potentialMoves["jumping"] = false
