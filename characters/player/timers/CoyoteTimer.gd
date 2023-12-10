class_name CoyoteTimer extends ProgressTimer

func is_coyote() -> bool:
	return not is_stopped()
