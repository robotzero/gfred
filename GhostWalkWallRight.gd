extends Node
class_name GhostWalkWallRight

@onready var ghostStateMachine = get_parent()
@onready var ghost: Ghost = get_parent().get_parent()

var printed = false
var DISTANCE_LEFT = 32 + 14
var collision_point = Vector2.ZERO
var saved = false

# Establish raycast distance to start decisioning when walking through wall stopped
# You are going right, check left cast on each frame, colliding with internal
# If exited the wall:
# check up raycast 
# collides with internal, add go up through wall
# does not collide with wall, add go up
# check bottom raycast
# collides with internal add go down through wall
# does not collide with wall add go down
# Check right cast
# Colliding with internal, go through wall
# Not colliding go right

func handle():
	var rayCastLeft = ghost.leftCast
	var rayCastRight = ghost.rightCast
	var rayCastUp = ghost.topFloor
	var rayCastDown = ghost.bottomFloor
	var possibilities = ghostStateMachine.possibilities as Array
	if rayCastLeft.is_colliding():
		if !saved:
			collision_point = Vector2(rayCastLeft.get_collision_point().x, 0)
			saved = true
		if !printed:
			#print(rayCastLeft.get_collision_point())
			#print(ghost.position.x)
			printed = true
	if collision_point.x != 0:
		if Vector2(ghost.position.x, 0).distance_to(Vector2(collision_point.x, 0)) > DISTANCE_LEFT:
			ghost.velocity = Vector2.ZERO
			saved = false
			collision_point = Vector2.ZERO
			if rayCastRight.get_collider() is InternalPyramid:
				possibilities.append(6)
			else:
				possibilities.append(2)
				
			if rayCastUp.is_colliding():
				if rayCastUp.get_collider()	is InternalPyramid:
					possibilities.append(7)
			else:
				possibilities.append(3)
			if rayCastDown.is_colliding():
				if rayCastDown.get_collider() is InternalPyramid:
					possibilities.append(8)
			else:
				possibilities.append(4)
			
	#if !possibilities.size() == 0:
	#	print(possibilities)
