class_name VNScriptCompiler
extends RefCounted

## Compiles .dialogue text files into VNDialogueResource.
## Performs two-pass compilation:
##   Pass 1: Parse text into raw command list, collect label positions
##   Pass 2: Resolve label references into command indexes, build final command array
##
## Usage:
##   var compiler := VNScriptCompiler.new()
##   var resource := compiler.compile_file("res://database/dialogue/prologue.dialogue")
##   if resource:
##       save_resource(resource, "res://database/dialogue/compiled/prologue.tres")

const COMMAND_PATTERNS := {
	"LINE":     r"^LINE\s+(\S+)\s+\"([^\"]*)\"\s+(\S+)\s+\"(.+)\"$",
	"SHOW":     r"^SHOW\s+(\S+)\s+(\S+)\s+(\S+)?$",
	"HIDE":     r"^HIDE\s+(\S+)\s+(\S+)?$",
	"EXPR":     r"^EXPR\s+(\S+)\s+(\S+)$",
	"BACKGROUND": r"^BACKGROUND\s+\"([^\"]+)\"\s+(\S+)\s+([\d\.]+)$",
	"BGM":      r"^BGM\s+\"([^\"]+)\"\s+([\d\.]+)$",
	"STOP_BGM": r"^STOP_BGM\s+([\d\.]+)$",
	"SFX":      r"^SFX\s+\"([^\"]+)\"\s*([\d\.\-]+)?$",
	"SHAKE":    r"^SHAKE\s+([\d\.]+)\s+([\d\.]+)$",
	"FADE":     r"^FADE\s+(\S+)\s+([\d\.]+)$",
	"GIVE_ITEM": r"^GIVE_ITEM\s+(\S+)\s+(\d+)$",
	"START_BATTLE": r"^START_BATTLE\s+(\S+)$",
	"UNLOCK_REGION": r"^UNLOCK_REGION\s+(\S+)$",
	"CUTSCENE": r"^CUTSCENE\s+(\S+)$",
	"SET_FLAG": r"^SET_FLAG\s+(\S+)\s+(.+)$",
	"SET_VAR":  r"^SET_VAR\s+(\S+)\s+(\S+)\s+(.+)$",
	"JUMP":     r"^JUMP\s+(\S+)$",
	"BRANCH":   r"^BRANCH\s+(.+?)\s+JUMP\s+(\S+)$",
	"CHOICE":   r"^CHOICE\s+\"(.+)\"$",
	"ANIM":     r"^ANIM\s+(\S+)\s+(\S+)\s*(.*)?$",
	"WAIT":     r"^WAIT\s+([\d\.]+)$",
	"LABEL":    r"^LABEL\s+(\S+)$",
}

# === Compilation ===

## Compile a .dialogue file from the given path.
func compile_file(file_path: String) -> VNDialogueResource:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("VNScriptCompiler: Cannot open file: %s" % file_path)
		return null
	
	var content: String = file.get_as_text()
	file.close()
	
	return compile_text(content, file_path)

## Compile a .dialogue text string into a VNDialogueResource.
## file_path is used for error reporting only.
func compile_text(content: String, source_path: String = "") -> VNDialogueResource:
	var resource := VNDialogueResource.new()
	
	# Parse metadata section
	var meta := _parse_metadata(content)
	if meta.has("id"):
		resource.dialogue_id = meta["id"]
	
	# Populate resource metadata from parsed [META] section
	if meta.has("on_start"):
		resource.on_start_events = _parse_json_array(meta["on_start"])
	if meta.has("on_end"):
		resource.on_end_events = _parse_json_array(meta["on_end"])
	if meta.has("bg"):
		var bg_path: String = meta["bg"]
		if ResourceLoader.exists(bg_path):
			resource.background = load(bg_path) as Texture2D
	if meta.has("bgm"):
		var bgm_path: String = meta["bgm"]
		if ResourceLoader.exists(bgm_path):
			resource.bgm = load(bgm_path) as AudioStream
	
	# Parse character definitions
	var characters := _parse_character_defs(content)
	
	# Parse variable definitions
	var variables := _parse_variable_defs(content)
	
	# Pass 1: Parse all lines into raw commands
	var raw_commands: Array[Dictionary] = []
	var label_map: Dictionary = {}  # label_name -> command_index
	
	var lines: PackedStringArray = content.split("\n", false)
	var in_script: bool = false
	var choice_buffer: Array[Dictionary] = []  # Buffer for CHOICE lines
	var current_choice_group: int = -1
	
	for i in range(lines.size()):
		var line: String = lines[i].strip_edges()
		
		# Skip empty lines and comments
		if line.is_empty() or line.begins_with("#"):
			continue
		
		# Section markers
		if line.begins_with("[") and line.ends_with("]"):
			var section: String = line.substr(1, line.length() - 2).to_upper()
			in_script = (section == "SCRIPT")
			continue
		
		if not in_script:
			continue
		
		# Try to parse the line
		var parsed: Variant = _parse_line(line)
		if parsed == null:
			push_warning("VNScriptCompiler: Unrecognized line at %s:%d: %s" % [source_path, i + 1, line])
			continue
		
		# Handle label indexing
		if parsed["type"] == "label":
			label_map[parsed["label_name"]] = raw_commands.size()
		
		# Handle choice buffering
		if parsed["type"] == "choice_start":
			choice_buffer.clear()
			current_choice_group = raw_commands.size()
		elif parsed["type"] == "choice_option":
			choice_buffer.append(parsed)
			continue  # Don't add to raw_commands yet
		elif parsed["type"] == "choice_effects_set_flag":
			if not choice_buffer.is_empty():
				var last_choice := choice_buffer[choice_buffer.size() - 1]
				last_choice["effects"].append(parsed)
			continue
		elif parsed["type"] == "choice_effects_set_var":
			if not choice_buffer.is_empty():
				var last_choice := choice_buffer[choice_buffer.size() - 1]
				last_choice["effects"].append(parsed)
			continue
		elif parsed["type"] == "choice_target":
			if not choice_buffer.is_empty():
				var last_choice := choice_buffer[choice_buffer.size() - 1]
				last_choice["target_label"] = parsed["target_label"]
			continue
		elif parsed["type"] == "choice_end":
			# Compile the buffered choices into a VNCmdChoice command
			var cmd := VNCmdChoice.new()
			var choice_data_array: Array[VNChoiceData] = []
			for choice_buf in choice_buffer:
				var data := VNChoiceData.new()
				data.choice_text = choice_buf.get("text", "")
				data.target_label = choice_buf.get("target_label", "")
				data.effects = choice_buf.get("effects", [])
				data.condition_expression = choice_buf.get("condition", "")
				choice_data_array.append(data)
			cmd.choices = choice_data_array
			raw_commands.append({"type": "command", "command": cmd})
			choice_buffer.clear()
			continue
		
		raw_commands.append(parsed)
	
	# Pass 2: Resolve labels and convert to VNCommand instances
	var commands: Array[VNCommand] = []
	for entry in raw_commands:
		var cmd: VNCommand = _entry_to_command(entry, label_map)
		if cmd != null:
			commands.append(cmd)
	
	resource.commands = commands
	return resource

# === Internal Parsing ===

func _parse_metadata(content: String) -> Dictionary:
	var meta: Dictionary = {}
	var lines: PackedStringArray = content.split("\n", false)
	var in_meta: bool = false
	
	for line in lines:
		var stripped: String = line.strip_edges()
		if stripped == "[META]":
			in_meta = true
			continue
		if in_meta and stripped.begins_with("["):
			break
		if not in_meta:
			continue
		
		var parts: PackedStringArray = stripped.split(":", true, 1)
		if parts.size() == 2:
			var key: String = parts[0].strip_edges().to_lower()
			var value: String = parts[1].strip_edges()
			# Remove quotes if present
			if value.begins_with("\"") and value.ends_with("\""):
				value = value.substr(1, value.length() - 2)
			meta[key] = value
	
	return meta

func _parse_character_defs(content: String) -> Dictionary:
	var chars: Dictionary = {}
	var lines: PackedStringArray = content.split("\n", false)
	var in_chars: bool = false
	
	for line in lines:
		var stripped: String = line.strip_edges()
		if stripped == "[CHARACTERS]":
			in_chars = true
			continue
		if in_chars and stripped.begins_with("["):
			break
		if not in_chars:
			continue
		
		var parts: PackedStringArray = stripped.split("=", true, 1)
		if parts.size() == 2:
			var key: String = parts[0].strip_edges()
			var value: String = parts[1].strip_edges().strip_edges()
			if value.begins_with("\"") and value.ends_with("\""):
				value = value.substr(1, value.length() - 2)
			chars[key] = value
	
	return chars

func _parse_variable_defs(content: String) -> Dictionary:
	var vars: Dictionary = {}
	var lines: PackedStringArray = content.split("\n", false)
	var in_vars: bool = false
	
	for line in lines:
		var stripped: String = line.strip_edges()
		if stripped == "[VARIABLES]":
			in_vars = true
			continue
		if in_vars and stripped.begins_with("["):
			break
		if not in_vars:
			continue
		
		var parts: PackedStringArray = stripped.split(":", true, 1)
		if parts.size() == 2:
			var key: String = parts[0].strip_edges()
			var value_str: String = parts[1].strip_edges()
			# Try to parse as int, float, bool, or string
			var value: Variant = _parse_value(value_str)
			vars[key] = value
	
	return vars

func _parse_value(value_str: String) -> Variant:
	if value_str.is_empty():
		return ""
	if value_str == "true":
		return true
	if value_str == "false":
		return false
	if value_str.is_valid_int():
		return value_str.to_int()
	if value_str.is_valid_float():
		return value_str.to_float()
	if value_str.begins_with("\"") and value_str.ends_with("\""):
		return value_str.substr(1, value_str.length() - 2)
	return value_str

## Parse a JSON-style array string from metadata into an Array[Dictionary].
## Handles formats like: [] or [{"type":"set_flag","key":"p","value":true}]
func _parse_json_array(raw: String) -> Array[Dictionary]:
	raw = raw.strip_edges()
	if raw == "[]" or raw == "":
		return []
	
	var result: Array[Dictionary] = []
	# Remove outer brackets
	var inner: String = raw.substr(1, raw.length() - 2).strip_edges()
	if inner.is_empty():
		return result
	
	# Parse each {...} object
	var depth: int = 0
	var start: int = -1
	for i in range(inner.length()):
		var ch: String = inner[i]
		if ch == "{":
			if depth == 0:
				start = i
			depth += 1
		elif ch == "}":
			depth -= 1
			if depth == 0 and start >= 0:
				var obj_str: String = inner.substr(start, i - start + 1)
				var obj := _parse_json_object(obj_str)
				if not obj.is_empty():
					result.append(obj)
				start = -1
	
	return result

## Parse a single JSON object string into a Dictionary.
## Handles: {"type":"set_flag","key":"p","value":true}
func _parse_json_object(raw: String) -> Dictionary:
	var obj: Dictionary = {}
	# Remove outer braces
	var inner: String = raw.substr(1, raw.length() - 2).strip_edges()
	if inner.is_empty():
		return obj
	
	# Split by commas, respecting quoted strings
	var pairs := _split_json_pairs(inner)
	for pair in pairs:
		var colon_idx: int = pair.find(":")
		if colon_idx == -1:
			continue
		var key: String = pair.substr(0, colon_idx).strip_edges()
		var value_str: String = pair.substr(colon_idx + 1).strip_edges()
		# Remove quotes from key
		if key.begins_with("\"") and key.ends_with("\""):
			key = key.substr(1, key.length() - 2)
		obj[key] = _parse_value(value_str)
	
	return obj

## Split a JSON object contents string by commas, respecting quoted strings and nested braces.
func _split_json_pairs(raw: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var current: String = ""
	var in_quotes: bool = false
	var depth: int = 0
	
	for i in range(raw.length()):
		var ch: String = raw[i]
		if ch == "\"" and (i == 0 or raw[i - 1] != "\\"):
			in_quotes = not in_quotes
		elif not in_quotes:
			if ch == "{" or ch == "[":
				depth += 1
			elif ch == "}" or ch == "]":
				depth -= 1
		
		if ch == "," and not in_quotes and depth == 0:
			result.append(current.strip_edges())
			current = ""
		else:
			current += ch
	
	if not current.strip_edges().is_empty():
		result.append(current.strip_edges())
	
	return result

func _parse_line(line: String) -> Variant:
	# Try each pattern
	if line.begins_with("LINE "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["LINE"])
		var result := regex.search(line)
		if result:
			return {
				"type": "dialogue_line",
				"speaker_id": result.get_string(1),
				"display_name": result.get_string(2),
				"emotion": result.get_string(3),
				"dialogue_text": result.get_string(4)
			}
	
	if line.begins_with("SHOW "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["SHOW"])
		var result := regex.search(line)
		if result:
			return {
				"type": "show_character",
				"character_id": result.get_string(1),
				"position": result.get_string(2),
				"animation": result.get_string(3) if result.get_string(3) != "" else "fade_in"
			}
	
	if line.begins_with("HIDE "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["HIDE"])
		var result := regex.search(line)
		if result:
			return {
				"type": "hide_character",
				"character_id": result.get_string(1),
				"animation": result.get_string(2) if result.get_string(2) != "" else "fade_out"
			}
	
	if line.begins_with("EXPR "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["EXPR"])
		var result := regex.search(line)
		if result:
			return {
				"type": "change_expression",
				"character_id": result.get_string(1),
				"emotion": result.get_string(2)
			}
	
	if line.begins_with("BACKGROUND "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["BACKGROUND"])
		var result := regex.search(line)
		if result:
			return {
				"type": "background",
				"texture_path": result.get_string(1),
				"transition": result.get_string(2),
				"duration": result.get_string(3).to_float()
			}
	
	if line.begins_with("BGM "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["BGM"])
		var result := regex.search(line)
		if result:
			return {
				"type": "play_bgm",
				"audio_path": result.get_string(1),
				"fade_in": result.get_string(2).to_float()
			}
	
	if line.begins_with("STOP_BGM "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["STOP_BGM"])
		var result := regex.search(line)
		if result:
			return {
				"type": "stop_bgm",
				"fade_out": result.get_string(1).to_float()
			}
	
	if line.begins_with("SFX "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["SFX"])
		var result := regex.search(line)
		if result:
			return {
				"type": "play_sfx",
				"audio_path": result.get_string(1),
				"volume": result.get_string(2).to_float() if result.get_string(2) != "" else 0.0
			}
	
	if line.begins_with("SHAKE "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["SHAKE"])
		var result := regex.search(line)
		if result:
			return {
				"type": "shake_camera",
				"intensity": result.get_string(1).to_float(),
				"duration": result.get_string(2).to_float()
			}
	
	if line.begins_with("FADE "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["FADE"])
		var result := regex.search(line)
		if result:
			return {
				"type": "fade",
				"target_color": result.get_string(1),
				"duration": result.get_string(2).to_float()
			}
	
	if line.begins_with("GIVE_ITEM "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["GIVE_ITEM"])
		var result := regex.search(line)
		if result:
			return {
				"type": "give_item",
				"item_id": result.get_string(1),
				"quantity": result.get_string(2).to_int()
			}
	
	if line.begins_with("START_BATTLE "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["START_BATTLE"])
		var result := regex.search(line)
		if result:
			return {
				"type": "start_battle",
				"enemy_group_id": result.get_string(1)
			}
	
	if line.begins_with("UNLOCK_REGION "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["UNLOCK_REGION"])
		var result := regex.search(line)
		if result:
			return {
				"type": "unlock_region",
				"region_id": result.get_string(1)
			}
	
	if line.begins_with("CUTSCENE "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["CUTSCENE"])
		var result := regex.search(line)
		if result:
			return {
				"type": "start_cutscene",
				"cutscene_id": result.get_string(1)
			}
	
	if line.begins_with("SET_FLAG "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["SET_FLAG"])
		var result := regex.search(line)
		if result:
			return {
				"type": "set_flag",
				"flag_key": result.get_string(1),
				"flag_value": _parse_value(result.get_string(2).strip_edges())
			}
	
	if line.begins_with("SET_VAR "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["SET_VAR"])
		var result := regex.search(line)
		if result:
			return {
				"type": "set_variable",
				"var_key": result.get_string(1),
				"operator": result.get_string(2),
				"var_value": _parse_value(result.get_string(3).strip_edges())
			}
	
	if line.begins_with("JUMP "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["JUMP"])
		var result := regex.search(line)
		if result:
			return {
				"type": "jump",
				"target_label": result.get_string(1)
			}
	
	if line.begins_with("BRANCH "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["BRANCH"])
		var result := regex.search(line)
		if result:
			return {
				"type": "branch",
				"condition": result.get_string(1),
				"target_label": result.get_string(2)
			}
	
	if line.begins_with("CHOICE "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["CHOICE"])
		var result := regex.search(line)
		if result:
			# Check if the next line is a condition or effect
			return {
				"type": "choice_option",
				"text": result.get_string(1),
				"effects": [],
				"target_label": "",
				"condition": ""
			}
	
	# Check for indented choice effects as separate lines
	if line.begins_with("    SET_FLAG "):
		var flag_regex := RegEx.create_from_string(COMMAND_PATTERNS["SET_FLAG"])
		var flag_result := flag_regex.search(line.strip_edges())
		if flag_result:
			return {
				"type": "choice_effects_set_flag",
				"flag_key": flag_result.get_string(1),
				"flag_value": _parse_value(flag_result.get_string(2).strip_edges())
			}
	if line.begins_with("    SET_VAR "):
		var var_regex := RegEx.create_from_string(COMMAND_PATTERNS["SET_VAR"])
		var var_result := var_regex.search(line.strip_edges())
		if var_result:
			return {
				"type": "choice_effects_set_var",
				"var_key": var_result.get_string(1),
				"operator": var_result.get_string(2),
				"var_value": _parse_value(var_result.get_string(3).strip_edges())
			}
	if line.begins_with("    JUMP "):
		var jump_regex := RegEx.create_from_string(COMMAND_PATTERNS["JUMP"])
		var jump_result := jump_regex.search(line.strip_edges())
		if jump_result:
			return {
				"type": "choice_target",
				"target_label": jump_result.get_string(1)
			}
	
	if line.begins_with("ANIM "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["ANIM"])
		var result := regex.search(line)
		if result:
			var params_str: String = result.get_string(3).strip_edges()
			var params: Dictionary = {}
			if not params_str.is_empty():
				# Parse key=value pairs
				var pairs: PackedStringArray = params_str.split(" ")
				for pair in pairs:
					var kv: PackedStringArray = pair.split("=")
					if kv.size() == 2:
						params[kv[0].strip_edges()] = _parse_value(kv[1].strip_edges())
			return {
				"type": "animation",
				"target": result.get_string(1),
				"animation_id": result.get_string(2),
				"params": params
			}
	
	if line.begins_with("WAIT "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["WAIT"])
		var result := regex.search(line)
		if result:
			return {
				"type": "wait",
				"duration": result.get_string(1).to_float()
			}
	
	if line.begins_with("LABEL "):
		var regex := RegEx.create_from_string(COMMAND_PATTERNS["LABEL"])
		var result := regex.search(line)
		if result:
			return {
				"type": "label",
				"label_name": result.get_string(1)
			}
	
	return null

func _entry_to_command(entry: Dictionary, label_map: Dictionary) -> VNCommand:
	match entry.get("type", ""):
		"dialogue_line":
			var cmd := VNCmdDialogueLine.new()
			cmd.speaker_id = entry.get("speaker_id", "")
			cmd.display_name = entry.get("display_name", "")
			cmd.emotion = entry.get("emotion", "neutral")
			cmd.dialogue_text = entry.get("dialogue_text", "")
			return cmd
		
		"show_character":
			var cmd := VNCmdShowCharacter.new()
			cmd.character_id = entry.get("character_id", "")
			cmd.position = entry.get("position", "center")
			cmd.animation = entry.get("animation", "fade_in")
			return cmd
		
		"hide_character":
			var cmd := VNCmdHideCharacter.new()
			cmd.character_id = entry.get("character_id", "")
			cmd.animation = entry.get("animation", "fade_out")
			return cmd
		
		"change_expression":
			var cmd := VNCmdChangeExpression.new()
			cmd.character_id = entry.get("character_id", "")
			cmd.emotion = entry.get("emotion", "neutral")
			return cmd
		
		"background":
			var cmd := VNCmdBackground.new()
			cmd.texture_path = entry.get("texture_path", "")
			cmd.transition = entry.get("transition", "fade")
			cmd.duration = entry.get("duration", 1.0)
			return cmd
		
		"play_bgm":
			var cmd := VNCmdPlayBGM.new()
			cmd.audio_path = entry.get("audio_path", "")
			cmd.fade_in = entry.get("fade_in", 0.0)
			return cmd
		
		"stop_bgm":
			var cmd := VNCmdStopBGM.new()
			cmd.fade_out = entry.get("fade_out", 0.0)
			return cmd
		
		"play_sfx":
			var cmd := VNCmdPlaySFX.new()
			cmd.audio_path = entry.get("audio_path", "")
			cmd.volume = entry.get("volume", 0.0)
			return cmd
		
		"shake_camera":
			var cmd := VNCmdShakeCamera.new()
			cmd.intensity = entry.get("intensity", 0.3)
			cmd.duration = entry.get("duration", 0.5)
			return cmd
		
		"fade":
			var cmd := VNCmdFade.new()
			cmd.target_color = entry.get("target_color", "black")
			cmd.duration = entry.get("duration", 1.0)
			return cmd
		
		"give_item":
			var cmd := VNCmdGiveItem.new()
			cmd.item_id = entry.get("item_id", "")
			cmd.quantity = entry.get("quantity", 1)
			return cmd
		
		"start_battle":
			var cmd := VNCmdStartBattle.new()
			cmd.enemy_group_id = entry.get("enemy_group_id", "")
			return cmd
		
		"unlock_region":
			var cmd := VNCmdUnlockRegion.new()
			cmd.region_id = entry.get("region_id", "")
			return cmd
		
		"start_cutscene":
			var cmd := VNCmdStartCutscene.new()
			cmd.cutscene_id = entry.get("cutscene_id", "")
			return cmd
		
		"set_flag":
			var cmd := VNCmdSetFlag.new()
			cmd.flag_key = entry.get("flag_key", "")
			cmd.flag_value = entry.get("flag_value", true)
			return cmd
		
		"set_variable":
			var cmd := VNCmdSetVariable.new()
			cmd.var_key = entry.get("var_key", "")
			cmd.operator = entry.get("operator", "assign")
			cmd.var_value = entry.get("var_value", 0)
			return cmd
		
		"jump":
			# Convert jump to a branch with no condition (always true)
			var cmd := VNCmdBranch.new()
			cmd.condition_expression = "true"
			cmd.target_label = entry.get("target_label", "")
			return cmd
		
		"branch":
			var cmd := VNCmdBranch.new()
			cmd.condition_expression = entry.get("condition", "")
			cmd.target_label = entry.get("target_label", "")
			return cmd
		
		"choice":
			# Already constructed as VNCmdChoice in the parser
			return entry.get("command", null)
		
		"animation":
			var cmd := VNCmdAnimation.new()
			cmd.target = entry.get("target", "")
			cmd.animation_id = entry.get("animation_id", "")
			cmd.params = entry.get("params", {})
			return cmd
		
		"wait":
			var cmd := VNCmdWait.new()
			cmd.duration = entry.get("duration", 1.0)
			return cmd
		
		"label":
			var cmd := VNCmdLabel.new()
			cmd.label_name = entry.get("label_name", "")
			return cmd
	
	return null

## Save a compiled VNDialogueResource to disk.
func save_resource(resource: VNDialogueResource, path: String) -> int:
	return ResourceSaver.save(resource, path)
