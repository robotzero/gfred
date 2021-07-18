extends StateMachine

var random: RandomNumberGenerator
var possibilities = []
# 1 - LEFT 2 - RIGHT 3 - UP 4 - DOWN 5 - LEFT WALL 6 - RIGHT WALL 7 - UP WALL 8 - DOWN WALL
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

func _get_transition(_delta):
	possibilities.clear()
	match state:
		states.walk:
			if parent.collision and parent.collision.normal.x != 0 and parent.collision.collider is TileMap:
				if parent.collision.normal.x == 1:
					if parent.collision.collider is InternalPyramid:
						possibilities.append(7)
					else:
						possibilities.append(3)
					parent.velocity.x = 1
				if parent.collision.normal.x == -1:
					if parent.collision.collider is InternalPyramid:
						possibilities.append(6)
					else:
						possibilities.append(1)
					parent.velocity.x = -1
			if parent.fl == parent.floorType.BOTTOM_INTERNAL:
					possibilities.append(8)
			print(possibilities)
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

func _exit_state(old_state, new_state):
	match new_state:
		states.walk:
			if old_state == states.walk_through_wall:
				pass

func _calculate_possibility():
	randomize()
