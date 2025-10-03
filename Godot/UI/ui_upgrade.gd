class_name UIUpgrade extends Control

@onready var cost_text : Label = $Cost
@onready var app_text : Label = $Appliance

@onready var bad : StyleBoxFlat = preload("res://UI/UI_Upgrade_Bad.tres")
@onready var good := preload("res://UI/UI_Upgrade_Good.tres")
@onready var bad_border := preload("res://UI/UI_Upgrade_Bad_Border.tres")
@onready var good_border := preload("res://UI/UI_Upgrade_Good_Border.tres")


func _set_info(upgrade : Upgradable, app : Appliance, can_buy : bool):
	assert(upgrade, "Upgrade is null")
	assert(app, "App is null")
	
	cost_text.text = "$" + str(upgrade.get_upgrade_cost())
	app_text.text = app.appliance_name
	
	$BG.add_theme_stylebox_override("panel", good_border if can_buy else bad_border)
	$CostBG.add_theme_stylebox_override("panel", good_border if can_buy else bad_border)
	$Color.add_theme_stylebox_override("panel", good if can_buy else bad)
