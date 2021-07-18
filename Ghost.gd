extends KinematicBody2D
class_name Ghost

const SPEED:int = 250
var velocity: Vector2 = Vector2.RIGHT
var collision = null
var ropeCollider = null
var isClimbing:bool = false

onready var sprite = $AnimatedSprite

#func _ready():
#	$AnimatedSprite.play("walk")

#func _physics_process(delta):
#	velocity = velocity.normalized() * SPEED
#	randomize()
#	var collision = move_and_collide(velocity * delta)
	#if collision and collision.normal.y != -1 and collision.collider is ExternalPyramid:
	#	print(collision.collider)
	#	print(collision.normal.y)
	#	print(collision.normal.x)
		
	
#	if collision and collision.normal.y != -1 and collision.normal.x != 0 and collision.collider is ExternalPyramid:
#		random.randomize()
#		var rand = random.randi_range(0, 1)
#		if ropeCollider:
#			rand = random.randi_range(0, 3)
#
#		if rand == 2:
#			velocity.y = 1
#			if position.x != ropeCollider.position.x:
#				position.x = ropeCollider.position.x
#		elif rand == 3:
#			velocity.y = -1
#			if position.x != ropeCollider.position.x:
#				position.x = ropeCollider.position.x
#		elif rand == 0:
#			rand = -1
#			velocity.x = rand
#		elif rand == 1:
#			velocity.x = rand
		
func _move(delta):
	velocity = velocity.normalized() * SPEED
	collision = move_and_collide(velocity * delta)
	
func setRopeCollider(rope):
	ropeCollider = rope
