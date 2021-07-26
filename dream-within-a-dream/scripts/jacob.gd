extends KinematicBody2D

export var max_speed:      float =  200.0
export var gravity:        float =   20.0
export var max_fall_speed: float =  600.0
export var jump_force:     float =  600.0
export var max_jumps:      int   =    2

var velocity: Vector2 = Vector2.ZERO
var jumps:    int     = 2

func _ready():
    pass

func _physics_process(_delta: float):
    if is_on_floor():
        jumps = max_jumps
    velocity.x = 0.0
    if Input.is_action_pressed("player_move_left"):
        velocity.x = -max_speed
    if Input.is_action_pressed("player_move_right"):
        velocity.x = max_speed
    velocity.y = clamp(velocity.y + gravity, -INF, max_fall_speed)
    if Input.is_action_just_pressed("player_jump") and can_jump():
        jump()
    velocity = move_and_slide(velocity, Vector2.UP)

func can_jump() -> bool:
    return jumps > 0

func jump():
    jumps -= 1
    velocity.y = -jump_force
