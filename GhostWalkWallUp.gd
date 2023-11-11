extends Node
class_name GhostWalkWallUp

@onready var ghostStateMachine = get_parent()
@onready var ghost: Ghost = get_parent().get_parent()

var printed = false
var DISTANCE_LEFT = 32 + 23
var collision_point = Vector2.ZERO
var saved = false

func handle():
	var rayCastLeft = ghost.leftCast
	var rayCastUp = ghost.topFloor
	var rayCastDown = ghost.bottomFloor
	var rayCastRight = ghost.rightCast
	var possibilities = ghostStateMachine.possibilities as Array
	
	if rayCastUp.is_colliding():
		if !saved:
			collision_point = Vector2(0, rayCastUp.get_collision_point().y)
			saved = true
		if !printed:
			print("WALL UP")
			#print(rayCastUp.get_collision_point())
			#print(ghost.position.y)
			printed = true
	if collision_point.y != 0:
		if Vector2(0, ghost.position.y).distance_to(Vector2(0, collision_point.y)) > DISTANCE_LEFT:
			ghost.velocity = Vector2.ZERO
			saved = false
			collision_point = Vector2.ZERO
			
			if rayCastLeft.get_collider() is InternalPyramid:
				possibilities.append(5)
			else:
				possibilities.append(1)
				
			if rayCastRight.get_collider() is InternalPyramid:
				possibilities.append(6)
			else:
				possibilities.append(2)
				
			if rayCastUp.get_collider() is InternalPyramid:
				possibilities.append(7)
			else:
				possibilities.append(3)
	
