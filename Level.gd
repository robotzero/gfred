extends Node2D

var topTexture: Texture = preload("res://textures/rope/line_top.png")
var bottomTexture: Texture = preload("res://textures/rope/line_bottom.png")
var endTexture: Texture = preload("res://textures/rope/line_end.png")

func _ready():
	for child in $End.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(endTexture)
			
	for n in range (1, 25):
		var nameTop = "Top%d" % n
		var nameBottom = "Bottom%d" % n
		var currentNodeTop = get_node(nameTop)
		var currentNodeBottom = get_node(nameBottom)
		if currentNodeTop:
			for child in currentNodeTop.get_children():
				if child is Sprite:
					var ch := child as Sprite
					ch.set_texture(topTexture)
		
		if currentNodeBottom:
			for child in currentNodeBottom.get_children():
				if child is Sprite:
					var ch := child as Sprite
					ch.set_texture(bottomTexture)
			currentNodeBottom.isBottom = true
		
func _process(delta):
	if Input.is_action_just_pressed("cameraDebug"):
		if $Fred.get_node("FredCamera").current:
			$DebugCamera.current = true
		else:
			$Fred.get_node("FredCamera").current = true
		
