extends KinematicBody2D
class_name Fred

var velocity:Vector2 = Vector2(0, 0)
const STONE_HEIGHT:int = 40
const SPEED:int = 50
const JUMP_HEIGHT:int = -10
const GRAVITY:int = 0
const SIMPLE_JUMP_INPX:int = -int(STONE_HEIGHT * 0.2)
var isJumping:bool = false
var isOnTheFloor:bool = true
var isWalking:bool = true

onready var fredRaycast:RayCast2D = $RayCast2D

func _physics_process(delta):
	velocity = Vector2(0, 0)
	if Input.is_action_pressed("right") and !isJumping:
		velocity.x += 1
		$Sprite.flip_h = false
		$Sprite.play("walk")
		isWalking = true
	elif Input.is_action_pressed("left") and !isJumping:
		velocity.x -= 1
		$Sprite.flip_h = true
		$Sprite.play("walk")
		isWalking = true
	else:
		$Sprite.play("idle")
		isWalking = false
	
	if Input.is_action_just_pressed("jump") and !isJumping and isOnTheFloor:
		position.y = position.y + SIMPLE_JUMP_INPX
		isJumping = true
		$Sprite.play("jump")
		$JumpTimer.start()
		
	if (isJumping):
		$Sprite.play("jump")
	
	velocity = velocity.normalized() * SPEED
	var collision = move_and_collide(velocity * delta)
	isOnTheFloor = is_on_floor_custom(collision)
		
func is_on_floor_custom(var collision):
	# @TODO only stone collision object
	if (collision != null and collision.normal.x == 0 and collision.normal.y == -1):
		return true
	if fredRaycast.is_colliding() and fredRaycast.get_collision_normal().y == -1 :
		return true
	return false
		

func _on_JumpTimer_timeout():
	$JumpTimer.stop()
	position.y = position.y - SIMPLE_JUMP_INPX
	isJumping = false
