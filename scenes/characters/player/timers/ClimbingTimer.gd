class_name ClimbingTimer extends ProgressTimer

const CLIMB_RESISTANCE: float = 0.5

@onready var default_wait_time: float = wait_time
@onready var start_wait_time: float = 0.0

var current_climb_resistance: float = CLIMB_RESISTANCE

func start_climb():
	start_wait_time = wait_time
	wait_time = default_wait_time
	current_climb_resistance = CLIMB_RESISTANCE
	start()

func start_climb_for(duration: float, resistance: float):
	wait_time = duration if duration > 0.0 else default_wait_time
	start_wait_time = wait_time
	current_climb_resistance = resistance if resistance > 0.0 else CLIMB_RESISTANCE
	start()

func climbing_resistance() -> float:
	return lerp(CLIMB_RESISTANCE, 1.0, progress())

func is_climbing() -> bool:
	return not is_stopped()
