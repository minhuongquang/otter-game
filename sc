[gd_scene load_steps=2 format=3 uid="uid://battlelog001"]

[ext_resource type="Script" path="res://scripts/battle/battle_log.gd" id="1_log"]

[node name="BattleLog" type="Panel"]
script = ExtResource("1_log")
offset_right = 320.0
offset_bottom = 160.0

[node name="MarginContainer" type="MarginContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
theme_override_constants/margin_left = 4
theme_override_constants/margin_right = 4
theme_override_constants/margin_top = 4
theme_override_constants/margin_bottom = 4

[node name="ScrollContainer" type="ScrollContainer" parent="MarginContainer"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 3
follow_focus = true

[node name="TextLabel" type="RichTextLabel" parent="MarginContainer/ScrollContainer"]
unique_name_in_owner = true
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 3
bbcode_enabled = true
text = ""
fit_content = true
scroll_active = false