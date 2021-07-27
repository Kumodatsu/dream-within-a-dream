extends Node2D

const FULL_HEART:  String = "res://assets/sprites/pickups/heart.png"
const EMPTY_HEART: String = "res://assets/sprites/hud/empty_heart.png"
const HEART_WIDTH: float  = 21.0
const PADDING:     float  =  1.0

func _on_player_health_changed(health: int, max_health: int):
    var x_offset: float = 0.0
    for node in get_children():
        remove_child(node)
        node.queue_free()    
    for _i in range(health):
        add_heart(FULL_HEART, x_offset)
        x_offset += HEART_WIDTH + PADDING
    for _i in range(max_health - health):
        add_heart(EMPTY_HEART, x_offset)
        x_offset += HEART_WIDTH + PADDING    
     
func add_heart(path: String, x_offset: float):
    var sprite: Sprite = Sprite.new()
    sprite.texture  = load(path)
    sprite.centered = false
    sprite.translate(Vector2(x_offset, 0.0))
    add_child(sprite)
