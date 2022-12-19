extends Node3D


@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var collision_shape : CollisionShape3D = $MeshInstance3D/StaticBody3D/CollisionShape3D
@export var height_ratio : float = 1.0
@export var col_shape_size_ratio : float = 0.1
@export var heightmap : Texture2D

var float_array : PackedFloat32Array
var shape : HeightMapShape3D = HeightMapShape3D.new()
var img : Image

# Called when the node enters the scene tree for the first time.
func _ready():
	img = heightmap.get_image()
	update_terrain(height_ratio, col_shape_size_ratio)
	collision_shape.shape = shape


func update_terrain(height_ratio, col_shape_size_ratio):
	mesh.material_override.set("shader_param/height_ratio", height_ratio)
	img.convert(Image.FORMAT_RF)
	img.resize(img.get_width()*col_shape_size_ratio, img.get_height()*col_shape_size_ratio)
	mesh.mesh.size = Vector2(img.get_width(), img.get_height())
	shape.map_width = img.get_width()
	shape.map_depth = img.get_height()
	for y in img.get_height():
		for x in img.get_height():
			float_array.push_back(img.get_pixel(x, y).r * height_ratio)
			
	shape.map_data = float_array
