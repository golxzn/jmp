class_name ProgressTimer extends Timer

func progress() -> float:
	return 1.0 - time_left / wait_time

