extends KinematicBody2D

# Horizontal speed when moving.
export var max_speed:      float = 120.0
# How fast the player accelerates down while airborne.
export var gravity:        float = 20.0
# The vertical speed at which the player stops accelerating while falling.
export var max_fall_speed: float = 600.0
# Initial upwards speed when starting a jump.
export var jump_force:     float = 390.0
# Number of airborne jumps that can be performed before touching the ground. 
export var max_air_jumps:  int   = 1
# Number of hits the player can take before dying.
export var max_health:     int   = 3 

signal health_changed

var velocity:  Vector2 = Vector2.ZERO
var air_jumps: int     = max_air_jumps
var health:    int     = max_health

func _ready():
    emit_signal("health_changed", health, max_health)

func _physics_process(_delta: float):
    var on_floor = is_on_floor()
    # Movement
    if on_floor:
        air_jumps = max_air_jumps
    velocity.x = 0.0
    if Input.is_action_pressed("player_move_left"):
        velocity.x = -max_speed
    if Input.is_action_pressed("player_move_right"):
        velocity.x = max_speed
    velocity.y = clamp(velocity.y + gravity, -INF, max_fall_speed)
    if Input.is_action_just_pressed("player_jump") and can_jump(on_floor):
        jump(on_floor)
    velocity = move_and_slide(velocity, Vector2.UP)
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
    var _ret = get_tree().reload_current_scene()

func handle_animations(on_floor: bool):
    var horizontally_still = abs(velocity.x) == 0.0
    var facing_right       = velocity.x >= 0.0
    
    if not horizontally_still:
        $AnimatedSprite.flip_h = not facing_right
        
    if not on_floor:
        $AnimatedSprite.play("Air")
    elif not horizontally_still:
        $AnimatedSprite.play("Walk")
    else:
        $AnimatedSprite.play("Idle")

func _on_death_zone_entered(body: Node):
    if body == self:
        die()
