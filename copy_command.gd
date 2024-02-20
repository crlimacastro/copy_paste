class_name CopyCommand
extends Command

var node: Node3D = null

var _previous_node: Node3D = null

func with_node(value: Node3D) -> CopyCommand:
	node = value
	return self

func execute() -> void:
	_previous_node = NodeClipboard.node
	NodeClipboard.node = node
	
func undo() -> void:
	NodeClipboard.node = _previous_node
