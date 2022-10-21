extends LinkButton

export var use_text_as_link = true
export var link = ""

func _ready():
	var err = connect("pressed", self, "goto_link")
	if err != 0:
		print("ERROR: ", err)

func goto_link():
	if use_text_as_link:
		var err = OS.shell_open(text)
		if err != 0:
			print("ERROR: ", err)
	else:
		var err = OS.shell_open(link)
		if err != 0:
			print("ERROR: ", err)
