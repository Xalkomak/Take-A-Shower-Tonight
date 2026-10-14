extends StaticBody3D

@onready var interactable: Interactable = $Interactable

func use_soap() -> void:
	EventBus.game_soap_used.emit()
