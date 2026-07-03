extends TextureRect
class_name VNPortrait

## Character portrait display for the Visual Novel.
## Handles expression switching and entrance/exit animations.

var character_id: String = ""
var character_resource: CharacterResource = null

## Initialize the portrait with character data.
func setup(char_id: String, resource: CharacterResource) -> void:
	character_id = char_id
	character_resource = resource
	
	# Set default portrait texture
	if resource.portrait != null:
		texture = resource.portrait
	
	# Set default size
	custom_minimum_size = Vector2(400, 600)
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

## Change the character's expression.
## Looks for a texture in the character resource matching the emotion name.
func set_expression(emotion: String) -> void:
	if character_resource == null:
		return
	
	# If the character resource has expression textures, use them
	# For now, we keep the default portrait
	# Future: character_resource could have an expressions Dictionary
	pass

## Play an animation on this portrait.
func play_animation(animation_id: String) -> void:
	match animation_id:
		"bounce":
			var tween := create_tween()
			var original_y := position.y
			tween.tween_property(self, "position:y", original_y - 20, 0.1)
			tween.tween_property(self, "position:y", original_y, 0.1)
		"shake":
			var original_pos := position
			var tween := create_tween()
			for i in range(5):
				tween.tween_property(self, "position", original_pos + Vector2(5, 0), 0.05)
				tween.tween_property(self, "position", original_pos - Vector2(5, 0), 0.05)
			tween.tween_property(self, "position", original_pos, 0.05)
		"flash":
			var original_modulate := modulate
			var tween := create_tween()
			tween.tween_property(self, "modulate", Color.WHITE, 0.05)
			tween.tween_property(self, "modulate", original_modulate, 0.1)