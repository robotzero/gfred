extends KinematicBody2D
class_name Fred

var velocity:Vector2 = Vector2(0, 0)
const STONE_HEIGHT:int = 40
const DISTANCE_TO_FLOOR_WHEN_CLIMBING:int = 22
const DISTANCE_OF_THE_JUMP_OFF:int = 28
const DISTANCE_OF_THE_JUMP_ON:int = 1
const VELOCITY_JUMP_ON:float = 0.195
const SPEED:int = 50
const GRAVITY:int = 0
const SIMPLE_JUMP_INPX:int = -int(STONE_HEIGHT * 0.150)
const CLIMB_COLLIDE_APRON:int = 5
var isJumping:bool = false
var isOnTheFloor:bool = true
var isWalking:bool = true
var climbing:bool = false
var currentRopeCollider:Rope = null
var previousRopeCollider:Rope = null
var jumpingOnCollider:Rope = null
var jumpingOff:bool = false
var flipping:bool = false
var jumpingOn:bool = false
var jumpTo:int = 0

onready var fredRaycast:RayCast2D = $FloorCast
onready var lineCastLeft:RayCast2D = $LineCastLeft
onready var lineCastRight:RayCast2D = $LineCastRight
onready var tileMapCastLeft1:RayCast2D = $TileMapCastLeft
onready var tileMapCastRight1:RayCast2D = $TileMapCastRight
onready var tileMapCastLeft2:RayCast2D = $TileMapCastLeft2
onready var tileMapCastRight2:RayCast2D = $TileMapCastRight2

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
		
	if Input.is_action_pressed("right") and !Input.is_action_pressed("left") and !Input.is_action_just_pressed("right") and !isJumping and !jumpingOff and !flipping and !jumpingOn:
		if climbing:
			if $Sprite.flip_h and not flipping and not shouldStopJumpingOff(tileMapCastRight1) and not shouldStopJumpingOff(tileMapCastRight2):
				$Sprite.play("jump")
				$Sprite.flip_h = false
				jumpingOff = true
				previousRopeCollider = currentRopeCollider
				jumpTo = 1
		elif shouldStartJumpingOn(tileMapCastRight1) and shouldStartJumpingOn(tileMapCastRight2):
			jumpTo = 1
			$Sprite.play("jump")
			jumpingOn = true
			jumpingOnCollider = tileMapCastRight1.get_collider()
			startJumpingOn(tileMapCastRight1.get_collider())
		else:
			velocity.x += 1
			$Sprite.flip_h = false
			$Sprite.play("walk")
			isWalking = true
	elif Input.is_action_pressed("left") and !Input.is_action_pressed("right") and !Input.is_action_just_pressed("left") and !isJumping and !jumpingOff and !flipping and !jumpingOn:
		if climbing:
			if not $Sprite.flip_h and not flipping and not shouldStopJumpingOff(tileMapCastLeft1) and not shouldStopJumpingOff(tileMapCastLeft2):
				$Sprite.play("jump")
				$Sprite.flip_h = true
				jumpingOff = true
				previousRopeCollider = currentRopeCollider
				jumpTo = -1
		elif shouldStartJumpingOn(tileMapCastLeft1) and shouldStartJumpingOn(tileMapCastLeft2):
			jumpTo = -1
			$Sprite.play("jump")
			jumpingOn = true
			jumpingOnCollider = tileMapCastLeft1.get_collider()
			startJumpingOn(tileMapCastLeft1.get_collider())
		else:
			velocity.x -= 1
			$Sprite.flip_h = true
			$Sprite.play("walk")
			isWalking = true
	elif Input.is_action_pressed("up") and !isJumping and climbing and !jumpingOff and !jumpingOn:
		velocity.y -= 1
	elif Input.is_action_pressed("down") and !isJumping and climbing and !jumpingOff and !jumpingOn:
		if !shouldStopGoingDown():
			velocity.y += 1
	elif climbing == false and !jumpingOff and !jumpingOn:
		$Sprite.play("idle")
		isWalking = false
	
	if Input.is_action_just_pressed("jump") and !isWalking and !isJumping and isOnTheFloor and !jumpingOff and !jumpingOn:
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
		var distanceX = Vector2(previousRopeCollider.position.x, 0).distance_to(Vector2(position.x, 0))
		if not distanceX > DISTANCE_OF_THE_JUMP_OFF:
			velocity.x += jumpTo
		if $JumpTimer.is_stopped():
			$JumpTimer.start()
	
	if jumpingOn:
		startJumpingOn(jumpingOnCollider)
			
	velocity = velocity.normalized() * SPEED
	var collision = move_and_collide(velocity * delta)
	isOnTheFloor = is_on_floor_custom(collision)
	
	
func startJumpingOn(rope):
	jumpingOn = true
	var distanceX = Vector2(rope.position.x, 0).distance_to(Vector2(position.x, 0))
	if distanceX > DISTANCE_OF_THE_JUMP_ON:
		velocity.x += jumpTo
		velocity.y -= VELOCITY_JUMP_ON
	if $JumpTimer.is_stopped():
		$JumpTimer.start()

		
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
		position.y = position.y - SIMPLE_JUMP_INPX
	if jumpingOn:
		jumpTo = 0
		climbing = false
		jumpingOn = false
		$Sprite.play("climb")
		climbing = true
		position.x = jumpingOnCollider.position.x + 1
		jumpingOnCollider = null
	if climbing:
		$Sprite.play("climb")
	else:
		position.y = position.y - SIMPLE_JUMP_INPX

func isNearLineVicinity():
	if currentRopeCollider:
		return true
	if $Sprite.flip_h and lineCastLeft.is_colliding() and lineCastLeft.get_collision_normal().x == 1:
		currentRopeCollider = lineCastLeft.get_collider()
		return true
	elif $Sprite.flip_h == false and lineCastRight.is_colliding() and lineCastRight.get_collision_normal().x == -1:
		currentRopeCollider = lineCastRight.get_collider()
		return true
	if currentRopeCollider == null:
		return false
	if currentRopeCollider:
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
	
func setRopeCollider(ropeCollider):
	currentRopeCollider = ropeCollider
	
func isClimbing():
	return climbing
	
func shouldStopJumpingOff(tileMapCast):
	print(tileMapCast.get_collider())
	return tileMapCast.is_colliding() and tileMapCast.get_collider() is TileMap
	
func shouldStartJumpingOn(tileMapCast):
	var collider = tileMapCast.get_collider()
	if collider is Rope:
		var rope = collider as Rope
		return tileMapCast.is_colliding() and not rope.isBottom
	return false

