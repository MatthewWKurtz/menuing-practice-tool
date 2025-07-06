extends Control

@onready var sequence_length = $"Sequence Length"
@onready var FPS = $FPS
@onready var sequence = $ScrollContainer/Sequence
@onready var name_text = $Name
@onready var max_attempt_track = $MAT

var sequence_input = "res://prefabs/sequence input.tscn"
var previous_menu: menu

func load_sequence_info(current_menu: menu):
	previous_menu = current_menu
	print(previous_menu.input_array.size())
	
	#Editing simple values
	sequence_length.value = previous_menu.input_array.size()
	FPS.value = previous_menu.fps
	name_text.text = previous_menu.menu_name
	max_attempt_track.value = previous_menu.max_attempt_track

	await _on_sequence_length_value_changed(sequence_length.value)
	
	#Editing the sequence array
	for index in range(sequence.get_child_count()):
		sequence.get_child(index).input.text = previous_menu.input_array[index]
		sequence.get_child(index).index.text = str(index+1)
	
	

func _on_sequence_length_value_changed(value: float) -> void:
	while sequence.get_child_count() != value:
		#print(sequence.get_child_count())
		if sequence.get_child_count() < value:
			print(str(sequence.get_child_count()))
			add_input_to_sequence()
			await get_tree().create_timer(0.01).timeout
			sequence.get_child(sequence.get_child_count()-1).index.text = str(sequence.get_child_count())
		else:
			#print("Remove")
			sequence.get_child(sequence.get_child_count()-1).queue_free()
			await get_tree().create_timer(0.01).timeout
	
	
	#Makes it so the sequence grid always has the last input
	sequence.custom_minimum_size.y = sequence.get_child_count() * 33

func _on_cancel_pressed() -> void:
	sequence_length.value = 1
	FPS.value = 60
	name_text.text = ""
	max_attempt_track.value = 25
	previous_menu = null
	for child in sequence.get_children():
		child.queue_free()
	
	add_input_to_sequence()
	
		
		
	$"..".hide()
	
func _on_save_pressed() -> void:
	#Makes sure all keys have valid inputs
	#print(not check_sequence())
	#print(not check_name())
	#print(not check_sequence() and not check_name())
	#print(not (check_sequence() and check_name()))
	if not (check_sequence() and check_name()):
		return
	
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
		"pb": -1,
		"completion_times": []
	}
	var save_string = JSON.stringify(dict)
	file.store_string(save_string)
	
	$"../../../../..".unload()
	_on_cancel_pressed()

func add_input_to_sequence():
	var item = load(sequence_input).instantiate()
	sequence.add_child(item)

#Makes sure all inputs in the input sequence are valid
func check_sequence() -> bool:
	for item in sequence.get_children():
		#print(item.input.text)
		if item.input.text == "{No Input}":
			return false
	
	return true

#Makes sure the name of the menu is at least 1 character
func check_name():
	return name_text.text.length() > 0
