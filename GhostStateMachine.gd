extends StateMachine

var random: RandomNumberGenerator

func _ready():
	random = RandomNumberGenerator.new()
	add_state("idle")
	add_state("walk")
	add_state("climb")
	add_state("walk_through_wall")
	call_deferred("set_state", states.walk)
	
func _state_logic(delta):
	#match state:
	#	parent.startJumpingOn(parent.tileMapCastRight1.get_collider())
	#parent._get_input()
	parent._move(delta)

func _get_transition(delta):
	randomize()
	match state:
		states.walk:	
			if parent.collision and parent.collision.normal.x != 0:
				print(parent.collision.collider)
			if parent.collision and parent.collision.normal.x != 0 and parent.collision.collider is TileMap:
				if parent.velocity.x < 0:
					parent.velocity.x = 1
				if parent.velocity.x > 0:
					parent.velocity.x = -1
	match state:
		states.walk_through_wall:
			if parent.collision and parent.collision.normal.x > 0:
				pass
			return states.walk
			
func _enter_state(new_state, old_state):
	match new_state:
		states.walk:
			if parent.velocity.x < 0 and !parent.sprite.flip_h:
				parent.sprite.flip_h = true
			if parent.velocity.x > 0 and parent.sprite.flip_h:
				parent.sprite.flip_h = false
			if old_state == states.walk_through_wall:
				pass
			parent.sprite.play("walk")
		states.walk_through_wall:
			parent.sprite.play("walk")
