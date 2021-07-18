extends KinematicBody2D
class_name Ghost

const SPEED:int = 250
var velocity: Vector2 = Vector2.RIGHT
var collision = null
var ropeCollider = null
enum floorType {BOTTOM_INTERNAL, BOTTOM_EXTERNAL}
var fl = null


onready var sprite = $AnimatedSprite
onready var bottomFloor = $BottomFloorRayCast
		
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
