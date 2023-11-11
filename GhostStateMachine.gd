extends StateMachine

var random: RandomNumberGenerator
var possibilities = []
var ghost_wall_collision = null
@onready var ghostWalkLeft = $GhostWalkLeftHandler
@onready var ghostWalkRight = $GhostWalkRightHandler
@onready var ghostWalkWallRight = $GhostWalkWallRightHandler
@onready var ghostWalkWallLeft = $GhostWalkWallLeftHandler
@onready var ghostWalkDown = $GhostWalkDownHandler
@onready var ghostWalkUp = $GhostWalkUpHandler
@onready var ghostWalkWallDown = $GhostWalkWallDownHandler
@onready var ghostWalkWallUp = $GhostWalkWallUpHandler

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
	call_deferred("set_state", states.walk_left)
	
	
func _state_logic(delta):
	parent._move(delta)

func _get_transition(_delta):
	# 1 - LEFT 2 - RIGHT 3 - UP 4 - DOWN 5 - LEFT WALL 6 - RIGHT WALL 7 - UP WALL 8 - DOWN WALL
	possibilities.clear()
	match state:
		states.walk_left:
			ghostWalkLeft.handle()
		states.walk_right:
			ghostWalkRight.handle()
		states.walk_through_wall_left:
			ghostWalkWallLeft.handle()
		states.walk_through_wall_right:
			ghostWalkWallRight.handle()
		states.climb_through_wall_up:
			ghostWalkWallUp.handle()
		states.climb_through_wall_down:
			ghostWalkWallDown.handle()
		states.climb_up:
			ghostWalkUp.handle()
		states.climb_down:
			ghostWalkDown.handle()
					
	var choosen_index = _calculate_possibility()
	if choosen_index:
		return states[possibilities_state_map.get(choosen_index)]
	return null
			
func _enter_state(new_state, old_state):
	match new_state:
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
			parent.set_collision_mask_value(2, false)
			ghost_wall_collision = parent.collision;
			parent.velocity = Vector2.LEFT
		states.walk_through_wall_right:
			parent.sprite.play("walk")
			parent.set_collision_mask_value(2, false)
			ghost_wall_collision = parent.collision;
			parent.velocity = Vector2.RIGHT
		states.climb_through_wall_up:
			if parent.collision != null:
				ghost_wall_collision = parent.collision;
			parent.sprite.play("walk")
			parent.set_collision_mask_value(2, false)
			parent.velocity = Vector2.UP
		states.climb_through_wall_down:
			if parent.collision != null:
				ghost_wall_collision = parent.collision;
			parent.sprite.play("walk")
			parent.set_collision_mask_value(2, false)
			parent.velocity = Vector2.DOWN

func _exit_state(old_state, new_state):
	match new_state:
		states.walk_right, states.walk_left:
			if old_state == states.walk_through_wall_left:
				ghost_wall_collision = null
				parent.set_collision_mask_value(2, true)
			if old_state == states.walk_through_wall_right:
				ghost_wall_collision = null
				parent.set_collision_mask_value(2, true)
			if old_state == states.climb_through_wall_up:
				ghost_wall_collision = null
				parent.set_collision_mask_value(2, true)
			if old_state == states.climb_through_wall_down:
				ghost_wall_collision = null
				parent.set_collision_mask_value(2, true)

func _ghost_rope_distance():
	var distance = Vector2(parent.ropeCollider.position.x, 0).distance_to(Vector2(parent.position.x, 0))
	#TODO potential issues with distance, when ghost is hitting wall, make sure that it is possible to have both
	if distance < 1:
		return true
	return false

func _calculate_possibility():
	if !possibilities.is_empty():
		randomize()
		possibilities.shuffle()
		var move = possibilities[randi() % possibilities.size()]
		#if possibilities.has(7):
		#	return 7
		return move
	return null
