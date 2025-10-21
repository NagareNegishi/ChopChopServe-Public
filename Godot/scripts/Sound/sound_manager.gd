# sound_manager.gd
extends Node

# Enum for sound identification
enum BGM {
	MENU,
	BUS,
	BEACH,
	# Add more as needed
}

enum SFX {
	RAT,
	# Add more as needed
}

# Map enum to file paths
var bgm_paths := {
	BGM.MENU: "res://Sounds/BGM/Beach/8bit Bossa.mp3",
}

var sfx_paths := {
	SFX.RAT: "res://Sounds/AwRats.wav"
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
## @param sfx_id: SFX enum value
func play_sfx(sfx_id: SFX) -> void:
	if not sfx_paths.has(sfx_id):
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
	var stream = load(sfx_paths[sfx_id])
	if stream:
		player.stream = stream
		player.volume_db = sfx_volume
		player.play()
	else:
		Debug.sound_log("Failed to load SFX: %s" % sfx_paths[sfx_id])


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