extends Area2D

func _on_body_entered(_body: Node):
    LevelManager.advance_level()
