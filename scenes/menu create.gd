extends Control

@onready var sequence_length = $"Sequence Length"
@onready var FPS = $FPS
@onready var sequence = $ScrollContainer/Sequence
@onready var name_text = $Name
@onready var max_attempt_track = $MAT

var sequence_input = "res://prefabs/sequence input.tscn"


func _on_sequence_length_value_changed(value: float) -> void:
	if sequence.get_child_count() < value:
		print("Add item")
		add_input_to_sequence()
	else:
		sequence.get_child(sequence.get_child_count()-1).queue_free()
	
	#Makes it so the sequence grid always has the last input
	sequence.custom_minimum_size.y = sequence.get_child_count() * 33


func _on_cancel_pressed() -> void:
	sequence_length.value = 1
	FPS.value = 60
	name_text.text = ""
	max_attempt_track.value = 25
	for child in sequence.get_children():
		child.queue_free()
	
	add_input_to_sequence()
	
		
		
	$"..".hide()
	
func _on_save_pressed() -> void:
	var input_array = []
	for child in sequence.get_children():
		input_array.append(child.input.text)
		
	var file = FileAccess.open("user://" + str(name_text.text) + ".menu", FileAccess.WRITE)
	var dict = {
		"input_array":input_array,
		"menu_name": name_text.text,
		"fps":FPS.value,
		"max_attempt_track":max_attempt_track.value,
		"attempts": [],
		"pb": -1
	}
	var save_string = JSON.stringify(dict)
	file.store_string(save_string)
	_on_cancel_pressed()

func add_input_to_sequence():
	var item = load(sequence_input).instantiate()
	sequence.add_child(item)
