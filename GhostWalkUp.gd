extends Node
class_name GhostWalkUp

onready var ghostStateMachine = get_parent()
onready var ghost: Ghost = get_parent().get_parent()

var printed = false

# Establish raycast distance to start decisioning
# You are going up, check up cast on each frame, colliding with internal
# pyramid: add go through wall up, add go down
# pyramid is external add go down
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
	
	if rayCastUp.is_colliding():
		if !printed:
			print(rayCastUp.get_collision_point())
			print(ghost.position.x)
			print("UP")
		ghost.velocity = Vector2.ZERO
		
		possibilities.append(4)
		if rayCastUp.get_collider() is InternalPyramid:
			possibilities.append(7)
			
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
