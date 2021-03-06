extends Node

const WIN_PATH   = "res://scenes/WinScreen.tscn"
const LEVEL_PATH = "res://levels/Level_"

var current_level = 1
var death_count   = 0

func _ready():
    var scene = get_tree().current_scene.filename
    print(scene)
    if scene.begins_with(LEVEL_PATH):
        current_level = int(scene)

func die():
    death_count += 1
    
func advance_level():
    current_level += 1
    var next = get_level_path(current_level)
    var _err = get_tree().change_scene(
        next if ResourceLoader.exists(next) else WIN_PATH
    )

func return_to_current_level():
    var _err = get_tree().change_scene(get_level_path(current_level))
    
func get_level_path(level: int) -> String:
    return "%s%d.tscn" % [LEVEL_PATH, level]

func _input(event: InputEvent):
    if event.is_action_pressed("level_skip"):
        advance_level()
