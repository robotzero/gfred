extends StateMachine

var random: RandomNumberGenerator
var possibilities = []
const possibilities_maps = {
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

func _ready():
	random = RandomNumberGenerator.new()
	add_state("idle")
	add_state("walk_left")
	add_state("walk_right")
	add_state("climb_up")
	add_state("climb_down")
	add_state("walk_through_wall_left")
	add_state("walk_through_wall_right")
	add_state("climb_through_wall_up")
	add_state("climb_through_wall_down")
	call_deferred("set_state", states.walk_right)
	
func _state_logic(delta):
	parent._move(delta)

func _get_transition(_delta):
	# 1 - LEFT 2 - RIGHT 3 - UP 4 - DOWN 5 - LEFT WALL 6 - RIGHT WALL 7 - UP WALL 8 - DOWN WALL
	possibilities.clear()
	match state:
		states.walk_left, states.walk_right:
			if parent.collision and parent.collision.normal.x != 0 and parent.collision.collider is TileMap:
				if parent.collision.normal.x == 1:
					if parent.collision.collider is InternalPyramid:
						#@TODO this should be a check for raycasting
						possibilities.append(7)
					else:
						possibilities.append(3)
				if parent.collision.normal.x == -1:
					if parent.collision.collider is InternalPyramid:
						possibilities.append(6)
					else:
						possibilities.append(1)
			if parent.fl == parent.floorType.BOTTOM_INTERNAL:
				possibilities.append(8)
			if parent.ropeCollider and _ghost_rope_distance():
				possibilities.append(3)
			if !parent.collision or parent.collision.normal.x == 0:
				if state == states.walk_left:
					possibilities.append(1)
				if state == states.walk_right:
					possibilities.append(2)
		
		states.walk_through_wall_left:
			pass
		
		states.walk_through_wall_right:
			pass
		
		states.climb_up:
			if parent.collision and parent.collision.normal.y != 0 and parent.collision.collider is TileMap:
				if parent.collision.normal.y == 1:
					if parent.collision.collider is InternalPyramid:
						possibilities.append(7)
				
				possibilities = parent.checkCollider(parent.leftCast, 5, possibilities)
				possibilities = parent.checkCollider(parent.rightCast, 6, possibilities)
				possibilities.append(4)
				if !parent.leftCast.is_colliding():
					possibilities.append(1)
				if !parent.rightCast.is_colliding():
					possibilities.append(2)
					
		states.climb_down:
			if parent.collision and parent.collision.normal.y < 0 and parent.collision.collider is TileMap:
				if parent.collision.collider is InternalPyramid:
					possibilities.append(8)
				possibilities = parent.checkCollider(parent.leftCast, 5, possibilities)
				possibilities = parent.checkCollider(parent.rightCast, 6, possibilities)
				possibilities.append(3)
				if !parent.leftCast.is_colliding():
					possibilities.append(1)
				if !parent.rightCast.is_colliding():
					possibilities.append(2)
		
		
		states.walk_through_wall_left:
			if parent.collision and parent.collision.normal.x > 0:
				pass
			#TODO discover that you no longer "in" the wall to switch the state
			#return states.walk_left
	var choosen_index = _calculate_possibility()
	if choosen_index:
		print(choosen_index)
		return states[possibilities_state_map.get(choosen_index)]
	return null
			
func _enter_state(new_state, old_state):
	match new_state:
		states.walk_through_wall_left, states.walk_through_wall_right:
			parent.sprite.play("walk")
		states.climb_up:
			parent.sprite.play("walk")
			parent.velocity = Vector2.UP
		states.climb_down:
			parent.sprite.play("walk")
			parent.velocity = Vector2.DOWN
		states.walk_left:
			parent.sprite.play("walk")
			parent.velocity = Vector2.LEFT
			if !parent.sprite.flip_h:
				parent.sprite.flip_h = true
		states.walk_right:
			parent.sprite.play("walk")
			if parent.sprite.flip_h:
				parent.sprite.flip_h = false
			parent.velocity = Vector2.RIGHT
		states.walk_through_wall_left:
			parent.sprite.play("walk")
			parent.velocity = Vector2.LEFT
			parent.set_collision_mask_bit(2, false)
		states.walk_through_wall_right:
			parent.sprite.play("walk")
			parent.velocity = Vector2.RIGHT
			parent.set_collision_mask_bit(2, false)

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
		possibilities.shuffle()
		var move = possibilities[randi() % possibilities.size()]
		return move
	return null
