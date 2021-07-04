extends Node2D

var topTexture: Texture = preload("res://textures/rope/line_top.png")
var bottomTexture: Texture = preload("res://textures/rope/line_bottom.png")

func _ready():
	$Bottom1.isBottom = true
	$Bottom2.isBottom = true
	$Bottom3.isBottom = true
	
	for child in $Top1.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(topTexture)
			
	for child in $Top2.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(topTexture)
			
	for child in $Top3.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(topTexture)
			
	for child in $Bottom1.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(bottomTexture)
			
	for child in $Bottom2.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(bottomTexture)
			
	for child in $Bottom3.get_children():
		if child is Sprite:
			var ch := child as Sprite
			ch.set_texture(bottomTexture)
