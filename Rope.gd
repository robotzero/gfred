extends Area2D
class_name Rope

var fred: Fred = null

func _on_Rope_body_entered(body):
	if body is Fred:
		fred = body


func _on_Rope_body_exited(body):
	if body is Fred:
		fred = null
