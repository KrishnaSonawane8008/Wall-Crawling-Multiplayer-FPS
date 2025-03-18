@tool
extends EditorProperty

var MainVbox
var The_Object

var AddRemoveTab=preload("res://addons/Multi_RayCast/Add_Remove_Tab.tscn").instantiate()
var HTree=preload("res://addons/Multi_RayCast/HierarchyTree.tscn").instantiate()
var TheTree=HTree.get_child(0)

var root
var previous_item


# Called when the node enters the scene tree for the first time.
func _ready():
	# doesn't work when playing scene
	if !The_Object.contains_root:
		The_Object.AddElement("Root")
		The_Object.contains_root=true
		var config_file=ConfigFile.new()
		var Err=config_file.load("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
		if Err!=OK:
			return
		config_file.set_value(The_Object.name.to_snake_case(), "ContainsRoot", The_Object.contains_root)
		config_file.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
		
	root=TheTree.create_item()
	previous_item=root
	root.set_text(0, "Root")
	var Top_Button=MainVbox.get_child(0)
	Top_Button.pressed.connect(self.toggle_panel)

func toggle_panel():
	if !The_Object.is_toggeled:
		The_Object.is_toggeled=true
		MainVbox.add_child(AddRemoveTab)
		if AddRemoveTab.get_child(0).pressed.is_connected(self.AddElement) and AddRemoveTab.get_child(1).pressed.is_connected(self.RemoveElement):
			pass
		else:
			AddRemoveTab.get_child(0).pressed.connect(self.AddElement)
			AddRemoveTab.get_child(1).pressed.connect(self.RemoveElement)
		MainVbox.add_child(HTree)
	else:
		The_Object.is_toggeled=false
		MainVbox.remove_child(AddRemoveTab)
		MainVbox.remove_child(HTree)

func _unhandled_input(event):#this doesn't work, i don't know why
	if Input.is_key_pressed(KEY_ALT):
		if Input.is_key_pressed(KEY_SHIFT):
			if Input.is_key_pressed(KEY_D):
				var config_file=ConfigFile.new()
				var Err=config_file.load("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
				if Err!=OK:
					return
				config_file.set_value(The_Object.name.to_snake_case(), "Duplicate", true)
				config_file.save("res://addons/Multi_RayCast/SpiderLeg_SaveData.cfg")
				print("Duplicating: ",The_Object.name)

func AddElement():
	The_Object.Element_Count+=1
	The_Object.AddElement("Element%d"%The_Object.Element_Count)
	var Element=TheTree.create_item(previous_item)
	previous_item=Element
	Element.set_text(0, "Element%d"%The_Object.Element_Count)

func RemoveElement():
	if The_Object.Element_Count>0:
		The_Object.Element_Count-=1
	The_Object.RemoveElement()

	TheTree.clear()
	for ele in range(The_Object.ElementList.size()):
		if ele==0:
			root=TheTree.create_item()
			previous_item=root
			root.set_text(0, The_Object.ElementList[ele])
		else:
			var Element=TheTree.create_item(previous_item)
			previous_item=Element
			Element.set_text(0, The_Object.ElementList[ele])
	
func _update_property():
	if The_Object.is_toggeled:
		MainVbox.add_child(AddRemoveTab)
		AddRemoveTab.get_child(0).pressed.connect(self.AddElement)
		AddRemoveTab.get_child(1).pressed.connect(self.RemoveElement)
		MainVbox.add_child(HTree)
	if The_Object.ElementList.size()>1:
		for elem in range(1, The_Object.ElementList.size()):
			var Element=TheTree.create_item(previous_item)
			previous_item=Element
			Element.set_text(0, The_Object.ElementList[elem])
			



		
		
		
		
		
		
		
		
