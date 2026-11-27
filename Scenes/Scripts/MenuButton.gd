extends Button

func _on_mouse_entered() -> void:
	var tween := get_tree().create_tween().set_parallel()
	tween.tween_property(self, "offset_transform_scale", Vector2(1.3, 1.3), 0.2)
	for button in get_tree().get_nodes_in_group("Menu Buttons") as Array[Button]:
		if button != self:
			tween.tween_property(button, "offset_transform_scale", Vector2(0.7, 0.7), 0.2)

func _on_mouse_exited() -> void:
	var tween := get_tree().create_tween().set_parallel()
	for button in get_tree().get_nodes_in_group("Menu Buttons") as Array[Button]:
		tween.tween_property(button, "offset_transform_scale", Vector2.ONE, 0.2)
