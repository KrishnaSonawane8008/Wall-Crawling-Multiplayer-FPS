extends Marker3D

@export var step_target: Node3D
@export var step_distance: float =3
var tweening_time=0.0045
@export var Other: Node3D
@export var adjacent_target: Node3D
@export var opposite_target: Node3D
@onready var MainParent=$"../../.."
var TravellingDistance=1
var is_stepping = false
var no_height_tween=false
var Current_step_pos
var prev_dist=0.8
var Initial_setup=false
func _ready():
	global_position=step_target.global_position
	Current_step_pos=global_position


func _process(_delta):
	if not is_multiplayer_authority(): return
	if(!Initial_setup):
		global_position=step_target.global_position
		Initial_setup=true
		
	if !is_stepping && !adjacent_target.is_stepping && abs(global_position.distance_to(step_target.global_position))>step_distance:
		#this is called constantly
		step()
		opposite_target.step()
	
	if Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		step_distance=2.5
		tweening_time=step_distance*0.01
		no_height_tween=false
	else:
		step_distance=0.5
		tweening_time=0.05
		no_height_tween=true
		
		


func step():
	#var target_pos
	#if(global_position.distance_to(step_target.global_position)>TravellingDistance):
		#target_pos = global_position+((step_target.global_position-global_position).normalized()*3)
	#else:
	var target_pos = step_target.global_position
	var half_way = (global_position + step_target.global_position)/ 2
	is_stepping = true
	
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way + owner.basis.y*1.25 , tweening_time)
	t.tween_property(self, "global_position", target_pos, tweening_time)
	t.tween_callback(func(): is_stepping = false)

	
