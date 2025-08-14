class_name Occupiable extends Node3D

var _id : String # For communications with other services

# Current occupiant information
var _is_occupied = false
var _is_occupied_with 

## Initialize occupiable with communication id
func initialize(id : String) -> void:
	_id = id

## Sets state of occupiable and what, if anything, is occupying it 
func set_occupied(occupied: bool = true, occupied_with = null):
	_is_occupied = occupied
	if occupied_with:
		_is_occupied_with = occupied_with
	if !occupied:
		_is_occupied_with = null
		
## return state of occupiable
func occupied():
	return _is_occupied
	
## returns current occuipant even if its nothing
func occupied_with():
	return _is_occupied_with
## Provides reference to id
func id()->String:
	return _id
