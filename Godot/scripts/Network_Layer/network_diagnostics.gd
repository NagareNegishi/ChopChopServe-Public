class_name NetworkDiagnostics
extends Node

var network_layer: ENetNetworkLayer

## Initialize with reference to ENetNetworkLayer
func setup(net_layer: ENetNetworkLayer):
	network_layer = net_layer


## Run full diagnostics and return structured results
func run_diagnostics(user_provided_ip: String = "") -> Dictionary:
	var result = {
		"local_ip": "",
		"public_ip": "",
		"user_ip": user_provided_ip,
		"network_type": "",  # "LAN", "Internet", "Offline"
		"can_host_lan": false,
		"can_host_internet": false,
		"upnp_enabled": false,
		"needs_port_forward": false,
		"issues": [],
		"recommendations": []
	}
	
	# 1. Get local IP
	result.local_ip = network_layer._get_best_local_ip()
	
	# 2. Determine network type
	if result.local_ip == "127.0.0.1":
		result.network_type = "Offline"
		result.issues.append("No network connection detected")
		result.recommendations.append("Connect to WiFi or Ethernet")
		return result
	
	# 3. Check if private network (LAN)
	if is_private_ip(result.local_ip):
		result.network_type = "LAN"
		result.can_host_lan = true
		result.recommendations.append("✅ Can host games on local network")
	
	# 4. Determine which public IP to check
	if user_provided_ip != "":
		# User provided an IP - validate that one
		result.public_ip = user_provided_ip
		Debug.net_log("Using user-provided IP: " + user_provided_ip)
	else:
		# No user input - try to fetch it
		result.public_ip = await _get_public_ip()
		if result.public_ip != "":
			Debug.net_log("Auto-detected public IP: " + result.public_ip)

	# 5. Test UPnP (only if no manual IP provided)
	if user_provided_ip == "":
		result.upnp_available = await _test_upnp_capability()
		
		if result.upnp_available:
			result.can_host_internet = true
			result.recommendations.append("✅ UPnP available - can host internet games!")
		else:
			result.needs_port_forward = true
			result.recommendations.append("⚠️ UPnP not available")
	else:
		# User provided manual IP, assume they know what they're doing
		result.recommendations.append("ℹ️ Using manual IP configuration")
		result.needs_port_forward = true  # Assume manual = port forwarding
	
	# 6. Check public IP usability
	if result.public_ip != "":
		var usability = network_layer.check_ip_usability(result.public_ip)
		
		if usability.is_private:
			# CGNAT detected
			result.issues.append("Behind CGNAT (Carrier-Grade NAT)")
			result.recommendations.append("⚠️ Your ISP uses private IP addressing")
			result.recommendations.append("   Solution: Request public IP from ISP or use relay")
			result.can_host_internet = false
		elif not usability.usable:
			result.issues.append("Public IP issue: " + usability.reason)
			result.can_host_internet = false
		else:
			# Public IP is good
			result.can_host_internet = true
			if not result.upnp_available and user_provided_ip == "":
				result.recommendations.append("📝 Manual port forwarding needed:")
				result.recommendations.append("   1. Router settings: 192.168.1.1")
				result.recommendations.append("   2. Forward UDP port 7000 to " + result.local_ip)
				result.recommendations.append("   3. Use this IP: " + result.public_ip + ":7000")
	else:
		result.issues.append("Could not detect public IP")
		result.recommendations.append("⚠️ Check internet connection")


	# # 4. Check UPnP status (if available from network_layer)
	# result.upnp_available = await _test_upnp_capability()
	# if result.upnp_available:
	# 	result.can_host_internet = true
	# 	result.recommendations.append("✅ UPnP available - can host internet games!")
	# else:
	# 	result.needs_port_forward = true
	# 	result.recommendations.append("⚠️ UPnP not available")
	# 	result.recommendations.append("   Need manual port forwarding for internet hosting")
	
	
	# # 5. Check if behind CGNAT or restricted network
	# var usability = network_layer.check_ip_usability(result.local_ip)
	# if usability.is_private:
	# 	if not result.upnp_enabled:
	# 		result.issues.append("Behind private network without UPnP")
	# 		result.recommendations.append("To host over internet:")
	# 		result.recommendations.append("	1. Access router at 192.168.1.1")
	# 		result.recommendations.append("	2. Enable UPnP OR")
	# 		result.recommendations.append("	3. Forward UDP port 7000 to " + result.local_ip)
	
	return result


## Check if an IP is private (LAN)
## @param ip: The IP address as a string
## @return: True if the IP is private, false otherwise
func is_private_ip(ip: String) -> bool:
	return ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172.")


## Test if UPnP is available without creating server
## @return: True if UPnP is available, false otherwise
func _test_upnp_capability() -> bool:
	# Run in thread to avoid blocking
	var thread = Thread.new()
	thread.start(_upnp_test)
	
	# Wait for thread to finish
	while thread.is_alive():
		await get_tree().process_frame
	
	var result = thread.wait_to_finish()
	return result


## Test if UPnP is available without creating server
## @return: True if UPnP is available, false otherwise
func _upnp_test() -> bool:
	var upnp = UPNP.new()
	var discover_result = upnp.discover(2000)  # 2 second timeout
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		Debug.net_log("UPnP test: Discovery failed")
		return false
	if not upnp.get_gateway() or not upnp.get_gateway().is_valid_gateway():
		Debug.net_log("UPnP test: No valid gateway")
		return false
	Debug.net_log("UPnP test: Available")
	return true


# In network_diagnostics.gd

## Fetch public IP from external service
func _get_public_ip() -> String:
	var http = HTTPRequest.new()
	add_child(http)
	
	var error = http.request("https://api.ipify.org")
	if error != OK:
		Debug.net_log("Failed to get public IP")
		http.queue_free()
		return ""
	
	var response = await http.request_completed
	http.queue_free()
	
	if response[0] == HTTPRequest.RESULT_SUCCESS and response[1] == 200:
		return response[3].get_string_from_utf8().strip_edges()
	
	return ""



## Format diagnostic results as readable text
func format_results(results: Dictionary) -> String:
	var lines = []
	
	lines.append("NETWORK DIAGNOSTICS")
	lines.append("--------------------")
	lines.append("")
	
	# Network Status
	lines.append("Network Status:")
	lines.append("Type: " + results.network_type)
	lines.append("Local IP: " + results.local_ip)
	if results.public_ip != "":
		lines.append("Public IP: " + results.public_ip)
	lines.append("")
	
	# Hosting Capabilities
	lines.append("Hosting Capabilities:")
	if results.can_host_lan:
		lines.append("✅ Can host on local network")
	if results.can_host_internet:
		lines.append("✅ Can host over internet")
	elif results.needs_port_forward:
		lines.append("⚠️ Cannot host over internet yet")
	lines.append("")
	
	# UPnP Status
	if results.upnp_enabled:
		lines.append("✅ UPnP: Enabled")
	else:
		lines.append("❌ UPnP: Not available")
	lines.append("")
	
	# Issues
	if not results.issues.is_empty():
		lines.append("⚠️ Issues Found:")
		for issue in results.issues:
			lines.append("   • " + issue)
		lines.append("")
	
	# Recommendations
	if not results.recommendations.is_empty():
		lines.append("Recommendations:")
		for rec in results.recommendations:
			lines.append(rec)
		lines.append("")
	
	# Quick Actions
	lines.append("------------------")
	lines.append("WHAT YOU CAN DO:")
	if results.can_host_lan:
		lines.append("✓ Host for friends on same WiFi")
	if results.can_host_internet:
		lines.append("✓ Host for anyone with room code")
	else:
		lines.append("✓ Join other people's games")
		lines.append("✓ Host after setting up port forwarding")
	
	return "\n".join(lines)



# network_diagnostics.gd
## Format diagnostic results as readable text (CONDENSED VERSION)
func format_short_results(results: Dictionary) -> String:
	var lines = []
	# Quick Status
	lines.append("📡 " + results.network_type + " | IP: " + results.local_ip)
	
	# Capabilities
	if results.can_host_internet:
		lines.append("✅ Ready to host over internet")
	elif results.can_host_lan:
		lines.append("✅ Can host on WiFi (same network only)")
	else:
		lines.append("⚠️ Can join games only")
	
	# Main issue/recommendation
	if results.upnp_enabled:
		lines.append("✅ UPnP enabled")
	else:
		lines.append("⚠️ No UPnP - need port forwarding")
		lines.append("Forward UDP port 7000 to " + results.local_ip)
	
	return "\n".join(lines)




## Get quick status summary (for UI badges/icons)
func get_status_summary(results: Dictionary) -> String:
	if results.network_type == "Offline":
		return "❌ Offline"
	elif results.can_host_internet:
		return "✅ Ready to Host"
	elif results.can_host_lan:
		return "⚠️ LAN Only"
	else:
		return "⚠️ Join Only"
