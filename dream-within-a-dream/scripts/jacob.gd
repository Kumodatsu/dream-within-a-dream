extends KinematicBody2D

# "I hope you didn't bring all of your dignity with you, 'cuz there'll be
# nothing left when I'm done with you."
# -Jacob Freud, 1896

enum Direction {
    LEFT  = -1,
    RIGHT =  1
}

# Horizontal speed when moving.
export            var max_speed:      float = 150.0
# How fast the player accelerates down while airborne.
export            var gravity:        float = 20.0
# The vertical speed at which the player stops accelerating while falling.
export            var max_fall_speed: float = 600.0
# Initial upwards speed when starting a jump.
export            var jump_force:     float = 390.0
# Number of airborne jumps that can be performed before touching the ground. 
export            var max_air_jumps:  int   = 1
# Number of hits the player can take before dying.
export            var max_health:     int   = 3
# The maximum angle in degrees the arm is allowed to make with the x-axis.
export            var max_arm_angle:  float = 85.0
# The direction the player is walking.
export(Direction) var direction:      int   = Direction.RIGHT

signal health_changed

onready var arm_offset: Vector2 = $Arm.position

var velocity:  Vector2 = Vector2.ZERO
var air_jumps: int     = max_air_jumps
var health:    int     = max_health

func _ready():
    emit_signal("health_changed", health, max_health)
    change_direction(direction)

func _input(event: InputEvent):
    if event.is_action_pressed("player_shoot"):
        var bullet = load("res://entities/Bullet.tscn").instance()
        bullet.is_enemy         = false
        bullet.position         = $Arm.global_position
        bullet.rotation_degrees = $Arm.rotation_degrees
        get_tree().get_root().add_child(bullet)
        $GunshotSound.play()

func _physics_process(_delta: float):
    var on_floor = is_on_floor()
    # Body movement
    if on_floor:
        air_jumps = max_air_jumps
    velocity.x = 0.0
    if Input.is_action_pressed("player_move_left"):
        velocity.x = -max_speed
    if Input.is_action_pressed("player_move_right"):
        velocity.x = max_speed
    if velocity.x != 0.0 and direction != sign(velocity.x):
        change_direction(-direction)
    velocity.y = clamp(velocity.y + gravity, -INF, max_fall_speed)
    if Input.is_action_just_pressed("player_jump") and can_jump(on_floor):
        jump(on_floor)
    velocity = move_and_slide(velocity, Vector2.UP)
    # Arm movement
    var aim_pos: Vector2 = get_global_mouse_position()
    var arm_pos: Vector2 = $Arm.global_position
    var aim_dir: Vector2 = aim_pos - arm_pos
    if aim_dir != Vector2.ZERO:
        aim_dir = aim_dir.normalized()
        rotate_arm(aim_dir)
    # Animation
    handle_animations(on_floor)

func can_jump(on_floor: bool) -> bool:
    return on_floor or air_jumps > 0

func jump(on_floor: bool):
    if not on_floor:
        air_jumps -= 1
    velocity.y = -jump_force

func change_health(n: int):
    health = health + n
    if health > max_health:
        health = max_health
    emit_signal("health_changed", health, max_health)
    if health <= 0:
        die()

func die():
    LevelManager.die()
    LevelManager.return_to_current_level()

func rotate_arm(aim_dir: Vector2):
    var angle: float = rad2deg(aim_dir.angle())
    match direction:
        Direction.LEFT:
            if 180.0 - abs(angle) > max_arm_angle:
                angle = sign(angle) * (180.0 - max_arm_angle)
        Direction.RIGHT:
            if abs(angle) > max_arm_angle:
                angle = sign(angle) * max_arm_angle
    $Arm.rotation_degrees = angle

func handle_animations(on_floor: bool):
    if not on_floor:
        $AnimatedSprite.play("Air")
    elif abs(velocity.x) != 0.0:
        $AnimatedSprite.play("Walk")
    else:
        $AnimatedSprite.play("Idle")

func change_direction(dir: int):
    direction                    = dir
    $AnimatedSprite.flip_h       = direction == Direction.LEFT
    $Arm/Sprite.flip_v           = direction == Direction.LEFT
    $Arm.position.x              = direction * arm_offset.x
    $CollisionShape2D.position.x = -direction \
                                 * abs($CollisionShape2D.position.x)

func _on_death_zone_entered(body: Node):
    if body == self:
        die()
