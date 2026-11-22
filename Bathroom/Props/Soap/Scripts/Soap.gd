extends StaticBody3D

func use_soap() -> void:
	EventBus.game_soap_used.emit()
