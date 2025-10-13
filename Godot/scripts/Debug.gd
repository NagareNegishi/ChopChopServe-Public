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
@export var network: bool = true
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



## Debugging function to test UPnP functionality--------------------------------
func detailed_upnp_test():
    var upnp = UPNP.new()
    
    print("=== UPnP Discovery Test ===")
    var discover_result = upnp.discover(2000, 2, "InternetGatewayDevice")
    print("Discovery result: ", discover_result)
    print("Result name: ", _get_upnp_result_name(discover_result))
    print("\nDevice count: ", upnp.get_device_count())
    
    if upnp.get_device_count() > 0:
        for i in range(upnp.get_device_count()):
            var device = upnp.get_device(i)
            print("\nDevice ", i, ":")
            print("  Valid: ", device.is_valid_gateway())
            print("  Description: ", device.query_external_address())
            print("  Service type: ", device.service_type)
            print("  IGD control URL: ", device.igd_control_url)
            print("  IGD service type: ", device.igd_service_type)
            print("  IGD status: ", device.igd_status)
    
    var gateway = upnp.get_gateway()
    if gateway:
        print("\nGateway found:")
        print("  Valid: ", gateway.is_valid_gateway())
        print("  Service type: ", gateway.service_type)
    else:
        print("\nNo gateway found")

func _get_upnp_result_name(result: int) -> String:
    match result:
        0: return "SUCCESS"
        1: return "NOT_AUTHORIZED"
        2: return "PORT_MAPPING_NOT_FOUND"
        26: return "NO_GATEWAY"
        27: return "NO_DEVICES"
        _: return "UNKNOWN_ERROR_" + str(result)
# ------------------------------------------------------------------------------