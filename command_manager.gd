class_name CommandManager

var _command_history: Array[Command] = []

func execute(command: Command):
	command.execute()
	_command_history.append(command)

func undo():
	var last_command:Command = _command_history.pop_back()
	if last_command == null:
		return
	last_command.undo()
