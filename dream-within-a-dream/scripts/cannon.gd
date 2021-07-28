extends StaticBody2D

func _on_animation_finished():
    var beam   = load("res://entities/Beam.tscn").instance()
    var dir    = sign(scale.x)
    var offset = Vector2(dir * 50.0, -5.0)
    
    beam.position         = position + offset
    beam.rotation_degrees = 0.0 if dir > 0.0 else 180.0
    
    get_tree().get_root().add_child(beam)
    $BeamSound.play()
