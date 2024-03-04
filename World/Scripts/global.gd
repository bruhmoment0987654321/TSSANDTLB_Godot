extends Node

signal level_completed
signal add_dash_amount
var coins = 0
var dash_amount = 0
var ammo = 0

static func chance(percent_num):
	return percent_num > randf()
