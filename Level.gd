extends Node2D

var topTexture: Texture = preload("res://textures/rope/line_top.png")
var bottomTexture: Texture = preload("res://textures/rope/line_bottom.png")

func _ready():
	for child in $Top1.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(topTexture)
			
	for child in $Bottom1.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(bottomTexture)
