extends KinematicBody2D
class_name Ghost

const SPEED:int = 50
var velocity: Vector2 = Vector2(1, 0)
var random: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	$AnimatedSprite.play("walk")

func _physics_process(delta):
	velocity = velocity.normalized() * SPEED
	var collision = move_and_collide(velocity * delta)
	if collision and collision.collider is TileMap and collision.normal.y != -1 and collision.normal.x != 0 and not ExternalPyramid:
		velocity.x += random.randf_range(-1, 1)
		print(collision.normal)
