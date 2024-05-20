extends Node

const TS = 16.0

var rng = RandomNumberGenerator.new()


func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
