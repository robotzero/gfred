extends KinematicBody2D
class_name Fred

var velocity:Vector2 = Vector2.ZERO
const STONE_HEIGHT:int = 40
const DISTANCE_TO_FLOOR_WHEN_CLIMBING:int = 22
const DISTANCE_OF_THE_JUMP_OFF:int = 28
const DISTANCE_OF_THE_JUMP_ON:int = 1
const VELOCITY_JUMP_ON:float = 0.600
const SPEED:int = 50
const GRAVITY:int = 0
const SIMPLE_JUMP_INPX:int = -int(STONE_HEIGHT * 0.185)
const CLIMB_COLLIDE_APRON:int = 5
var isOnTheFloor:bool = true
var currentRopeCollider:Rope = null
var previousRopeCollider:Rope = null
var jumpingOnCollider:Rope = null
var jumpTo:int = 0

onready var fredRaycast:RayCast2D = $FloorCast
onready var tileMapCastLeft1:RayCast2D = $TileMapCastLeft
onready var tileMapCastRight1:RayCast2D = $TileMapCastRight
onready var tileMapCastLeft2:RayCast2D = $TileMapCastLeft2
onready var tileMapCastRight2:RayCast2D = $TileMapCastRight2
onready var sprite:AnimatedSprite = $Sprite
onready var jumpTimer:Timer = $JumpTimer
onready var fredStateMachine = $StateMachine
onready var flipTimer = $FlipTimer
	
func _get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right") and !Input.is_action_just_pressed("left") and not [fredStateMachine.states.climb, fredStateMachine.states.jump, fredStateMachine.states.flip_right, fredStateMachine.states.flip_left, fredStateMachine.states.jump_off_left, fredStateMachine.states.jump_off_right].has(_get_state()):
		velocity.x -= 1
	elif Input.is_action_pressed("left") and !Input.is_action_pressed("right") and !Input.is_action_just_pressed("left") and [fredStateMachine.states.climb].has(_get_state()) and not [fredStateMachine.states.jump_off_left, fredStateMachine.states.jump_off_right].has(_get_state()):
		if not $Sprite.flip_h and not shouldStopJumpingOff(tileMapCastLeft1) and not shouldStopJumpingOff(tileMapCastLeft2):
			fredStateMachine.set_state(fredStateMachine.states.jump_off_left)
		else:
			fredStateMachine.set_state(fredStateMachine.states.flip_left)
	elif Input.is_action_pressed("right") and !Input.is_action_pressed("left") and !Input.is_action_just_pressed("right") and not [fredStateMachine.states.climb, fredStateMachine.states.jump, fredStateMachine.states.flip_right, fredStateMachine.states.flip_left, fredStateMachine.states.jump_off_right, fredStateMachine.states.jump_off_left].has(_get_state()):
		velocity.x += 1
	elif Input.is_action_pressed("right") and !Input.is_action_pressed("left") and !Input.is_action_just_pressed("right") and [fredStateMachine.states.climb].has(_get_state()) and not [fredStateMachine.states.jump_off_left, fredStateMachine.states.jump_off_right].has(_get_state()):
		if $Sprite.flip_h and not shouldStopJumpingOff(tileMapCastRight1) and not shouldStopJumpingOff(tileMapCastRight2):
			fredStateMachine.set_state(fredStateMachine.states.jump_off_right)
		else:
			fredStateMachine.set_state(fredStateMachine.states.flip_right)
	elif Input.is_action_pressed("up") and !Input.is_action_pressed("right") and !Input.is_action_pressed("left") and !Input.is_action_just_pressed("down") and not [fredStateMachine.states.walk, fredStateMachine.states.jump].has(_get_state()):
		velocity.y -= 1
	elif Input.is_action_pressed("down") and !shouldStopGoingDown() and !Input.is_action_pressed("right") and !Input.is_action_pressed("left") and !Input.is_action_just_pressed("up") and not [fredStateMachine.states.walk, fredStateMachine.states.jump].has(_get_state()):
		velocity.y += 1
	elif Input.is_action_just_pressed("jump") and !isNearLineVicinity():
		fredStateMachine.set_state(fredStateMachine.states.jump)
	elif Input.is_action_just_pressed("jump") and isNearLineVicinity():
		fredStateMachine.set_state(fredStateMachine.states.start_climb)

func _move(delta):
	velocity = velocity.normalized() * SPEED
	var collision = move_and_collide(velocity * delta)
	isOnTheFloor = is_on_floor_custom(collision)
	
func startJumpingOn(rope):
	if rope != null:
		var distanceX = Vector2(rope.position.x, 0).distance_to(Vector2(position.x, 0))
		if distanceX > DISTANCE_OF_THE_JUMP_ON:
			velocity.x += jumpTo
			velocity.y -= VELOCITY_JUMP_ON

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

func isNearLineVicinity():
	if currentRopeCollider:
		return true
	return false

func calculateCorrectedVerticalPosition():
	if currentRopeCollider:
		var currentPos = currentRopeCollider.position.x
		return currentPos + 1
	return 0

func _on_FlipTimer_timeout():
	$FlipTimer.stop()
	
func setRopeCollider(ropeCollider):
	currentRopeCollider = ropeCollider
	
func shouldStopJumpingOff(tileMapCast):
	return tileMapCast.is_colliding() and tileMapCast.get_collider() is TileMap
	
func shouldStartJumpingOn(tileMapCast):
	var collider = tileMapCast.get_collider()
	if collider is Rope:
		var rope = collider as Rope
		return tileMapCast.is_colliding() and not rope.isBottom
	return false

func _get_state():
	return fredStateMachine.state
