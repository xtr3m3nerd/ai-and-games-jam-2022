extends LinkButton

export var use_text_as_link = true
export var link = ""

func _ready():
	connect("pressed", self, "goto_link")

func goto_link():
	if use_text_as_link:
		OS.shell_open(text)
	else:
		OS.shell_open(link)
