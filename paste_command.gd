class_name PasteCommand
extends Command

var parent_node: Node = null
var position: Vector3 = Vector3.ZERO

var _pasted_node: Node3D = null;

func with_parent_node(value: Node) -> PasteCommand:
	parent_node = value
	return self
	
func with_position(value: Vector3) -> PasteCommand:
	position = value
	return self

func execute() -> void:
	if NodeClipboard.node == null:
		return
	_pasted_node = NodeClipboard.node.duplicate() as Node3D
	_pasted_node.position = position
	parent_node.add_child(_pasted_node)

func undo() -> void:
	if _pasted_node == null:
		return
	_pasted_node.queue_free()
