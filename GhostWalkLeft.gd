extends Node
class_name GhostWalkLeft

@onready var ghostStateMachine = get_parent()
@onready var ghost: Ghost = get_parent().get_parent()

var printed = false
var DISTANCE_LEFT = 16

# Establish raycast distance to start decisioning
# You are going left, check left cast on each frame, colliding with internal
# pyramid: add go through wall left, add go right
# pyramid is external add go right
# either pyarmid
# check up raycast 
# collides with internal, add go up through wall
# does not collide with wall, add go up
# check bottom raycast
# collides with internal add go down through wall
# does not collide with wall add go down

func handle():
	var rayCastLeft = ghost.leftCast
	var rayCastUp = ghost.topFloor
	var rayCastDown = ghost.bottomFloor
	var possibilities = ghostStateMachine.possibilities as Array
	if rayCastLeft.is_colliding():
		if !printed:
			#print(rayCastLeft.get_collision_point())
			#print(ghost.position.x)
			print("LEFT")
		if Vector2(ghost.position.x, 0).distance_to(Vector2(rayCastLeft.get_collision_point().x, 0)) < DISTANCE_LEFT:
			ghost.velocity = Vector2.ZERO
			possibilities.append(2)
			if rayCastLeft.get_collider() is InternalPyramid:
				possibilities.append(5)
			
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
		
		printed = true
