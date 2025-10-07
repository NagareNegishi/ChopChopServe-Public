# Network Architecture & Internet Multiplayer Support

## Current Stack
Our multiplayer uses **Godot ENet + High-Level Multiplayer API with RPC**.

## Critical Limitation
**We cannot integrate Steam/Epic networking or switch to WebSocket without rewriting all RPC calls.** This would take 4-6 weeks and risk breaking existing gameplay. Not feasible for current timeline.

## The Problem
Players behind routers can't host internet games without manual port forwarding (requires technical knowledge most users don't have).

## Our Solution: UPnP (Universal Plug and Play)
Industry-standard protocol that **automatically configures port forwarding** on compatible routers.
- Works within our ENet constraints - no code rewrite
- Automatic for users - zero configuration
- 2-week implementation timeline
- Covers ~70-80% of home networks

### But UPnP Won't Work On:
- University/corporate networks (strict firewalls)
- Routers with UPnP disabled

## User Support Matrix
| Environment | Solution |
|------------|----------|
| Home (UPnP enabled) | Automatic hosting |
| Home (UPnP disabled) | Manual setup required |
| University/Corporate | LAN mode only |



# UPnP References

## Concept & Protocol Documentation

**Official UPnP Specification:**
- UPnP Forum: https://openconnectivity.org/developer/specifications/upnp-resources/upnp/

**Easier Explanations:**
- How NAT & Port Forwarding Works: https://www.howtogeek.com/66214/how-to-forward-ports-on-your-router/

## Godot 4.4 Implementation

**Official Godot Documentation:**
- UPNP Class Reference: https://docs.godotengine.org/en/stable/classes/class_upnp.html
- UPNPDevice Class: https://docs.godotengine.org/en/stable/classes/class_upnpdevice.html

**Key Methods:**
- `UPNP.discover()` - Find UPnP devices on network
- `UPNP.add_port_mapping()` - Open port automatically
- `UPNP.delete_port_mapping()` - Close port when done
- `UPNP.query_external_address()` - Get public IP


## Room lookup services
- Run small server with Railway
- Use Godot HTTPRequest to query server for rooms
https://docs.godotengine.org/en/4.4/classes/class_httprequest.html
https://docs.godotengine.org/en/stable/tutorials/networking/http_request_class.html
https://docs.godotengine.org/en/4.4/classes/class_json.html

Main pattern is:
- Create HTTPRequest node
- Call request() method with URL, default is GET
- Connect to request_completed signal
- Parse response (usually JSON) and execute corresponding logic


