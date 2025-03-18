extends Node3D

var distance
var start_pos
var end_pos
var size=1
var up_axis=Vector3(0,1,0);
var player_pos
var normal_transform
var Anchored=false

@onready var Anchor=$Anchor
@onready var Rope=$HropeContainer
@onready var rope_mesh=$HropeContainer/HRope

func _ready():
	pass
	

func _process(_delta):
	if distance!=null:
		distance-=2
		if distance>=0:
			Anchor.global_position+=Anchor.global_transform.basis*Vector3(0,2,0)
		else:
			distance+=2-0.4
			Anchor.global_position+=Anchor.global_transform.basis*Vector3(0,distance,0)
			distance=null
			Anchored=true
		
	if start_pos!=null && size!=null:
		Rope.basis=Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
		var harpoon_dir=(Anchor.global_position-start_pos).normalized()
		var angle=up_axis.angle_to(harpoon_dir)
		var rot_axis=(up_axis.cross(harpoon_dir)).normalized()
		var quat= Quaternion( rot_axis, angle )
		
		#Rope.set_rotation_edit_mode(Node3D.ROTATION_EDIT_MODE_QUATERNION)
		#print(typeof(Rope))
		#var rope_transform=Rope.transform
		#Rope.transform=Rope.transform.rotated( rot_axis, angle )
		Rope.basis=Basis(quat)
		size=(start_pos.distance_to(Anchor.global_position))
		Rope.global_position=start_pos+(harpoon_dir*(size/2))
		Rope.scale.y=size

func set_rope_material(Bmat):
	rope_mesh.set_surface_override_material(0, Bmat)
