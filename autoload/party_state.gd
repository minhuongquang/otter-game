## PartyState — persistent runtime holder for party HP/SP between scenes.
## Written by battle lifecycle handlers after every battle.
## Read/written by SaveManager during save/load.
## Apply snapshots via PartyState.apply_to() before starting a battle.
extends Node

## Persistent party runtime state.
## Each entry: { character_id: String, current_hp: int, current_sp: int }
var snapshots: Array[Dictionary] = []

## Apply saved HP/SP to an array of BattleActors.
## Matches by actor_id. Actors not found in snapshots keep their defaults.
func apply_to(party: Array[BattleActor]) -> void:
	for actor in party:
		for snap in snapshots:
			if snap.get("character_id", "") == actor.actor_id:
				actor.current_hp = snap.get("current_hp", actor.current_hp)
				actor.current_sp = snap.get("current_sp", actor.current_sp)
				break