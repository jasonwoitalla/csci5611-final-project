extends Node


@export var rand_values : Array[int]
@export var animation_tree : NodePath
@export var parameter : String

var tree : AnimationTree
var anim_node : AnimationNode


func _ready():
	tree = get_node(animation_tree)
	anim_node = tree.tree_root


func _on_animation_player_animation_finished(anim_name):
	if not tree:
		print("Can't change animation because tree is null")
		return
	
	anim_node.set_parameter(parameter, rand_values.pick_random())
