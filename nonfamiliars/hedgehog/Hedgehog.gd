extends KinematicBody2D

var speed = 45
var velocity = Vector2()
var direction = 1
var normalized_direction = 1
var collision_point = Vector2.ZERO

func _ready():
	if normalized_direction == -1:
		$Sprite.flip_h = true
	$floor_checker.position.x = $CollisionShape2D.shape.get_extents().x * normalized_direction

func _physics_process(delta):
	if is_on_wall() or not $floor_checker.is_colliding() and is_on_floor():
		normalized_direction = normalized_direction * -1
		$Sprite.flip_h = not $Sprite.flip_h
		$floor_checker.position.x = $CollisionShape2D.shape.get_extents().x * normalized_direction
	if $bounce_checker.is_colliding() and is_on_floor():
		collision_point = $bounce_checker.get_collision_point();
		velocity.y = -30
	elif Vector2(0, collision_point.y).distance_to(Vector2(0, position.y)) > 5:
		velocity.y = 30
	velocity.x = speed * normalized_direction
	velocity = move_and_slide(velocity, Vector2.UP)
