extends Node
class_name menu

var input_array: Array ##Sequence of inputs for the menu
var menu_name: String


var fps : int ##FPS of the game
var pb: float ##Fastest completion of the menu

var attempts: Array ##Array of attempts, true means run was finish, false be run failed
var max_attempt_track: int ##Highest number of attempts that are counted


func add_attempt(success: bool):
	attempts.append(success)
	
	if attempts.size() > max_attempt_track:
		attempts.pop_front()

func get_completion_rate() -> float:
	var victories = 0.0
	for item in attempts:
		victories += int(item)
	
	return victories/float(attempts.size())

func check_for_pb(time: float):
	if time < pb or pb == -1:
		pb = time
