extends Area2D

const SPEED:       float = 450.0
const ANGULAR_INC: float = 30.0

var direction: Vector2 = Vector2.RIGHT

func _ready():
    $Timer.start()

func _physics_process(delta: float):
    position += delta * (SPEED * direction)
    var angle = direction.angle()
    var inc   = deg2rad(delta * ANGULAR_INC)
    direction = Vector2(cos(angle - inc), sin(angle - inc))

func _on_body_entered(body: Node):
    if body.get_collision_layer() == 1:
        body.die()
        queue_free()
    elif body.get_collision_layer() != 16:
        queue_free()

func _on_timeout():
    queue_free()
