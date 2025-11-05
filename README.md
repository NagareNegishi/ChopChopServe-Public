# ChopChopServe

A competitive multiplayer cooking game where two restaurants battle to be the last one standing through strategic cooking, upgrading, and sabotage.

## Game Overview

Players run competing restaurants, serving customers while managing reputation, currency, and strategic decisions. Cook meals, upgrade your kitchen, and sabotage opponents to emerge victorious.

## Download Game

**Prototype release:**  [beta version 1.0.0](https://github.com/ringwoodem/ChopChopServe/releases/tag/v1.0.0-beta)

## Technology

- **Engine**: Godot 4.4
- **Language**: GDScript
- **Networking**: Client-Server model using ENet
- **Target Platform**: Windows

## Core Gameplay

### Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Walk | W/A/S/D | Left Joystick |
| Interact | E/SPACE | A |
| Action | J | X |
| Dash | K / Left Shift | B |
| Cycle Left | J | L1 |
| Cycle Right | L | R1 |
| Sabotage | 1/2/3/4/5/6 | D-Pad Up
| Cycle Sabotage Left | N/A | D-Pad Left
| Cycle Sabotage Right | N/A | D-Pad Right

### Game Loop
1. **Prep Phase** (30s): Upgrade restaurant or prepare for service
2. **Serving Phase**: Cook and serve customer orders
3. **Strategize**: Use currency to upgrade or sabotage opponents

### Key Systems
- **Cooking**: Combine ingredients using various appliances (stove, oven, fryer, etc.)
- **Orders**: Customers request starters, mains, and desserts with variations
- **Reputation**: Restaurant health - reaches zero and you lose
- **Currency**: Earned from serving customers, spent on upgrades/sabotages
- **Sabotage**: Send challenges to opponents (power cuts, water spills, fires, rats, etc.)
- **Upgrades**: Improve appliances or purchase new equipment

## How to Play

**Carryable Items**: Players can pick up and carry hammer, fire extinguisher, plate, food, and cookware.

**Prep Phase**:
- Use hammer to upgrade appliances (costs money)
- Prepare your kitchen for the serving phase

**Serving Customers**:
1. Customers sit at tables and place orders
2. Check recipes with **Tab** button
3. Take food from the food crate
4. Place food in appropriate appliance to start cooking
5. Transfer cooked food to a plate
6. Combine ingredients on the plate to create dishes
7. Serve completed dishes to customers → earn reputation + money

**Sabotage**:
- Spend money to sabotage your rival's kitchen
- Example: Start fires in opponent's kitchen
- Use fire extinguisher to put out fires in your own kitchen

**Win/Lose**:

You lose the day when your reputation reaches zero.

## Quick Start

1. Download the game from [beta version 1.0.0](https://github.com/ringwoodem/ChopChopServe/releases/tag/v1.0.0-beta)
2. Run the `.exe` file
3. Follow the Networking Setup instructions to host or join a game


## Networking Setup

### Requirements
- **Each player needs the game executable** - the game is not browser-based
- Players connect via IP address or room code
- Host shares connection details with clients (via Discord, etc.)

### Hosting a Game

1. **Input your name** (optional - sets in-game character name)
2. **Choose hosting method**:
   - **No IP input**: Game attempts UPnP configuration
     - If supported: Provides public IP and the room code for the host to share
     - If not supported: Hosts on LAN only
   - **Input public IP**: Game generates the room code (does not guarantee connectivity)
3. **Start hosting**: Select **Host**

**Host Options**:
1. Use UPnP (leave IP blank, let game configure)
2. Enable UPnP in router settings if disabled
3. Play on LAN if UPnP unavailable
4. Manually configure port forwarding and input public IP

~~**Network Test**: Use the **Network Test** button in main menu to check available options for your setup.~~  
Some networking functionalities are currently disabled for aesthetic reasons.

### Joining a Game

1. **Input your name** (optional - sets in-game character name)
2. **Choose connection method**:
   - **Search Host**: Ask the room code from the host, or "SEARCH HOST" button will find active hosts
   - **Input IP or code**: Join specific host
   - **Leave blank**: Automatically searches for LAN hosts
3. **Join game**: Select **Join**

### Troubleshooting
- Host must share IP/code with clients externally (Discord, etc.)
- Valid IP format doesn't guarantee successful connection
- Active room codes does not guarantee connectivity
- Check firewall and router settings if connection fails


### Lobby

Once hosted, players wait in the lobby:

- **Player Requirements**: 2 or 4 players total
- **Team Selection**: Players choose Team 1 or Team 2 (if not full)
- **Starting the Game**:
  - Cannot start with odd number of players
  - ~~Host can~~ Game start when teams are balanced (equal players per team)
- ~~**Host Controls**:~~
  - ~~Shuffle teams (forces even split if enough players)~~
  - ~~Kick clients~~
  - ~~Start game (only with balanced teams)~~

~~While all those functions exist, the lobby scene is currently undergoing a redesign.~~  
~~The version you see in the game may not reflect the above functionality.~~


### Example Recipe

[Table of example recipes available in-game](https://github.com/ringwoodem/ChopChopServe/blob/main/docs/Menu/MenuItems%20-%20Sheet1.pdf)


## Credits and asset used

- https://quaternius.com/packs/ultimatenature.html
- https://kaylousberg.itch.io/city-builder-bits

