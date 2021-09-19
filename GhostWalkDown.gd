extends Node
class_name GhostWalkDown

onready var ghostStateMachine = get_parent()
onready var ghost: Ghost = get_parent().get_parent()

var printed = false

# Establish raycast distance to start decisioning
# You are going down, check down cast on each frame, colliding with internal
# pyramid: add go through wall down, add go up
# pyramid is external add go up
# either pyramid
# check left raycast
# collides with internal, add go left through wall
# else add go left
# check right raycast
# collides with internal, add go right through wall
# else add go right


func handle():
	var rayCastLeft = ghost.leftCast
	var rayCastRight = ghost.rightCast
	var rayCastUp = ghost.topFloor
	var rayCastDown = ghost.bottomFloor
	var possibilities = ghostStateMachine.possibilities as Array
	
	if rayCastDown.is_colliding():
		if !printed:
			print("DOWN")
			print(rayCastDown.get_collision_point())
			print(ghost.position.x)
		ghost.velocity = Vector2.ZERO
		
		possibilities.append(3)
		if rayCastDown.get_collider() is InternalPyramid:
			possibilities.append(8)
			
		if rayCastLeft.is_colliding():
			if rayCastLeft.get_collider() is InternalPyramid:
				possibilities.append(5)
		else:
			possibilities.append(1)
			
		if rayCastRight.is_colliding():
			if rayCastRight.get_collider() is InternalPyramid:
				possibilities.append(6)
		else:
			possibilities.append(2)
		
		possibilities.clear()
		printed = true
