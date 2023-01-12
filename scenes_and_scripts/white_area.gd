extends Area2D

onready var parent = get_parent()
onready var col = $CollisionShape2D

var partner = []

func _on_white_area_mouse_entered():
	if parent.get_parent().eraser:
		for line in parent.get_parent().all_lines_and_circles.size():
			if parent.get_parent().all_lines_and_circles[line] == self:
				parent.get_parent().all_lines_and_circles.remove(line)
				break
		queue_free_this()

func queue_free_this():
	queue_free()
	for part in partner:
		part.queue_free()
