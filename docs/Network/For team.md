# Network Layer Documentation for Developers

## Overview

Our game uses **ENet** for networking with a **host-client model**:
- Player 1 is always the host
- Supports up to 4 total players (1 host + 3 clients)
- `ENetManager` and `SceneManager` are auto-loaded and available everywhere

## Essential Functions

```gdscript
# Player info
var my_id = ENetManager.get_my_id()        # Your player ID
var is_host = ENetManager.is_host()        # Are you the host?
var my_team = ENetManager.get_my_team()    # Your team
```

## Adding New Scenes

1. Add to Scene enum in `scene_manager.gd`
2. Add path to SCENE_PATHS
3. Use `SceneManager.change_scene_all_players()` in host

## Rules

- Host manages everything
- **Do NOT bypass ENetManager** - Use it for all network operations
- **Do NOT directly modify player lists or network state** - Let ENetManager handle it
- Always check `ENetManager.is_host()` before host-only operations
- Read the code if you need more details (What actually manages Network layer is ENetNetworkLayer, which is component of ENetManager)

## RPC Pattern

**Recommended pattern for multiplayer actions:**

1. **Client**: Check preconditions locally (reduce network load)
2. **Client**: Request action from host (or do directly if you are host)
3. **Host**: Validate and execute the action
4. **Host**: Tell all clients what happened

```gdscript
# Client requests
if ENetManager.is_host():
    do_action()           # Host shortcut
    tell_clients.rpc()    # Notify others
else:
    request_host.rpc_id(1)  # Ask host

# Host processes and broadcasts result
@rpc("any_peer", "call_remote", "reliable")
func request_host():
    # Host validates and does action
    tell_clients.rpc()    # Tell everyone
```