extends Control

@onready var create_window = $"Control Panel/Buttons/Create/Create Window"
@onready var load_sequence = $"Control Panel/Buttons/Load/SequenceLoad"

##Creating the sequence
@onready var sequence_holder = $"Sequence Holder"
var input = "res://prefabs/input.tscn"
var current_menu: menu

##Menu information
var current_index = 0
var current_key
var key_held: bool = false #Is true is a key is held. Is to prevent just holding a key to cheese a menu or to prevent frame perfect button presses
var current_input: InputEvent
var previous_input: InputEvent
var can_continue: bool = true #Checks if you have either succeeded in the menu, or if you have failed the menu.
@onready var completion_rate = $"Information/Completion Rate"
@onready var time_text = $"Information/Time"
@onready var personal_best = $"Information/PB"
@onready var menu_name = $"Information/Menu Name"
@onready var average_time = $"Information/Average Time"
var time: float = 0

func _process(delta: float) -> void:
	$Information/FPS.text = str(Engine.get_frames_per_second())
	
	if current_menu:
		
		if current_index > 0 and can_continue:
			time += delta
			time_text.text = "%.2f" % time
		
		if (not current_input or (current_input != null and previous_input != null and current_input != previous_input)) and key_held:
			#print(str(current_input) + ":" + str(previous_input))
			key_held = false
		
		
		#Makes sure there is a key pressed, and it hasnt been held for more than a frame
		if current_input and not key_held and can_continue:
			
			if (current_input.as_text() == current_key):
				key_held = true
				
				change_current_key_color("black")
				current_index += 1
				
				#Checks if you have succeeded the menu
				if current_index >= sequence_holder.get_child_count(): 
					can_continue = false
					current_menu.add_attempt(true)
					update_completion_rate()
					average_time.text = "%.2f" % current_menu.get_avg_time()
					current_menu.add_completion_time(time)
					current_menu.check_for_pb(time)
					save()
					
					personal_best.text = "%.2f" % current_menu.pb
				#Continues to the next key
				else:
					print("Advance")
					go_to_next_key()
					change_current_key_color("green")
			#Checks for misinputs
			elif(current_input.as_text() != current_key):
				print(current_input.as_text())
				change_current_key_color("red")
				current_menu.add_attempt(false)
				update_completion_rate()
				save()
				can_continue = false
		
			previous_input = current_input
		

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_pressed():
		current_input = event
	elif event.is_released() or event.is_echo():
		current_input = null
		

func update_completion_rate():
	#var format_string = "%3.0f %"
	var actual_string = "%3.0f" % (current_menu.get_completion_rate()*100)
	completion_rate.text = actual_string + "%"

##Menu methods
func change_current_key_color(color: String):
	#print(current_index)
	sequence_holder.get_child(current_index).change_color(color)

func _on_restart_pressed() -> void:
	if current_menu == null:
		return
	
	for child in sequence_holder.get_children():
		child.change_color("black")
	
	
	current_index = 0
	time = 0
	can_continue = true
	go_to_next_key()
	change_current_key_color("green")
	

func _on_create_pressed() -> void:
	create_window.show()


func _on_load_pressed() -> void:
	load_sequence.show()

func _on_sequence_load_file_selected(path: String) -> void:
	for child in sequence_holder.get_children():
		child.queue_free()
	
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	
	var file_string = file.get_line()
	
	var parse_result = json.parse(file_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", file_string, " at line ", json.get_error_line())
		return
	
	var sequence_data = json.data
	
	#Getting all the data from the JSON
	current_menu = menu.new()
	for data in sequence_data:
		current_menu.set(data, sequence_data[data])
	
	#Changing FPS
	Engine.max_fps = current_menu.fps
	
	
	menu_name.text = current_menu.menu_name
	update_completion_rate()
	
	personal_best.text = "%.2f" % current_menu.pb
	average_time.text = "%.2f" % current_menu.get_avg_time()
	load_input_sequence()
	
	
	await get_tree().create_timer(0.01).timeout
	_on_restart_pressed()

func load_input_sequence():
	for input in current_menu.input_array:
		var item = load("res://prefabs/input.tscn").instantiate() #Creating input key
		sequence_holder.add_child(item)
		item.input = input
		#item.color = "black"
		item.change_color("black")
	

func go_to_next_key():
	current_key = sequence_holder.get_child(current_index).input
	#print(current_key)

func save() -> void:
	var file = FileAccess.open("user://" + str(current_menu.menu_name) + ".menu", FileAccess.WRITE)
	var dict = {
		"input_array":current_menu.input_array,
		"menu_name": current_menu.menu_name,
		"fps":current_menu.fps,
		"max_attempt_track":current_menu.max_attempt_track,
		"attempts": current_menu.attempts,
		"pb": current_menu.pb,
		"completion_times": current_menu.completion_times
	}
	var save_string = JSON.stringify(dict)
	file.store_string(save_string)

func unload() -> void:
	current_menu = null
	Engine.max_fps = 60
	
	
	menu_name.text = "{Insert Name}"
	completion_rate.text = "-1%"
	
	personal_best.text ="0"
	average_time.text = "0"
	for child in sequence_holder.get_children():
		child.queue_free()
	

func _on_edit_pressed() -> void:
	if current_menu == null:
		return
	
	
	$"Control Panel/Buttons/Create/Create Window/Control".load_sequence_info(current_menu)
	create_window.show()
