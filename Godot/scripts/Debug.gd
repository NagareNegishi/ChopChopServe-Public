# Debug.gd
extends Node

enum Level {
    OFF = 0,
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
    ALL = 4
}

# Current debug level
@export var level: Level = Level.ALL
# System toggles
@export var fire: bool = true
@export var cooking: bool = true
@export var network: bool = false
@export var upgrade: bool = true

# Main logging functions
func error(message: String):
    if level >= Level.ERROR:
        push_error(message)
        print("[ERROR] ", message)

func warning(message: String):
    if level >= Level.WARNING:
        push_warning(message)
        print("[WARNING] ", message)

func info(message: String):
    if level >= Level.INFO:
        print("[INFO] ", message)

func all(message: String):
    if level >= Level.ALL:
        print("[DEBUG] ", message)

# System-specific shortcuts
func fire_log(message: String):
    if fire and level >= Level.ALL:
        print("[FIRE] ", message)

func net_log(message: String):
    if network and level >= Level.ALL:
        print("[NET] ", message)

func cook_log(message: String):
    if cooking and level >= Level.ALL:
        print("[COOK] ", message)

func upgrade_log(message: String):
    if upgrade and level >= Level.ALL:
        print("[UPGRADE] ", message)