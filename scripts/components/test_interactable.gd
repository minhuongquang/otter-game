class_name TestInteractable
extends Interactable
## A simple test interactable that prints to the console.
##
## Used to validate the interaction foundation (M3.1).
##
## Behavior:
##     Player presses E → console prints "Interaction successful."

func interact(_player: Node2D) -> void:
	super(_player)
	print("Interaction successful.")