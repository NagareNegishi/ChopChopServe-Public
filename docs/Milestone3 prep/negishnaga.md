# Contribution to the project

Name: Nagare Negishi

During development, I created numerous scripts, but I will focus on my two largest modules:
the **Appliance System** and the **Network Layer**. First, I'll cover the Appliance System.

## Appliance System (All)

The Appliance System encompasses all classes used by the player to cook and manage food. It utilizes class inheritance to enhance maintainability and flexibility. To minimize hardcoding in the editor, most functionality is handled through scripts. However, to assist designers in placing instances within pre-made stages, corresponding `.tscn` files for some appliances were created.

**Scope:** Everything in the `scenes/Appliance_system` and `scripts/Appliance_system` folders was implemented by me, with the exception of 2 `progress_bar` scripts, which was placed there by another team member.

### High-Level System Overview

**Placeable (Root Class):**  
This is the base class for all appliances. Since we initially designed the game to allow players to customize their kitchen, it includes functionality for moving, rotating, and locking objects. To avoid manual scaling, it automatically aligns object size to the model and repositions it to the original root position after alignment.

- **Appliance:**  
   This class contains several abstract methods, enforcing a consistent structure across subclasses. The main functionality handles item transfer between the player and appliances.

   - **PoweredAppliance:**  
     Provides power for cooking (e.g., ovens, fryers). It handles taking in/out paired cookware and start/stop the cooking process.

   - **UnPoweredAppliance:**  
     Covers utility classes such as benches, sinks, and bins. Since concrete implementations vary widely, this class simply provides a start/stop action framework.

   - **Equipment/Cookware:**  
     Initially, the team designed tools like whisks and knives as part of gameplay, so Equipment was implemented with cooking functionality that required power from either the player or a PoweredAppliance. **Tool** was implemented as a subclass of Equipment for items used to process food. However, we removed tools from the final implementation, leaving Cookware as the only Equipment subclass. While I could have combined them, I maintained the original structure for flexibility in case design requirements changed. Note that concrete Tool classes do not exist in the current implementation. Cookware can take in/out food and start/stop cooking.

        - **Concrete Implementations:**  
        There are 15 concrete classes derived from these base classes. Each slightly overrides superclass behavior to modify functionality, but the main features are provided by the three core classes, minimizing code duplication.


## Network Layer (All)

The Network Layer supports multiplayer functionality. At the beginning of the project, I confirmed with the team both our ideal goals and realistic capabilities. While we ideally wanted to support fully online play with browser-hosted games, achieving this would require not only implementing the network layer with WebSocket or Steam, but also adjusting the entire game implementation to use those protocols. Since this was the first multiplayer game for most team members, we decided to implement multiplayer using ENet, which supports RPC functions (making implementation easier), and consider switching to other network protocols if we made sufficient progress.

**Scope:**  
- All files in `scripts/Network_Layer` were implemented by me
- All files in `scenes/Network_Layer` were initially my work. However, some team members later modified visual aspects of the scenes. In the final submission, we are likely switching the lobby scene itself.
- All files in the `room_server` folder.

### High-Level System Overview

To maintain flexibility for potential protocol changes, I implemented `NetworkLayer` as almost an interface (GDScript limitation). The concrete implementation, `ENetNetworkLayer`, handles all ENet-specific functionality including server creation, joining, leaving, disconnecting, and sending messages between players. The class also covers UPnP for automatic port forwarding and communication with the room code lookup server.

To avoid tightly coupling the network layer to this specific game, I created `ENetManager`, an autoloaded class accessible throughout the project. This wraps the network layer with game-specific implementation, handling user input for joining/leaving games and team assignment.

**UI Implementation:**  
Since establishing network connection is the first step of gameplay, I also implemented the functional components of the main menu and lobby, providing GUI for player input such as host/join options, IP input, room code lookup, etc.

**Room Code Server:**  
To support room code generation and lookup, I created a small server using JavaScript and deployed it on Railway with GitHub CI integration.


## Other Classes and Utility Systems

### Upgrade System (All)

A component-based system that can be attached to other classes as a child node, making the parent upgradeable. While currently only used for appliances in the prototype, the initial game design considered upgrading different object types. This implementation supports any parent class, maintaining flexibility for future expansion.

### Fire System (All)

Similar to the Upgrade System, this can be attached to any parent node to make it flammable. It manages ignition, extinguishing, and visual effects for fire mechanics.

### SceneManager (All)

Manages scene switching and synchronization across multiplayer clients, ensuring all players remain in the same game state.

### SoundManager (All)

An autoloaded class handling BGM and SFX. It provides generic implementation which allows team members to create their own specific SFX management methods. Features include volume fade control. Note: sound is not synchronized in multiplayer.

### Debug Class (All)

Manages console output with configurable verbosity levels and category-based filtering, allowing developers to control debug information granularity.

### Particle Control (All)

The entire particle effect assets were created by the designer, but lacked programmatic control. I implemented a system allowing effects to be attached to nodes and controlled via script.

## Classes I Touched

**Plate Class** (Touched)  
Added functionality related to cleaning plates, integrating with the sink mechanics in the UnPoweredAppliance system.

**Food Class** (Touched)  
Added and connected signals to indicate when food begins burning, enabling proper state management and visual feedback during cooking.


## Commentary

### The quality of the work I have done

**Research:**  
To implement the Network Layer and room code lookup server, I conducted extensive research on networking protocols, multiplayer architecture, and server deployment. Some of this research is documented in docs/Network.

**Group Coordination and Planning:**  
While my lecture schedule prevented me from attending all meetings on time, I attended all in-person and online meetings and stayed active on Discord communications.
With a group of 7, I recognized early that planning and coordination would be critical to success. I organized a few in-person meetings and a code review session for programmers when I identified areas requiring coordination. Throughout development, I attempted to establish high-level design and implementation standards multiple times:

1. **Project Setup:** Encouraged each team member to create high-level implementation documentation for their modules
2. **Global Standards:** Suggested establishing collision layers and globally-used variable conventions early in development
3. **Documentation by Example:** Created simplified UML diagrams of my implementations to demonstrate documentation practices and shared implementation details
4. **Game Flow Coordination:** As each module's implementation and overall game flow remained unclear even at prototyping stages, I attempted to coordinate game flow design through an online whiteboard (Figma). Unfortunately, I did not receive input from other members, so the game flow remained unclear
5. **Code Review Sessions:** Organized formal code review sessions, using these opportunities to finally communicate high-level designs and ensure team understanding
6. **Code Documentation:** I maintained continuous code documentation throughout development, including inline comments explaining complex logic, clear variable naming to help team members understand system architecture. For functions meant to be used by other members, I added detailed usage instructions in the comments and communicated directly with them through Discord and GitHub comments to ensure proper integration.

**Subtle Implementation Details:**  
Throughout my implementations, I emphasized abstraction and inheritance to improve maintainability. The Appliance System's class hierarchy allows new appliances to be added with minimal code by inheriting from base classes, while the NetworkLayer interface pattern enables protocol switching without modifying game logic. Similarly, the component-based approach for Fire and Upgrade systems allows functionality to be attached to any node, avoiding tight coupling.