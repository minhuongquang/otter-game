## Quest VN Commands — registers quest-related commands with VNCommandExecutor.
## Called once per session from wherever VN initialization happens.
## All commands delegate to QuestManager.instance().
class_name QuestVNCommands
extends RefCounted

## Register all quest VN commands on a VNCommandExecutor.
static func register(executor) -> void:
	executor.register_handler("accept_quest", _vn_accept_quest)
	executor.register_handler("complete_quest", _vn_complete_quest)
	executor.register_handler("advance_stage", _vn_advance_stage)
	executor.register_handler("fail_quest", _vn_fail_quest)
	executor.register_handler("check_quest", _vn_check_quest)

## ACCEPT_QUEST quest_id — Accept an available quest.
static func _vn_accept_quest(cmd, _executor) -> bool:
	var quest_id: String = _param_str(cmd, "quest_id")
	if quest_id == "":
		push_warning("QuestVN: ACCEPT_QUEST missing quest_id")
		return false
	var qm := QuestManager.instance()
	qm.accept_quest(quest_id)
	return false  # non-blocking

## COMPLETE_QUEST quest_id — Complete a ready-to-complete quest (turn-in).
static func _vn_complete_quest(cmd, _executor) -> bool:
	var quest_id: String = _param_str(cmd, "quest_id")
	if quest_id == "":
		push_warning("QuestVN: COMPLETE_QUEST missing quest_id")
		return false
	var qm := QuestManager.instance()
	qm.complete_quest(quest_id)
	qm.claim_rewards(quest_id)
	return false  # non-blocking

## ADVANCE_STAGE quest_id — Manually advance to next stage (dialogue-driven).
static func _vn_advance_stage(cmd, _executor) -> bool:
	var quest_id: String = _param_str(cmd, "quest_id")
	if quest_id == "":
		push_warning("QuestVN: ADVANCE_STAGE missing quest_id")
		return false
	var qm := QuestManager.instance()
	qm.advance_stage(quest_id)
	return false  # non-blocking

## FAIL_QUEST quest_id — Fail a quest.
static func _vn_fail_quest(cmd, _executor) -> bool:
	var quest_id: String = _param_str(cmd, "quest_id")
	if quest_id == "":
		push_warning("QuestVN: FAIL_QUEST missing quest_id")
		return false
	var qm := QuestManager.instance()
	qm.fail_quest(quest_id)
	return false  # non-blocking

## CHECK_QUEST quest_id var_name — Write quest state to a VN variable.
static func _vn_check_quest(cmd, executor) -> bool:
	var quest_id: String = _param_str(cmd, "quest_id")
	var var_name: String = _param_str(cmd, "state_var")
	if quest_id == "" or var_name == "":
		return false
	var qm := QuestManager.instance()
	var state: int = qm.get_state(quest_id)
	# VN variable store is accessible through executor
	if executor.has_method("_variable_store") or executor._variable_store != null:
		executor._variable_store.set_variable(var_name, str(state))
	return false  # non-blocking

## Extract a named parameter from the command.
static func _param_str(cmd, param_name: String) -> String:
	if cmd.has_method("get") and cmd.get(param_name) != null:
		return str(cmd.get(param_name))
	# VNCommand subclasses store params in metadata
	if cmd.has_method("get_meta") and cmd.has_meta(param_name):
		return str(cmd.get_meta(param_name))
	return ""