extends KinematicBody2D
class_name Fred

var velocity:Vector2 = Vector2(0, 0)
const STONE_HEIGHT:int = 40
const DISTANCE_TO_FLOOR_WHEN_CLIMBING:int = 24
const DISTANCE_OF_THE_JUMP_OFF:int = 28
const SPEED:int = 50
const JUMP_HEIGHT:int = -10
const GRAVITY:int = 0
const SIMPLE_JUMP_INPX:int = -int(STONE_HEIGHT * 0.2)
const CLIMB_COLLIDE_APRON:int = 5
var isJumping:bool = false
var isOnTheFloor:bool = true
var isWalking:bool = true
var climbing:bool = false
var currentRopeCollider:Rope = null
var previousRopeCollider:Rope = null
var jumpingOff:bool = false
var flipping:bool = false
var jumpTo:int = 0

onready var fredRaycast:RayCast2D = $FloorCast
onready var lineCastLeft:RayCast2D = $LineCastLeft
onready var lineCastRight:RayCast2D = $LineCastRight
onready var tileMapCastLeft:RayCast2D = $TileMapCastLeft
onready var tileMapCastRight:RayCast2D = $TileMapCastRight

func _physics_process(delta):
	velocity = Vector2(0, 0)
	if Input.is_action_just_pressed("right") and !Input.is_action_just_pressed("left") and !isJumping and !jumpingOff and !flipping:
		if climbing:
			if $Sprite.flip_h:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = true
			flipping = true
			$FlipTimer.start()
				
	if Input.is_action_just_pressed("left") and !Input.is_action_just_pressed("right") and !isJumping and !jumpingOff and !flipping:
		if climbing:
			if $Sprite.flip_h:
				$Sprite.flip_h = false
			else:
				$Sprite.flip_h = false
			flipping = true
			$FlipTimer.start()
	
	if Input.is_action_pressed("right") and !Input.is_action_pressed("left") and !Input.is_action_just_pressed("right") and !isJumping and !jumpingOff and !flipping:
		if climbing:
			var stop = false
			if test_move(transform, Vector2(position.x + CLIMB_COLLIDE_APRON, position.y)):
				stop = false
			if $Sprite.flip_h and not flipping and not stop and not (tileMapCastRight.is_colliding() and tileMapCastRight.get_collider() is TileMap):
				$Sprite.play("jump")
				$Sprite.flip_h = false
				jumpingOff = true
				previousRopeCollider = currentRopeCollider
				jumpTo = 1
		else:
			velocity.x += 1
			$Sprite.flip_h = false
			$Sprite.play("walk")
			isWalking = true
	elif Input.is_action_pressed("left") and !Input.is_action_pressed("right") and !Input.is_action_just_pressed("left") and !isJumping and !jumpingOff and !flipping:
		if climbing:
			var stop = false
			if test_move(transform, Vector2(position.x - CLIMB_COLLIDE_APRON, position.y)):
				stop = false
			if not $Sprite.flip_h and not flipping and not stop and not (tileMapCastLeft.is_colliding() and tileMapCastLeft.get_collider() is TileMap):
				$Sprite.play("jump")
				$Sprite.flip_h = true
				jumpingOff = true
				previousRopeCollider = currentRopeCollider
				jumpTo = -1
		else:
			velocity.x -= 1
			$Sprite.flip_h = true
			$Sprite.play("walk")
			isWalking = true
	elif Input.is_action_pressed("up") and !isJumping and climbing and !jumpingOff:
		velocity.y -= 1
	elif Input.is_action_pressed("down") and !isJumping and climbing and !jumpingOff:
		if !shouldStopGoingDown():
			velocity.y += 1
	elif climbing == false and !jumpingOff:
		$Sprite.play("idle")
		isWalking = false
	
	if Input.is_action_just_pressed("jump") and !isWalking and !isJumping and isOnTheFloor and !jumpingOff:
		position.y = position.y + SIMPLE_JUMP_INPX
		climbing = isNearLineVicinity()
		if (climbing):
			var newPosX = calculateCorrectedVerticalPosition()
			position.x = newPosX
		isJumping = true
		$Sprite.play("jump")
		$JumpTimer.start()
		
	if isJumping:
		$Sprite.play("jump")
		
	if jumpingOff:
		var distance = Vector2(previousRopeCollider.position.x, 0).distance_to(Vector2(position.x, 0))
		if not distance > DISTANCE_OF_THE_JUMP_OFF:
			velocity.x += jumpTo
		if $JumpTimer.is_stopped():
			$JumpTimer.start()
		
	velocity = velocity.normalized() * SPEED
	var collision = move_and_collide(velocity * delta)
	isOnTheFloor = is_on_floor_custom(collision)
		
func is_on_floor_custom(var collision):
	if collision != null and collision.normal.x == 0 and collision.normal.y == -1 and collision.collider is TileMap:
		return true
	if fredRaycast.is_colliding() and fredRaycast.get_collision_normal().y == -1 and fredRaycast.get_collider() is TileMap:
		return true
	return false
	
func shouldStopGoingDown():
	if fredRaycast.is_colliding() and fredRaycast.get_collision_normal().y == -1:
		var colliderPositionY = fredRaycast.get_collision_point().y
		var distance = Vector2(0, colliderPositionY).distance_to(Vector2(0, position.y))
		if distance < DISTANCE_TO_FLOOR_WHEN_CLIMBING:
			return true
		return false
		
func _on_JumpTimer_timeout():
	$JumpTimer.stop()
	isJumping = false
	if jumpingOff:
		climbing = false
		jumpingOff = false
		jumpTo = 0
		$Sprite.play("idle")
	if climbing:
		$Sprite.play("climb")
	else:
		position.y = position.y - SIMPLE_JUMP_INPX

func isNearLineVicinity():
	if $Sprite.flip_h and lineCastLeft.is_colliding() and lineCastLeft.get_collision_normal().x == 1:
		currentRopeCollider = lineCastLeft.get_collider()
		return true
	elif $Sprite.flip_h == false and lineCastRight.is_colliding() and lineCastRight.get_collision_normal().x == -1:
		currentRopeCollider = lineCastRight.get_collider()
		return true
	currentRopeCollider = null
	return false

func calculateCorrectedVerticalPosition():
	if currentRopeCollider:
		var currentPos = currentRopeCollider.position.x
		var fredPos = position.x
		return currentPos + 1
	return 0


func _on_FlipTimer_timeout():
	$FlipTimer.stop()
	flipping = false
