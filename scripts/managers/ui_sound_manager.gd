extends Node

@onready var select_sound = %SelectSound
@onready var press_sound = %PressSound

func _ready():
	# when _ready is called, there might already be nodes in the tree, so connect all existing buttons
	connect_buttons(get_tree().root)
	get_tree().node_added.connect(self._on_scene_tree_node_added)

func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func connect_to_button(button: BaseButton):
	button.focus_entered.connect(self._on_button_focus_entered)
	# button.mouse_entered.connect(self._on_button_focus_entered)
	button.button_down.connect(self._on_button_down)

#region slots

func _on_scene_tree_node_added(node: Node):
	if node is BaseButton:
		connect_to_button(node)

func _on_button_focus_entered():
	select_sound.play()

func _on_button_down():
	press_sound.play()

#endregion
