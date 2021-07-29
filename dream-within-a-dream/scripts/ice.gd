extends Area2D

var speed:     float   = 400.0
var direction: Vector2 = Vector2.DOWN

func _physics_process(delta: float):
    position += delta * speed * direction

func _on_timeout():
    queue_free()

func _on_body_entered(body: Node):
    if body.get_collision_layer() == 1:
        body.change_health(-1)
    queue_free()
