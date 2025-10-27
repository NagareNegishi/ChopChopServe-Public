# ChopChopServe

A competitive multiplayer cooking game where two restaurants battle to be the last one standing through strategic cooking, upgrading, and sabotage.

## Game Overview

Players run competing restaurants, serving customers while managing reputation, currency, and strategic decisions. Cook meals, upgrade your kitchen, and sabotage opponents to emerge victorious.

## Download Game

**Latest stable version as zip:** [Releases](https://drive.google.com/file/d/1mOFt2NeyoWTUyd4bOEgeRfFFDiboNG6m/view)




## Development Team

- **Johno 🐻**: Player Controller, UI System
- **Emma 🐺**: Food/Cooking System, Order System, Game Phases
- **Mitchell 🐱**: 3D Modeling, Asset Creation
- **Bradley 🐶**: Level Design, VFX
- **Nagare 🐶**: Appliance System, Network Layer
- **Josh 🐰**: Customer AI (NPC), Building System
- **Jessica 🦉**: Currency System, Reputation System, Sabotage System

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


## Quick Start



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
This function exists but is currently disabled for aesthetic reasons.

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
  - Host can start when teams are balanced (equal players per team)
  - Cannot start with odd number of players
- **Host Controls**:
  - Shuffle teams (forces even split if enough players)
  - Kick clients
  - Start game (only with balanced teams)

While all those functions exist, the lobby scene is currently undergoing a redesign.  
The version you see in the game may not reflect the above functionality.


### Example Recipe??


## Development Timeline

- **Duration**: 3 months (July 23 - October 25, 2025)
- **Current Phase**: MVP → Final Polish

## Installation & Running

[Instructions to be added]

## Links

- [Demo Video](https://youtu.be/P1bXwwFyT1g)
- [Game Design Document](included in repository)

## Credits and asset used



### INFO for development team
Before you try to merge from your branch to the main of this repo you need to make sure youve first pulled any updates,
this means that if there are going to be conflicts within the main you can fix them before you send the merge request.

If there is a merge conflict then you need to make sure to talk to the person whos code yours is conflicting with and dicuss
it to figure out what their code is and if you need to keep it. DO NOT just delete someone elses code without their knowledge
or you might create worse problems down the road.

Everyone has their own files, and you shouldnt be editing someone elses code without them knowing. Make sure before you touch 
their code that they have merged and updated the main with their current code. Then after you pull from the main, only then 
can you add or update any of their code to fit your needed requirements. This should help avoid alot of merge conflicts if people
are not working in the same file without eachother knowing.

DO NOT FORGET that your commit messages must contain a reference number to an issue, that way we can keep track of who is doing what 
and the progress they have made on it.
