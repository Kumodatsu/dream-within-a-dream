extends Area2D

var speed:     float   = 200.0
var direction: Vector2 = Vector2.RIGHT

func _ready():
    var rads  = deg2rad(rotation_degrees)
    direction = Vector2(cos(rads), sin(rads))
    $Timer.start()

func _physics_process(delta: float):
    position += delta * speed * direction

func _on_body_entered(body: Node):
    if body.get_collision_layer() == 16:
        body.die()
    queue_free()

func _on_timeout():
    queue_free()
