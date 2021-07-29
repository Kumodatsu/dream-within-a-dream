extends KinematicBody2D

# Emitted when the enemy is damaged, with hp and max_hp as parameters.
signal on_damage

enum Direction {
    LEFT  = -1,
    RIGHT =  1
}

# Horizontal speed when moving.
export            var max_speed:      float = 150.0
# Direction the enemy is flying.
export(Direction) var direction:      int   = Direction.LEFT
# Number of hits to take before dying.
export            var max_hp:         int   = 75

onready var hp:     int  = max_hp
onready var player: Node = get_player()

var velocity: Vector2 = Vector2.ZERO

func _ready():
    change_direction(direction)

func _physics_process(_delta: float):
    velocity = move_and_slide(velocity, Vector2.UP)
    if is_on_wall():
        change_direction(-1 * direction)

func get_player() -> Node:
    return get_node("/root/Level/Jacob")

func die():
    if hp <= 0:
        return
    hp -= 1
    emit_signal("on_damage", hp, max_hp)
    if hp <= 0:
        velocity.x = 0.0
        $AnimatedSprite.play("explode")
        $ExplosionSound.play()

func change_direction(dir: int):
    direction              = dir
    velocity.x             = direction * max_speed
    $AnimatedSprite.flip_h = direction == Direction.LEFT

func shoot():
    var aim_pos = player.global_position
    var aim_dir = aim_pos - global_position
    if aim_dir == Vector2.ZERO:
        return
    aim_dir = aim_dir.normalized()
    
    var ice    = load("res://entities/Ice.tscn").instance()
    var offset = Vector2(0.0, 40.0)
    
    ice.position  = global_position + offset
    ice.direction = aim_dir
    
    get_tree().get_root().add_child(ice)

func _on_body_entered(body: Node):
    if body.get_collision_layer() == 1:
        body.change_health(-1)

func _on_timeout():
    if $AnimatedSprite.animation == "explode":
        return
    $AnimatedSprite.play("spit")
    shoot()

func _on_animation_finished():
    match $AnimatedSprite.animation:
        "spit":
            $AnimatedSprite.play("float")
        "explode":
            LevelManager.advance_level()
