extends Node
class_name menu

var input_array: Array ##Sequence of inputs for the menu
var menu_name: String


var fps : int ##FPS of the game
var pb: float ##Fastest completion of the menu
var completion_times: Array ##Array of completed times
var avg_time: float ##Average time of completion

var attempts: Array ##Array of attempts, true means run was finish, false be run failed
var max_attempt_track: int ##Highest number of attempts that are counted


func add_attempt(success: bool):
	attempts.append(success)
	
	if attempts.size() > max_attempt_track:
		attempts.pop_front()

func add_completion_time(time: float):
	completion_times.append(time)
	
	if completion_times.size() > max_attempt_track:
		completion_times.pop_front()

func get_completion_rate() -> float:
	var victories = 0.0
	for item in attempts:
		victories += int(item)
	
	return victories/float(attempts.size())

func check_for_pb(time: float):
	if time < pb or pb == -1:
		pb = time

func get_avg_time() -> float:
	if completion_times.size() == 0:
		return 0
	
	var time = 0
	
	for item in completion_times:
		time += item
	
	return time/completion_times.size()
