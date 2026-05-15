extends Node
class_name RequestSystem

var flower_stand: FlowerStand
var request_database: RequestDatabase

var current_request: RequestData
var all_requests: Array[RequestData]

func setup(flower_stand_ref: FlowerStand, request_database_ref: RequestDatabase) -> void:
	# This function is called by FlowerShopManager when shop session is enabled by player
	
	flower_stand = flower_stand_ref
	request_database = request_database_ref
	
	if request_database == null:
		push_error("RequestSystem ERROR: assignment of request_database failed")
		return
	
	all_requests = request_database.get_requests()
	
func build_current_request_pool() -> Array[RequestData]:
	assert(flower_stand != null)
	
	var current_request_pool: Array[RequestData]
	var active_meanings = flower_stand.get_all_active_meanings()
	
	if all_requests.is_empty():
		return []
		
	for request in all_requests:
		var request_meanings = request.request_meanings
		
		if request_meanings.is_empty():
			push_warning("Request System WARNING: core_meanings not set in:", request)
			continue
		
		for meaning in request_meanings:
			if active_meanings.has(meaning):
				if not current_request_pool.has(request):
					current_request_pool.append(request)
					
				break ## If already added to request_pool, check next item
		
	return current_request_pool
	
func get_current_request() -> RequestData:
	var current_request_pool = build_current_request_pool()
	
	if current_request_pool.is_empty():
		return null
	
	# Subtract 1 from total weight to get valid range index
	var total_range = get_total_request_weight(current_request_pool) - 1
	
	var random_number = randi_range(0, total_range)
	var request = get_random_request(random_number, current_request_pool)
	
	return request
	
func get_total_request_weight(current_request_pool: Array[RequestData]) -> int:
	if current_request_pool.is_empty():
		push_warning("Request_System WARNING: no valid meanings found in FlowerStand")
		return 0
	
	var total: int = 0
	for request in current_request_pool:
		total += request.request_weight
		
	return total
	
func get_random_request(random_number: int, current_request_pool: Array[RequestData]) -> RequestData:
	
	if current_request_pool.size() == 1: 
		return current_request_pool[0]
		
	var running_total: int = 0
	var random_request: RequestData = null
	
	for request in current_request_pool:
		running_total += request.request_weight
		if random_number < running_total: 
			random_request = request
			return random_request
			
	return random_request
			
