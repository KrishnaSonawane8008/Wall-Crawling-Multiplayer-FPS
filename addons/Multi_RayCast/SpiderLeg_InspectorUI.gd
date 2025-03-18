@tool
extends EditorInspectorPlugin

var TheObject=200


func _can_handle(object):
	if object.get_script()!=null:
		if object.get_script().get_script_property_list ( )[0].name=="SpiderLeg.gd":
			return true

func _parse_category(object, category):
	if category=="Node3D":
		TheObject=instance_from_id(object.get_instance_id())
		var MainControl_Node=preload("res://addons/Multi_RayCast/Main_Control_Node.tscn").instantiate()
		add_custom_control(MainControl_Node)
		var PropertyScript=preload("res://addons/Multi_RayCast/SpiderLeg_Properties.gd").new()
		PropertyScript.MainVbox=MainControl_Node
		PropertyScript.The_Object=TheObject
		add_property_editor("Spider_Properties",PropertyScript)
