extends Area2D
class_name Rope

var fred = null
var ghost:Ghost = null
var isBottom: bool = false
var blah:ExternalPyramid = null

func _on_Rope_body_entered(body):
	if body is Ghost:
		ghost = body
		ghost.setRopeCollider(self)
	elif body is KinematicBody2D:
		fred = body
		fred.setRopeCollider(self)


func _on_Rope_body_exited(body):
	if body is Ghost:
		ghost.setRopeCollider(null)
		ghost = null
	elif body is KinematicBody2D:
		if not [fred.fredStateMachine.states.climb].has(fred._get_state()):
			fred.setRopeCollider(null)
			fred = null
