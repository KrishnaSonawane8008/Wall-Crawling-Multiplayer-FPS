@tool
extends Node

var is_toggeled=false
var ElementList=[]
var contains_root=false
var Element_Count=0
var Apressed=false
var duplicated=false

var nameinsnakecase

var CubeStart=preload("res://addons/Multi_RayCast/CubeStart.tscn")
var CubeEnd=preload("res://addons/Multi_RayCast/CubeEnd.tscn")
var ArrowHead=preload("res://addons/Multi_RayCast/ArrowHead.tscn")
var ArrowBody=preload("res://addons/Multi_RayCast/ArrowBody.tscn")

var InstanceList=[]
var positions_list=[]
var rotation_list=[]
var previnst

var Collision_mesh
var IsColliding=false
var collision_point
var collider
var normal
var collider_id


func _ready():
	#=====================LOADING=DATA==============================================================

	Collision_mesh=black_box()
	add_child(Collision_mesh)
	Collision_mesh.set_scale(Vector3(0.1,0.1,0.1))
	
	nameinsnakecase=name.to_snake_case()
	self.tree_exited.connect(self.TreeExited)
	self.renamed.connect(self.NodeRenamed)
	var config_file=ConfigFile.new()
	var Err=config_file.load("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
	if Err!=OK:
		return
	for secs in config_file.get_sections():
		if config_file.has_section_key(secs, "Duplicate"):
			var isduplicate=config_file.get_value(secs, "Duplicate", "Error")
			if isduplicate:
				ElementList=config_file.get_value(secs, "Element_List", "Error")
				Element_Count=config_file.get_value(secs, "Element_Count", "Error")
				contains_root=config_file.get_value(secs, "ContainsRoot", "Error")
				positions_list=config_file.get_value(secs, "PositionList", "Error")
				rotation_list=config_file.get_value(secs, "RotationList", "Error")
				config_file.set_value(name.to_snake_case(), "Element_List", ElementList)
				config_file.set_value(name.to_snake_case(), "Element_Count", Element_Count)
				config_file.set_value(name.to_snake_case(), "ContainsRoot", contains_root)
				config_file.set_value(name.to_snake_case(), "PositionList", positions_list)
				config_file.set_value(name.to_snake_case(), "RotationList", rotation_list)
				self.global_position=positions_list[0]
				Initialize_da_Leg()
				if InstanceList.size()==positions_list.size():
					for insts in range(InstanceList.size()):
						InstanceList[insts].position=positions_list[insts]
						InstanceList[insts].rotation=rotation_list[insts]
				config_file.erase_section_key(secs, "Duplicate")
				duplicated=true
				config_file.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
			break
	#[Vector3(0, 0, 0), Vector3(0, 1.19209e-07, 1), Vector3(0, -0.813203, 0.581981), Vector3(0, -0.813202, 0.581981)]
	#[Vector3(0, 0, 0), Vector3(0, 1.19209e-07, 1), Vector3(0, -0.813203, 0.581981), Vector3(0, -0.813202, 0.581981)]
	if config_file.has_section(name.to_snake_case()) and !duplicated:
		if IsValid(config_file, "Element_List", "Error", TYPE_ARRAY):
			ElementList=config_file.get_value(name.to_snake_case(), "Element_List", "Error")
		if IsValid(config_file, "Element_Count", "Error", TYPE_INT):
			Element_Count=config_file.get_value(name.to_snake_case(), "Element_Count", "Error")
		if IsValid(config_file, "ContainsRoot", "Error", TYPE_BOOL):
			contains_root=config_file.get_value(name.to_snake_case(), "ContainsRoot", "Error")
		if IsValid(config_file, "PositionList", "Error", TYPE_ARRAY):
			positions_list=config_file.get_value(name.to_snake_case(), "PositionList", "Error")
		if IsValid(config_file, "RotationList", "Error", TYPE_ARRAY):
			rotation_list=config_file.get_value(name.to_snake_case(), "RotationList", "Error")
		Initialize_da_Leg()
		if InstanceList.size()==positions_list.size():
			for insts in range(InstanceList.size()):
				InstanceList[insts].position=positions_list[insts]
				InstanceList[insts].rotation=rotation_list[insts]
	else:
		config_file.set_value(name.to_snake_case(), "Element_List", ElementList)
		config_file.set_value(name.to_snake_case(), "Element_Count", Element_Count)
		config_file.set_value(name.to_snake_case(), "ContainsRoot", contains_root)
		config_file.set_value(name.to_snake_case(), "PositionList", positions_list)
		config_file.set_value(name.to_snake_case(), "RotationList", rotation_list)
		config_file.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
	#=====================LOADING=DATA==============================================================
		
	for insts in range(InstanceList.size()-1):
		InstanceList[insts].get_child(0).set_scale(Vector3(0.07,0.07,1))


func Initialize_da_Leg():
	for ele in range(ElementList.size()):
		if ele==ElementList.size()-1:
			if previnst==null:
				var AH=ArrowHead.instantiate()
				add_child(AH)
				previnst=AH
				InstanceList.append(AH)
				var CS=CubeStart.instantiate()
				previnst.add_child(CS)
				CS.global_position=AH.global_position+Vector3(0,0,1)
				InstanceList.append(CS)
			else:
				var AH=ArrowHead.instantiate()
				previnst.add_child(AH)
				previnst=AH
				var CE=red_box()
				AH.add_child(CE)
				CE.set_scale(Vector3(0.1,0.1,0.1))
				CE.global_position=AH.global_position
				InstanceList.append(AH)
				var CS=CubeStart.instantiate()
				previnst.add_child(CS)
				InstanceList.append(CS)
		else:
			if previnst==null:
				var AB=ArrowBody.instantiate()
				previnst=AB
				add_child(AB)
				InstanceList.append(AB)
			else:
				var AB=ArrowBody.instantiate()
				previnst.add_child(AB)
				previnst=AB
				var CE=red_box()
				AB.add_child(CE)
				CE.set_scale(Vector3(0.1,0.1,0.1))
				CE.global_position=AB.global_position
				InstanceList.append(AB)
				


func _physics_process(delta):
	if self.visible:
		for Inst in range(InstanceList.size()-1):
			var dist=InstanceList[Inst].global_position.distance_to(InstanceList[Inst+1].global_position)
			InstanceList[Inst].get_child(0).look_at(InstanceList[Inst+1].global_position)
			InstanceList[Inst].get_child(0).set_scale(Vector3(0.07,0.07,dist))
		
			
	if Input.is_key_pressed(KEY_CTRL):
		if Input.is_key_pressed(KEY_S):
			print("Saved by: ", name)
			positions_list.clear()
			rotation_list.clear()
			for instances in InstanceList:
				positions_list.append(instances.position)
				rotation_list.append(instances.rotation)
			var cfg=ConfigFile.new()
			var err=cfg.load("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
			if err!=OK:
				return
			cfg.set_value(name.to_snake_case(), "PositionList",positions_list)
			cfg.set_value(name.to_snake_case(), "RotationList", rotation_list)
			cfg.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")

	for objs in range(InstanceList.size()-1):
		var startpt=InstanceList[objs].global_position
		var endpt=InstanceList[objs+1].global_position
		if startpt!=endpt:
			var space_state = InstanceList[objs].get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(startpt, endpt)
			var result = space_state.intersect_ray(query)
			if result.size()>0 && result.collider.get_collision_mask()!=2:
				IsColliding=true
				normal=result.normal
				collider=result.collider
				collider_id=result.collider_id
				collision_point=result.position
				Collision_mesh.global_position=collision_point
				break
			else:
				IsColliding=false
				
	

		
func red_box():
	var box=MeshInstance3D.new()
	box.mesh=BoxMesh.new()
	var red_mat=StandardMaterial3D.new()
	red_mat.albedo_color=Color.RED
	box.mesh.surface_set_material(0, red_mat)
	return box

func black_box():
	var box=MeshInstance3D.new()
	box.mesh=BoxMesh.new()
	var red_mat=StandardMaterial3D.new()
	red_mat.albedo_color=Color.BLACK
	box.mesh.surface_set_material(0, red_mat)
	return box

func NodeRenamed():
	var config_file=ConfigFile.new()
	var Err=config_file.load("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
	if Err!=OK:
		return
	config_file.erase_section(nameinsnakecase)
	nameinsnakecase=name.to_snake_case()
	config_file.set_value(name.to_snake_case(), "Element_List", ElementList)
	config_file.set_value(name.to_snake_case(), "Element_Count", Element_Count)
	config_file.set_value(name.to_snake_case(), "ContainsRoot", contains_root)
	config_file.set_value(name.to_snake_case(), "PositionList", positions_list)
	config_file.set_value(name.to_snake_case(), "RotationList", rotation_list)
	config_file.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")



func TreeExited():
	if get_parent()==null:
		var cfg=ConfigFile.new()
		var Err=cfg.load("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
		if Err!=OK:
			return
		cfg.erase_section(name.to_snake_case())
		cfg.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")

func IsValid(cfg, key, errval, typeval):
	if cfg.has_section_key(name.to_snake_case(), key):
		var val=cfg.get_value(name.to_snake_case(), key, errval)
		if typeof(val)==typeval:
			return true
		else: 
			return false
	else:
		return false

#func _physics_process(delta):
	#print("inj physics process")

func AddElement(Element_name):
	ElementList.append(Element_name)
	var AH_inst=ArrowHead.instantiate()
	var AB_inst=ArrowBody.instantiate()
	var AB_Mesh=AB_inst.get_child(0).mesh
	if previnst==null:
		add_child(AH_inst)
		previnst=AH_inst
		InstanceList.append(AH_inst)
		var CS_inst=CubeStart.instantiate()
		previnst.add_child(CS_inst)
		InstanceList.append(CS_inst)
		CS_inst.global_position=previnst.global_position+Vector3(0,0,1)
		AH_inst.get_child(0).look_at(CS_inst.global_position)
	else:
		var second_last=InstanceList[InstanceList.size()-2]
		var last=InstanceList[InstanceList.size()-1]
		second_last.get_child(0).mesh=AB_Mesh
		second_last.add_child(AH_inst)
		previnst=AH_inst
		InstanceList[InstanceList.size()-1]=previnst
		previnst.get_child(0).set_scale(Vector3(0.07,0.07,1))
		previnst.global_position=last.global_position
		previnst.get_child(0).look_at(previnst.global_position+Vector3(0,0,1))
		var CE_inst=red_box()
		previnst.add_child(CE_inst)
		CE_inst.set_scale(Vector3(0.1,0.1,0.1))
		CE_inst.global_position=previnst.global_position
		last.reparent(previnst)
		last.global_position=previnst.global_position+Vector3(0,0,1)
		InstanceList.append(last)
			
	var config_file=ConfigFile.new()
	var Err=config_file.load("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
	if Err!=OK:
		return
	config_file.set_value(name.to_snake_case(),"Element_List",ElementList)
	config_file.set_value(name.to_snake_case(), "Element_Count", Element_Count)
	config_file.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")


func RemoveElement():
	if ElementList.size()>1:
		ElementList.pop_back()
	if InstanceList.size()>2:
		var AH_inst=ArrowHead.instantiate()
		var AH_mesh=AH_inst.get_child(0).mesh
		var last=InstanceList[InstanceList.size()-1]
		var secondlast=InstanceList[InstanceList.size()-2]
		var thirdlast=InstanceList[InstanceList.size()-3]
		thirdlast.get_child(0).mesh=AH_mesh
		thirdlast.get_child(0).look_at(secondlast.global_position)
		var dist=thirdlast.global_position.distance_to(secondlast.global_position)
		thirdlast.get_child(0).set_scale(Vector3(0.07,0.07,dist))
		previnst=thirdlast
		last.reparent(previnst)
		last.global_position=secondlast.global_position
		InstanceList[InstanceList.size()-2]=last
		InstanceList.pop_back()
		secondlast.queue_free()
	
	var config_file=ConfigFile.new()
	var Err=config_file.load("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
	if Err!=OK:
		return
	config_file.set_value(name.to_snake_case(),"Element_List",ElementList)
	config_file.set_value(name.to_snake_case(), "Element_Count", Element_Count)
	config_file.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")








	


