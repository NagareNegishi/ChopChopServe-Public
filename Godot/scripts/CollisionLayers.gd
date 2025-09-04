class_name CollisionLayers



## Layer definitions (powers of 2) - placeholders for all possible objects
const FLOORS = 1                # Bit 0 - Floor surfaces, walkable areas
const APPLIANCES = 2            # Bit 1 - Tables, counters, placeable surfaces
# const APPLIANCES = 4          # Bit 2 - Stoves, ovens, fryers, all cooking appliances
# const SMALL_APPLIANCES = 8    # Bit 3 - Pots, pans, small cookware
# const PLAYERS = 16            # Bit 4 - Player characters
# const CUSTOMERS = 32          # Bit 5 - Customer NPCs
# const INGREDIENTS = 64        # Bit 6 - Raw ingredients (tomato, meat, etc.)
# const COOKED_FOOD = 128       # Bit 7 - Prepared dishes, cooked items
# const WALLS = 256             # Bit 8 - Walls, immovable obstacles
# const DOORS = 512             # Bit 9 - Doors, openable barriers
# const INTERACTION_ZONES = 1024 # Bit 10 - Pickup zones, serving areas
# const FURNITURE = 2048        # Bit 11 - Chairs, decorative items
# const TRASH = 4096            # Bit 12 - Trash cans, disposal areas
# const STORAGE = 8192          # Bit 13 - Cabinets, fridges, storage
# const EFFECTS = 16384         # Bit 14 - Particles, visual effects, sabotages
# const UI_ELEMENTS = 32768     # Bit 15 - 3D UI, floating elements
