class_name TutorialNode extends Resource
 
enum TYPE{
	WAIT,
	SIGNAL
}
@export var text_keyboard : String
@export var text_controller : String
@export var type : TYPE
@export var num : int
@export var time : float
@export var world_interaction : int = -1
