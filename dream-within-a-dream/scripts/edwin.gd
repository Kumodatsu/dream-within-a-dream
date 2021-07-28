extends KinematicBody2D

# "Hey.... ben jij klaar om je skills te pijlen?"
# -Eric Edwin van de Sar-

func die():
    queue_free()

func _ready():
    $Timer.start()

func _on_body_entered(body: Node):
    if body.get_collision_layer() == 1:
        body.change_health(-1)

func _on_timeout():
    var arrow  = load("res://entities/Arrow.tscn").instance()
    var dir    = sign(scale.x)
    var offset = Vector2(dir * 50.0, -5.0)
    
    arrow.position  = position + offset
    arrow.direction = dir * Vector2.RIGHT
    arrow.get_node("Sprite").flip_h = scale.x < 0.0
    
    get_tree().get_root().add_child(arrow)
    $ArrowSound.play()
    $Timer.start()
