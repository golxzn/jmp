class_name DashingTimer extends ProgressTimer

@export_range(0.0, 5.0) var next_dash_treshold: float = 0.025

func start_dash():
	start()

func start_dash_for(duration: float):
	wait_time = duration
	start()

func can_dash() -> bool:
	return is_stopped() or (wait_time <= next_dash_treshold)

func is_dashing() -> bool:
	return not is_stopped()
