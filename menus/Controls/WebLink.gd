extends LinkButton

export var use_text_as_link = true
export var link = ""

func _ready():
	var _err = connect("pressed", self, "goto_link")

func goto_link():
	if use_text_as_link:
		var _err = OS.shell_open(text):
	else:
		var _err = OS.shell_open(link)
