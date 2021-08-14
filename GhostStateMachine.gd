extends StateMachine

var random: RandomNumberGenerator
var possibilities = []
const possibilities_map = {
	1:Vector2.LEFT,
	2:Vector2.RIGHT,
	3:Vector2.UP,
	4:Vector2.DOWN,
	5:Vector2.LEFT,
	6:Vector2.RIGHT,
	7:Vector2.UP,
	8:Vector2.DOWN
}

var possibilities_state_map = {
	1:"walk_left",
	2:"walk_right",
	3:"climb_up",
	4:"climb_down",
	5:"walk_through_wall_left",
	6:"walk_through_wall_right",
	7:"climb_through_wall_up",
	8:"climb_through_wall_down"
}
# 1 - LEFT 2 - RIGHT 3 - UP 4 - DOWN 5 - LEFT WALL 6 - RIGHT WALL 7 - UP WALL 8 - DOWN WALL
func _ready():
	random = RandomNumberGenerator.new()
	add_state("idle")
	add_state("walk_right")
	add_state("walk_left")
	add_state("climb_up")
	add_state("climb_down")
	add_state("walk_through_wall_right")
	add_state("walk_through_wall_left")
	add_state("climb_through_wall_up")
	add_state("climb_through_wall_down")
	call_deferred("set_state", states.walk_right)
	
func _state_logic(delta):
	if !possibilities.empty():
		pass
		#print(possibilities)
	#var choosen_index = _calculate_possibility()
	#print(choosen_index)
	#if choosen_index:
#		possibilities_map.get(choosen_index)
	#if !possibilities.empty():
	#	var move = random.randi_range(1, 8)
		#parent.velocity = possibilities_map.get(move)
		#print(parent.velocity)
	#match state:
	#	parent.startJumpingOn(parent.tileMapCastRight1.get_collider())
	#parent._get_input()
	parent._move(delta)

func _get_transition(_delta):
	possibilities.clear()
	match state:
		states.walk_left, states.walk_right:
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
			if parent.ropeCollider and _ghost_rope_distance():
				possibilities.append(3)
		states.walk_through_wall_left:
			if parent.collision and parent.collision.normal.x > 0:
				pass
			#TODO discover that you no longer "in" the wall to switch the state
			return states.walk_left
	var choosen_index = _calculate_possibility()
	if choosen_index:
		return states[possibilities_state_map.get(choosen_index)]
	return null
			
func _enter_state(new_state, old_state):
	match new_state:
		states.walk_right,states.walk_left:
			if parent.velocity.x < 0 and !parent.sprite.flip_h:
				parent.sprite.flip_h = true
			if parent.velocity.x > 0 and parent.sprite.flip_h:
				parent.sprite.flip_h = false
			if old_state == states.walk_through_wall_left:
				pass
			if old_state == states.walk_through_wall_right:
				pass
			parent.sprite.play("walk")
		states.walk_through_wall_left, states.walk_through_wall_right:
			parent.sprite.play("walk")
		states.climb_up:
			parent.velocity = Vector2.UP
		states.climb_down:
			parent.velocity = Vector2.DOWN

func _exit_state(old_state, new_state):
	match new_state:
		states.walk_right, states.walk_left:
			if old_state == states.walk_through_wall_left:
				pass
			if old_state == states.walk_through_wall_right:
				pass

func _ghost_rope_distance():
	var distance = Vector2(parent.ropeCollider.position.x, 0).distance_to(Vector2(parent.position.x, 0))
	#TODO potential issues with distance, when ghost is hitting wall, make sure that it is possible to have both
	if distance < 3:
		return true
	return false

func _calculate_possibility():
	if !possibilities.empty():
		randomize()
		var move = random.randi_range(0, possibilities.size() - 1)
		return possibilities[move]
	return null
