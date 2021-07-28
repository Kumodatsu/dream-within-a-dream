extends KinematicBody2D

enum Direction {
    LEFT  = -1,
    RIGHT =  1
}

# Horizontal speed when moving.
export            var max_speed:      float = 100.0
# Direction the enemy is walking.
export(Direction) var direction:      int   = Direction.LEFT
# How fast the enemy accelerates down while airborne.
export            var gravity:        float = 20.0
# The vertical speed at which the enemy stops accelerating while falling.
export            var max_fall_speed: float = 600.0

var velocity: Vector2 = Vector2.ZERO

onready var ray_offset: float = $FloorRay.position.x

func _ready():
    change_direction(direction)

func _physics_process(_delta: float):
    velocity.y = clamp(velocity.y + gravity, -INF, max_fall_speed)
    velocity   = move_and_slide(velocity, Vector2.UP)
    if is_on_wall() or is_on_floor() and not $FloorRay.is_colliding():
        change_direction(-1 * direction)

func die():
    queue_free()

func change_direction(dir: int):
    direction              = dir
    velocity.x             = direction * max_speed
    $AnimatedSprite.flip_h = direction == Direction.LEFT
    $FloorRay.position.x   = ray_offset \
                           + direction * $CollisionShape2D.shape.extents.x

func _on_body_entered(body: Node):
    body.change_health(-1)
