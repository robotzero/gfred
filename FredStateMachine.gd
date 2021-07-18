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
	add_state("start_climb")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	match state:
		states.jump_off_left:
			var distanceX = Vector2(parent.previousRopeCollider.position.x, 0).distance_to(Vector2(parent.position.x, 0))
			if not distanceX > parent.DISTANCE_OF_THE_JUMP_OFF:
				parent.velocity.x += parent.jumpTo
		states.jump_off_right:
			var distanceX = Vector2(parent.previousRopeCollider.position.x, 0).distance_to(Vector2(parent.position.x, 0))
			if not distanceX > parent.DISTANCE_OF_THE_JUMP_OFF:
				parent.velocity.x += parent.jumpTo
		states.jump_on_left:
			parent.startJumpingOn(parent.tileMapCastLeft1.get_collider())
		states.jump_on_right:
			parent.startJumpingOn(parent.tileMapCastRight1.get_collider())
	if [states.jump, states.jump_off_left, states.jump_off_right, states.jump_on_left, states.jump_on_right, states.flip_right, states.flip_left, states.start_climb].has(state):
		parent._move(delta)
	else:
		parent._get_input()
		parent._move(delta)

func _get_transition(delta):
	match state:
		states.idle:
			if parent.velocity.x != 0:
				return states.walk
		states.walk:
			if parent.velocity.x == 0:
				return states.idle
			if parent.shouldStartJumpingOn(parent.tileMapCastLeft1) and parent.shouldStartJumpingOn(parent.tileMapCastLeft2):
				return states.jump_on_left
			if parent.shouldStartJumpingOn(parent.tileMapCastRight1) and parent.shouldStartJumpingOn(parent.tileMapCastRight2):
				return states.jump_on_right
		states.jump:
			if parent.jumpTimer.is_stopped():
				return states.idle
		states.start_climb:
			if parent.jumpTimer.is_stopped():
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
		states.jump_on_right:
			if parent.jumpTimer.is_stopped():
				return states.climb
		states.jump_on_left:
			if parent.jumpTimer.is_stopped():
				return states.climb
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
		states.start_climb:
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
			if parent.jumpTimer.is_stopped():
				parent.jumpTimer.start()
		states.jump_on_right:
			if parent.jumpTimer.is_stopped():
				parent.jumpTimer.start()
			parent.jumpTo = 1
			parent.sprite.play("jump")
			parent.jumpingOnCollider = parent.tileMapCastRight1.get_collider()
			parent.startJumpingOn(parent.tileMapCastRight1.get_collider())
		states.jump_on_left:
			if parent.jumpTimer.is_stopped():
				parent.jumpTimer.start()
			parent.jumpTo = -1
			parent.sprite.play("jump")
			parent.jumpingOnCollider = parent.tileMapCastLeft1.get_collider()
			parent.startJumpingOn(parent.tileMapCastLeft1.get_collider())
	
func _exit_state(old_state, new_state):
	match new_state:
		states.idle:
			if old_state == states.jump_off_right or old_state == states.jump_off_left:
				parent.jumpTo = 0
				parent.sprite.play("idle")
				parent.position.y = parent.position.y - parent.SIMPLE_JUMP_INPX
		states.climb:
			if old_state == states.jump_on_right or old_state == states.jump_on_left:
				parent.jumpTo = 0
				parent.sprite.play("climb")
				parent.position.x = parent.jumpingOnCollider.position.x + 1
				parent.jumpingOnCollider = null
		states.start_climb:
			var newPosX = parent.calculateCorrectedVerticalPosition()
			parent.position.x = newPosX
