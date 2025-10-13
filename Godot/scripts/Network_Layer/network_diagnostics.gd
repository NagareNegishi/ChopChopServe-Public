class_name NetworkDiagnostics
extends Node

var network_layer: ENetNetworkLayer

## Initialize with reference to ENetNetworkLayer
func setup(net_layer: ENetNetworkLayer):
	network_layer = net_layer


## Run full diagnostics and return structured results
## @param user_provided_ip: Optional manual public IP to validate
## @return: Dictionary with diagnostic results
func run_diagnostics(user_provided_ip: String = "") -> Dictionary:
	var result = {
		"local_ip": "",
		"public_ip": "",
		"user_ip": user_provided_ip,
		"network_type": "",  # "Offline", "LAN", "Internet"
		"can_host_lan": false,
		"upnp_enabled": false,
		"issues": [],
		"recommendations": []
	}

	# 1. Get local IP
	result.local_ip = network_layer._get_best_local_ip()

	# 2. Handle the offline case
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

	# 4. Check public IP usability
	if user_provided_ip != "":
		# User provided an IP - validate that one
		result.public_ip = user_provided_ip
		var usability = network_layer.check_ip_usability(result.public_ip)
		if not usability.usable:
			result.issues.append("Public IP issue: " + usability.reason)
			result.recommendations.append("Check your public IP")
	else:
		# No user input - try to fetch it
		result.public_ip = await _get_public_ip()
		if result.public_ip != "":
			result.recommendations.append("Auto-detected public IP: " + result.public_ip)
		else:
			result.issues.append("Could not auto-detect public IP")
			result.recommendations.append("⚠️ Check internet connection")
			return result

	# 5. Test UPnP
	result.upnp_available = await _test_upnp_capability()
	if result.upnp_available:
		result.recommendations.append("✅ Your router may support automatic setup")
		result.recommendations.append("Try Hosting without IP input")
	else:
		result.recommendations.append("⚠️ UPnP not available, check router settings")
		result.recommendations.append("Manual port forwarding needed: UDP port 7000 → " + result.local_ip)

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


## Fetch public IP from external service
## @return: Public IP as string, or empty if failed
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
	## response has 4 elements: result, response_code, headers, body
	if response[0] == HTTPRequest.RESULT_SUCCESS and response[1] == 200:
		return response[3].get_string_from_utf8().strip_edges()
	return ""


## Format diagnostic results as readable text
## @param results: Diagnostic results dictionary
## @return: Detailed multi-line string with full info
func format_results(results: Dictionary) -> String:
	var lines = []
	lines.append("====== Network Diagnostics =====")
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
	if results.upnp_available:
		lines.append("✅ May be able to host over internet (automatic setup)")
	else:
		lines.append("⚠️ Manual port forwarding required for internet hosting")
	# UPnP Status
	if results.upnp_available:
		lines.append("✅ UPnP: Available")
	else:
		lines.append("⚠️ UPnP: Not available")
	lines.append("")
	
	# Issues
	if not results.issues.is_empty():
		lines.append("⚠️ Issues Found:")
		for issue in results.issues:
			lines.append(" - " + issue)
		lines.append("")
	
	# Recommendations
	if not results.recommendations.is_empty():
		lines.append("Recommendations:")
		for rec in results.recommendations:
			lines.append(" - " + rec)
		lines.append("")

	return "\n".join(lines)


## Format diagnostic results as readable text
## @param results: Diagnostic results dictionary
## @return: Short summary string with key info
func format_short_results(results: Dictionary) -> String:
	var lines = []
	# Quick Status
	lines.append(results.network_type + " | IP: " + results.local_ip)
	# Capabilities
	if results.upnp_available:
		lines.append("✅ Ready to host (automatic setup available)")
	elif results.can_host_lan:
		lines.append("✅ Can host on local network")
	else:
		lines.append("⚠️ Limited to local device testing")
	# Main recommendation
	if results.upnp_available:
		lines.append("Try hosting without entering IP")
	else:
		lines.append("⚠️ Manual setup needed for internet")
		lines.append("Forward UDP port 7000 → " + results.local_ip)
	return "\n".join(lines)


## Get quick status summary
## @param results: Diagnostic results dictionary
## @return: Summary string with emoji status
func get_status_summary(results: Dictionary) -> String:
	if results.upnp_available:
		return "✅ Ready to Host"
	if results.can_host_lan:
		return "⚠️ LAN Only"
	return "❌ Offline"
