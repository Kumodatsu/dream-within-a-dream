extends Area2D

func _on_body_entered(body: Node):
    body.change_health(+1)
    queue_free()
