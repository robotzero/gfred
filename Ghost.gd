extends KinematicBody2D
class_name Ghost

const SPEED:int = 50
var velocity: Vector2 = Vector2.RIGHT
var collision = null
var ropeCollider = null
enum floorType {BOTTOM_INTERNAL, BOTTOM_EXTERNAL}
enum collideType {UP, BOTTOM, LEFT, RIGHt}
var fl = null


onready var sprite = $AnimatedSprite
onready var bottomFloor = $BottomFloorRayCast
onready var topFloor = $UpFloorRayCast
onready var rightCast = $RightRayCast
onready var leftCast = $LeftRayCast
		
func _move(delta):
	velocity = velocity.normalized() * SPEED
	collision = move_and_collide(velocity * delta)
	fl = is_on_floor_custom(collision)
	
func is_on_floor_custom(var collision):
	if collision != null and collision.normal.x == 0 and collision.normal.y == -1 and collision.collider:
		if collision.collider is ExternalPyramid:
			return floorType.BOTTOM_EXTERNAL
		if collision.collider is InternalPyramid:
			return floorType.BOTTOM_INTERNAL
	if bottomFloor.is_colliding() and bottomFloor.get_collision_normal().y == -1:
		if bottomFloor.get_collider() is ExternalPyramid:
			return floorType.BOTTOM_EXTERNAL
		if bottomFloor.get_collider() is InternalPyramid:
			return floorType.BOTTOM_INTERNAL
	return null

func setRopeCollider(rope):
	ropeCollider = rope
		
func isAboutToCollide(var possibilities, var state):
	# 1 - LEFT 2 - RIGHT 3 - UP 4 - DOWN 5 - LEFT WALL 6 - RIGHT WALL 7 - UP WALL 8 - DOWN WALL

	
	if topFloor.is_colliding() and topFloor.get_collider() is InternalPyramid:
		possibilities.append(7)
	#@TODO check the type of the current state because we do not want to go up and then just go down immediately
	if bottomFloor.is_colliding() and bottomFloor.get_collider() is InternalPyramid:
		possibilities.append(8)
	if rightCast.is_colliding() and rightCast.get_collider() is InternalPyramid:
		possibilities.append(6)
	if leftCast.is_colliding() and leftCast.get_collider() is InternalPyramid:
		possibilities.append(5)
	return possibilities
	
func checkCollider(var raycast, var possibility, var possibilities):
	if raycast.is_colliding() and raycast.get_collider() is InternalPyramid:
		possibilities.append(possibility)
	return possibilities
