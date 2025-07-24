extends Node

signal money_changed(new_amount)

var money: int = 0

func _ready():
	load_money()

func add_money(amount: int):
	money += amount
	money_changed.emit(money)
	save_money()

func get_money() -> int:
	return money

func save_money():
	# Save to OS user directory (works on web as local storage)
	var config = ConfigFile.new()
	config.set_value("player", "money", money)
	var save_path = "user://money_save.cfg"
	config.save(save_path)

func load_money():
	var config = ConfigFile.new()
	var save_path = "user://money_save.cfg"
	
	if config.load(save_path) == OK:
		money = config.get_value("player", "money", 0)
	else:
		money = 0
	
	money_changed.emit(money)