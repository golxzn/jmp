class_name Collector extends Area2D

signal collected_values_updated(collected_score: int, collected_count: int)
signal collected(score: int)

var collected_count: int = 0
var collected_score: int = 0

func _ready() -> void:
	area_entered.connect(self._on_area_entered)

func collect(item: Collectable) -> void:
	if not item.is_collected():
		var value: int = item.collect()
		collected_score += value
		collected_count += 1
		collected_values_updated.emit(collected_score, collected_count)
		collected.emit(value)

func _on_area_entered(area: Area2D) -> void:
	if area is Collectable:
		collect(area as Collectable)
