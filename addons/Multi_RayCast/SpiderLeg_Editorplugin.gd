@tool
extends EditorPlugin

var InspectorUI=preload("res://addons/Multi_RayCast/SpiderLeg_InspectorUI.gd").new()

func _enter_tree():
	add_custom_type("Spider Leg", "Node3D", preload("res://addons/Multi_RayCast/SpiderLeg.gd"), preload("res://addons/Multi_RayCast/SpiderLeg_Plugin_Icon.png"))
	add_inspector_plugin(InspectorUI)

func _exit_tree():
	remove_custom_type("Spider Leg")
	remove_inspector_plugin(InspectorUI)
