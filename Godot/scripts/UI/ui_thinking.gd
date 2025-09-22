class_name UIThinking
extends Control

@onready	 var big_cog : TextureRect = $BigCog
@onready	 var small_cog : TextureRect = $SmallCog
@onready	 var froggo : TextureRect = $Froggo
@onready	 var anim_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	start()


func start() -> void:
	anim_player.play("Cog", -1, 0.3)
	


func stop() -> void:
	anim_player.stop(true)
