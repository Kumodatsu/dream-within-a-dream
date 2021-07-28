extends KinematicBody2D

# "Say hello to my little friend!"
# -Rake Ricardo, 2014

enum Direction {
    LEFT  = -1,
    RIGHT =  1
}

# Horizontal speed when moving.
export            var max_speed: float = 130.0
# Direction the enemy is walking.
export(Direction) var direction: int   = Direction.LEFT

var velocity: Vector2 = Vector2.ZERO

onready var ray_offset: float = $FloorRay.position.x

func _ready():
    change_direction(direction)
    $Timer.start()

func _physics_process(_delta: float):
    velocity = move_and_slide(velocity, Vector2.UP)
    if is_on_wall() or not $FloorRay.is_colliding():
        change_direction(-1 * direction)

func die():
    queue_free()

func change_direction(dir: int):
    direction              = dir
    velocity.x             = direction * max_speed
    $AnimatedSprite.flip_h = direction == Direction.LEFT
    $FloorRay.position.x   = ray_offset \
                           + direction * $CollisionShape2D.shape.extents.x

func shoot():
    var bullet  = load("res://entities/Bullet.tscn").instance()
    var offset = Vector2(direction * 50.0, 0.0)
    
    bullet.position         = position + offset
    bullet.rotation_degrees = 0.0 if direction == Direction.RIGHT else 180.0
    bullet.get_node("Sprite").flip_h = scale.x < 0.0
    
    get_tree().get_root().add_child(bullet)
    $GunshotSound.play()

func _on_body_entered(body: Node):
    if body.get_collision_layer() == 1:
        body.change_health(-1)

func _on_timeout():
    velocity.x = 0.0
    $AnimatedSprite.play("crouch")

func _on_animation_finished():
    match $AnimatedSprite.animation:
        "crouch":
            shoot()
            $AnimatedSprite.play("stand-up")
        "stand-up":
            velocity.x = direction * max_speed
            $AnimatedSprite.play("walk")
            $Timer.start()
