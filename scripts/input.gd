extends NinePatchRect

@onready var text = $Text
var input: String
#var color = "black"

func change_color(color: String):
	text.text = "[color=" + color + "]" + input + "[/color]" 
