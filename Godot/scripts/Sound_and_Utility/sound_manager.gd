# sound_manager.gd
extends Node

# Note: field orders are not following style guide for improved maintainability
# Enum for sound identification and Map enum to file paths

# Background Music (BGM)
enum BGM {
	MENU,
	BUS,
	BEACH,
	# Add more as needed
}

var bgm_paths := {
	BGM.MENU: "res://Sounds/Main MenuLoop.mp3",
}

# Sound Effects (SFX)
enum SFX {
	RAT,
	# Add more as needed
}

var sfx_paths := {
	SFX.RAT: "res://Sounds/AwRats.wav"
}

# Player-specific SFX
enum SFX_PLAYER { JUMP}

var sfx_player_paths := {
	SFX_PLAYER.JUMP: "res://Sounds/SabotageSFX/AwRats.wav"
}

# Cooking-specific SFX
enum SFX_COOKING {
	BLEND,
	BOIL,
	CHOP1,
	CHOP2,
	CHOP3,
	DEEP_FRY,
	PAN_FRY,
	WASH,
	BIN,
	CRATE,
	PLATE
	}

var sfx_cooking_paths := {
	SFX_COOKING.BLEND: "res://Sounds/CookingSFX/Blender.wav",
	SFX_COOKING.BOIL: "res://Sounds/CookingSFX/WaterBoil.ogg",
	SFX_COOKING.CHOP1: "res://Sounds/CookingSFX/Chopping Knife.mp3",
	SFX_COOKING.CHOP2: "res://Sounds/CookingSFX/GoodKnifeChop.wav",
	SFX_COOKING.CHOP3: "res://Sounds/CookingSFX/KnifeChop.wav",
	SFX_COOKING.DEEP_FRY: "res://Sounds/CookingSFX/DeepFryer.wav",
	SFX_COOKING.PAN_FRY: "res://Sounds/CookingSFX/Frying Pan.wav",
	SFX_COOKING.WASH: "res://Sounds/CookingSFX/Dish Wash Scrub.wav",
	SFX_COOKING.BIN: "res://Sounds/CookingSFX/ThrowingOutTrash.wav",
	SFX_COOKING.CRATE: "res://Sounds/CookingSFX/SwitchingCrates.wav",
	SFX_COOKING.PLATE: "res://Sounds/CookingSFX/Plate Pick Up Good.wav"
}


# Audio players
var bgm_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

# Settings
var current_bgm: int = -1
const MAX_SFX_PLAYERS = 3
# in dB
var bgm_volume: float = 0.0
var sfx_volume: float = 0.0
var fade_volume: float = -80.0

## initialization
func _ready() -> void:
	_setup_audio_players()
	_validate_audio_files()


## Setup audio players for BGM and SFX
func _setup_audio_players() -> void:
	# Setup BGM player
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	add_child(bgm_player)
	# Setup SFX players
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)


## Validate that all audio files can be loaded
func _validate_audio_files() -> void:
	Debug.sound_log("=== Validating Audio Files ===")
	_validate_audio_category("BGM", bgm_paths)
	_validate_audio_category("SFX", sfx_paths)
	_validate_audio_category("Player SFX", sfx_player_paths)
	# _validate_audio_category("Cooking SFX", sfx_cooking_paths)


## Validate audio files in a category
## @param category_name: Name of the category
## @param paths_dict: Dictionary mapping IDs to file paths
func _validate_audio_category(category_name: String, paths_dict: Dictionary) -> void:
	Debug.sound_log("Checking %s files..." % category_name)
	for sound_id in paths_dict:
		var path = paths_dict[sound_id]
		var stream = load(path)
		if stream:
			Debug.sound_log("SUCCESS: %s" % path)
		else:
			Debug.sound_log("FAILED: %s" % path)


## Play background music with optional fade
## @param bgm_id: BGM enum value
## @param fade_duration: Duration of fade in seconds
func play_bgm(bgm_id: BGM, fade_duration: float = 0.0) -> void:
	# Already playing this BGM
	if current_bgm == bgm_id and bgm_player.playing:
		return
	# Fade out current BGM if needed
	if fade_duration > 0.0 and bgm_player.playing:
		await fade_out_bgm(fade_duration)
	if not bgm_paths.has(bgm_id):
		Debug.sound_log("BGM ID %d not found in bgm_paths" % bgm_id)
		return
	# Load and play new BGM
	var stream = load(bgm_paths[bgm_id])
	if stream:
		bgm_player.stream = stream
		# if fade in, start quiet
		bgm_player.volume_db = bgm_volume if fade_duration == 0.0 else fade_volume
		bgm_player.play()
		current_bgm = bgm_id
		if fade_duration > 0.0:
			await fade_in_bgm(fade_duration)
	else:
		Debug.sound_log("BGM ID %d failed to load from path: %s" % [bgm_id, bgm_paths[bgm_id]])


## Stop background music with optional fade
## @param fade_duration: Duration of fade in seconds
func stop_bgm(fade_duration: float = 0.0) -> void:
	if fade_duration > 0.0:
		await fade_out_bgm(fade_duration)
	else:
		bgm_player.stop()
	current_bgm = -1


## Play sound effect
## @param sfx_id: SFX_PLAYER enum value
func play_sfx_player(sfx_id: SFX_PLAYER) -> void:
	_play_sfx(sfx_id, sfx_player_paths)


## Play cooking sound effect
## @param sfx_id: SFX_COOKING enum value
func play_sfx_cooking(sfx_id: SFX_COOKING) -> void:
	_play_sfx(sfx_id, sfx_cooking_paths)


## Play sound effect
## @param sfx_id: SFX enum value
func _play_sfx(sfx_id: int, paths: Dictionary) -> void:
	if not paths.has(sfx_id):
		Debug.sound_log("SFX ID %d not found in sfx_paths" % sfx_id)
		return
	# Find available player
	var player: AudioStreamPlayer = null
	for p in sfx_players:
		if not p.playing:
			player = p
			break
	# If all players busy, interrupt the oldest
	if player == null:
		player = sfx_players[0]
	# Load and play SFX
	var stream = load(paths[sfx_id])
	if stream:
		player.stream = stream
		player.volume_db = sfx_volume
		player.play()
	else:
		Debug.sound_log("Failed to load SFX: %s" % paths[sfx_id])


## Fade in BGM over duration
## @param duration: Duration of fade in seconds
func fade_in_bgm(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(bgm_player, "volume_db", bgm_volume, duration)
	await tween.finished


## Fade out BGM over duration
## @param duration: Duration of fade in seconds
func fade_out_bgm(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(bgm_player, "volume_db", fade_volume, duration)
	await tween.finished
	bgm_player.stop()


## Config BGM volume
## @param volume_db: Volume in dB
func set_bgm_volume(volume_db: float) -> void:
	bgm_volume = volume_db
	if bgm_player.playing:
		bgm_player.volume_db = volume_db


## Config SFX volume
## @param volume_db: Volume in dB
func set_sfx_volume(volume_db: float) -> void:
	sfx_volume = volume_db
	for player in sfx_players:
		if player.playing:
			player.volume_db = volume_db
