extends ProgressBar

func _on_ich_damage(hp: int, max_hp: int):
    value = float(hp) / float(max_hp)
