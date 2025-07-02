extends Control

@onready var index = $Index
@onready var input = $Input
var index_set: bool = false
var is_editing = false
var main_window 

func _process(delta: float) -> void:
	if not index_set:
		if $"../../..".sequence_length:
			main_window = $"../../.."
			index.text = str(int(main_window.sequence_length.value))
			index_set = true
		

func _input(event: InputEvent) -> void:
	if is_editing:
		if event is not InputEventMouseMotion and event.is_released():
			is_editing = false
			change_action_mode_on_remapping_buttons()
		elif event.is_action_type():
			print(event.keycode)
			input.text = event.as_text()

func _on_input_pressed() -> void:
	is_editing = true
	change_action_mode_on_remapping_buttons()
	input.text = "Waiting"
	
func change_action_mode_on_remapping_buttons():
	pass
