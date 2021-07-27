extends KinematicBody2D

export var max_speed:      float =  200.0
export var gravity:        float =   20.0
export var max_fall_speed: float =  600.0
export var jump_force:     float =  600.0
export var max_air_jumps:    int =    1

var velocity:  Vector2 = Vector2.ZERO
var air_jumps: int     = max_air_jumps

func _ready():
    pass

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
