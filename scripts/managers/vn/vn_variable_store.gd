class_name VNVariableStore
extends RefCounted

## Stores VN-local variables and evaluates conditions.
## Variables are scoped to the current dialogue session and reset on start.
## Global flags are read/written through GlobalFlags autoload.

var _variables: Dictionary = {}

## Set a variable with an operator.
## Supported operators: "assign", "add", "subtract", "multiply", "divide"
func set_variable(key: String, operator_type: String, value: Variant) -> void:
	var current: Variant = _variables.get(key, 0)
	
	match operator_type:
		"assign":
			_variables[key] = value
		"add":
			_variables[key] = _to_numeric(current) + _to_numeric(value)
		"subtract":
			_variables[key] = _to_numeric(current) - _to_numeric(value)
		"multiply":
			_variables[key] = _to_numeric(current) * _to_numeric(value)
		"divide":
			var divisor: float = _to_numeric(value)
			if divisor != 0.0:
				_variables[key] = _to_numeric(current) / divisor
			else:
				push_warning("VNVariableStore: Division by zero for variable '%s'" % key)
		_:
			push_warning("VNVariableStore: Unknown operator '%s'" % operator_type)

## Get a variable value.
func get_variable(key: String, default_value: Variant = null) -> Variant:
	return _variables.get(key, default_value)

## Evaluate a condition expression string.
## Supported formats:
##   "flag_name == true"  — checks GlobalFlags
##   "flag_name == false"
##   "var_name >= 5"      — checks local variable
##   "var_name == value"
##   "true"               — always true
##   "false"              — always false
func evaluate_condition(expression: String) -> bool:
	expression = expression.strip_edges()
	
	if expression == "true":
		return true
	if expression == "false":
		return false
	
	# Try to parse "key operator value"
	var operators := ["==", "!=", ">=", "<=", ">", "<"]
	var op: String = ""
	var op_index: int = -1
	
	for operator in operators:
		var idx: int = expression.find(operator)
		if idx != -1:
			op = operator
			op_index = idx
			break
	
	if op_index == -1:
		push_warning("VNVariableStore: Could not parse condition: %s" % expression)
		return false
	
	var key: String = expression.substr(0, op_index).strip_edges()
	var value_str: String = expression.substr(op_index + op.length()).strip_edges()
	var value: Variant = _parse_value(value_str)
	
	# Check if it's a flag (prefixed with "flag_") or a local variable
	var actual_value: Variant = null
	
	if key.begins_with("flag_") or key.begins_with("story_"):
		# Read from GlobalFlags
		if GlobalFlags != null:
			actual_value = GlobalFlags.get_flag(key, null)
		else:
			push_warning("VNVariableStore: GlobalFlags not available")
			return false
	else:
		# Read from local variables
		actual_value = _variables.get(key, null)
	
	if actual_value == null:
		return false
	
	match op:
		"==":
			return _compare_equal(actual_value, value)
		"!=":
			return not _compare_equal(actual_value, value)
		">=":
			return _to_numeric(actual_value) >= _to_numeric(value)
		"<=":
			return _to_numeric(actual_value) <= _to_numeric(value)
		">":
			return _to_numeric(actual_value) > _to_numeric(value)
		"<":
			return _to_numeric(actual_value) < _to_numeric(value)
	
	return false

## Apply a choice effect dictionary.
func apply_effect(effect: Dictionary) -> void:
	var effect_type: String = effect.get("type", "")
	var key: String = effect.get("key", "")
	var value: Variant = effect.get("value", true)
	
	match effect_type:
		"set_flag":
			if GlobalFlags != null:
				GlobalFlags.set_flag(key, value)
		"set_variable":
			var op: String = effect.get("operator", "assign")
			set_variable(key, op, value)
		"add_relationship":
			if GlobalFlags != null:
				var current: int = GlobalFlags.get_flag(key, 0)
				GlobalFlags.set_flag(key, current + _to_numeric(value))
		_:
			push_warning("VNVariableStore: Unknown effect type: %s" % effect_type)

## Reset all local variables.
func reset() -> void:
	_variables.clear()

## Initialize variables from a Dictionary (e.g., from [VARIABLES] section).
func initialize(variables: Dictionary) -> void:
	_variables = variables.duplicate()

## Serialize for save system.
func serialize() -> Dictionary:
	return _variables.duplicate()

## Deserialize from save system.
func deserialize(data: Dictionary) -> void:
	_variables = data.duplicate()

# === Private Helpers ===

func _to_numeric(value: Variant) -> float:
	if value is float:
		return value
	if value is int:
		return float(value)
	if value is String:
		if value.is_valid_float():
			return value.to_float()
		if value.is_valid_int():
			return float(value.to_int())
	return 0.0

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

func _compare_equal(a: Variant, b: Variant) -> bool:
	if a is bool and b is bool:
		return a == b
	if a is int and b is int:
		return a == b
	if a is float and b is float:
		return abs(a - b) < 0.001
	if a is String and b is String:
		return a == b
	# Mixed types: convert to string comparison
	return str(a) == str(b)